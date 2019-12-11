import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DayPage extends StatefulWidget {
  DayPage({@required this.id, this.date, this.target, this.exercises});
  final id;
  final date;
  final target;
  final exercises;

  @override
  _DayPageState createState() => _DayPageState();
}

class _DayPageState extends State<DayPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.date.toString()),
      ),
      body: new Center(
        child: new Column(
          // Or Row or whatever\
          children: createChildrenTexts(),
        ),
      ),

    );
  }

  List<Widget> createChildrenTexts() {
    List<Widget> childrenTexts = [];
    widget.exercises.forEach((exercise) {
      childrenTexts.add(ListTile(
        title: Text(exercise['name'].toString()),
        subtitle: CreateChildrenSets(
            weight: exercise['sets'][0]['weight'],
            rep: exercise['sets'][0]['rep'],
            set: exercise['sets'][0]['set']),
      ));
    });
    return childrenTexts;
  }
}

class CreateChildrenSets extends StatefulWidget {

  CreateChildrenSets({this.weight, this.rep, this.set});

  final Object weight;
  final Object rep;
  final Object set;
  
  @override
  _CreateChildrenSetsState createState() => _CreateChildrenSetsState(rep: rep);
}

class _CreateChildrenSetsState extends State<CreateChildrenSets> {
  _CreateChildrenSetsState({this.rep});
  final Object rep;
  int _counter = 0;
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(widget.weight),
        ),
        Expanded(
          child: Text(rep),
        ),
        Expanded(
          child: 
          Text( '$_counter',),
        ),
        IconButton(
          icon: Icon(Icons.add),
          tooltip: 'Increase volume by 10',
          onPressed: _incrementCounter,
        ),
      ],
    );
  }
}


















// class DayPage extends StatelessWidget {
//   DayPage({@required this.id, this.date, this.target, this.exercises});

//   final id;
//   final date;
//   final target;
//   final exercises;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(date),
//       ),
//       body: new Center(
//         child: new Column(
//           // Or Row or whatever\
//           children: createChildrenTexts(),
//         ),
//       ),
//     );
//   }

  // List<Widget> createChildrenTexts() {
  //   List<Widget> childrenTexts = [];
  //   exercises.forEach((exercise) {
  //     childrenTexts.add(ListTile(
  //       title: Text(exercise['name'].toString()),
  //       subtitle: CreateChildrenSets(
  //           weight: exercise['sets'][0]['weight'],
  //           rep: exercise['sets'][0]['rep'],
  //           set: exercise['sets'][0]['set']),
  //     ));
  //   });
  //   return childrenTexts;
  // }
// }

// class CreateChildrenSets extends StatelessWidget {

//   CreateChildrenSets({this.weight, this.rep, this.set});

//   final Object weight;
//   final Object rep;
//   final Object set;
//   int _counter = 1;

//   // int _counter = 0;
//   void _incrementCounter() {
//     print('ok');
//     _counter = _counter++;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         Expanded(
//           child: Text(weight),
//         ),
//         Expanded(
//           child: Text(rep),
//         ),
//         Expanded(
//           child: 
//           Text( '$_counter',),
//         ),
//         IconButton(
//           icon: Icon(Icons.add),
//           tooltip: 'Increase volume by 10',
//           onPressed: _incrementCounter,
//         ),
//       ],
//     );
//   }
// }
