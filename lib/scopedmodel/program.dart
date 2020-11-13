import 'package:bench_more/home/subscriber_series.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../models/program.dart';
import '../models/week.dart';
import '../models/day.dart';
import '../models/exercise.dart';
import '../models/round.dart';

import '../db/db_provider.dart';
import '../db/default_data.dart';

import 'package:charts_flutter/flutter.dart' as charts;

class WeekListModel extends Model {
  var _db = DBProvider.db;
  List<Week> get weeks => _weeks.toList();
  List<Program> get programs => _programs.toList();
  List<Day> get days => _days.toList();
  List<Exercise> get exercises => _exercises.toList();
  List<Round> get rounds => _rounds.toList();
  int getTaskCompletionPercent(Program program) => _programCompletionPercentage[program.id];
  int getTotalTodosFrom(Program program) => weeks.where((it) => it.program == program.id).length;  
  bool get isLoading => _isLoading;

  bool _isLoading = false;
  List<Program> _programs = [];
  List<Week> _weeks = [];
  List<Day> _days = [];
  List<Exercise> _exercises = [];
  List<Round> _rounds = [];
  Map<String, int> _programCompletionPercentage =  Map();

  static WeekListModel of(BuildContext context) => ScopedModel.of<WeekListModel>(context);

  @override
  void addListener(listener) {
    super.addListener(listener);
    _isLoading = true;
    loadTodos();
    notifyListeners();
  }

  void loadTodos() async {
    var isNew = !await DBProvider.db.dbExists();
    if (isNew) {
      await _db.addPrograms(DefaultData.defaultData.programs);
      await _db.addWeeks(DefaultData.defaultData.weeks);
      await _db.addDays(DefaultData.defaultData.days);
      await _db.addExercises(DefaultData.defaultData.exercises);
      await _db.addRounds(DefaultData.defaultData.rounds);
    }
    
    _programs = await _db.getAllPrograms();
    _weeks = await _db.getAllWeeks();
    _days = await _db.getAllDaysAll();
    _exercises = await _db.getAllExercisesAll();
    _rounds = await _db.getAllRoundsAll();
    _programs.forEach((it) => _calcTaskCompletionPercent(it.id));
    _isLoading = false;
    await Future.delayed(Duration(milliseconds: 300));
    notifyListeners();
  }

  @override
  void removeListener(listener) {
    super.removeListener(listener);
    print("remove listner called");
    // DBProvider.db.closeDB();
  }

  void addProgram(Program program) {
    _programs.add(program);
    _calcTaskCompletionPercent(program.id);
    _db.addProgram(program);
    notifyListeners();
  }

  void removeProgram(Program program) {
    _db.removeProgram(program).then((_) {
      _programs.removeWhere((it) => it.id == program.id);
      _weeks.removeWhere((it) => it.program == program.id);
      notifyListeners();
    });
  }
  
  void addToChart(Exercise exercise) {
    _exercises.add(exercise);
    notifyListeners();
  }

  void updateChart(Exercise exercise) {
    print(exercise);
    var oldExercise = _exercises.firstWhere((it) => it.id == exercise.id);
    var replaceIndex = _exercises.indexOf(oldExercise);
    _exercises.replaceRange(replaceIndex, replaceIndex + 1, [exercise]);
    notifyListeners();
  }

  getChart() {
    _weeks.sort((a, b) => a.date.compareTo(b.date));
    // _weeks.forEach((element) {
    //   print(element.toJson());
    // });
    var allDays = _days.where((i) => i.weekId == _weeks.last.toJson()['id']).toList();
    // allDays.forEach((element) {
    //   print(element.toJson());
    // });
    List<SubscriberSeries> data = [];
    for (int i = 0; i < allDays.length; i++) {
      var dayExercises = _exercises.where((it) => it.dayId == allDays[i].id).toList();
      List volumes = [];
      dayExercises.forEach((day) {
        // print(day.currentVolume);
        if(day.currentVolume != 0) {
          volumes.add(day.currentVolume);
        } else {
          volumes.add(0);
        }
      });
      var sum;
      if(volumes.length > 1) {
        sum = volumes.reduce((a, b) => a + b);
      } else if (volumes.length > 0) {
        sum = volumes[0];
      } else if (volumes.length == 0) {
        sum = 0;
      }
      data.add(
        SubscriberSeries(
          year: allDays[i].dayName.substring(0, 3),
          subscribers: sum,
          barColor:charts.ColorUtil.fromDartColor(Colors.blue),
        ),
      );
    }
    return data;
  }

  void updateProgram(Program program) {
    var oldTask = _programs.firstWhere((it) => it.id == program.id);
    var replaceIndex = _programs.indexOf(oldTask);
    _programs.replaceRange(replaceIndex, replaceIndex + 1, [program]);
    _db.updateProgram(program);
    notifyListeners();
  }

  void updateDayTarget(Day day) {
    var oldDay = _days.firstWhere((it) => it.id == day.id);
    var replaceIndex = _days.indexOf(oldDay);
    _days.replaceRange(replaceIndex, replaceIndex + 1, [day]);
    _db.updateDayTarget(day);
    notifyListeners();
  }

  void addWeek(Week week) {
    _weeks.sort((a, b) => b.seq.compareTo(a.seq));
    var weeks = _weeks.where((el) => el.program == week.program).toList();
    if (weeks.length > 0) {
      Week previousWeek;
      for (int i = 0; i < 1; i++) {previousWeek = weeks[i];}
      weeks.sort((a, b) => a.seq.compareTo(b.seq));
      _weeks.add(Week(week.name, program: week.program, seq: previousWeek.seq + 1, id: week.id));      
      _db.addPreviousWeek(previousWeek.id, previousWeek.seq + 1, week );
    } else  {
      _weeks.add(week);
      _db.addWeek(week);
       notifyListeners();
    }
    _syncJob(week);
    notifyListeners();
  }

  void updateWeek(Week week) {
    var oldTodo = _weeks.lastWhere((it) => it.id == week.id);
    var replaceIndex = _weeks.indexOf(oldTodo);
    _weeks.replaceRange(replaceIndex, replaceIndex + 1, [week]);
    _syncJob(week);
    _db.updateWeek(week);
    notifyListeners();
  }

  void removeWeek(Week week) {
    _weeks.removeWhere((it) => it.id == week.id);
    _syncJob(week);
    _db.removeWeek(week);
    notifyListeners();
  }

  _syncJob(Week week) {
    _calcTaskCompletionPercent(week.program);
   // _syncTodoToDB();
  }

  void _calcTaskCompletionPercent(String taskId) {
    var weeks = this.weeks.where((it) => it.program == taskId);
    var totalTodos = weeks.length;

    if (totalTodos == 0) {
      _programCompletionPercentage[taskId] = 0;
    } else {
      var totalCompletedTodos = weeks.where((it) => it.isCompleted == 1).length;
     _programCompletionPercentage[taskId] = (totalCompletedTodos / totalTodos * 100).toInt();
    }
  }

}
