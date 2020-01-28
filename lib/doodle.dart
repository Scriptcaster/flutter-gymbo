import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DayScreen extends StatefulWidget {
  DayScreen({@required this.weekId, this.dayId, this.date, this.target, this.exercises});
  final weekId;
  final dayId;
  final date;
  final target;
  final exercises;
  
  @override
  _StartDayScreenState createState() => _StartDayScreenState(dayId: dayId, weekId: weekId);
}

class _StartDayScreenState extends State<DayScreen> {
  _StartDayScreenState({this.weekId, this.dayId});
  final Object weekId;
  final Object dayId;
  List exercises = [];

  void initState() {
    super.initState();
    exercises.addAll(widget.exercises);
  }

  // List get age {
  //   print(exercises);
  //   return exercises;
  // }
  // void set age(int currentOk) {
  //   print('age setter');
  //   print(ok);
  //   ok = 11;
  //   // print(ok);
  // }
  
  addExercise() {
    setState(() {
      exercises.add({'name': 'New Exercise', 'sets': [{'set': 6, 'weight': 25, 'rep': 8}], 'volume': 0});
      // exercises.removeLast();
    });
    // showDialog(
    //   context: context,
    //   builder: (_) => new AlertDialog(
    //     title: new Text("Dialog Title"),
    //     content: new Text("This is my content"),
    //   )
    // );
  }

  removeExercise(index) {
    // setState(() {
    //   exercises.removeAt(index);
    // });
    print(index);
    print(exercises);
  }
  
  // List<String> list = List.generate(100, (i) => i.toString());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.date.toString()),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              addExercise();
            },
          )
        ],
      ),
      body: new Container(
        padding: EdgeInsets.only(top: 0.0),
        child: 
        // new ListView(
        //   children: createChildrenExercises(weekId: weekId, dayId: dayId, exercises: exercises),
        // ),
        new ListView.builder(
          itemCount: exercises.length,
          itemBuilder: (context, index) {
            return MyItem(weekId, dayId, index, exercises[index]['volume'], exercises[index], onDelete: () => removeItem(index));
          },
        ),
      ),
    );
  }

  void removeItem(int index) {
    print(index);
    setState(() {
      exercises = List.from(exercises)
        ..removeAt(index);
    });
  }

  // List<Widget> createChildrenExercises({weekId, dayId, exercises}) {
  //   List<Widget> childrenExercises = [];
  //   int index = 0;
  //   exercises.forEach((exercise) {
  //     childrenExercises.add(
  //       CreateChildrenSets(
  //         name: exercise['name'],
  //         total: exercise['volume'],
  //         exercises: exercises,
  //         index: index++,
  //         weekId: weekId,
  //         dayId: dayId
  //       ),
  //     );
  //   });
  //   return childrenExercises;
  // }
}

class MyItem extends StatefulWidget {
  final int index;
  final Object exercise;
  final VoidCallback onDelete;
  final Object total;
  final Object weekId;
  final Object dayId;

  String name;

  MyItem(this.weekId, this.dayId, this.index, this.total, this.exercise, {this.onDelete});

  @override
  // Widget build(BuildContext context) {
  //   return ListTile(
  //     title: Text(this.exercise.toString()),
  //     onTap: this.onDelete,
  //   );
  // }
  _CreateChildrenSetsState createState() => _CreateChildrenSetsState(name: name, total: total, exercises: exercise, index: index, weekId: weekId, dayId: dayId);

}

// class CreateChildrenSets extends StatefulWidget {
//   CreateChildrenSets({this.name, this.total, this.exercises, this.index, this.weekId, this.dayId});
//   final Object name;
//   final Object total;
//   final Object exercises;
//   final int index;
//   final Object weekId;
//   final Object dayId;
//   @override
//   _CreateChildrenSetsState createState() => _CreateChildrenSetsState(name: name, total: total, exercises: exercises, index: index, weekId: weekId, dayId: dayId);
// }

class _CreateChildrenSetsState extends State<MyItem> {

  final name;
  final total;
  // final exercises;
  List exercises = [];
  final index;
  final weekId;
  final dayId;
  final databaseReference = Firestore.instance;

  int _total;
  List sets = [];
  List<Color> colors = [Colors.blue, Colors.white, Colors.white];
  List<bool> _selected = [true, false, false];

  // String value = "Something";
  TextEditingController controller = TextEditingController();

  // List<bool> _selection = List.generate(3, (_) => false);
  // var sets = new List<Object>();

  // controller.addListener(() {
  //   // Do something here
  // });

  void initState() {
    super.initState();
    _total = total;
    sets.addAll(exercises[index]['sets']);
    controller.text = name; 
    // _selection[1] = true;
    // var list = sets as List;
    // list.add('a string');
  }

  void updateData() {
    try {
      databaseReference.collection('data').document('Xi2BQ9KuCwOR2MeHIHUPH5G7bTc2').collection('weeks').document(weekId).collection('days').document(dayId).updateData(
        {'exercises': exercises}
      );
    } catch (e) {
      print(e.toString());
    }
  }

  _decrementCounter(i, sets) {
    setState(() {
      if (_selected[0]) {
        sets[i]['weight']-=5;
      } else if (_selected[1]) {
        sets[i]['set']-=1;
      } else if(_selected[2]) {
        sets[i]['rep']-=1;
      }
      _total = sets[i]['weight']*sets[i]['set']*sets[i]['rep'];
      updateData();
    });
  }

  _incrementCounter(i, sets) {
    setState(() {
      if (_selected[0]) {
        sets[i]['weight']+=5;
      } else if (_selected[1]) {
        sets[i]['set']+=1;
      } else if(_selected[2]) {
        sets[i]['rep']+=1;
      }
      _total = sets[i]['weight']*sets[i]['set']*sets[i]['rep'];
      updateData();
    });
  }

  _removeSet(lenght) {
    if(lenght > 1) {
      setState(() {
        sets.removeLast();
      });
    }
  }
  
  _addSet(lenght, set) {
    if(lenght < 16) {
      setState(() {
        sets.add({'weight': set['weight'], 'set': set['set'], 'rep': set['rep']});
      });
     }
    // updateData();
  }

  // removeExercise() {
  //   // setState(() {
  //   //   exercises.removeAt(index);
  //   // });
  //   print(exercises);
  // }

  _CreateChildrenSetsState({this.name, this.total, this.exercises,  this.index, this.weekId, this.dayId});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [ 
        Container(
          padding: EdgeInsets.only(top: 40.0, bottom: 5.0, left: 40.0, right: 40.0),
          child: 
          TextField(
            style: new TextStyle(fontSize: 20.0, color: Colors.blue),
            keyboardType: TextInputType.text,
            // textAlign: TextAlign.center,
            controller: controller,
            onSubmitted: (value) {
              exercises[index]['name'] = value;
              updateData();
            }
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
            //  renderSets(sets),
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
                  onPressed: () => _StartDayScreenState().removeExercise(index),
                )
              ),
              Expanded(
                flex: 1,
                child: new IconButton(
                  padding: new EdgeInsets.all(0.0),
                  icon: new Icon(Icons.remove_circle, size: 24.0),
                  onPressed: () => _removeSet(sets.length),
                )
              ),
               Expanded(
                flex: 1,
                child: new IconButton(
                  padding: new EdgeInsets.all(0.0),
                  icon: new Icon(Icons.add_circle, size: 24.0),
                  onPressed: () => _addSet(sets.length, sets.last),
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
                  onPressed: ()=>_decrementCounter(sets.indexOf(set), sets)
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
                  onPressed: ()=>_incrementCounter(sets.indexOf(set), sets),
                )
              ),
            ),
          ],
        ),
      ),
    ).toList());
  }
}



addExercise() {
  setState(() {
  exercises.add({'name': 'New Exercise', 'sets': [{'set': 6, 'weight': 25, 'rep': 8}], 'volume': 0});
  // exercises.removeLast();
  });
  // showDialog(
  //   context: context,
  //   builder: (_) => new AlertDialog(
  //     title: new Text("Dialog Title"),
  //     content: new Text("This is my content"),
  //   )
  // );
}

// List get age {
//   print(exercises);
//   return exercises;
// }
// void set age(int currentOk) {
//   print('age setter');
//   print(ok);
//   ok = 11;
//   // print(ok);
// }

removeExercise(index) {
  // setState(() {
  //   exercises.removeAt(index);
  // });
}

// List<String> list = List.generate(100, (i) => i.toString());









// LATEST



import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DayScreen extends StatefulWidget {
  DayScreen({@required this.weekId, this.dayId, this.date, this.target, this.exercises});
  final weekId;
  final dayId;
  final date;
  final target;
  final exercises;
  
  @override
  _StartDayScreenState createState() => _StartDayScreenState(dayId: dayId, weekId: weekId);
}

class _StartDayScreenState extends State<DayScreen> {
  _StartDayScreenState({this.weekId, this.dayId});
  final Object weekId;
  final Object dayId;
  List exercises = [];
  List newExercises = [];

  void initState() {
    super.initState();
    exercises.addAll(widget.exercises);
  }
  
  addExercise() {
    setState(() {
      exercises.add({'name': 'New Exercise', 'sets': [{'set': 6, 'weight': 25, 'rep': 8}], 'volume': 0});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.date.toString()),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              addExercise();
            },
          )
        ],
      ),
      body: new Container(
        padding: EdgeInsets.only(top: 0.0),
        child: 
        new ListView.builder(
          itemCount: exercises.length,
          itemBuilder: (context, index) {
            // return CreateChildrenSets(exercises[index]['name'], exercises[index]['volume'], exercises[index], exercises[index]['sets'], index, weekId, dayId, onDelete: () => removeItem(index));
            return CreateChildrenSets(exercises[index], onDelete: () => removeItem(index));

          },
        ),
      ),
    );
  }

  void removeItem(index) {
    setState(() {
      exercises.removeAt(index);
    });
    print(index);
    print(exercises[index]['name']);
  }
}

// class CreateChildrenSets extends StatelessWidget {
//   final Object exercises;
//   final VoidCallback onDelete;
//   CreateChildrenSets(this.exercises, {this.onDelete});
//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       title: Text(exercises.toString()),
//       onTap: this.onDelete,
//     );
//   }
// }

class CreateChildrenSets extends StatefulWidget {
  // String name;
  // final Object total;
  // List sets;
  // final int index;
  // final Object weekId;
  // final Object dayId;
  final Object exercises;
  final VoidCallback onDelete;
  // CreateChildrenSets(this.name, this.total, this.exercises,  this.sets, this.index, this.weekId, this.dayId, {this.onDelete});
  CreateChildrenSets(this.exercises, {this.onDelete});

  @override
  // _CreateChildrenSetsState createState() => _CreateChildrenSetsState(name, total, exercises, sets, index, weekId, dayId, this.onDelete);
  _CreateChildrenSetsState createState() => _CreateChildrenSetsState(exercises, this.onDelete);
}

class _CreateChildrenSetsState extends State<CreateChildrenSets> {
  final Object exercises;
  final VoidCallback onDelete;
  void initState() {
     super.initState();
  }
  _CreateChildrenSetsState(this.exercises, this.onDelete);

  // void didUpdateWidget(CreateChildrenSets oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   print('didUpdateWidget');
  // }

  @override
    Widget build(BuildContext context) {
    return ListTile(
      title: Text(exercises.toString()),
      onTap: this.onDelete,
    );
  } 
}

// class _CreateChildrenSetsState extends State<CreateChildrenSets> {

//   String name;
//   final int total;
//   int _total;
//   final Object exercises;
//   final List sets;
//   List mySets = [];
//   final int index;
//   final Object weekId;
//   final Object dayId;
//   final VoidCallback onDelete;
//   final databaseReference = Firestore.instance;

//   List<Color> colors = [Colors.blue, Colors.white, Colors.white];
//   List<bool> _selected = [true, false, false];
//   TextEditingController controller = TextEditingController();

//   void initState() {
//     super.initState();
//     _total = this.total;
//     mySets.addAll(this.sets);
//     // mySets = this.sets;
//     controller.text = this.name; 
//     // _selection[1] = true;
//     // var list = sets as List;
//     // list.add('a string');
//   }

//   // void updateData() {
//   //   try {
//   //     databaseReference.collection('data').document('Xi2BQ9KuCwOR2MeHIHUPH5G7bTc2').collection('weeks').document(weekId).collection('days').document(dayId).updateData(
//   //       {'exercises': exercises}
//   //     );
//   //   } catch (e) {
//   //     print(e.toString());
//   //   }
//   // }

//   _decrementCounter(i, sets) {
//     setState(() {
//       if (_selected[0]) {
//         sets[i]['weight']-=5;
//       } else if (_selected[1]) {
//         sets[i]['set']-=1;
//       } else if(_selected[2]) {
//         sets[i]['rep']-=1;
//       }
//       _total = sets[i]['weight']*sets[i]['set']*sets[i]['rep'];
//       // updateData();
//     });
//   }

//   _incrementCounter(i, sets) {
//     setState(() {
//       if (_selected[0]) {
//         sets[i]['weight']+=5;
//       } else if (_selected[1]) {
//         sets[i]['set']+=1;
//       } else if(_selected[2]) {
//         sets[i]['rep']+=1;
//       }
//       _total = sets[i]['weight']*sets[i]['set']*sets[i]['rep'];
//       // updateData();
//     });
//   }

//   _removeSet(lenght) {
//     if(lenght > 1) {
//       setState(() {
//         mySets.removeLast();
//       });
//     }
//   }
  
//   _addSet(lenght, set) {
//     if(lenght < 16) {
//       setState(() {
//         mySets.add({'weight': set['weight'], 'set': set['set'], 'rep': set['rep']});
//       });
//      }
//     // updateData();
//   }

//   _CreateChildrenSetsState(this.name, this.total, this.exercises, this.sets, this.index, this.weekId, this.dayId, this.onDelete);

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [ 
//         Container(
//           padding: EdgeInsets.only(top: 40.0, bottom: 5.0, left: 40.0, right: 40.0),
//           child: 
//           TextField(
//             style: new TextStyle(fontSize: 20.0, color: Colors.blue),
//             keyboardType: TextInputType.text,
//             // textAlign: TextAlign.center,
//             controller: controller,
//             onSubmitted: (value) {
//               this.name = value;
//               // updateData();
//             }
//           ),
//         ),
//         Container(
//           padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
//           child: Text(
//             // this.widget.total.toString(), 
//             // this.name.toString(),
//             '$_total', 
//             textAlign: TextAlign.center,
//             style: TextStyle(fontSize: 18),
//             ),
//         ),
//         Container(
//           padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
//           child: Row(
//             children: <Widget>[
//               Expanded(
//                 flex: 1,
//                 child: Container(
//                   height: 50
//                 )
//               ),
//               Container(
//                 width: 90,
//                 padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
//                 child: Text(
//                  'Weight',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(fontSize: 16),
//                 ),
//               ),
//               Container(
//                 width: 90,
//                 padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
//                 child: Text(
//                   'Sets',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(fontSize: 16),
//                 ),
//               ),
//               Container(
//                 width: 90,
//                 padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
//                 child: Text(
//                   'Reps',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(fontSize: 16),
//                 ),
//               ),
//               Expanded(
//                 flex: 1,
//                 child: Container(
//                   height: 50
//                 )
//               ),
//             ],
//           ),
//         ),
//         Container(
//           child: Column(
//            children: [
//              renderSets(mySets),
//             ],
//           ),
//         ),

//         Container(
//           padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
//           child: Row(
//             children: <Widget>[
//               Expanded(
//                 flex: 1,
//                 child: new IconButton(
//                   padding: new EdgeInsets.all(0.0),
//                   icon: new Icon(Icons.delete, size: 24.0),
//                   onPressed: this.onDelete,
//                 )
//               ),
//               Expanded(
//                 flex: 1,
//                 child: new IconButton(
//                   padding: new EdgeInsets.all(0.0),
//                   icon: new Icon(Icons.remove_circle, size: 24.0),
//                   onPressed: () => _removeSet(mySets.length),
//                 )
//               ),
//                Expanded(
//                 flex: 1,
//                 child: new IconButton(
//                   padding: new EdgeInsets.all(0.0),
//                   icon: new Icon(Icons.add_circle, size: 24.0),
//                   onPressed: () => _addSet(mySets.length, mySets.last),
//                 )
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//   renderSets(List sets) {
//     return Column(
//       children: sets.map((set) => 
//       Container(
//         padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
//         child: Row(
//           children: <Widget>[
//             Expanded(
//               child: new SizedBox(
//                 height: 18.0,
//                 width: 24.0,
//                 child: new IconButton(
//                   padding: new EdgeInsets.all(0.0),
//                   icon: new Icon(Icons.remove, size: 18.0),
//                   onPressed: () => _decrementCounter(sets.indexOf(set), sets)
//                 )
//               ),
//             ),
//             FlatButton(
//               color: colors[0],
//               onPressed: () {
//                 _selected = [false, false, false];
//                 setState(() {
//                   colors = [Colors.white, Colors.white, Colors.white];
//                   colors[0] = Colors.blue;
//                   _selected[0] = true;
//                 });
//               },
//               child: Text(
//                 set['weight'].toString(),
//               ),
//             ),
//               FlatButton(
//               color: colors[1],
//               onPressed: () {
//                 _selected = [false, false, false];
//                 setState(() {
//                   colors = [Colors.white, Colors.white, Colors.white];
//                   colors[1] = Colors.blue;
//                   _selected[1] = true;
//                 });
//               },
//               child: Text(
//                 set['set'].toString(),
//               ),
//             ),
//             FlatButton(
//               color: colors[2],
//               onPressed: () {
//                 // print(sets.indexOf(set));
//                   _selected = [false, false, false];
//                 setState(() {
//                   colors = [Colors.white, Colors.white, Colors.white];
//                   colors[2] = Colors.blue;
//                   _selected[2] = true;
//                 });
//               },
//               child: Text(
//                 set['rep'].toString(),
//               ),
//             ),
//             Expanded(
//               child: new SizedBox(
//                 height: 18.0,
//                 width: 24.0,
//                 child: new IconButton(
//                   padding: new EdgeInsets.all(0.0),
//                   icon: new Icon(Icons.add, size: 18.0),
//                   onPressed: ()=>_incrementCounter(sets.indexOf(set), sets),
//                 )
//               ),
//             ),
//           ],
//         ),
//       ),
//     ).toList());
//   }
// }