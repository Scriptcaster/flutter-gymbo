import 'package:bench_more/home/subscriber_series.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../models/week.dart';
import '../models/program.dart';
import '../models/day.dart';
import '../models/exercise.dart';
import '../models/round.dart';

import 'default_data.dart';

import 'package:charts_flutter/flutter.dart' as charts;

class DBProvider {
  static Database _database;

  DBProvider._();
  static final DBProvider db = DBProvider._();

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await initDB();
    return _database;
  }

  get _dbPath async {
    String documentsDirectory = await _localPath;
    return p.join(documentsDirectory, "db_benchy80.db");
  }

  Future<bool> dbExists() async {
    return File(await _dbPath).exists();
  }

  initDB() async {
    String path = await _dbPath;
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE Program ("
          "id TEXT PRIMARY KEY,"
          "name TEXT,"
          "color INTEGER,"
          "code_point INTEGER"
          ")");
      await db.execute("""CREATE TABLE Week (
        id TEXT PRIMARY KEY,
        name TEXT,
        program TEXT,
        seq INTEGER,
        completed INTEGER NOT NULL DEFAULT 0,
        date INTEGER DEFAULT (cast(strftime('%s','now') as int))
        )""");
      await db.execute("""CREATE TABLE Day (
        id INTEGER PRIMARY KEY,
        dayName TEXT,
        target TEXT,
        isCompleted INTEGER NOT NULL DEFAULT 0,
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
        round TEXT,
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
        dayId INTEGER,
        exerciseId INTEGER,
        weekId TEXT,
        programId TEXT,
        FOREIGN KEY (exerciseId) REFERENCES Exercise (id) ON DELETE NO ACTION ON UPDATE NO ACTION
      )""");
    });
  }

  addPrograms(List<Program> programs) async {
    final db = await database;
    programs.forEach((it) async { var res = await db.insert("Program", it.toJson()); });
  }

  addWeeks(List<Week> weeks) async {
    // print(weeks.asMap());
    final db = await database;
    weeks.forEach((week) async { var res = await db.insert("Week", week.toJson()); });
  }

  addDays(List<Day> days) async {
    final db = await database;
    days.forEach((day) async { var res = await db.insert("Day", day.toMap()); });
  }

  addExercises(List<Exercise> exercises) async {
    final db = await database;
    exercises.forEach((exercise) async { var res = await db.insert("Exercise", exercise.toMap()); });
  }

  addRounds(List<Round> rounds) async {
    final db = await database;
    rounds.forEach((round) async { var res = await db.insert("Round", round.toMap()); });
  }

  Future<int> addProgram(Program program) async {
    final db = await database;
    return db.insert('Program', program.toJson());
  }

  Future<int> addWeek(Week week) async {
    final db = await database;
    DefaultData.defaultData.days.forEach((day) async {
      await db.insert("Day", Day(
        dayName: day.dayName,
        target: day.target,
        weekId: week.id,
        programId: week.program
      ).toMap());
    });
    return await db.rawInsert("INSERT Into Week (id, program, seq, name, completed, date)"" VALUES (?,?,?,?,?,?)", [
      week.id,
      week.program,
      week.seq,
      week.name,
      week.isCompleted,
      week.date
    ]);
  }

  Future<int> addDay(Day day) async {
    final _db = await database;
    var _table = await _db.rawQuery("SELECT MAX(id)+1 as id FROM Day");
    return await _db.rawInsert("INSERT Into Day (id, dayName, target, completed, weekId, programId)"" VALUES (?,?,?,?,?,?)", [
      _table.first["id"],
      day.dayName,
      day.target,
      day.isCompleted,
      day.weekId,
      day.programId
    ]);
  }

  Future<int> addExercise(Exercise newExercise) async {
    final _db = await database;
    var _table = await _db.rawQuery("SELECT MAX(id)+1 as id FROM Exercise");
    int _id = _table.first["id"];
    return await _db.rawInsert("INSERT Into Exercise (id, name, bestVolume, previousVolume, currentVolume, dayId, weekId, programId)"" VALUES (?,?,?,?,?,?,?,?)", [
      _id,
      newExercise.name,
      newExercise.bestVolume,
      newExercise.previousVolume,
      newExercise.currentVolume,
      newExercise.dayId,
      newExercise.weekId,
      newExercise.programId
    ]);
  }

  Future<int> addRound(Round round) async {
    final _db = await database;
    var _lastRow = await _db.query("Round", where: "exerciseId = ?", whereArgs: [round.exerciseId]);
    var _table = await _db.rawQuery("SELECT MAX(id)+1 as id FROM Round");
    if (_lastRow.isNotEmpty) {
      return await _db.rawInsert("INSERT Into Round (id, weight, round, rep, exerciseId,  dayId, weekId, programId)"" VALUES (?,?,?,?,?,?,?,?)", [
        _table.first["id"],
        _lastRow.last['weight'],
        _lastRow.last['round'],
        _lastRow.last['rep'],
        round.exerciseId,
        round.dayId,
        round.weekId,
        round.programId
      ]);
    } else {
      return await _db.rawInsert("INSERT Into Round (id, weight, round, rep, exerciseId, dayId, weekId, programId)"" VALUES (?,?,?,?,?,?,?,?)", [
        _table.first["id"],
        round.weight,
        round.round,
        round.rep,
        round.exerciseId,
        round.dayId,
        round.weekId,
        round.programId
      ]);
    }
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

  Future<List<Day>> getAllDaysAll() async {
    final db = await database;
    var result = await db.query('Day');
    return result.map((it) => Day.fromJson(it)).toList();
  }

   Future<List<Exercise>> getAllExercisesAll() async {
    final db = await database;
    var result = await db.query('Exercise');
    return result.map((it) => Exercise.fromJson(it)).toList();
  }














  Future<List<SubscriberSeries>> getChartData() async {
    final db = await database;
    var currentWeek = await db.query('Week ORDER BY date DESC LIMIT 1');
    List fullListDaysIds = [];
    for (int i = 0; i < currentWeek.length; i++) {
      var _allDays = await db.query("Day", where: "weekId = ?", whereArgs: [currentWeek[i]['id']]);
      for (int k = 0; k < _allDays.length; k++) {
        fullListDaysIds.add(_allDays[k]);
      }
    }
    List<SubscriberSeries> data = [];
    List dayExercises = [];
    for (int i = 0; i < 7; i++) {
      var dayExercises = await db.query("Exercise", where: "dayId = ?", whereArgs: [fullListDaysIds[i]['id']]);
      List volumes = [];
      dayExercises.toList().forEach((day) {
        volumes.add(day['currentVolume']);
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
            year: fullListDaysIds[i]['dayName'].substring(0, 3),
            subscribers: sum,
            barColor:charts.ColorUtil.fromDartColor(Colors.blue),
          ),
        );
    }
    // return resultWeeks.map((it) => Week.fromJson(it)).toList();
    return data;
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
    // print(dayExercises);
    var previousDays = await db.rawQuery( "SELECT * FROM Exercise WHERE dayId != ? ORDER BY id DESC", [dayId]);
    // previousDays.toList().forEach((element) {
    dayExercises.toList().forEach((element2) {
      previousDays.toList().forEach((element) {
        if (element['name'] == element2['name']) {
          // print(element['currentVolume']);
        }
      });
    });
    // });
    List<Exercise> fullList = List<Exercise>();
    for (int i = 0; i < dayExercises.length; i++) {
      fullList.add(Exercise.fromMap(dayExercises[i]));
      var _rounds = await db.query("Round", where: "exerciseId = ?", whereArgs: [dayExercises[i]['id']]);
      List<Round> _finalRounds = _rounds.isNotEmpty ? _rounds.map((c) => Round.fromMap(c)).toList() : [];
      var previousExerciseVolume = await db.rawQuery( "SELECT * FROM Exercise WHERE id < ? AND name = ? ORDER BY id DESC", [dayExercises[i]['id'], dayExercises[i]['name']]);
      if (previousExerciseVolume.length > 0) {
        for (int e = 0; e < 1; e++) {
          fullList[i].previousVolume = previousExerciseVolume[e]['currentVolume'];
        }
      }
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

  Future<List<Round>> getAllRoundsAll() async {
    final _db = await database;
    var _res = await _db.query("Round");
    // var _res = await _db.query("Round",
    //     where: "date BETWEEN '2020-11-09' AND '2014-10-11'");
    // var _res = await _db.rawQuery(
    //     "SELECT * FROM Week WHERE date BETWEEN '2020-11-06' AND '2014-11-06'");
    List<Round> _list = _res.isNotEmpty ? _res.map((c) => Round.fromMap(c)).toList() : [];
    return _list;
  }

  getPreviousVolume(int id, String name) async {
    final db = await database;
    var previousExerciseVolume = await db.rawQuery("SELECT * FROM Exercise WHERE id < ? AND name = ? ORDER BY id DESC LIMIT 1", [id, name]);
    if (previousExerciseVolume.isNotEmpty) { return previousExerciseVolume.first['currentVolume']; }
  }

  getBestVolume(int id, String name) async {
    final db = await database;
    var bestExerciseVolume = await db.rawQuery("SELECT MAX(currentVolume) as currentVolume FROM Exercise WHERE id != ? AND name = ?", [id, name]);
    if (bestExerciseVolume.isNotEmpty) { return bestExerciseVolume.first['currentVolume']; }
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
        await _db.insert("Day",
          Day(
              dayName: element['dayName'],
              target: element['target'],
              weekId: week.id,
              programId: element['programId']
          ).toMap());
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
                      'dayId': incrementDay,
                      'exerciseId': incrementExercise,
                      'weekId': week.id,
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
    return await _db.rawInsert("INSERT Into Week (id, program, seq, name, completed, date)"" VALUES (?,?,?,?,?,?)",
        [
          week.id,
          week.program,
          previousSeq,
          week.name,
          week.isCompleted,
          week.date
        ]);
  }

  Future<int> updateProgram(Program program) async {
    final db = await database;
    return db.update('Program', program.toJson(), where: 'id = ?', whereArgs: [program.id]);
  }

  Future<int> updateWeek(Week week) async {
    final db = await database;
    return db.update('Week', week.toJson(), where: 'id = ?', whereArgs: [week.id]);
  }

  Future<int> updateDayTarget(Day day) async {
    final _db = await database;
    return await _db.rawUpdate('''UPDATE Day SET target = ? WHERE id = ?''', [day.target, day.id]);
  }

  Future<int> updateDay(Day day) async {
    final db = await database;
    return db.update('Day', day.toMap(), where: 'id = ?', whereArgs: [day.id]);
  }

  Future<int> updateExercise(Exercise newExercise) async {
    final _db = await database;
    return await _db.rawUpdate(
        '''UPDATE Exercise SET name = ?, bestVolume = ?, previousVolume = ?, currentVolume = ? WHERE id = ?''',
        [
          newExercise.name,
          newExercise.bestVolume,
          newExercise.previousVolume,
          newExercise.currentVolume,
          newExercise.id
        ]);
  }

  Future<int> updateRound(Round newRound) async {
    final _db = await database;
    return await _db.rawUpdate(
        '''UPDATE Round SET weight = ?, round = ?, rep = ? WHERE id = ?''',
        [newRound.weight, newRound.round, newRound.rep, newRound.id]);
  }

  updateExerciseName(Exercise exerercise) async {
    final db = await database;
    return await db.rawUpdate('''UPDATE Exercise SET name = ? WHERE id = ?''',
        [exerercise.name, exerercise.id]);
  }

  updateExerciseBestVolume(bestVolume, id) async {
    final db = await database;
    return await db.rawUpdate('''UPDATE Exercise SET bestVolume = ? WHERE id = ?''', [bestVolume, id]);
  }

  updateExercisePreviousVolume(previousVolume, id) async {
    final db = await database;
    return await db.rawUpdate(
        '''UPDATE Exercise SET previousVolume = ? WHERE id = ?''',
        [previousVolume, id]);
  }

  Future<void> removeProgram(Program program) async {
    final db = await database;
    return db.transaction<void>((txn) async {
      await txn
          .delete('Round', where: 'programId = ?', whereArgs: [program.id]);
      await txn
          .delete('Exercise', where: 'programId = ?', whereArgs: [program.id]);
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

  Future<void> removeDay(Day day) async {
    final db = await database;
    return db.transaction<void>((txn) async {
      await txn.delete('Round', where: 'dayId = ?', whereArgs: [day.id]);
      await txn.delete('Exercise', where: 'dayId = ?', whereArgs: [day.id]);
      await txn.delete('Day', where: 'id = ?', whereArgs: [day.id]);
    });
  }

  Future<void> removeExercise(Exercise exercise) async {
    final db = await database;
    return db.transaction<void>((txn) async {
      await txn
          .delete('Round', where: 'exerciseId = ?', whereArgs: [exercise.id]);
      await txn.delete('Exercise', where: 'id = ?', whereArgs: [exercise.id]);
    });
  }

  Future<void> removeRound(int exerciseId) async {
    final _db = await database;
    var _table = await _db
        .query("Round", where: "exerciseId = ?", whereArgs: [exerciseId]);
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
