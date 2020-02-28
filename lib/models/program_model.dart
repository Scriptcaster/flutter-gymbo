import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../utils/uuid.dart';

part 'program_model.g.dart';

@JsonSerializable()
class Program {
  String id;
  String name;
  int color;
  @JsonKey(name: 'code_point')
  int codePoint;

  Program(
    this.name, {
    @required this.color,
    @required this.codePoint,
    String id,
  }) : this.id = id ?? Uuid().generateV4();

  /// A necessary factory constructor for creating a new User instance
  /// from a map. Pass the map to the generated `_$TaskFromJson()` constructor.
  /// The constructor is named after the source class, in this case User.
  factory Program.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$TaskFromJson`.
  Map<String, dynamic> toJson() => _$TaskToJson(this);
}
