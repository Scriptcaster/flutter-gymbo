import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'week.dart';

class Weeks extends StatelessWidget {
  Weeks({this.uid, this.weeks, this.firestore});
  final List<DocumentSnapshot> weeks;
  final Firestore firestore;
  final String uid;

  List<Widget> _getChildren() {
    List<Widget> children = [];
    // print(documents[0]['number']);
    // documents.sort((a, b) => compare(a['number'], b['number']));
    weeks.sort((b,a) => a['date'].compareTo(b['date']));
    weeks.forEach((doc) {
      // print(doc.documentID);
      children.add(
        ProjectsExpansionTile(
          uid: uid,
          weekId: doc.documentID,
          date: DateFormat('yMMMMd').format(doc['date'].toDate()), 
          firestore: firestore
        ),
      );
    });
    return children;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: _getChildren(),
    );
  }
}

class ProjectsExpansionTile extends StatelessWidget {
  ProjectsExpansionTile({this.uid, this.weekId, this.date, this.firestore});
  final String uid;
  final String weekId;
  final Object date;
  final Firestore firestore;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.only(top: 5.0),
        child: Column(
          children: <Widget>[ 
            ListTile(
              title: Text(date.toString()),
              subtitle: Text(weekId.toString()),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Week(uid: uid, id: weekId, date: date,),
                  ),
                );
              },
            )
          ]
        ),
      ),
    );
  }
}

  // String formatTimestamp(int timestamp) {
  //     var format = new DateFormat('d MMM, hh:mm a');
  //     var date = new DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  //     return format.format(date);
  //   }

          // children: <Widget>[
          //   Text(weekId),
          //   StreamBuilder(
          //       stream: Firestore.instance
          //           .collection("data")
          //           .document('Xi2BQ9KuCwOR2MeHIHUPH5G7bTc2')
          //           .collection('weeks')
          //           .document(weekId)
          //           .collection('days')
          //           .snapshots(),
          //       builder: (BuildContext context,
          //           AsyncSnapshot<QuerySnapshot> snapshot) {
          //         if (!snapshot.hasData) return const Text('Loading...');
          //         List<DocumentSnapshot> documents = snapshot.data.documents;
          //         List<Widget> surveysList = [];
          //         documents.forEach((doc) {
          //           // PageStorageKey _surveyKey =
          //           //     new PageStorageKey('${doc.documentID}');
          //           surveysList.add(ListTile(
          //             // key: _surveyKey,
          //             title: FlatButton(
          //                 child: Text(doc['date']),
          //                 onPressed: () {
          //                   Navigator.push(
          //                       context,
          //                       MaterialPageRoute(
          //                           builder: (context) => TaskPage(
          //                               id: doc['id'],
          //                               date: doc['date'],
          //                               target: doc['target'])));
          //                 }),
          //             subtitle: Text(doc['target']),
          //             trailing: Icon(Icons.keyboard_arrow_right),
          //             dense: true,
          //           ));
          //         });
          //         return Column(children: surveysList);
          //       }),
          // ],
    
