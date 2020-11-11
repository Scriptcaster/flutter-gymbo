import 'package:bench_more/scopedmodel/program.dart';
import 'package:meta/meta.dart';
import 'package:json_annotation/json_annotation.dart';

part 'day.g.dart';

@JsonSerializable()

class Day {
  
  Day({ 
    this.id, 
    this.dayName, 
    this.target,
    this.isCompleted = 0,
    // this.exercise,  
    this.weekId,
    this.programId
  });

  int id;
  String dayName;
  String target;
  int isCompleted;
  // List<Exercise> exercise;
  String weekId;
  String programId;

  static final columns = [
    'id', 
    'dayName', 
    'target', 
    'isCompleted', 
    // 'exercise', 
    'weekId', 
    'programId'
  ];

  // Map toMap() {
  //   Map map = {
  //     "dayName": dayName,
  //     "target": target,
  //     "weekId": weekId,
  //   };
  //   if (id != null) {
  //     map["id"] = id;
  //   }
  //   return map;
  // }

   Map<String, dynamic> toMap() => {
    "dayName": dayName,
    "target": target,
    "isCompleted": isCompleted,
    // "exercise": exercise,
    "weekId": weekId,
    "programId": programId,
  };

  // static fromMap(Map map) {
  //   Day day = new Day();
  //   day.id = map["id"];
  //   day.dayName = map["dayName"];
  //   day.weekId = map["weekId"];
  //   return day;
  // }

  factory Day.fromMap(Map<String, dynamic> json) => new Day(
    id: json["id"],
    dayName: json["dayName"],
    target: json["target"],
    isCompleted: json['isCompleted'],
    // exercise: json["exercise"],
    weekId: json["weekId"],
    programId: json["programId"],
  );

   Day copy({int id, String dayName, String target, int isCompleted, int weekId, int programId}) {
    return Day(
      id: id ?? this.id,
      dayName: dayName ?? this.dayName,
      target: target ?? this.target,
      isCompleted: isCompleted ?? this.isCompleted,
      weekId: weekId ?? this.weekId,
      programId: programId ?? this.programId,
    );
  }

  /// A necessary factory constructor for creating a new User instance
  /// from a map. Pass the map to the generated `_$TodoFromJson()` constructor.
  /// The constructor is named after the source class, in this case User.
  factory Day.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$TodoFromJson`.
  Map<String, dynamic> toJson() => _$TodoToJson(this);

}