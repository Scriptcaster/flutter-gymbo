import 'exercise.dart';
class Day {
  
  Day({ 
    this.id, 
    this.dayName, 
    this.target,
    // this.exercise,  
    this.weekId
  });

  int id;
  String dayName;
  String target;
  // List<Exercise> exercise;
  int weekId;

  static final columns = ['id', 'dayName', 'target', 'exercise', 'weekId'];

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
    // "exercise": exercise,
    "weekId": weekId,
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
    // exercise: json["exercise"],
    weekId: json["weekId"],
  );

}