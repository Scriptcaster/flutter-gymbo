import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'weeks.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({this.firestore});
  final Firestore firestore;
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final weeksCollection = Firestore.instance.collection("data").document('Xi2BQ9KuCwOR2MeHIHUPH5G7bTc2').collection("weeks");
  addWeek() {
    print(widget.firestore);
    // setState(() {
    //   // exercises.add({'name': 'New Exercise', 'sets': [{'set': 4, 'weight': 25, 'rep': 8}], 'volume': 800});
    // });
  }

  Future<void> createCommitment() async {
    DocumentReference docRef = await weeksCollection.add({
      'date': new DateTime.now(),
      'number': 1,
    });

    weeksCollection.document(docRef.documentID).updateData(
      {'id': docRef.documentID}
    );
    
    DocumentReference monRef = await weeksCollection.document(docRef.documentID).collection('days').add({ 
      'index': 0, 
      'date': 'Monday', 
      'target': 'Chest & Triceps', 
      'exercises': [{
        'name': 'Bench Press',
        'volume': 5760,
        'sets': [{
          'weight': 120,
          'set': 4,
          'rep': 12,
        }]
      }]
    });
    weeksCollection.document(docRef.documentID).collection('days').document(monRef.documentID).updateData(
      {'id': monRef.documentID}
    );

    DocumentReference tueRef = await weeksCollection.document(docRef.documentID).collection('days').add({ 
      'index': 0, 
      'date': 'Tuesday', 
      'target': 'Legs & Abs', 
      'exercises': [{
        'name': 'Bench Press',
        'volume': 5760,
        'sets': [{
          'weight': 120,
          'set': 4,
          'rep': 12,
        }]
      }]
    });
    weeksCollection.document(docRef.documentID).collection('days').document(tueRef.documentID).updateData(
      {'id': tueRef.documentID}
    );

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
