import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../models/week_model.dart';
import '../models/program_model.dart';
import '../models/day.dart';
import '../models/exercise.dart';
import '../models/round.dart';

class DBProvider {
  static Database _database;

  DBProvider._();
  static final DBProvider db = DBProvider._();


  var days = [
    Day(dayName: 'Monday', target: 'Chest & Triceps'),
    Day(dayName: 'Tuesday', target: 'Legs'),
    Day(dayName: 'Wednesday', target: 'Abs'),
    Day(dayName: 'Thursday', target: 'Back & Biceps'),
    Day(dayName: 'Friday', target: 'Shoulder'),
    Day(dayName: 'Saturday', target: 'Day Off'),
    Day(dayName: 'Sunday', target: 'Day Off'),
  ];

  var weeks = [
    Week("Week 1", seq: 1, program: '1', isCompleted: 0),
    Week("Week 1", seq: 1, program: '2', isCompleted: 0),
  ];

  var programs = [
    Program('5 Days Split', id: '1',  color: Colors.purple.value, codePoint: Icons.fitness_center.codePoint),
    Program('Pull & Push', id: '2', color: Colors.pink.value, codePoint: Icons.fitness_center.codePoint),
  ];

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await initDB();
    return _database;
  }

  get _dbPath async {
    String documentsDirectory = await _localPath;
    return p.join(documentsDirectory, "db_benchy27.db");
  }

  Future<bool> dbExists() async {
    return File(await _dbPath).exists();
  }

  initDB() async {
    String path = await _dbPath;
    return await openDatabase(path, version: 1, onOpen: (db) {

    }, onCreate: (Database db, int version) async {
      print("DBProvider:: onCreate()");
      await db.execute("CREATE TABLE Program ("
        "id TEXT PRIMARY KEY,"
        "name TEXT,"
        "color INTEGER,"
        "code_point INTEGER"
        ")");
      await db.execute("CREATE TABLE Week ("
        "id TEXT PRIMARY KEY,"
        "name TEXT,"
        "program TEXT,"
        "seq INTEGER,"
        "completed INTEGER NOT NULL DEFAULT 0"
        ")");
      await db.execute("""CREATE TABLE Day (
        id INTEGER PRIMARY KEY,
        dayName TEXT,
        target TEXT,
        weekId TEXT,
        programId TEXT,
        FOREIGN KEY (weekId) REFERENCES Week (id) ON DELETE NO ACTION ON UPDATE NO ACTION
      )""");
      await db.execute("""CREATE TABLE Exercise (
        id INTEGER PRIMARY KEY,
        name TEXT,
        bestVolume INTEGER,
        previousVolume INTEGER,
        currentVolume INTEGER,
        dayId INTEGER,
        weekId TEXT,
        programId TEXT,
        FOREIGN KEY (dayId) REFERENCES Day (id) ON DELETE NO ACTION ON UPDATE NO ACTION
      )""");
       await db.execute("""CREATE TABLE  Round (
        id INTEGER PRIMARY KEY,
        weight INTEGER,
        round INTEGER,
        rep INTEGER,
        rounds TEXT,
        exerciseId INTEGER,
        weekId TEXT,
        programId TEXT,
        FOREIGN KEY (exerciseId) REFERENCES Exercise (id) ON DELETE NO ACTION ON UPDATE NO ACTION
      )""");

    });
  }

  Future<List<Program>> getAllPrograms() async {
    final db = await database;
    var result = await db.query('Program');
    return result.map((it) => Program.fromJson(it)).toList();
  }

  Future<List<Week>> getAllWeeks() async {
    final db = await database;
    var result = await db.query('Week ORDER BY seq DESC');
    return result.map((it) => Week.fromJson(it)).toList();
  }

  Future<List<Day>> getAllDays(String weekId) async {
    final db = await database;
    var res = await db.query("Day", where: 'weekId = ?', whereArgs: [weekId]);
    List<Day> list = res.isNotEmpty ? res.map((c) => Day.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<Exercise>> getAllExercises(int dayId) async {
    final db = await database;
    var dayExercises = await db.query("Exercise", where: "dayId = ?", whereArgs: [dayId]);
    List<Exercise> fullList = List<Exercise>();
    for (int i = 0; i < dayExercises.length; i++) {
      fullList.add(Exercise.fromMap(dayExercises[i]));
      var _rounds = await db.query("Round", where: "exerciseId = ?", whereArgs: [dayExercises[i]['id']]);
      List<Round> _finalRounds = _rounds.isNotEmpty ? _rounds.map((c) => Round.fromMap(c)).toList() : [];
        fullList[i].round = _finalRounds;
    }
    return fullList;
  }

  Future<List<Round>> getAllRounds(int exerciseId) async {
    final _db = await database;
    var _res = await _db.query("Round", where: "exerciseId = ?", whereArgs: [exerciseId]);
    List<Round> _list = _res.isNotEmpty ? _res.map((c) => Round.fromMap(c)).toList() : [];
    return _list;
  }

  getPreviousVolume(int id, String name) async {
    final db = await database;
    var previousExerciseVolume = await db.rawQuery("SELECT * FROM Exercise WHERE id < ? AND name = ? ORDER BY id DESC LIMIT 1", [id, name]);
    if(previousExerciseVolume.isNotEmpty) {
      return previousExerciseVolume.first['currentVolume'];
    }
  }

  getBestVolume(int id, String name) async {
    final db = await database;
    var bestExerciseVolume = await db.rawQuery("SELECT MAX(currentVolume) as currentVolume FROM Exercise WHERE id != ? AND name = ?", [id, name]);
    if(bestExerciseVolume.isNotEmpty) {
      return bestExerciseVolume.first['currentVolume'];
    }
  }

  Future<int> addProgram(Program program) async {
    final db = await database;
    return db.insert('Program', program.toJson());
  }

  addPrograms(List<Program> programs) async {
    final db = await database;
    programs.forEach((it) async {
      var res = await db.insert("Program", it.toJson());
      print("Program ${it.id} = $res");
    });
  }

  addWeeks(List<Week> weeks) async {
    final db = await database;
    weeks.forEach((week) async {
      var res = await db.insert("Week", week.toJson());
      print("Week ${week.id} = $res");
    });
  }

  addWeek(Week week) async {
    final db = await database;
    days.forEach((day) async { 
      await db.insert("Day", Day(dayName: day.dayName, target: day.target, weekId: week.id, programId: week.program).toMap());
    });
    return await db.rawInsert("INSERT Into Week (id, program, seq, name, completed)" " VALUES (?,?,?,?,?)", [week.id, week.program, week.seq, week.name, week.isCompleted]);
  }

  Future<int> addPreviousWeek(previousWeekId, previousSeq, Week week) async {
    final _db = await database;
    var _newDayId = await _db.rawQuery("SELECT MAX(id)+1 as id FROM Day");
    var _newExerciseId = await _db.rawQuery("SELECT MAX(id)+1 as id FROM Exercise");
  
    var _oldDays = await _db.query("Day", where: "weekId = ?", whereArgs: [previousWeekId]);
    var _oldExercises = await _db.query("Exercise", where: "weekId = ?", whereArgs: [previousWeekId]);
    var _oldRounds = await _db.query("Round", where: "weekId = ?", whereArgs: [previousWeekId]);

    int incrementDay = _newDayId.first['id'];
    int incrementExercise = _newExerciseId.first['id'];

    if (_oldDays.isNotEmpty) {
      _oldDays.asMap().forEach((index, element) async {
        await _db.insert("Day", Day(dayName: element['dayName'], target: element['target'], weekId: week.id, programId: element['programId']).toMap()); 
        if (_oldExercises.isNotEmpty) {
          _oldExercises.asMap().forEach((index2, element2) {
            if (element['id'] == element2['dayId']) {
              _db.insert("Exercise", {
                'name': element2['name'],
                'bestVolume': element2['bestVolume'],
                'previousVolume': element2['previousVolume'],
                'currentVolume': element2['currentVolume'],
                'dayId': incrementDay,
                'weekId': week.id,
                'programId': element['programId']
              });
              if (_oldRounds.isNotEmpty) {
                _oldRounds.asMap().forEach((index3, element3) {
                  if (element2['id'] == element3['exerciseId']) {     
                    _db.insert("Round", {
                      'weight': element3['weight'], 
                      'round': element3['round'], 
                      'rep': element3['rep'],
                      'exerciseId': incrementExercise, 
                      'weekId':  week.id,
                      'programId': element['programId']
                    });
                  }
                });
              }
              incrementExercise++;
            }
          });
        }
        incrementDay++;
      });
    }
    return await _db.rawInsert("INSERT Into Week (id, program, seq, name, completed)" " VALUES (?,?,?,?,?)", [week.id, week.program, previousSeq, week.name, week.isCompleted ]);
  }

  addDay(Day day) async {
    final _db = await database;
    var _table = await _db.rawQuery("SELECT MAX(id)+1 as id FROM Day");
    return await _db.rawInsert("INSERT Into Day (id, dayName, target, weekId, programId)" " VALUES (?,?,?,?,?)", [_table.first["id"], day.dayName, day.target, day.weekId, day.programId ]);
  }

  addExercise(Exercise newExercise) async {
    final _db = await database;
    var _table = await _db.rawQuery("SELECT MAX(id)+1 as id FROM Exercise");
    int _id = _table.first["id"];
    return await _db.rawInsert("INSERT Into Exercise (id, name, bestVolume, previousVolume, currentVolume, dayId, weekId, programId)" " VALUES (?,?,?,?,?,?,?,?)", [_id, newExercise.name, newExercise.bestVolume, newExercise.previousVolume, newExercise.currentVolume, newExercise.dayId, newExercise.weekId, newExercise.programId]);
  }

  addRound(Round round) async {
    final _db = await database;
    var _lastRow = await _db.query("Round", where: "exerciseId = ?", whereArgs: [round.exerciseId]);
    var _table = await _db.rawQuery("SELECT MAX(id)+1 as id FROM Round");
    if(_lastRow.isNotEmpty) {
      return await _db.rawInsert("INSERT Into Round (id, weight, round, rep, exerciseId, weekId, programId)" " VALUES (?,?,?,?,?,?,?)", [_table.first["id"], _lastRow.last['weight'],  _lastRow.last['round'],  _lastRow.last['rep'], round.exerciseId, round.weekId, round.programId]);
    } else {
      return await _db.rawInsert("INSERT Into Round (id, weight, round, rep, exerciseId, weekId, programId)" " VALUES (?,?,?,?,?,?,?)", [_table.first["id"], round.weight, round.round, round.rep, round.exerciseId, round.weekId, round.programId]);
    }
  }

  Future<int> updateProgram(Program program) async {
    final db = await database;
    return db.update('Program', program.toJson(), where: 'id = ?', whereArgs: [program.id]);
  }

  Future<int> updateWeek(Week week) async {
    final db = await database;
    return db.update('Week', week.toJson(), where: 'id = ?', whereArgs: [week.id]);
  }

  updateExercise(Exercise newExercise) async {
    final _db = await database;
    return await _db.rawUpdate('''UPDATE Exercise SET name = ?, bestVolume = ?, previousVolume = ?, currentVolume = ? WHERE id = ?''', [newExercise.name, newExercise.bestVolume, newExercise.previousVolume, newExercise.currentVolume, newExercise.id]);
  }

  updateRound(Round newRound) async {
    final _db = await database;
    return await _db.rawUpdate('''UPDATE Round SET weight = ?, round = ?, rep = ? WHERE id = ?''', [newRound.weight, newRound.round, newRound.rep, newRound.id]);
  }

  updateDayTarget(Day day) async {
    final _db = await database;
    return await _db.rawUpdate('''UPDATE Day SET target = ? WHERE id = ?''', [day.target, day.id]);
  }

   updateExerciseName(Exercise exerercise) async {
    final db = await database;
    return await db.rawUpdate('''UPDATE Exercise SET name = ? WHERE id = ?''', [exerercise.name, exerercise.id]);
  }

  updateExerciseBestVolume(bestVolume, id) async {
    final db = await database;
    return await db.rawUpdate('''UPDATE Exercise SET bestVolume = ? WHERE id = ?''', [bestVolume, id]);
  }

  updateExercisePreviousVolume(previousVolume, id) async {
    final db = await database;
    return await db.rawUpdate('''UPDATE Exercise SET previousVolume = ? WHERE id = ?''', [previousVolume, id]);
  }

  Future<void> removeProgram(Program program) async {
    final db = await database;
    return db.transaction<void>((txn) async {
      await txn.delete('Round', where: 'programId = ?', whereArgs: [program.id]);
      await txn.delete('Exercise', where: 'programId = ?', whereArgs: [program.id]);
      await txn.delete('Day', where: 'programId = ?', whereArgs: [program.id]);
      await txn.delete('Week', where: 'program = ?', whereArgs: [program.id]);
      await txn.delete('Program', where: 'id = ?', whereArgs: [program.id]);
    });
  }

  Future<void> removeWeek(Week week) async {
    final db = await database;
    return db.transaction<void>((txn) async {
      await txn.delete('Round', where: 'weekId = ?', whereArgs: [week.id]);
      await txn.delete('Exercise', where: 'weekId = ?', whereArgs: [week.id]);
      await txn.delete('Day', where: 'weekId = ?', whereArgs: [week.id]);
      await txn.delete('Week', where: 'id = ?', whereArgs: [week.id]);
    });
  }

  Future<void> removeDay(int id) async {
    final db = await database;
    return db.delete("Day", where: "id = ?", whereArgs: [id]);
  }

  Future<void> removeExercise(int id) async {
    final db = await database;
    return db.delete("Exercise", where: "id = ?", whereArgs: [id]);
  }

  Future<void> removeRound(int exerciseId) async {
    final _db = await database;
    var _table = await _db.query("Round", where: "exerciseId = ?", whereArgs: [exerciseId]);
    return _db.delete("Round", where: "id = ?", whereArgs: [_table.last["id"]]);
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  closeDB() {
    if (_database != null) {
      _database.close();
    }
  }

}