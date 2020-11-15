
import 'package:bench_more/models/round.dart';
import 'package:flutter/material.dart';
import '../db/db_provider.dart';
import 'round.dart';
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

  List<Color> colors = [Colors.blue, Colors.white, Colors.white];
  List<bool> _selected = [true, false, false];

  _updateCurrentVolume(_round, subtract) async {
    setState(() {
      if (subtract) {
        if (_selected[0]) {
        _round.weight -= 5;
        } else if (_selected[1]) {
          _round.round -= 1;
        } else if(_selected[2]) {
          _round.rep -= 1;
        }
      } else {
         if (_selected[0]) {
        _round.weight += 5;
        } else if (_selected[1]) {
          _round.round += 1;
        } else if(_selected[2]) {
          _round.rep += 1;
        }
      }
      // widget.exercise.currentVolume = 0;
      // widget.exercise.round.forEach((i) {
      // widget.exercise.currentVolume += i.weight*i.round*i.rep;
      // });
    });
    // await DBProvider.db.updateRound(Round(id: _round.id, weight: _round.weight, round: _round.round, rep: _round.rep, exerciseId: widget.exercise.dayId ));
    // await DBProvider.db.updateExercise(Exercise( id: widget.exercise.id, name: widget.exercise.name, bestVolume: widget.exercise.bestVolume, previousVolume: widget.exercise.previousVolume, currentVolume: widget.exercise.currentVolume, dayId: widget.id ));
    // widget.parentUpdater();
  }



  refreshVolumes(id, value) async {
    var getPreviousExerciseVolume = await DBProvider.db.getPreviousVolume(id, value);
    if (getPreviousExerciseVolume != null) {
      previousExerciseVolume = getPreviousExerciseVolume;
      await DBProvider.db.updateExercisePreviousVolume(previousExerciseVolume, id);
    }
    var getBestExerciseVolume = await DBProvider.db.getBestVolume(id, value);
    if (getBestExerciseVolume != null) {
      bestExerciseVolume = getBestExerciseVolume;
      await DBProvider.db.updateExerciseBestVolume(bestExerciseVolume, id);
    }    
  }
  
  _updateCurrentVolumeOnRemove(exercise) async {
    exercise.currentVolume = 0;
    for (int i = 0; i < exercise.round.length - 1; i++) {   
      exercise.currentVolume += exercise.round[i].weight*exercise.round[i].round*exercise.round[i].rep;
    }
    // await DBProvider.db.updateExercise(Exercise( id: exercise.id, name: exercise.name, bestVolume: exercise.bestVolume, previousVolume: exercise.previousVolume, currentVolume: exercise.currentVolume, dayId: widget.id, weekId: widget.weekId, programId: widget.programId )); 
    // model.updateChart(Exercise(id: exercise.id, name: exercise.name, bestVolume: exercise.bestVolume, previousVolume: exercise.previousVolume, currentVolume: exercise.currentVolume, dayId: widget.id, weekId: widget.weekId, programId: widget.programId));
    setState(() {});                     
  }

  _updateCurrentVolumeOnAdd(exercise) async {
    exercise.round.add(exercise.round.last);
    exercise.currentVolume = 0;
    for (int i = 0; i < exercise.round.length; i++) {   
      exercise.currentVolume += exercise.round[i].weight*exercise.round[i].round*exercise.round[i].rep;
    }
    // await DBProvider.db.updateExercise(Exercise( id: exercise.id, name: exercise.name, bestVolume: exercise.bestVolume, previousVolume: exercise.previousVolume, currentVolume: exercise.currentVolume, dayId: widget.id, weekId: widget.weekId, programId: widget.programId )); 
    // await DBProvider.db.addRound( Round( weight: 0, round: 0, rep: 0, exerciseId: exercise.id, dayId: widget.id, weekId: widget.weekId, programId: widget.programId )); 

    setState(() {});                     
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<WeekListModel>(
      builder: (BuildContext context, Widget child, WeekListModel model) {
      var _rounds = model.rounds.where((round) => round.exerciseId == widget.id).toList();
      var _exercise = model.exercises.where((exercise) => exercise.id == widget.id).toList();
      TextEditingController _exerciseController = TextEditingController();
        return Scaffold(
          appBar: AppBar(title: Text(exerciseName)),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
            // child: Column(children: [
            //   Expanded(
            //     child: Padding(
            //       padding: EdgeInsets.only(top: 16.0),
            //       child: ListView.builder(itemBuilder: (BuildContext context, int index) {
            //         // if (index == _rounds.length) { return SizedBox(height: 56); }
            //         _exerciseController.text = widget.name;
            //         previousExerciseVolume = widget.previousVolume;
            //         bestExerciseVolume = widget.bestVolume;
            //         return Container(
            //           padding: EdgeInsets.only(top: 10.0, bottom: 5.0, left: 10.0, right: 10.0),
                      child: Column(
                        children: <Widget>[
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
                        
                        RenderRounds(widget.id, _exercise.single, parentUpdater: () => setState(() {})),

                        // Column(
                        //   children: _rounds.map((_round) => 
                        //     Container(padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                        //       child: Row(
                        //         children: <Widget>[
                        //             Expanded(
                        //               child: new SizedBox(height: 18.0, width: 24.0,
                        //                 child: new IconButton(
                        //                   padding: new EdgeInsets.all(0.0),
                        //                   icon: new Icon(Icons.remove, size: 18.0),
                        //                   onPressed: () {
                        //                     _updateCurrentVolume(_round, true);
                        //                   }
                        //                 )
                        //               ),
                        //             ),
                        //             FlatButton(color: colors[0],
                        //               onPressed: () async {
                        //                 _selected = [false, false, false];
                        //                 setState(() {
                        //                   colors = [Colors.white, Colors.white, Colors.white];
                        //                   colors[0] = Colors.blue;
                        //                   _selected[0] = true;
                        //                 });
                        //               },
                        //               child: Text(_round.weight.toString())
                        //             ),
                        //             FlatButton(color: colors[1],
                        //             onPressed: () {
                        //               _selected = [false, false, false];
                        //               setState(() {
                        //                 colors = [Colors.white, Colors.white, Colors.white];
                        //                 colors[1] = Colors.blue;
                        //                 _selected[1] = true;
                        //               });
                        //             },
                        //             child: Text(_round.round.toString())),
                        //             FlatButton(color: colors[2],
                        //               onPressed: () {
                        //                 _selected = [false, false, false];
                        //                 setState(() {
                        //                   colors = [Colors.white, Colors.white, Colors.white];
                        //                   colors[2] = Colors.blue;
                        //                   _selected[2] = true;
                        //                 });
                        //               },
                        //               child: Text(_round.rep.toString())
                        //             ),
                        //             Expanded(
                        //               child: new SizedBox(height: 18.0, width: 24.0,
                        //                 child: new IconButton(
                        //                   padding: new EdgeInsets.all(0.0),
                        //                   icon: new Icon(Icons.add, size: 18.0),
                        //                   onPressed: () {    
                        //                     _updateCurrentVolume(_round, false);
                        //                   }
                        //                 )
                        //               )
                        //             )
                        //           ]
                        //         )
                        //       )
                        //     ).toList()
                        //   ),     

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
                                          model.removeRound( Round( weight: 0, round: 0, rep: 0, exerciseId: _exercise.single.id, dayId: _exercise.single.dayId, weekId: _exercise.single.weekId, programId: _exercise.single.programId ) );
                                          // await DBProvider.db.removeRound(exercise.id);
                                          // setState(() {});
                                          // _updateCurrentVolumeOnRemove(_exercise.single);
                                          // refreshVolumes(exercise.id, exercise.name);
                                        }
                                      )
                                    ),
                                    Expanded(flex: 1,
                                      child: new IconButton(
                                        padding: new EdgeInsets.all(0.0),
                                        icon: new Icon(Icons.add_circle, size: 24.0),
                                        onPressed: () async {
                                          model.addRound( Round( weight: 0, round: 0, rep: 0, exerciseId: _exercise.single.id, dayId: _exercise.single.dayId, weekId: _exercise.single.weekId, programId: _exercise.single.programId ) );
                                          // await DBProvider.db.addRound( Round( weight: 0, round: 0, rep: 0, exerciseId: _exercise.single.id, dayId: _exercise.single.dayId, weekId: _exercise.single.weekId, programId: _exercise.single.programId )); 
                                          // setState(() {});
                                          // _updateCurrentVolumeOnAdd(_exercise.single);
                                          // refreshVolumes(exercise.id, exercise.name);
                                        },      
                                      )
                                    ),
                                  ],
                                ),
                              )
                        ] 
                      ),

              //       );
              //     }, itemCount: _rounds.length + 1,),
              //   ),
              // ),
            // ]
            // ),
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
                  // if (_exerciseController.text.isEmpty) {
                  //   final snackBar = SnackBar(
                  //     content: Text('Ummm... It seems that you are trying to add an invisible program which is not allowed in this realm.'),
                  //     backgroundColor: Colors.black,
                  //   );
                  //   Scaffold.of(context).showSnackBar(snackBar);
                  //   // _scaffoldKey.currentState.showSnackBar(snackBar);
                  // } else {
                    model.saveExercise(Exercise(
                      id: widget.id,
                      name: widget.name,
                      bestVolume: widget.bestVolume,
                      previousVolume: widget.previousVolume,
                      currentVolume: widget.currentVolume,
                      round: _exercise.single.round,
                      dayId: widget.dayId,
                      weekId: widget.weekId,
                      programId: widget.programId
                    ));
                    Navigator.pop(context);
                  // }
                },
              );
            },
          ),

        );
    });
  }
}