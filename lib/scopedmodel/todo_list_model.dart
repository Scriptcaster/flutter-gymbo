// import 'dart:convert';
// import 'dart:io';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

// import 'package:objectdb/objectdb.dart';

import '../models/week_model.dart';
import '../models/program_model.dart';
import '../db/db_provider.dart';

class TodoListModel extends Model {
  // ObjectDB db;
  var _db = DBProvider.db;
  List<Week> get todos => _todos.toList();
  List<Program> get tasks => _tasks.toList();
  int getTaskCompletionPercent(Program program) => _taskCompletionPercentage[program.id];
  int getTotalTodosFrom(Program program) => todos.where((it) => it.parent == program.id).length;
  bool get isLoading => _isLoading;

  bool _isLoading = false;
  List<Program> _tasks = [];
  List<Week> _todos = [];
  Map<String, int> _taskCompletionPercentage =  Map();

  static TodoListModel of(BuildContext context) =>
      ScopedModel.of<TodoListModel>(context);

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
      await _db.insertBulkTask(_db.tasks);
      await _db.insertBulkWeek(_db.weeks);
      // await _db.insertBulkDay(_db.days);
    }

    _tasks = await _db.getAllTask();
    _todos = await _db.getAllTodo();
    _tasks.forEach((it) => _calcTaskCompletionPercent(it.id));
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

  void addTask(Program program) {
    _tasks.add(program);
    _calcTaskCompletionPercent(program.id);
    _db.insertTask(program);
    notifyListeners();
  }

  void removeProgram(Program program) {
    _db.removeProgram(program).then((_) {
      _tasks.removeWhere((it) => it.id == program.id);
      _todos.removeWhere((it) => it.parent == program.id);
      notifyListeners();
    });
  }

  void updateTask(Program program) {
    var oldTask = _tasks.firstWhere((it) => it.id == program.id);
    var replaceIndex = _tasks.indexOf(oldTask);
    _tasks.replaceRange(replaceIndex, replaceIndex + 1, [program]);
    _db.updateTask(program);
    notifyListeners();
  }

  void removeTodo(Week week) {
    _todos.removeWhere((it) => it.id == week.id);
    _syncJob(week);
    _db.removeTodo(week);
    notifyListeners();
  }

  void addWeek(Week week) {
    _todos.add(week);
    _syncJob(week);
    _db.insertWeek(week);
    notifyListeners();
  }

  void updateTodo(Week week) {
    var oldTodo = _todos.firstWhere((it) => it.id == week.id);
    var replaceIndex = _todos.indexOf(oldTodo);
    _todos.replaceRange(replaceIndex, replaceIndex + 1, [week]);

    _syncJob(week);
    _db.updateTodo(week);

    notifyListeners();
  }

  _syncJob(Week week) {
    _calcTaskCompletionPercent(week.parent);
   // _syncTodoToDB();
  }

  void _calcTaskCompletionPercent(String taskId) {
    var todos = this.todos.where((it) => it.parent == taskId);
    var totalTodos = todos.length;

    if (totalTodos == 0) {
      _taskCompletionPercentage[taskId] = 0;
    } else {
      var totalCompletedTodos = todos.where((it) => it.isCompleted == 1).length;
     _taskCompletionPercentage[taskId] = (totalCompletedTodos / totalTodos * 100).toInt();
    }
    // return todos.fold(0, (total, week) => week.isCompleted ? total + scoreOfTask : total);
  }

  // Future<int> _syncTodoToDB() async {
  //   return await db.update({'user': 'guest'}, {'todos': _todos});
  // }
}
