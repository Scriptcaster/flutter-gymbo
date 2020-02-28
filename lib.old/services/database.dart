import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/week.dart';
import '../models/day.dart';
import '../models/exercise.dart';
import '../models/round.dart';

class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();
  Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await initDB();
    return _database;
  }
  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "new42.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},
    onCreate: (Database db, int version) async {
      await db.execute("""
      CREATE TABLE Week ( id INTEGER PRIMARY KEY, name TEXT )""");
      await db.execute("""
      CREATE TABLE Day (
        id INTEGER PRIMARY KEY,
        dayName TEXT,
        target TEXT,
        weekId INTEGER,
        FOREIGN KEY (weekId) REFERENCES Week (id) ON DELETE NO ACTION ON UPDATE NO ACTION
      )""");
      await db.execute("""
      CREATE TABLE Exercise (
        id INTEGER PRIMARY KEY,
        name TEXT,
        bestVolume INTEGER,
        previousVolume INTEGER,
        currentVolume INTEGER,
        dayId INTEGER,
        weekId INTEGER,
        FOREIGN KEY (dayId) REFERENCES Day (id) ON DELETE NO ACTION ON UPDATE NO ACTION
      )""");
       await db.execute("""
      CREATE TABLE  Round (
        id INTEGER PRIMARY KEY,
        weight INTEGER,
        round INTEGER,
        rep INTEGER,
        rounds TEXT,
        exerciseId INTEGER,
        weekId INTEGER,
        FOREIGN KEY (exerciseId) REFERENCES Exercise (id) ON DELETE NO ACTION ON UPDATE NO ACTION
      )""");
    });
  }
  newWeek(Week week) async {
    final _db = await database;
    
    var _oldWeekId = await _db.rawQuery("SELECT MAX(id) as id FROM Week");
    var _newWeekId = await _db.rawQuery("SELECT MAX(id)+1 as id FROM Week");
    var _newDayId = await _db.rawQuery("SELECT MAX(id)+1 as id FROM Day");
    var _newExerciseId = await _db.rawQuery("SELECT MAX(id)+1 as id FROM Exercise");
  
    var _oldDays = await _db.query("Day", where: "weekId = ?", whereArgs: [_oldWeekId.last['id']]);
    var _oldExercises = await _db.query("Exercise", where: "weekId = ?", whereArgs: [_oldWeekId.last['id']]);
    var _oldRounds = await _db.query("Round", where: "weekId = ?", whereArgs: [_oldWeekId.last['id']]);

    int incrementDay = _newDayId.first['id'];
    int incrementExercise = _newExerciseId.first['id'];

    _db.rawInsert("INSERT Into Week (id, name)" " VALUES (?,?)", [_newWeekId.first["id"], week.name]);
    if (_oldDays.isNotEmpty) {
      _oldDays.asMap().forEach((index, element) {
        _db.insert("Day", Day(dayName: element['dayName'], target: element['target'], weekId: _newWeekId.last['id']).toMap());
        if (_oldExercises.isNotEmpty) {
          _oldExercises.asMap().forEach((index2, element2) {
            if (element['id'] == element2['dayId']) {
              _db.insert("Exercise", {
                'name': element2['name'],
                'bestVolume': element2['bestVolume'],
                'previousVolume': element2['previousVolume'],
                'currentVolume': element2['currentVolume'],
                'dayId': incrementDay,
                'weekId': _newWeekId.last['id'] 
              });
              if (_oldRounds.isNotEmpty) {
                _oldRounds.asMap().forEach((index3, element3) {
                  if (element2['id'] == element3['exerciseId']) {
                    _db.insert("Round", {
                      'weight': element3['weight'], 
                      'round': element3['round'], 
                      'rep': element3['rep'],
                      'exerciseId': incrementExercise, 
                      'weekId': _newWeekId.last['id']
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
  }
  newDay(Day day) async {
    final _db = await database;
    var _table = await _db.rawQuery("SELECT MAX(id)+1 as id FROM Day");
    return await _db.rawInsert("INSERT Into Day (id, dayName, target, weekId)" " VALUES (?,?,?,?)", [_table.first["id"], day.dayName, day.target, day.weekId ]);
  }
  newExercise(Exercise newExercise) async {
    final _db = await database;
    var _table = await _db.rawQuery("SELECT MAX(id)+1 as id FROM Exercise");
    int _id = _table.first["id"];
    return await _db.rawInsert("INSERT Into Exercise (id, name, bestVolume, previousVolume, currentVolume, dayId, weekId)" " VALUES (?,?,?,?,?,?,?)", [_id, newExercise.name, newExercise.bestVolume, newExercise.previousVolume, newExercise.currentVolume, newExercise.dayId, newExercise.weekId]);
  }
  newRound(Round round) async {
    final _db = await database;
    var _lastRow = await _db.query("Round", where: "exerciseId = ?", whereArgs: [round.exerciseId]);
    var _table = await _db.rawQuery("SELECT MAX(id)+1 as id FROM Round");
    if(_lastRow.isNotEmpty) {
      return await _db.rawInsert("INSERT Into Round (id, weight, round, rep, exerciseId, weekId)" " VALUES (?,?,?,?,?,?)", [_table.first["id"], _lastRow.last['weight'],  _lastRow.last['round'],  _lastRow.last['rep'], round.exerciseId, round.weekId]);
    } else {
      return await _db.rawInsert("INSERT Into Round (id, weight, round, rep, exerciseId, weekId)" " VALUES (?,?,?,?,?,?)", [_table.first["id"], round.weight, round.round, round.rep, round.exerciseId, round.weekId]);
    }
  }

  updateWeek(Week newWeek) async {
    final db = await database;
    return await db.update("Week", newWeek.toMap(), where: "id = ?", whereArgs: [newWeek.id]);
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
 
  updateExercise(Exercise newExercise) async {
    final _db = await database;
    return await _db.rawUpdate('''UPDATE Exercise SET name = ?, bestVolume = ?, previousVolume = ?, currentVolume = ? WHERE id = ?''', [newExercise.name, newExercise.bestVolume, newExercise.previousVolume, newExercise.currentVolume, newExercise.id]);
  }

  updateRound(Round newRound) async {
    final _db = await database;
    return await _db.rawUpdate('''UPDATE Round SET weight = ?, round = ?, rep = ? WHERE id = ?''', [newRound.weight, newRound.round, newRound.rep, newRound.id]);
  }

  Future<List<Week>> getAllWeeks() async {
    final db = await database;
    var res = await db.query("Week");
    List<Week> list = res.isNotEmpty ? res.map((c) => Week.fromMap(c)).toList() : [];
    return list;
  }

  Future<List<Day>> getAllDays(int weekId) async {
    final db = await database;
    var res = await db.query("Day", where: "weekId = ?", whereArgs: [weekId]);
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

  deleteWeek(int id) async {
    final db = await database;
    db.delete("Week", where: "id = ?", whereArgs: [id]);
    db.delete("Day", where: "weekId = ?", whereArgs: [id]);
    db.delete("Exercise", where: "weekId = ?", whereArgs: [id]);
    db.delete("Round", where: "weekId = ?", whereArgs: [id]);
  }

  deleteDay(int id) async {
    final db = await database;
    return db.delete("Day", where: "id = ?", whereArgs: [id]);
  }

  deleteExercise(int id) async {
    final db = await database;
    return db.delete("Exercise", where: "id = ?", whereArgs: [id]);
  }

  deleteRound(int exerciseId) async {
    final _db = await database;
    var _table = await _db.query("Round", where: "exerciseId = ?", whereArgs: [exerciseId]);
    return _db.delete("Round", where: "id = ?", whereArgs: [_table.last["id"]]);
  }
}

  //   // final _db = await database;
  //   // var _res = await _db.query("Exercise", where: "dayId = ?", whereArgs: [dayId]);
  //   // List<Exercise> fullList = List<Exercise>();
  //   // for (int i = 0; i < _res.length; i++) {
  //   //   fullList.add(Exercise.fromMap(_res[i]));
  //   //   var _rounds = await _db.query("Round", where: "exerciseId = ?", whereArgs: [_res[i]['id']]);
  //   //   List<Round> _finalRounds = _rounds.isNotEmpty ? _rounds.map((c) => Round.fromMap(c)).toList() : [];
  //   //     fullList[i].round = _finalRounds;
  //   // }
  //   // return fullList;
  //   // print('Here: ' + newExercise.currentVolume.toString());
  //   // final _db = await database;
  //   // return await _db.rawUpdate('''UPDATE Exercise SET name = ?, currentVolume = ? WHERE id = ?''', [newExercise.name, newExercise.currentVolume, newExercise.id]);
  // }
