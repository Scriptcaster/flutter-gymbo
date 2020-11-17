// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'round.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Round _$TodoFromJson(Map<String, dynamic> json) {
  return Round(
    id: json['id'] as int,
    weight: json['weight'] as int,
    round: json['round'] as int,
    rep: json['rep'] as int,
    exerciseId: json['exerciseId'] as int,
    dayId: json['dayId'] as int,
    weekId: json['weekId'] as String,
    programId: json['programId'] as String
  );
}

Map<String, dynamic> _$TodoToJson(Round instance) => <String, dynamic>{
  'id': instance.id,
  'weight': instance.weight,
  'round': instance.round,
  'rep': instance.rep,
  'exerciseId': instance.exerciseId,
  'dayId': instance.dayId,
  'weekId': instance.weekId,
  'programId': instance.programId
};

