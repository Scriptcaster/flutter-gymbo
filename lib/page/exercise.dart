
import 'package:flutter/material.dart';
import '../db/db_provider.dart';
import 'exercise.dart';
import 'round.dart';
import '../models/day.dart';
import '../models/exercise.dart';

import 'package:scoped_model/scoped_model.dart';
import '../scopedmodel/program.dart';

class ExerciseLocal extends StatefulWidget {
  ExerciseLocal({this.id, this.name, this.bestVolume, this.previousVolume, this.currentVolume, this.dayId, this.weekId, this.programId});
  final int id;
  final String name;
  final int bestVolume;
  final int previousVolume;
  final int currentVolume;
  final int dayId;
  final String weekId; 
  final String programId; 
  @override
  _StartExerciseLocalState createState() => _StartExerciseLocalState();
}
class _StartExerciseLocalState extends State<ExerciseLocal> { _StartExerciseLocalState();
  TextEditingController _targetController = TextEditingController();
  int previousExerciseVolume  = 0;
  int bestExerciseVolume = 0;
  String exerciseName;

  @override
  void initState() {
    _targetController.text = widget.name;
    super.initState();
    setState(() {
      exerciseName = widget.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<WeekListModel>(
      builder: (BuildContext context, Widget child, WeekListModel model) {
      var _round = model.rounds.where((round) => round.exerciseId == widget.id).toList();
      var exercises = model.exercises.where((exercise) => exercise.id == widget.id);
      // print(exercise.first);
      Exercise exercise = exercises.first;
      TextEditingController _exerciseController = TextEditingController();
        return Scaffold(
          appBar: AppBar(
            title: Text(exerciseName),
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
            child: Column(children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: ListView.builder(itemBuilder: (BuildContext context, int index) {
                    // _days.sort((a, b) => b.seq.compareTo(a.seq));
                    if (index == _round.length) { return SizedBox(height: 56); }
                    // var exercise = _round[index];
                    _exerciseController.text = widget.name;
                    previousExerciseVolume = widget.previousVolume;
                    bestExerciseVolume = widget.bestVolume;
                    return Container(
                      padding: EdgeInsets.only(top: 10.0, bottom: 5.0, left: 10.0, right: 10.0),
                      child: Column(
                        children: <Widget>[
                          // Container(padding: EdgeInsets.only(top: 0.0, bottom: 0.0, left: 40.0, right: 40.0),
                          //   child: Column(
                          //     children: <Widget>[
                          //       // TextFormField(
                          //       //   initialValue: _exerciseController.text,
                          //       //   onChanged: (text) {
                          //       //     setState(() => _exerciseController.text = text);
                          //       //   },
                          //       //   cursorColor: Colors.black54,
                          //       //   autofocus: true,
                          //       //   decoration: InputDecoration(
                          //       //       border: InputBorder.none,
                          //       //       hintText: 'Category Name...',
                          //       //       hintStyle: TextStyle(
                          //       //         color: Colors.black26,
                          //       //       )),
                          //       //   style: TextStyle(
                          //       //       color: Colors.black54,
                          //       //       fontWeight: FontWeight.w500,
                          //       //       fontSize: 36.0),
                          //       // ),
                          //       TextField(style: new TextStyle(fontSize: 20.0, color: Colors.blue),
                          //         keyboardType: TextInputType.text,
                          //         controller: _exerciseController,
                          //         // onSubmitted: (value) async {
                          //         //   if (value.isNotEmpty) {
                          //         //     // await DBProvider.db.updateExerciseName(Exercise(id: exercise.id, name: value));
                          //         //     // model.addToChart(Exercise(id: exercise.id, name: exercise.name, bestVolume: exercise.bestVolume, previousVolume: exercise.previousVolume, currentVolume: exercise.currentVolume, dayId: widget.id, weekId: widget.weekId, programId: widget.programId));
                          //         //   }
                          //         //   // refreshVolumes(exercise.id, value);
                          //         //   setState(() {});
                          //         // }
                          //       )
                          //     ]
                          //   )
                          // ),
                        Container(padding: EdgeInsets.only(top: 30.0, bottom: 0.0),
                          child: Row(
                            children: <Widget>[
                              Expanded(flex: 1, child: Container(height: 5)),
                              Container(width:100, padding: EdgeInsets.only(top: 0.0, bottom: 0.0),
                                child: Text('Best', textAlign: TextAlign.center, style: TextStyle(fontSize: 16))
                              ),
                              Container(width:100, padding: EdgeInsets.only(top: 0.0, bottom: 0.0),
                                child: Text('Previous', textAlign: TextAlign.center, style: TextStyle(fontSize: 16))
                              ),
                              Container(width: 100, padding: EdgeInsets.only(top: 0.0, bottom: 0.0),
                                child: Text('Current', textAlign: TextAlign.center, style: TextStyle(fontSize: 16))
                              ),
                              Expanded(flex: 1, child: Container(height: 5)),
                            ],
                          ),
                        ),
                        Container(padding: EdgeInsets.only(top: 0.0, bottom: 0.0),
                          child: Row(
                            children: <Widget>[
                              Expanded(flex: 1, child: Container(height: 10)),
                              Container( width:100, padding: EdgeInsets.only(top: 0.0, bottom: 0.0),
                                child: Text(bestExerciseVolume.toString(), textAlign: TextAlign.center, style: TextStyle(fontSize: 16))
                              ),
                              Container( width:100, padding: EdgeInsets.only(top: 0.0, bottom: 0.0),
                                child: Text(previousExerciseVolume.toString(), textAlign: TextAlign.center, style: TextStyle(fontSize: 16))
                              ),
                              Container(width: 100, padding: EdgeInsets.only(top: 0.0, bottom: 0.0),
                                child: Text(widget.currentVolume.toString(), textAlign: TextAlign.center, style: TextStyle(fontSize: 16))
                              ),
                              Expanded(flex: 1, child: Container(height: 10)),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 20.0, bottom: 0.0),
                          child: Row(
                            children: <Widget>[
                              Expanded(flex: 1, child: Container(height: 0)),
                              Container(width: 90, padding: EdgeInsets.only(top: 0.0, bottom: 0.0),
                                child: Text('Weight', textAlign: TextAlign.center, style: TextStyle(fontSize: 16))
                              ),
                              Container(width: 90, padding: EdgeInsets.only(top: 0.0, bottom: 0.0),
                                child: Text('Sets', textAlign: TextAlign.center, style: TextStyle(fontSize: 16))
                              ),
                              Container(width: 90, padding: EdgeInsets.only(top: 0.0, bottom: 0.0),
                                child: Text('Reps', textAlign: TextAlign.center, style: TextStyle(fontSize: 16))
                              ),
                              Expanded(flex: 1, child: Container(height: 0)),
                            ],
                          ),
                        ),
                              RenderRounds(widget.id, exercise.first, parentUpdater: () => setState(() {})),
                              // RenderRounds(widget.id, exercise, parentUpdater: () => refreshVolumes(exercise.id, exercise.name) ),
                              Container(
                                padding: EdgeInsets.only(top: 0.0, bottom: 5.0),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(flex: 1,
                                      child: new IconButton(
                                        padding: new EdgeInsets.all(0.0),
                                        icon: new Icon(Icons.delete, size: 24.0),
                                        onPressed: () async { 
                                          // DBProvider.db.removeExercise(exercise); setState(() {});
                                          // refreshVolumes(exercise.id, exercise.name);
                                        }
                                      )
                                    ),
                                    Expanded(flex: 1,
                                      child: new IconButton(
                                        padding: new EdgeInsets.all(0.0),
                                        icon: new Icon(Icons.remove_circle, size: 24.0),
                                        onPressed: () async { 
                                          // await DBProvider.db.removeRound(exercise.id);
                                          setState(() {});
                                          // _updateCurrentVolumeOnRemove(exercise);
                                          // refreshVolumes(exercise.id, exercise.name);
                                        }
                                      )
                                    ),
                                    // Expanded(flex: 1,
                                    //   child: new IconButton(
                                    //     padding: new EdgeInsets.all(0.0),
                                    //     icon: new Icon(Icons.add_circle, size: 24.0),
                                    //     onPressed: () async {
                                    //       await DBProvider.db.addRound( Round( weight: 0, round: 0, rep: 0, exerciseId: exercise.id, dayId: widget.id, weekId: widget.weekId, programId: widget.programId )); 
                                    //       setState(() {});
                                    //       // _updateCurrentVolumeOnAdd(exercise);
                                    //       // refreshVolumes(exercise.id, exercise.name);
                                    //     },      
                                    //   )
                                    // ),
                                  ],
                                ),
                              )
                        ] 
                      ),

                    );
                  }, itemCount: _round.length + 1,),
                ),
              ),
            ]),
          ),

          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Builder(
            builder: (BuildContext context) {
              return FloatingActionButton.extended(
                heroTag: 'fab_new_card',
                icon: Icon(Icons.save),
                backgroundColor: Colors.blue,
                label: Text('Save Exercise'),
                onPressed: () {
                  if (_exerciseController.text.isEmpty) {
                    final snackBar = SnackBar(
                      content: Text('Ummm... It seems that you are trying to add an invisible program which is not allowed in this realm.'),
                      backgroundColor: Colors.black,
                    );
                    Scaffold.of(context).showSnackBar(snackBar);
                    // _scaffoldKey.currentState.showSnackBar(snackBar);
                  } else {
                    print(_exerciseController.text);
                    model.updateExercise(Exercise(
                      id: widget.id,
                      name: _exerciseController.text,
                      bestVolume: widget.bestVolume,
                      previousVolume: widget.previousVolume,
                      currentVolume: widget.currentVolume,
                      dayId: widget.dayId,
                      weekId: widget.weekId,
                      programId: widget.programId
                    ));
                    Navigator.pop(context);
                  }
                },
              );
            },
          ),




        );
    });
  }
}