class Exercise {
  final String id;
  final String name;
  final int bestVolume;

  const Exercise({
    this.id,
    this.name,
    this.bestVolume
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'bestVolume': bestVolume
  };

  // String toString(){
  //   return "{id: $id, name: $name, bestVolume: $bestVolume}";
  // }
}