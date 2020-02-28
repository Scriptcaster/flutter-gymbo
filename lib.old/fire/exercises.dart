import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/exercises.dart';

class CreateChildrenSets extends StatefulWidget {
  final Object uid;
  final Object index;
  final Object exercises;
  final Object sets;
  final String exerciseName;
  final String weekId;
  final String dayId;
  final VoidCallback onDelete;
  CreateChildrenSets(this.uid, this.index, this.exercises, this.exerciseName, this.sets, this.weekId, this.dayId, {this.onDelete});
  
  @override
  _CreateChildrenSetsState createState() => _CreateChildrenSetsState(this.onDelete);
}

class _CreateChildrenSetsState extends State<CreateChildrenSets> {
  _CreateChildrenSetsState(this.onDelete);
  List _exercises = [];
  List _sets = [];
  final VoidCallback onDelete;
  List<Color> colors = [Colors.blue, Colors.white, Colors.white];
  List<bool> _selected = [true, false, false];
  TextEditingController _exerciseNameController = TextEditingController();

  Future<void> getExercises() async {
    // Set Best Volume
    final _exerciseCollection = Firestore.instance.collection("data").document(widget.uid).collection("exercises");
    QuerySnapshot _exercisesQuerySnapshot = await _exerciseCollection.getDocuments();
    Object _newExercise;
    _exercisesQuerySnapshot.documents.forEach((item) async {
      if (item['name'] == _exerciseNameController.text) {
        setState(() {
          _exercises[widget.index]['bestVolume'] = item['bestVolume'];
          _exercises[widget.index]['bestVolumeId'] = item['id'];
        });
      } 
    });

    // Check if exercise already exist
    bool contains(element) {
      for (var item in _exercisesQuerySnapshot.documents) {
        if (item['name'] == element) return true;
      }
      return false; 
      // var countExercises = _exercisesQuerySnapshot.documents.where((item) => item['name'] == _exerciseNameController.text);
    }
    
    // Create A New Exercise
    if(!contains(_exerciseNameController.text)) {
      print('create');
       _newExercise = new Exercise(name: _exerciseNameController.text, bestVolume: 0).toJson();
      DocumentReference _newExerciseRef = await _exerciseCollection.add(_newExercise);
      _exerciseCollection.document(_newExerciseRef.documentID).updateData({'id': _newExerciseRef.documentID});
    }

    // Set Previous Volume
    final _weeksReference = Firestore.instance.collection('data').document(widget.uid).collection('weeks');
    QuerySnapshot _weekQuerySnapshot = await _weeksReference.orderBy('date', descending: true).getDocuments();
    _weekQuerySnapshot.documents.sort((a, b) => a['date'].compareTo(b['date']));
    previousCounter() {
      var i = 0;
      for(var item in _weekQuerySnapshot.documents) {
        i++;
        if(item['id'] == widget.weekId) return i;
      }
      return i;
    }
    if (_weekQuerySnapshot.documents.length > 1 && previousCounter() != 1) {
      print('Update Previous Volume');
      QuerySnapshot _daysQuerySnapshot = await _weeksReference.document(_weekQuerySnapshot.documents[previousCounter() - 2]['id']).collection('days').getDocuments();
      _daysQuerySnapshot.documents.forEach((item) {
        if (item.data['exercises'] != null) {
           item.data['exercises'].forEach((item) {
            if (item['name'] == _exerciseNameController.text) {
              print(item['name']);
               print(_exerciseNameController.text);
              setState(() {
                _exercises[widget.index]['previousVolume'] = item['volume'];
              });
            } 
          });
        }
      });
    } else {
      setState(() {
        _exercises[widget.index]['previousVolume'] = 0;
      });
    }
  }

  @override
  void initState() {
    _exercises.addAll(widget.exercises);
    _sets.addAll(_exercises[widget.index]['sets']);
    _exerciseNameController.text = widget.exerciseName;
    getExercises(); 
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
              child: Text(set['weight'].toString())
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