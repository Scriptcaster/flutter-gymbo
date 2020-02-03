import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateChildrenSets extends StatefulWidget {
  final Object index;
  final Object exercises;
  final Object sets;
  final String exerciseName;
  final String weekId;
  final String dayId;
  final VoidCallback onDelete;
  CreateChildrenSets(this.index, this.exercises, this.exerciseName, this.sets, this.weekId, this.dayId, {this.onDelete});
  @override
  _CreateChildrenSetsState createState() => _CreateChildrenSetsState(this.onDelete);
}

class _CreateChildrenSetsState extends State<CreateChildrenSets> {
  _CreateChildrenSetsState(this.onDelete);
  List _exercises = [];
  List _sets = [];

  final VoidCallback onDelete;
  final weeksReference = Firestore.instance.collection('data').document('Xi2BQ9KuCwOR2MeHIHUPH5G7bTc2').collection('weeks');
  final exerciseReference = Firestore.instance.collection("data").document('Xi2BQ9KuCwOR2MeHIHUPH5G7bTc2').collection("exercises");

  List<Color> colors = [Colors.blue, Colors.white, Colors.white];
  List<bool> _selected = [true, false, false];
  TextEditingController _exerciseNameController = TextEditingController();

  Future<void> getExercises() async {
    QuerySnapshot exercisesQuerySnapshot = await exerciseReference.getDocuments();
    QuerySnapshot weekQuerySnapshot = await weeksReference.orderBy('date', descending: true).getDocuments();
    exercisesQuerySnapshot.documents.forEach((item) {
      if (item['name'] == _exerciseNameController.text) {
        setState(() {
          _exercises[widget.index]['bestVolume'] = item['bestVolume'];
          _exercises[widget.index]['bestVolumeId'] = item['id'];
        });
      }
    });
    // print( weekQuerySnapshot.documents[1]['id']);

    QuerySnapshot daysQuerySnapshot = await weeksReference.document(weekQuerySnapshot.documents[1]['id']).collection('days').getDocuments();
    daysQuerySnapshot.documents.forEach((item) {
       item.data['exercises'].forEach((item) {
         if (item['name'] == _exerciseNameController.text) {
          // print(item['name']);
          setState(() {
            _exercises[widget.index]['previousVolume'] = item['volume'];
          });
         }
       });
    });


    //  weekQuerySnapshot.documents[1]['exercises'].forEach((item) {
    //    print(item);
    //   // if (item['name'] == controller.text) {
    //     // setState(() {
    //     //   _exercises[widget.index]['bestVolume'] = item['bestVolume'];
    //     //   _exercises[widget.index]['bestVolumeId'] = item['id'];
    //     // });
        
    //     // exerciseReference.document(item['id']).updateData({'bestVolume': _exercises[widget.index]['volume']});
    //     // weeksReference.document(item['id']).updateData({'bestVolumeId': item['id']});
    //   // }
    // });

  }

  @override
  void initState() {
    _exercises.addAll(widget.exercises);
    _sets.addAll(_exercises[widget.index]['sets']);
    _exerciseNameController.text = widget.exerciseName; 
    super.initState();
  }

  @override
  void didUpdateWidget(CreateChildrenSets oldWidget) {
    if (oldWidget != widget) {
      _exerciseNameController.text = widget.exerciseName; 
      _sets.clear();
      _sets.addAll(widget.sets);
    }
    super.didUpdateWidget(oldWidget);
  }

  _decrementCounter(i, sets) => setState(() {
    if (_selected[0]) {
      sets[i]['weight']-=5;
    } else if (_selected[1]) {
      sets[i]['set']-=1;
    } else if(_selected[2]) {
      sets[i]['rep']-=1;
    }
    int _sum = 0;
    sets.forEach((item) {
      _sum += item['weight']*item['set']*item['rep'];
    });
    _exercises[widget.index]['volume'] = _sum;
  });

  _incrementCounter(i, sets) => setState(() {
    if (_selected[0]) {
      sets[i]['weight']+=5;
    } else if (_selected[1]) {
      sets[i]['set']+=1;
    } else if(_selected[2]) {
      sets[i]['rep']+=1;
    }
    int _sum = 0;
    sets.forEach((item) {
      _sum += item['weight']*item['set']*item['rep'];
    });
    _exercises[widget.index]['volume'] = _sum;
  });
  
  _removeSet(lenght) {
    if(lenght > 1) {
      setState(() {
        _sets.removeLast();
      });
    }
    _exercises[widget.index]['sets'] = _sets;
  }
  
  _addSet(lenght, set) {
    if(lenght < 16) {
      setState(() {
        _sets.add({'weight': set['weight'], 'set': set['set'], 'rep': set['rep']});
      });
    }
     _exercises[widget.index]['sets'] = _sets;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.only(top: 10.0, bottom: 5.0, left: 40.0, right: 40.0),
          child: TextField(
            style: new TextStyle(fontSize: 20.0, color: Colors.blue),
            keyboardType: TextInputType.text,
            controller: _exerciseNameController,
            onSubmitted: (value) {
              // _exerciseName = value;
              _exercises[widget.index]['name'] = _exerciseNameController.text;
              getExercises();
            }
          ),
        ),
        Container(
          padding: EdgeInsets.only(top: 0.0, bottom: 0.0),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  height: 5
                )
              ),
              Container(
                width:120,
                padding: EdgeInsets.only(top: 0.0, bottom: 0.0),
                child: Text(
                 'Best',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Container(
                width:120,
                padding: EdgeInsets.only(top: 0.0, bottom: 0.0),
                child: Text(
                 'Previous',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Container(
                width: 120,
                padding: EdgeInsets.only(top: 0.0, bottom: 0.0),
                child: Text(
                  'Current',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  height: 5
                )
              ),
            ],
          ),
        ),

        Container(
          padding: EdgeInsets.only(top: 0.0, bottom: 0.0),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  height: 10
                )
              ),
              Container(
                width:120,
                padding: EdgeInsets.only(top: 0.0, bottom: 0.0),
                child: Text(
                 _exercises[widget.index]['bestVolume'].toString(), 
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Container(
                width:120,
                padding: EdgeInsets.only(top: 0.0, bottom: 0.0),
                child: Text(
                 _exercises[widget.index]['previousVolume'].toString(), 
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Container(
                width: 120,
                padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                child: Text(
                  _exercises[widget.index]['volume'].toString(), 
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  height: 10
                )
              ),
            ],
          ),
        ),

        Container(
          padding: EdgeInsets.only(top: 0.0, bottom: 0.0),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  height: 50
                )
              ),
              Container(
                width: 90,
                padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                child: Text(
                 'Weight',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Container(
                width: 90,
                padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                child: Text(
                  'Sets',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Container(
                width: 90,
                padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                child: Text(
                  'Reps',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  height: 50
                )
              ),
            ],
          ),
        ),
        Container(
          child: Column(
           children: [
              renderSets(_sets),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.only(top: 0.0, bottom: 5.0),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: new IconButton(
                  padding: new EdgeInsets.all(0.0),
                  icon: new Icon(Icons.delete, size: 24.0),
                  onPressed: this.widget.onDelete,
                )
              ),
              Expanded(
                flex: 1,
                child: new IconButton(
                  padding: new EdgeInsets.all(0.0),
                  icon: new Icon(Icons.remove_circle, size: 24.0),
                  onPressed: () => _removeSet(_sets.length),
                )
              ),
               Expanded(
                flex: 1,
                child: new IconButton(
                  padding: new EdgeInsets.all(0.0),
                  icon: new Icon(Icons.add_circle, size: 24.0),
                  onPressed: () => _addSet(_sets.length, _sets.last),
                )
              ),
            ],
          ),
        ),
      ],
    );
  }
  renderSets(List sets) {
    return Column(
      children: sets.map((set) => 
      Container(
        padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: new SizedBox(
                height: 18.0,
                width: 24.0,
                child: new IconButton(
                  padding: new EdgeInsets.all(0.0),
                  icon: new Icon(Icons.remove, size: 18.0),
                  onPressed: () => _decrementCounter(sets.indexOf(set), sets)
                )
              ),
            ),
            FlatButton(
              color: colors[0],
              onPressed: () {
                _selected = [false, false, false];
                setState(() {
                  colors = [Colors.white, Colors.white, Colors.white];
                  colors[0] = Colors.blue;
                  _selected[0] = true;
                });
              },
              child: Text(
                set['weight'].toString(),
              ),
            ),
              FlatButton(
              color: colors[1],
              onPressed: () {
                _selected = [false, false, false];
                setState(() {
                  colors = [Colors.white, Colors.white, Colors.white];
                  colors[1] = Colors.blue;
                  _selected[1] = true;
                });
              },
              child: Text(
                set['set'].toString(),
              ),
            ),
            FlatButton(
              color: colors[2],
              onPressed: () {
                // print(sets.indexOf(set));
                  _selected = [false, false, false];
                setState(() {
                  colors = [Colors.white, Colors.white, Colors.white];
                  colors[2] = Colors.blue;
                  _selected[2] = true;
                });
              },
              child: Text(
                set['rep'].toString(),
              ),
            ),
            Expanded(
              child: new SizedBox(
                height: 18.0,
                width: 24.0,
                child: new IconButton(
                  padding: new EdgeInsets.all(0.0),
                  icon: new Icon(Icons.add, size: 18.0),
                  onPressed: () =>_incrementCounter(sets.indexOf(set), sets),
                )
              ),
            ),
          ],
        ),
      ),
    ).toList());
  }
}