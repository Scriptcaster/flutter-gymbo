// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'week_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Week _$TodoFromJson(Map<String, dynamic> json) {
  return Week(json['name'] as String,
    parent: json['parent'] as String,
    seq: json['seq'] as int,
    isCompleted: json['completed'] as int,
    id: json['id'] as String);
}

Map<String, dynamic> _$TodoToJson(Week instance) => <String, dynamic>{
  'id': instance.id,
  'parent': instance.parent,
  'seq': instance.seq,
  'name': instance.name,
  'completed': instance.isCompleted
};
