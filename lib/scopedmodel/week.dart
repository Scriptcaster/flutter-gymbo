import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../db/db_provider.dart';
import '../db/default_data.dart';

import '../models/week.dart';
import '../models/day.dart';

class WeekListModel extends Model {
  var _db = DBProvider.db;

  bool _isLoading = false;
  List<Day> _days = [];
  Map<String, int> _programCompletionPercentage =  Map();

  List<Day> get days => _days.toList();
  bool get isLoading => _isLoading;

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
    _days = await _db.getAllDays();
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
