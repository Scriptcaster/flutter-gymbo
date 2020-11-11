// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Day _$TodoFromJson(Map<String, dynamic> json) {
  return Day(
    id: json['id'] as int,
    dayName: json['dayName'] as String,
    target: json['target'] as String,
    isCompleted: json['completed'] as int,
    weekId: json['weekId'] as String,
    programId: json['programId'] as String
  );
}

Map<String, dynamic> _$TodoToJson(Day instance) => <String, dynamic>{
  'id': instance.id,
  'dayName': instance.dayName,
  'target': instance.target,
  'isCompleted': instance.isCompleted,
  'weekId': instance.weekId,
  'programId': instance.programId
};

