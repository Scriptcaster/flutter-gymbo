import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateChildrenSets extends StatefulWidget {
  final Object index;
  final Object day;
  final Object name;
  final Object weekId;
  final Object dayId;
  final Object sets;
  final VoidCallback onDelete;
  CreateChildrenSets(this.index, this.day, this.name, this.sets, this.weekId, this.dayId, {this.onDelete});
  @override
  _CreateChildrenSetsState createState() => _CreateChildrenSetsState(index, day, name, sets, weekId, dayId, this.onDelete);
}

class _CreateChildrenSetsState extends State<CreateChildrenSets> {
  final String weekId;
  final String dayId;
  final int index;
  final List day;
  List _exercises = [];
  String name;
  List sets;
  List editableSets = [];
 
  final VoidCallback onDelete;
  final databaseReference = Firestore.instance;

  List<Color> colors = [Colors.blue, Colors.white, Colors.white];
  List<bool> _selected = [true, false, false];
  TextEditingController controller = TextEditingController();

  void initState() {
    print('updateData');
    super.initState();
    _exercises.addAll(widget.day);
    controller.text = _exercises[index]['name']; 
    editableSets.addAll(_exercises[index]['sets']);
  }

  void updateData() {
    _exercises[index]['name'] = controller.text;
    _exercises[index]['sets'] = editableSets;
  }

  void didUpdateWidget(CreateChildrenSets oldWidget) {
    print('didUpdateWidget');
    super.didUpdateWidget(oldWidget);
    if (oldWidget != widget) {
      setState(() {
        controller.text = widget.name; 
        _exercises.clear();
        _exercises.addAll(widget.day);
        editableSets.clear();
        editableSets.addAll(widget.sets);
        updateData(); 
      });
    }
  }

  void dispose() {
    super.dispose();
    try {
      databaseReference.collection('data').document('Xi2BQ9KuCwOR2MeHIHUPH5G7bTc2').collection('weeks').document(weekId).collection('days').document(dayId).updateData(
        {'exercises': _exercises}
      );
    } catch (e) {
      print(e.toString());
    }
  }

  _decrementCounter(i, sets) => setState(() {
      if (_selected[0]) {
        sets[i]['weight']-=5;
      } else if (_selected[1]) {
        sets[i]['set']-=1;
      } else if(_selected[2]) {
        sets[i]['rep']-=1;
      }
      _exercises[index]['volume'] = sets[i]['weight']*sets[i]['set']*sets[i]['rep'];
      updateData();
  });
  

  _incrementCounter(i, sets) => setState(() {
      if (_selected[0]) {
        sets[i]['weight']+=5;
      } else if (_selected[1]) {
        sets[i]['set']+=1;
      } else if(_selected[2]) {
        sets[i]['rep']+=1;
      }
      _exercises[index]['volume'] = sets[i]['weight']*sets[i]['set']*sets[i]['rep'];
      updateData();
  });
  

  _removeSet(lenght) {
    if(lenght > 1) {
      setState(() {
        editableSets.removeLast();
      });
    }
    updateData();
  }
  
  _addSet(lenght, set) {
    if(lenght < 16) {
      setState(() {
        editableSets.add({'weight': set['weight'], 'set': set['set'], 'rep': set['rep']});
      });
    }
    // _exercises[index]['volume'] = sets[i]['weight']*sets[i]['set']*sets[i]['rep'];
    updateData();
  }

  _CreateChildrenSetsState(this.index, this.day, this.name, this.sets,  this.weekId, this.dayId, this.onDelete);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [ 
        Container(
          padding: EdgeInsets.only(top: 15.0, bottom: 5.0, left: 40.0, right: 40.0),
          child: TextField(
            style: new TextStyle(fontSize: 20.0, color: Colors.blue),
            keyboardType: TextInputType.text,
            controller: controller,
            onSubmitted: (value) {
              name = value;
              updateData();
            }
          ),
        ),
        Container(
          padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
          child: Text(
            _exercises[index]['volume'].toString(), 
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
            ),
        ),
        Container(
          padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
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
              renderSets(editableSets),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
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
                  onPressed: () => _removeSet(editableSets.length),
                )
              ),
               Expanded(
                flex: 1,
                child: new IconButton(
                  padding: new EdgeInsets.all(0.0),
                  icon: new Icon(Icons.add_circle, size: 24.0),
                  onPressed: () => _addSet(editableSets.length, editableSets.last),
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