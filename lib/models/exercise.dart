import 'round.dart';
class Exercise {

  Exercise({
    this.id,
    this.name,
    this.bestVolume,
    this.previousVolume,
    this.currentVolume,
    this.round,
    this.dayId,
    this.weekId,
    this.programId
  });

  int id;
  String name;
  int bestVolume;
  int previousVolume;
  int currentVolume;
  List<Round> round;
  int dayId;
  String weekId; 
  String programId; 

  static final columns = [
    'id', 
    'name',
    'bestVolume' 
    'previousVolume', 
    'currentVolume', 
    'round', 
    'dayId',
    'weekId',
    'programId'
  ];

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'bestVolume': bestVolume,
    'previousVolume': previousVolume,
    'currentVolume': currentVolume,
    'round': round,
    'dayId': dayId,
    'weekId': weekId,
    'programId': programId
  };

  factory Exercise.fromMap(Map<String, dynamic> json) => new Exercise(
    id: json["id"],
    name: json["name"],
    bestVolume: json["bestVolume"],
    previousVolume: json["previousVolume"],
    currentVolume: json["currentVolume"],
    round: json["round"],
    dayId: json["dayId"],
    weekId: json["weekId"],
    programId: json["programId"]
  );
}