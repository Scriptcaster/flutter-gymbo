import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'exercises.dart';

class DayScreen extends StatefulWidget {
  DayScreen({@required this.weekId, this.dayId, this.date, this.target, this.exercises });
  final weekId;
  final dayId;
  final date;
  final target;
  final exercises;
  @override
  _StartDayScreenState createState() => _StartDayScreenState();
}

class _StartDayScreenState extends State<DayScreen> { _StartDayScreenState();
  List exercises = [];

  @override
  void initState() {
    print(widget.date);
    exercises.addAll(widget.exercises);
    super.initState();
  }

  void addExercise() => setState(() => exercises.add({'name': 'New Exercise', 'sets': [{'set': 4, 'weight': 25, 'rep': 8}], 'volume': 800}));
  void removeItem(index) => setState(() => this.exercises.removeAt(index));
  
  
  @override
  void dispose() {
    try {
      Firestore.instance.collection('data').document('Xi2BQ9KuCwOR2MeHIHUPH5G7bTc2').collection('weeks').document(widget.weekId).collection('days').document(widget.dayId).updateData(
        {'exercises': exercises}
      );
    } catch (e) {
      print(e.toString());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.date.toString()),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => addExercise(),     
          )
        ],
      ),
      body: new Container(
        padding: EdgeInsets.only(top: 0.0),
        child: 
        new ListView.builder(
          itemCount: exercises.length,
          itemBuilder: (context, index) {
            return CreateChildrenSets(index, exercises, exercises[index]['name'], exercises[index]['sets'], widget.weekId, widget.dayId, onDelete: () => removeItem(index));
          },
        ),
      ),
    );
  }
}