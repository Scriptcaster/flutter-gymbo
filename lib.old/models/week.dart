import 'dart:convert';

Week weekFromJson(String str) {
  final jsonData = json.decode(str);
  return Week.fromMap(jsonData);
}

String weekToJson(Week data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class Week {
  int id;
  String name;

  Week({
    this.id,
    this.name,
  });

  factory Week.fromMap(Map<String, dynamic> json) => new Week(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "name": name,
  };
}
