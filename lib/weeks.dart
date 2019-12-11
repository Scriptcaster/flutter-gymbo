import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'week.dart';

class CustomWeek extends StatelessWidget {
  CustomWeek({this.weeks, this.firestore});
  final List<DocumentSnapshot> weeks;
  final Firestore firestore;
  List<Widget> _getChildren() {
    List<Widget> children = [];
    // print(documents[0]['number']);
    // documents.sort((a, b) => compare(a['number'], b['number']));
    weeks.sort((b,a) => a['number'].compareTo(b['number']));
    weeks.forEach((doc) {
      children.add(
        ProjectsExpansionTile(projectKey: doc.documentID, date: doc['number'], firestore: firestore),
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
  ProjectsExpansionTile({this.projectKey, this.date, this.firestore});

  final String projectKey;
  final Object date;
  final Firestore firestore;

  @override
  Widget build(BuildContext context) {
    PageStorageKey _projectKey = PageStorageKey('$projectKey');
    return Card(
      child: Container(
        padding: const EdgeInsets.only(top: 5.0),
        child: Column(
          children: <Widget>[ 
            ListTile(
              title: Text('Week ' + date.toString()),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WeekPage(
                      id: projectKey,
                      date: date,
                    ),
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
          // children: <Widget>[
          //   Text(projectKey),
          //   StreamBuilder(
          //       stream: Firestore.instance
          //           .collection("data")
          //           .document('Xi2BQ9KuCwOR2MeHIHUPH5G7bTc2')
          //           .collection('weeks')
          //           .document(projectKey)
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
    
