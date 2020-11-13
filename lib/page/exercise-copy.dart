import 'package:bench_more/scopedmodel/program.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import '../db/db_provider.dart';
import '../models/exercise.dart';
import '../models/round.dart';
import 'round.dart';

class RenderExercises extends StatefulWidget {
  final Object id;
  final Object weekId;
  final Object programId;
  RenderExercises(this.id, this.weekId, this.programId);
  @override
  _RenderExercisesState createState() => _RenderExercisesState();
}
class _RenderExercisesState extends State<RenderExercises> { _RenderExercisesState();
  var previousExerciseVolume  = 0;
  int bestExerciseVolume = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => afterLayoutWidgetBuild());
  }

  afterLayoutWidgetBuild() {}

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
    await DBProvider.db.updateExercise(Exercise( id: exercise.id, name: exercise.name, bestVolume: exercise.bestVolume, previousVolume: exercise.previousVolume, currentVolume: exercise.currentVolume, dayId: widget.id, weekId: widget.weekId, programId: widget.programId )); 
    // model.updateChart(Exercise(id: exercise.id, name: exercise.name, bestVolume: exercise.bestVolume, previousVolume: exercise.previousVolume, currentVolume: exercise.currentVolume, dayId: widget.id, weekId: widget.weekId, programId: widget.programId));
    setState(() {});                     
  }

  _updateCurrentVolumeOnAdd(exercise) async {
    exercise.round.add(exercise.round.last);
    exercise.currentVolume = 0;
    for (int i = 0; i < exercise.round.length; i++) {   
      exercise.currentVolume += exercise.round[i].weight*exercise.round[i].round*exercise.round[i].rep;
    }
    await DBProvider.db.updateExercise(Exercise( id: exercise.id, name: exercise.name, bestVolume: exercise.bestVolume, previousVolume: exercise.previousVolume, currentVolume: exercise.currentVolume, dayId: widget.id, weekId: widget.weekId, programId: widget.programId )); 
    setState(() {});                     
  }



  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<WeekListModel>(builder: (BuildContext context, Widget child, WeekListModel model) {
      return WillPopScope(
        onWillPop: () {
          print('print');
          // model.updateChart(Day(id: widget.id, target: _targetController.text));
          Navigator.pop(context, 'pop');
          return Future.value(false);
        },


      child: Expanded(
      child: FutureBuilder<List<Exercise>>(
        future: DBProvider.db.getAllExercises(widget.id),
        builder: (BuildContext context, AsyncSnapshot<List<Exercise>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(itemCount: snapshot.data.length, itemBuilder: (BuildContext context, int index) {
              Exercise exercise = snapshot.data[index];
              TextEditingController _exerciseController = TextEditingController();
              _exerciseController.text = exercise.name;
              previousExerciseVolume = exercise.previousVolume;
              bestExerciseVolume = exercise.bestVolume;
              return new Container(
                padding: EdgeInsets.only(top: 10.0, bottom: 5.0, left: 10.0, right: 10.0),
                child: Column(
                  children: <Widget>[
                    Container(padding: EdgeInsets.only(top: 0.0, bottom: 0.0, left: 40.0, right: 40.0),
                      child: Column(
                        children: <Widget>[
                          TextField(style: new TextStyle(fontSize: 20.0, color: Colors.blue),
                            keyboardType: TextInputType.text,
                            controller: _exerciseController,
                            onSubmitted: (value) async {
                              if (value.isNotEmpty) { 
                                await DBProvider.db.updateExerciseName(Exercise(id: exercise.id, name: value));
                                model.addToChart(Exercise(id: exercise.id, name: exercise.name, bestVolume: exercise.bestVolume, previousVolume: exercise.previousVolume, currentVolume: exercise.currentVolume, dayId: widget.id, weekId: widget.weekId, programId: widget.programId));
                              }
                              refreshVolumes(exercise.id, value);
                              setState(() {});
                            }
                          )
                        ]
                      )
                    ),
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
                            child: Text(exercise.currentVolume.toString(), textAlign: TextAlign.center, style: TextStyle(fontSize: 16))
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
                    RenderRounds(widget.id, exercise, parentUpdater: () => setState(() {})),
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
                                DBProvider.db.removeExercise(exercise); setState(() {});
                                // refreshVolumes(exercise.id, exercise.name);
                              }
                            )
                          ),
                          Expanded(flex: 1,
                            child: new IconButton(
                              padding: new EdgeInsets.all(0.0),
                              icon: new Icon(Icons.remove_circle, size: 24.0),
                              onPressed: () async { 
                                await DBProvider.db.removeRound(exercise.id);
                                setState(() {});
                                _updateCurrentVolumeOnRemove(exercise);
                                // refreshVolumes(exercise.id, exercise.name);
                              }
                            )
                          ),
                          Expanded(flex: 1,
                            child: new IconButton(
                              padding: new EdgeInsets.all(0.0),
                              icon: new Icon(Icons.add_circle, size: 24.0),
                              onPressed: () async {
                                await DBProvider.db.addRound( Round( weight: 0, round: 0, rep: 0, exerciseId: exercise.id, dayId: widget.id, weekId: widget.weekId, programId: widget.programId )); 
                                setState(() {});
                                _updateCurrentVolumeOnAdd(exercise);
                                // refreshVolumes(exercise.id, exercise.name);
                              },      
                            )
                          ),
                        ],
                      ),
                    )
                  ]
                )  
              );
            });
          } else {
            return Center(child: CircularProgressIndicator());
          }
        }
      )
    ),
  

       



      );
    });
  }



    
























}


  // void afterBuild() {
  //   print('build');
  // }  
// }