// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Exercise _$TodoFromJson(Map<String, dynamic> json) {
  return Exercise(
    id: json['id'] as int,
    name: json['name'] as String,
    bestVolume: json['bestVolume'] as int,
    previousVolume: json['previousVolume'] as int,
    currentVolume: json['currentVolume'] as int,
    round: json['round'] as List<Round>,
    dayId: json['dayId'] as int,
    weekId: json['weekId'] as String,
    programId: json['programId'] as String
  );
}

Map<String, dynamic> _$TodoToJson(Exercise instance) => <String, dynamic>{
  'id': instance.id,
  'dayName': instance.name,
  'bestVolume': instance.bestVolume,
  'previousVolume': instance.previousVolume,
  'currentVolume': instance.currentVolume,
  'round': instance.round,
  'dayId': instance.dayId,
  'weekId': instance.weekId,
  'programId': instance.programId
};

