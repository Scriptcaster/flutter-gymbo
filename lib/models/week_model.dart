import 'package:meta/meta.dart';
import 'package:json_annotation/json_annotation.dart';

import '../utils/uuid.dart';

part 'week_model.g.dart';

@JsonSerializable()
class Week {
  final String id, parent;
  final String name;
  @JsonKey(name: 'completed')
  final int isCompleted, seq;

  Week(this.name, {
    @required this.parent,
    this.seq = 0,
    this.isCompleted = 0,
    String id
  }): this.id = id ?? Uuid().generateV4();

  Week copy({String name, int seq, int isCompleted, int id, int parent}) {
    return Week(
      name ?? this.name,
      seq: seq ?? this.seq,
      isCompleted: isCompleted ?? this.isCompleted,
      id: id ?? this.id,
      parent: parent ?? this.parent,
    );
  }

    /// A necessary factory constructor for creating a new User instance
  /// from a map. Pass the map to the generated `_$TodoFromJson()` constructor.
  /// The constructor is named after the source class, in this case User.
  factory Week.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$TodoFromJson`.
  Map<String, dynamic> toJson() => _$TodoToJson(this);
}
