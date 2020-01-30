import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'weeks.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({this.firestore});
  final Firestore firestore;
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final weeksCollection = Firestore.instance.collection("data").document('Xi2BQ9KuCwOR2MeHIHUPH5G7bTc2').collection("weeks");
 
  var i = 0;
  var weeksId;
  
  Future<void> createCommitment() async {

    var id = new Random();
    print(id.nextInt(100));
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

    // DocumentReference weekRef = await weeksCollection.add({
    //   'date': new DateTime.now(),
    //   'number': i++,
    // });
    // weeksCollection.document(weekRef.documentID).updateData({'id': weekRef.documentID});

    // weeksCollection.document(weekRef.documentID).updateData({'id': weekRef.documentID});
    // DocumentReference monRef = await weeksCollection.document(weekRef.documentID).collection('days').add({ 
    //   'index': 0, 
    //   'date': 'Monday', 
    //   'target': 'Chest & Triceps', 
    //   'exercises': [{
    //     'name': 'Bench Press',
    //     'volume': 5760,
    //     'sets': [{
    //       'weight': 120,
    //       'set': 4,
    //       'rep': 12,
    //     }]
    //   }]
    // });
    // weeksCollection.document(weekRef.documentID).collection('days').document(monRef.documentID).updateData({'id': monRef.documentID});

    // DocumentReference tueRef = await weeksCollection.document(weekRef.documentID).collection('days').add({ 
    //   'index': 1, 
    //   'date': 'Tuesday', 
    //   'target': 'Legs & Abs', 
    //   'exercises': [{
    //     'name': 'Bench Press',
    //     'volume': 5760,
    //     'sets': [{
    //       'weight': 120,
    //       'set': 4,
    //       'rep': 12,
    //     }]
    //   }]
    // });
    // weeksCollection.document(weekRef.documentID).collection('days').document(tueRef.documentID).updateData({'id': tueRef.documentID});

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Weeks'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              createCommitment();
            },
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
