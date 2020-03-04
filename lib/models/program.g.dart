// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'program.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Program _$TaskFromJson(Map<String, dynamic> json) {
  return Program(json['name'] as String,
      color: json['color'] as int,
      codePoint: json['code_point'] as int,
      id: json['id'] as String);
}

Map<String, dynamic> _$TaskToJson(Program instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'color': instance.color,
      'code_point': instance.codePoint
    };
