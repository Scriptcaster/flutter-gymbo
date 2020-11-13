import 'package:flutter/material.dart';
import '../db/db_provider.dart';
import 'exercise.dart';
import '../models/day.dart';
import '../models/exercise.dart';

import 'package:scoped_model/scoped_model.dart';
import '../scopedmodel/program.dart';

class DayLocal extends StatefulWidget {
  DayLocal({this.id, this.dayName, this.target, this.weekId, this.programId});
  final int id;
  final String dayName;
  final String target;
  final String weekId;
  final String programId;
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
    return ScopedModelDescendant<WeekListModel>(
      builder: (BuildContext context, Widget child, WeekListModel model) {
      var _exercise = model.exercises.where((exercise) => exercise.dayId == widget.id).toList();
      // print(_exercise);
      return WillPopScope(
        onWillPop: () async {
          // model.updateChart(Day(id: widget.id, target: _targetController.text));
          print('POP');
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
                  await DBProvider.db.addExercise( Exercise( name: 'New Exercise', bestVolume: 0, previousVolume: 0, currentVolume: 0, dayId: widget.id, weekId: widget.weekId, programId: widget.programId )); setState(() {});
                },   
              )
            ],
          ),
          // body: new Column(
          //   children: <Widget>[
          //     Container(
          //       padding: EdgeInsets.only(top: 5.0, bottom: 0.0, left: 40.0, right: 40.0),
          //       child: TextField(
          //         style: new TextStyle(fontSize: 20.0, color: Colors.blue),
          //         keyboardType: TextInputType.text,
          //         controller: _targetController,
          //         // onSubmitted: (value) async { await DBProvider.db.updateDayTarget(Day(id: widget.id, target: value)); }
          //         onSubmitted: (value) { model.updateDayTarget(Day(id: widget.id, target: value)); }
          //       ),
          //     ),
          //     RenderExercises(widget.id, widget.weekId, widget.programId),
          //   ]
          // )

          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
            child: Column(children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: ListView.builder(itemBuilder: (BuildContext context, int index) {
                    // _days.sort((a, b) => b.seq.compareTo(a.seq));
                      if (index == _exercise.length) { return SizedBox(height: 56); }
                      var exercise = _exercise[index];
                      return Dismissible(key: UniqueKey(), background: Container(color: Colors.red),
                        confirmDismiss: (DismissDirection direction) async {
                          return await showDialog(context: context, builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Confirm Removal"),
                              content: const Text("Are you sure you wish to delete this item?"),
                              actions: <Widget>[
                                FlatButton(
                                  child: const Text("DELETE"),
                                  onPressed: () {
                                    // model.removeDay(day);
                                    Navigator.of(context).pop(true);
                                  }
                                ),
                                FlatButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text("CANCEL"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: ListTile(
                        onTap: () {
                          Navigator.push(context,
                            MaterialPageRoute(
                              builder: (context) => ExerciseLocal(
                                id: exercise.id,
                                name: exercise.name,
                                bestVolume: exercise.bestVolume,
                                previousVolume: exercise.previousVolume,
                                currentVolume: exercise.currentVolume,
                                dayId: exercise.dayId,
                                weekId: exercise.weekId,
                                programId: exercise.programId
                              ),
                            ),
                          );
                        },
                        // leading: Checkbox(
                        //     onChanged: (value) => model.updateWeek(week.copy(isCompleted: value ? 1 : 0)),
                        //     value: week.isCompleted == 1 ? true : false
                        // ),
                        title: Text(
                          exercise.name,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                            // color: exercise.isCompleted == 1 ? _color : Colors.black54,
                            // decoration: exercise.isCompleted == 1 ? TextDecoration.lineThrough : TextDecoration.none,
                          ),
                        ),
                        // subtitle: Text(
                        //   DateFormat('MMM d').format(DateTime.fromMillisecondsSinceEpoch(exercise.date)).toString()
                        // ),
                        trailing: Icon(Icons.chevron_right),
                      ),
                    );
                  }, itemCount: _exercise.length + 1,),
                ),
              ),
            ]),
          ),

        )
      );
    });
  }
}