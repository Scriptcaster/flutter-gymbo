import 'package:flutter/material.dart';
import 'services/database.dart';
import 'exercises.dart';
import 'models/day.dart';
import 'models/exercise.dart';

class DayLocal extends StatefulWidget {
  DayLocal({this.id, this.dayName, this.target, this.weekId});
  final int id;
  final String dayName;
  final String target;
  final int weekId;
  @override
  _StartDayLocalState createState() => _StartDayLocalState();
}
class _StartDayLocalState extends State<DayLocal> { _StartDayLocalState();
  TextEditingController _targetController = TextEditingController();

  @override
  void initState() {
    _targetController.text = widget.target;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _targetController.text);
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.dayName),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () async {
                await DBProvider.db.newExercise( Exercise( name: 'New Exercise', bestVolume: 0, previousVolume: 0, currentVolume: 0, dayId: widget.id, weekId: widget.weekId )); setState(() {});
              },   
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
                controller: _targetController,
                onSubmitted: (value) async { await DBProvider.db.updateDayTarget(Day(id: widget.id, target: value)); }
              ),
            ),
            RenderExercises(widget.weekId, widget.id),
          ]
        )
      )
    );
  }
}