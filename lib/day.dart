import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'exercises.dart';

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
  
  addExercise() {
    // print(exercises);
    setState(() {
      exercises.add({'name': 'New Exercise', 'sets': [{'set': 4, 'weight': 25, 'rep': 8}], 'volume': 800});
    });
  }

  void removeItem(index) {
    setState(() {
      this.exercises.removeAt(index);
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
            return CreateChildrenSets(index, exercises, exercises[index]['name'], exercises[index], exercises[index]['sets'], weekId, dayId, onDelete: () => removeItem(index));
            // return Day(exercises[index]['name'], exercises[index]['name']);
          },
        ),
      ),
    );
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

// class CreateChildrenSets extends StatefulWidget {
//   final Object exercises;
//   final VoidCallback onDelete;
//   CreateChildrenSets(this.exercises, {this.onDelete});

//   @override
//   _CreateChildrenSetsState createState() => _CreateChildrenSetsState();
// }

// class _CreateChildrenSetsState extends State<CreateChildrenSets> {
//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       title: Text(widget.exercises.toString()),
//       onTap: this.widget.onDelete,
//     );
//   }
// }

// class CreateChildrenSets extends StatefulWidget {
//   final Object index;
//   final Object day;
//   final Object name;
//   final Object weekId;
//   final Object dayId;
//   final Object exercises;
//   final Object sets;
//   final VoidCallback onDelete;
//   // CreateChildrenSets(this.name, this.total, this.exercises,  this.sets, this.index, this.weekId, this.dayId, {this.onDelete});
//   CreateChildrenSets(this.index, this.day, this.name, this.exercises, this.sets, this.weekId, this.dayId, {this.onDelete});

//   @override
//   // _CreateChildrenSetsState createState() => _CreateChildrenSetsState(name, total, exercises, sets, index, weekId, dayId, this.onDelete);
//   _CreateChildrenSetsState createState() => _CreateChildrenSetsState(index, day, name, exercises, sets, weekId, dayId, this.onDelete);
// }

// // class _CreateChildrenSetsState extends State<CreateChildrenSets> {
// //   final Object exercises;
// //   final VoidCallback onDelete;
// //   List editableExercises = [];
// //   void initState() {
// //     super.initState();
// //   }
// //   _CreateChildrenSetsState(this.exercises, this.onDelete);

// //   void didUpdateWidget(CreateChildrenSets oldWidget) {
// //     super.didUpdateWidget(oldWidget);
// //     if (oldWidget != widget) {
// //         setState(() {
// //         print(exercises);
// //     });
// //     }
// //   }

// //   @override
// //     Widget build(BuildContext context) {
// //     return ListTile(
// //       title: Text(widget.exercises.toString()),
// //       onTap: this.widget.onDelete,
// //     );
// //   } 
// // }

// class _CreateChildrenSetsState extends State<CreateChildrenSets> {
//   final Object weekId;
//   final Object dayId;
//   final Object index;
//   final Object exercises;
//   final List day;
//   List editableDay = [];
//   String name;
//   List sets;
//   List editableSets = [];
 

//   final VoidCallback onDelete;
//   final databaseReference = Firestore.instance;

//   List<Color> colors = [Colors.blue, Colors.white, Colors.white];
//   List<bool> _selected = [true, false, false];
//   TextEditingController controller = TextEditingController();

//   void initState() {
//     super.initState();
//     editableDay.addAll(widget.day);
//     controller.text = editableDay[index]['name']; 
//     editableSets.addAll(editableDay[index]['sets']);
//   }

//   void updateData() {
//     editableDay[index]['name'] = controller.text;
//     editableDay[index]['sets'] = editableSets;
//     print(editableDay);
//     // try {
//     //   databaseReference.collection('data').document('Xi2BQ9KuCwOR2MeHIHUPH5G7bTc2').collection('weeks').document(weekId).collection('days').document(dayId).updateData(
//     //     {'exercises': editableDay}
//     //   );
//     // } catch (e) {
//     //   print(e.toString());
//     // }
//   }

//   void didUpdateWidget(CreateChildrenSets oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget != widget) {
//       setState(() {
//         controller.text = widget.name; 
//         editableDay.clear();
//         editableDay.addAll(widget.day);
//         editableSets.clear();
//         editableSets.addAll(widget.sets); 
//       });
//     }
//   }

//   _decrementCounter(i, sets) {
//     setState(() {
//       if (_selected[0]) {
//         sets[i]['weight']-=5;
//       } else if (_selected[1]) {
//         sets[i]['set']-=1;
//       } else if(_selected[2]) {
//         sets[i]['rep']-=1;
//       }
//       editableDay[index]['volume'] = sets[i]['weight']*sets[i]['set']*sets[i]['rep'];
//       updateData();
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
//       editableDay[index]['volume'] = sets[i]['weight']*sets[i]['set']*sets[i]['rep'];
//       updateData();
//     });
//   }

//   _removeSet(lenght) {
//     if(lenght > 1) {
//       setState(() {
//         editableSets.removeLast();
//       });
//     }
//     updateData();
//   }
  
//   _addSet(lenght, set) {
//     if(lenght < 16) {
//       setState(() {
//         editableSets.add({'weight': set['weight'], 'set': set['set'], 'rep': set['rep']});
//       });
//     }
//     // editableDay[index]['volume'] = sets[i]['weight']*sets[i]['set']*sets[i]['rep'];
//     updateData();
//   }

//   // _CreateChildrenSetsState(this.name, this.total, this.exercises, this.sets, this.index, this.weekId, this.dayId, this.onDelete);
//   _CreateChildrenSetsState(this.index, this.day, this.name, this.exercises, this.sets,  this.weekId, this.dayId, this.onDelete);

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
//             controller: controller,
//             onSubmitted: (value) {
//               name = value;
//               updateData();
//             }
//           ),
//         ),
//         Container(
//           padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
//           child: Text(
//             editableDay[index]['volume'].toString(), 
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
//               renderSets(editableSets),
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
//                   onPressed: this.widget.onDelete,
//                 )
//               ),
//               Expanded(
//                 flex: 1,
//                 child: new IconButton(
//                   padding: new EdgeInsets.all(0.0),
//                   icon: new Icon(Icons.remove_circle, size: 24.0),
//                   onPressed: () => _removeSet(editableSets.length),
//                 )
//               ),
//                Expanded(
//                 flex: 1,
//                 child: new IconButton(
//                   padding: new EdgeInsets.all(0.0),
//                   icon: new Icon(Icons.add_circle, size: 24.0),
//                   onPressed: () => _addSet(editableSets.length, editableSets.last),
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