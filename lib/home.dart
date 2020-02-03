import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'weeks.dart';
import 'models/day.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({this.firestore});
  final Firestore firestore;
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final weeksCollection = Firestore.instance.collection("data").document('Xi2BQ9KuCwOR2MeHIHUPH5G7bTc2').collection("weeks");
  final exercisesCollection = Firestore.instance.collection("data").document('Xi2BQ9KuCwOR2MeHIHUPH5G7bTc2').collection("exercises");

  var i = 0;
  var weeksId;
  
  Future<void> createCommitment() async {

  // weeksCollection.snapshots().listen(
  //     (data) => print(data.documents[1].data['id'])
  //   );


    // List myArray = [];
    // weeksCollection.document('brj1DuECwtpxoSWj9Ps5').collection('days').snapshots().listen(
    //   (data) => 
    //   // print('grower ${data.documents[0].data}')
    //   data.documents.forEach((talk){
    //     // myArray.add(talk.data['name']);
    //     // print(talk.data['name']);
    //     print(talk.data['exercises']);
    //   }),
    // );

    // var id = new Random();
    // print(id.nextInt(100));
    // this.weeksCollection.doc(id).set({ id: id, date:Date.now() / 1000});
    // if (array == undefined) {
    //     this.weeksCollection.doc(id).collection('days').add({ id: '', index: 0, date: 'Monday', target: 'Chest & Triceps', volume: 0 });
    //     this.weeksCollection.doc(id).collection('days').add({ id: '', index: 1, date: 'Tuesday', target: 'Legs', volume: 0 });
    //     this.weeksCollection.doc(id).collection('days').add({ id: '', index: 2, date: 'Wednesday', target: 'Day Off', volume: 0 });
    //     this.weeksCollection.doc(id).collection('days').add({ id: '', index: 3, date: 'Thursday', target: 'Back & Biceps', volume: 0 });
    //     this.weeksCollection.doc(id).collection('days').add({ id: '', index: 4, date: 'Friday', target: 'Shoulder & Abs', volume: 0 });
    //     this.weeksCollection.doc(id).collection('days').add({ id: '', index: 5, date: 'Saturday', target: 'Day Off', volume: 0 });
    //     this.weeksCollection.doc(id).collection('days').add({ id: '', index: 6, date: 'Sunday', target: 'Day Off', volume: 0 });
    // } else {
    //     array.forEach(element => {
    //         this.weeksCollection.doc(id).collection('days').add(element);
    //     });
    // }

    // weeksCollection
    // // where('number', isLessThan: '1')
    // // .orderBy('date', descending: false)
    // // .limit(1)
    // .snapshots().listen((data){
    //   print(data.documents[1]['id']);
    //   // data.documents.forEach((talk){
    //   // });
    // });

    // DocumentReference fromDocument = await weeksCollection.document('TntbeOhHJA4akiDiEKNM');
    // DocumentReference toDocument = await weeksCollection.document('brj1DuECwtpxoSWj9Ps5');
    // fromDocument.get().then((datasnapshot) {
    //   if (datasnapshot.exists) {
    //     print(datasnapshot.data);
    //     // toDocument.setData(datasnapshot.data).whenComplete(() {
    //     // }).catchError((e) => print(e));
    //   }
    // });

    // weekQuerySnapshot.documents.forEach((day){
    //   print(day['date']);
    // });
    // Object exercises;

    // if(weeksQuerySnapshot.documents.last['id'] == null) {
    //  print('YAHOOOOOOO');
    // } 

    QuerySnapshot weeksQuerySnapshot = await weeksCollection.orderBy('date', descending: false).getDocuments();
    // QuerySnapshot exercisesQuerySnapshot = await exercisesCollection.getDocuments();
    QuerySnapshot weekQuerySnapshot = await weeksCollection.document(weeksQuerySnapshot.documents.last['id']).collection('days').getDocuments();

    DocumentReference weekRef = await weeksCollection.add({
      'date': new DateTime.now(),
      'number': i++,
    });
    weeksCollection.document(weekRef.documentID).updateData({'id': weekRef.documentID});

    List lastExercises = [];
    weekQuerySnapshot.documents.forEach((day){
      lastExercises.add(day.data);
    });
    lastExercises.sort((a, b) => a['index'].compareTo(b['index']));


    List defaultExercises = [{
      'name': 'Bench Press',
      'volume': 5760,
      'sets': [{
        'weight': 120,
        'set': 4,
        'rep': 12,
      }]
    }];

    if(weeksQuerySnapshot.documents.last['id'] != null) {

      DocumentReference monRef = await weeksCollection.document(weekRef.documentID).collection('days').add({ 
        'index': 0, 
        'date': 'Monday', 
        'target': 'Chest & Triceps', 
        'exercises': lastExercises[0]['exercises']
      });
      weeksCollection.document(weekRef.documentID).collection('days').document(monRef.documentID).updateData({'id': monRef.documentID});

      DocumentReference tueRef = await weeksCollection.document(weekRef.documentID).collection('days').add({ 
        'index': 1, 
        'date': 'Tuesday', 
        'target': 'Legs & Abs', 
        'exercises': lastExercises[1]['exercises']
      });
      weeksCollection.document(weekRef.documentID).collection('days').document(tueRef.documentID).updateData({'id': tueRef.documentID});

      DocumentReference wedRef = await weeksCollection.document(weekRef.documentID).collection('days').add({ 
        'index': 2, 
        'date': 'Wednesday', 
        'target': 'Day Off', 
        'exercises': lastExercises[2]['exercises']
      });
      weeksCollection.document(weekRef.documentID).collection('days').document(wedRef.documentID).updateData({'id': wedRef.documentID});

      DocumentReference thuRef = await weeksCollection.document(weekRef.documentID).collection('days').add({ 
        'index': 3, 
        'date': 'Thursday', 
        'target': 'Back & Biceps', 
        'exercises': lastExercises[3]['exercises']
      });
      weeksCollection.document(weekRef.documentID).collection('days').document(thuRef.documentID).updateData({'id': thuRef.documentID});

      DocumentReference friRef = await weeksCollection.document(weekRef.documentID).collection('days').add({ 
        'index': 4, 
        'date': 'Friday', 
        'target': 'Shoulders & Abs', 
        'exercises': lastExercises[4]['exercises']
      });
      weeksCollection.document(weekRef.documentID).collection('days').document(friRef.documentID).updateData({'id': friRef.documentID});

      DocumentReference satRef = await weeksCollection.document(weekRef.documentID).collection('days').add({ 
        'index': 5, 
        'date': 'Saturday', 
        'target': 'Day Off', 
        'exercises': lastExercises[5]['exercises']
      });
      weeksCollection.document(weekRef.documentID).collection('days').document(satRef.documentID).updateData({'id': satRef.documentID});

      DocumentReference sunRef = await weeksCollection.document(weekRef.documentID).collection('days').add({ 
        'index': 6, 
        'date': 'Sunday', 
        'target': 'Day Off', 
        'exercises': lastExercises[6]['exercises']
      });
      weeksCollection.document(weekRef.documentID).collection('days').document(sunRef.documentID).updateData({'id': sunRef.documentID});
   
    } else {

      DocumentReference monRef = await weeksCollection.document(weekRef.documentID).collection('days').add({ 
        'index': 0, 
        'date': 'Monday', 
        'target': 'Chest & Triceps', 
        'exercises': defaultExercises
      });
      weeksCollection.document(weekRef.documentID).collection('days').document(monRef.documentID).updateData({'id': monRef.documentID});

      DocumentReference tueRef = await weeksCollection.document(weekRef.documentID).collection('days').add({ 
        'index': 1, 
        'date': 'Tuesday', 
        'target': 'Legs & Abs', 
        'exercises': defaultExercises,
      });
      weeksCollection.document(weekRef.documentID).collection('days').document(tueRef.documentID).updateData({'id': tueRef.documentID});

      DocumentReference wedRef = await weeksCollection.document(weekRef.documentID).collection('days').add({ 
        'index': 2, 
        'date': 'Wednesday', 
        'target': 'Day Off', 
        'exercises': defaultExercises,
      });
      weeksCollection.document(weekRef.documentID).collection('days').document(wedRef.documentID).updateData({'id': wedRef.documentID});

      DocumentReference thuRef = await weeksCollection.document(weekRef.documentID).collection('days').add({ 
        'index': 3, 
        'date': 'Thursday', 
        'target': 'Back & Biceps', 
        'exercises': defaultExercises,
      });
      weeksCollection.document(weekRef.documentID).collection('days').document(thuRef.documentID).updateData({'id': thuRef.documentID});

      DocumentReference friRef = await weeksCollection.document(weekRef.documentID).collection('days').add({ 
        'index': 4, 
        'date': 'Friday', 
        'target': 'Shoulders & Abs', 
        'exercises': defaultExercises,
      });
      weeksCollection.document(weekRef.documentID).collection('days').document(friRef.documentID).updateData({'id': friRef.documentID});

      DocumentReference satRef = await weeksCollection.document(weekRef.documentID).collection('days').add({ 
        'index': 5, 
        'date': 'Saturday', 
        'target': 'Day Off', 
        'exercises': defaultExercises,
      });
      weeksCollection.document(weekRef.documentID).collection('days').document(satRef.documentID).updateData({'id': satRef.documentID});

      DocumentReference sunRef = await weeksCollection.document(weekRef.documentID).collection('days').add({ 
        'index': 6, 
        'date': 'Sunday', 
        'target': 'Day Off', 
        'exercises': defaultExercises,
      });
      weeksCollection.document(weekRef.documentID).collection('days').document(sunRef.documentID).updateData({'id': sunRef.documentID});
    }

    lastExercises.forEach((item) {
      item['exercises'].forEach((exercise) {
        if(exercise['volume'] > exercise['bestVolume']) {
          exercisesCollection.document(exercise['bestVolumeId']).updateData({'bestVolume': exercise['volume'] });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Weeks'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => createCommitment(),
          )
        ],
      ),
      body: Center(
        child: StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance.collection("data").document('Xi2BQ9KuCwOR2MeHIHUPH5G7bTc2').collection("weeks").snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              List<DocumentSnapshot> documents = snapshot.data.documents;
              return CustomWeek(weeks: documents);
            },
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => setState(() => _count++),
      //   tooltip: 'Increment Counter',
      //   child: const Icon(Icons.add),
      // ),
    );

  }
}
