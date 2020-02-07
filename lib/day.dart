import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'exercises.dart';

class Day extends StatefulWidget {
  Day({this.uid, this.weekId, this.dayId, this.date, this.target, this.exercises, this.cardio });
  final uid;
  final weekId;
  final dayId;
  final date;
  final target;
  final exercises;
  final cardio;
  @override
  _StartDayState createState() => _StartDayState();
}

class _StartDayState extends State<Day> { _StartDayState();
  List exercises = [];
  TextEditingController _targetNameController = TextEditingController();
  int _cardio;

  @override
  void initState() {
    _targetNameController.text = widget.target;

    if(widget.exercises != null) {
      exercises.addAll(widget.exercises);
    }
    if (widget.cardio == null) {
      _cardio = 0;
    } else {
      _cardio = widget.cardio;
    }
    super.initState();
  }

  void addExercise() => setState(() => exercises.add({'name': 'New Exercise', 'sets': [{'set': 0, 'weight': 0, 'rep': 0}], 'volume': 0, 'bestVolume': 0, 'previousVolume': 0}));
  void removeItem(index) => setState(() => this.exercises.removeAt(index));
  
  @override
  void dispose() {
    try {
      Firestore.instance.collection('data').document(widget.uid).collection('weeks').document(widget.weekId).collection('days').document(widget.dayId).updateData({'exercises': exercises, 'target': _targetNameController.text, 'cardio': _cardio});
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
      body: new Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 5.0, bottom: 0.0, left: 40.0, right: 40.0),
            child: TextField(
              style: new TextStyle(fontSize: 20.0, color: Colors.blue),
              keyboardType: TextInputType.text,
              controller: _targetNameController,
              onSubmitted: (value) {
                _targetNameController.text = value;
              }
            ),
          ),

          Container(
            padding: EdgeInsets.only(top: 5.0, bottom: 0.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: new SizedBox(
                    height: 18.0,
                    width: 24.0,
                    child: new IconButton(
                      padding: new EdgeInsets.all(0.0),
                      icon: new Icon(Icons.remove, size: 18.0),
                      onPressed: () => setState(() => _cardio-=1),
                    )
                  ),
                ),

                FlatButton(
                  color: Colors.blue,
                  padding: EdgeInsets.all(2.0),
                  child: Column( // Replace with a Row for horizontal icon + text
                    children: <Widget>[
                      Text(
                        _cardio.toString(),
                      ),
                      Text("minutes")
                    ],
                  ),
                  onPressed: () => setState(() => _cardio+=1),
                ),

                Expanded(
                  child: new SizedBox(
                    height: 18.0,
                    width: 24.0,
                    child: new IconButton(
                      padding: new EdgeInsets.all(0.0),
                      icon: new Icon(Icons.add, size: 18.0),
                      onPressed: () => setState(() => _cardio+=1),
                    )
                  ),
                ),
              ],
            ),
          ),

          new Expanded(
            child: new Container(
              height: 200.0,
              child: new ListView.builder(
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  return CreateChildrenSets(widget.uid, index, exercises, exercises[index]['name'], exercises[index]['sets'], widget.weekId, widget.dayId, onDelete: () => removeItem(index));
                },
              ),
            )
          )
        ]
      )
    );
  }
}