class Round {

  Round({
    this.id,
    this.weight,
    this.round,
    this.rep,
    this.exerciseId,
    this.weekId
  });

  int id;
  int weight;
  int round;
  int rep;
  int exerciseId;
  int weekId;

  static final columns = ['id', 'weight', 'round', 'rep', 'exerciseId', 'weekId'];

  Map<String, dynamic> toMap() => {
    'id': id,
    'weight': weight,
    'round': round,
    'rep': rep,
    'exerciseId': exerciseId,
    'weekId': weekId
  };

  factory Round.fromMap(Map<String, dynamic> json) => new Round(
    id: json['id'],
    weight: json['weight'],
    round: json['round'],
    rep: json['rep'],
    exerciseId: json['exerciseId'],
    weekId: json['weekId']
  );
}