import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DayPage extends StatefulWidget {
  DayPage({@required this.weekId, this.dayId, this.date, this.target, this.exercises});
  final weekId;
  final dayId;
  final date;
  final target;
  final exercises;
  @override
  _DayPageState createState() => _DayPageState(dayId: dayId, weekId: weekId);
}

class _DayPageState extends State<DayPage> {
  _DayPageState({this.weekId, this.dayId});
  final Object weekId;
  final Object dayId;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.date.toString()),
      ),
      body: new Container(
        padding: EdgeInsets.only(top: 0.0),
        child: new ListView(
          children: createChildrenTexts(weekId: weekId, dayId: dayId),
        ),
      ),
    );
  }

  List<Widget> createChildrenTexts({weekId, dayId}) {
    List<Widget> childrenTexts = [];
    int index = 0;
    widget.exercises.forEach((exercise) {
      childrenTexts.add(
        CreateChildrenSets(
          name: exercise['name'],
          total: exercise['volume'],
          newExercise: widget,
          index: index++,
          weekId: weekId,
          dayId: dayId
        ),
      );
    });
    return childrenTexts;
  }
}

class CreateChildrenSets extends StatefulWidget {
  CreateChildrenSets({this.name, this.total, this.newExercise, this.index, this.weekId, this.dayId});
  final Object name;
  final Object total;
  final Object newExercise;
  final Object index;
  final Object weekId;
  final Object dayId;
  @override
  _CreateChildrenSetsState createState() => _CreateChildrenSetsState(name: name, total: total, newExercise: newExercise, index: index, weekId: weekId, dayId: dayId);
}

class _CreateChildrenSetsState extends State<CreateChildrenSets> {
  final name;
  final total;
  final newExercise;
  final index;
  final weekId;
  final dayId;
  final databaseReference = Firestore.instance;
  List<bool> _selection = List.generate(3, (_) => false);
  // List<String> list = ['ok'];
  int _total;

  var sets = new List<Object>();

  void initState() {
    _total = total;
    _selection[0] = true;
    sets.addAll(newExercise.exercises[index]['sets']);
    // var list = sets as List;
    // list.add('a string');
  }
  
  void updateData() {
    // newExercise.exercises[index]['sets'][0]['weight'] = _weight;
    // newExercise.exercises[index]['sets'][0]['set'] = _set;
    // newExercise.exercises[index]['sets'][0]['rep'] = _rep;
    try {
      databaseReference.collection('data').document('Xi2BQ9KuCwOR2MeHIHUPH5G7bTc2').collection('weeks').document(weekId).collection('days').document(dayId).updateData(
        {'exercises': newExercise.exercises}
      );
    } catch (e) {
      print(e.toString());
    }
  }

  _incrementCounter() {
    setState(() {
      if (_selection[0]) {
        // _weight+=5;
      } else if (_selection[1]) {
        //  _set++;
      } else if(_selection[2]) {
        // _rep++;
      }
      // _total = _weight*_set*_rep;
      updateData();
    });
  }
  
  _decrementCounter() {
    setState(() {
      if (_selection[0]) {
        // _weight-=5;
      } else if (_selection[1]) {
        //  _set--;
      } else if(_selection[2]) {
        // _rep--;
      }
      //  _total = _weight*_set*_rep;
      updateData();
    });
  }

  _addSet() {
    setState(() {
      sets.add({'rep': '111', 'set': '444', 'weight': '222'});
    });
    // newExercise.exercises[index]['sets'] = sets;
    // updateData();
  }

  _removeSet() {
    setState(() {
      sets.removeLast();
    });
  }

  _CreateChildrenSetsState({this.name, this.total, this.newExercise,  this.index, this.weekId, this.dayId});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [ 
        Container(
          padding: EdgeInsets.only(top: 40.0, bottom: 5.0),
          child: Text(
            '$name', 
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
        Container(
          padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
          child: Text(
            '$_total', 
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
                  // color: Colors.amber,
                  height: 50
                )
              ),
              Container(
                // color: Colors.blue,
                // height: 50,
                width: 90,
                padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                child: Text(
                  'Weight',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Container(
                // color: Colors.blue,
                // height: 50,
                width: 90,
                padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                child: Text(
                  'Sets',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Container(
                // color: Colors.blue,
                // height: 50,
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
                  // color: Colors.green,
                  height: 50
                )
              ),
            ],
          ),
        ),
        Container(
          child: Column(
           children: [
              renderPlayers(sets),
            ],
          ),
        ),
         Container(
          padding: EdgeInsets.only(top: 20.0, bottom: 5.0),
            child: new SizedBox(
              height: 18.0,
              width: 24.0,
              child: new IconButton(
                padding: new EdgeInsets.all(0.0),
                icon: new Icon(Icons.remove_circle, size: 24.0),
                onPressed: _removeSet,
              )
            ),
        ),
        Container(
          padding: EdgeInsets.only(top: 20.0, bottom: 5.0),
           child: new SizedBox(
              height: 18.0,
              width: 24.0,
              child: new IconButton(
                padding: new EdgeInsets.all(0.0),
                icon: new Icon(Icons.add_circle, size: 24.0),
                onPressed: _addSet,
              )
            ),
        ),
      ],
    );
  }

  renderPlayers(List sets) {
    return 
    Column(
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
                    onPressed: _decrementCounter,
                  )
                ),
              ),
              ToggleButtons(
                children: <Widget>[
                  Column(
                    children: [
                      Container(
                        padding: EdgeInsets.only(top: 5.0, bottom: 10.0),
                        child: Text(
                          set['weight'], 
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                 Column(
                    children: [
                      Container(
                        padding: EdgeInsets.only(top: 5.0, bottom: 10.0),
                        child: Text(
                          set['set'],
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        padding: EdgeInsets.only(top: 5.0, bottom: 10.0),
                        child: Text(
                          set['rep'],
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ],
                onPressed: (int index) {
                
                  _selection[0] = false;
                  setState(() {
                    // if (sets.indexOf(set) == 0) {
                      for (int buttonIndex = 0; buttonIndex < _selection.length; buttonIndex++) {
                        // print(sets.indexOf(set));
                        if (buttonIndex == index) {
                          _selection[buttonIndex] = true;
                        } else {
                          _selection[buttonIndex] = false;
                        }
                      }
                    // }
                  });
                },
                isSelected: _selection,
                renderBorder: false,
              ),
              Expanded(
                child: new SizedBox(
                  height: 18.0,
                  width: 24.0,
                  child: new IconButton(
                    padding: new EdgeInsets.all(0.0),
                    icon: new Icon(Icons.add, size: 18.0),
                    onPressed: _incrementCounter,
                  )
                ),
              ),
            ],
          ),
        ),

    ).toList());



      


  }

}

// class CreateChildrenReps extends StatefulWidget {
//   CreateChildrenReps({this.something});
//   final Object something;
//   @override
//   _CreateChildrenRepsState createState() => _CreateChildrenRepsState(something: something);
// }

// class _CreateChildrenRepsState extends State<CreateChildrenSets> {
//   final something;
//   void initState() {
//   }
//   _CreateChildrenRepsState({this.something});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [ 
//         Container(
//           child: Text(
//             'Weight',
//             style: TextStyle(fontSize: 16),
//           ),
//         ),
//       ],
//     );
//   }
// }