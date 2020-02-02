// import 'package:duration/duration.dart';

// import 'temp.dart';

// class Day {
//   final String title;
//   final String text;

//   Day(this.title, this.text);

//   static List<Day> fetchAll() {
//     return [
//       Day('apple', 'orange'),
//     ];
//   }
// }


class Day {
  final String id;
  final String name;

  const Day({
    this.id,
    this.name,
  });

  Day.fromMap(Map<String, dynamic> data, String id) : this(
    id: id,
    name: data['name'],
    // ingredients: new List<String>.from(data['ingredients']),
  );
}

// 'exercises':[{
//   'name': 'Bench Press',
//   'volume': 5760,
//   'sets': [{
//     'weight': 120,
//     'set': 4,
//     'rep': 12,
//   }]
// }]