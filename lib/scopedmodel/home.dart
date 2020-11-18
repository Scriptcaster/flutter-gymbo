import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../models/week.dart';
import '../models/program.dart';
import '../db/db_provider.dart';
import '../db/default_data.dart';

class HomeModel extends Model {
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

  static HomeModel of(BuildContext context) => ScopedModel.of<HomeModel>(context);

  @override
  void addListener(listener) {
    super.addListener(listener);
    _isLoading = true;
    // loadTodos();
    notifyListeners();
  }


  @override
  void removeListener(listener) {
    super.removeListener(listener);
    // print("remove listner called");
    // DBProvider.db.closeDB();
  }

  void updateChart() {
    // print('update chart');
    // var oldTask = _programs.firstWhere((it) => it.id == program.id);
    // var replaceIndex = _programs.indexOf(oldTask);
    // _programs.replaceRange(replaceIndex, replaceIndex + 1, [program]);
    // _db.updateProgram(program);
    // notifyListeners();
  }
 
}
