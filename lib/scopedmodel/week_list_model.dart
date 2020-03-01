// import 'dart:convert';
// import 'dart:io';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

// import 'package:objectdb/objectdb.dart';

import '../models/week_model.dart';
import '../models/program_model.dart';
import '../db/db_provider.dart';

class WeekListModel extends Model {
  var _db = DBProvider.db;
  List<Week> get weeks => _weeks.toList();
  List<Program> get programs => _programs.toList();
  int getTaskCompletionPercent(Program program) => _programCompletionPercentage[program.id];
  int getTotalTodosFrom(Program program) => weeks.where((it) => it.program == program.id).length;  
  bool get isLoading => _isLoading;

  bool _isLoading = false;
  List<Program> _programs = [];
  List<Week> _weeks = [];
  Map<String, int> _programCompletionPercentage =  Map();

  static WeekListModel of(BuildContext context) => ScopedModel.of<WeekListModel>(context);

  @override
  void addListener(listener) {
    super.addListener(listener);
    // update data for every subscriber, especially for the first one
    _isLoading = true;
    loadTodos();
    notifyListeners();
  }

  void loadTodos() async {
    var isNew = !await DBProvider.db.dbExists();
    if (isNew) {
      await _db.addPrograms(_db.programs);
      // await _db.addWeeks(_db.weeks);
    }
    
    _programs = await _db.getAllPrograms();
    _weeks = await _db.getAllWeeks();
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

  void updateProgram(Program program) {
    var oldTask = _programs.firstWhere((it) => it.id == program.id);
    var replaceIndex = _programs.indexOf(oldTask);
    _programs.replaceRange(replaceIndex, replaceIndex + 1, [program]);
    _db.updateProgram(program);
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
