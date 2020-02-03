import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'day.dart';
import 'package:intl/intl.dart';

class WeekPage extends StatelessWidget {
  WeekPage({ @required this.id, this.date });
  final id;
  final date;
  // final dateFormatter = DateFormat('yyyy-MM-dd');
  // final dateString = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text( 
          date.toString()
          // dateString
          // DateFormat('yyyy-MM-dd').format(
          //   (new DateTime.fromMillisecondsSinceEpoch((date*1000).toInt()))
          // )
          // 
        ),
         actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              Firestore.instance.collection("data").document('Xi2BQ9KuCwOR2MeHIHUPH5G7bTc2').collection('weeks').document(id).delete();
              Navigator.pop(context);
            },
          )
        ],
        // title: Text( (date.toInt()).toString() ),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            // Text(id),
            StreamBuilder(
                stream: Firestore.instance
                    .collection("data")
                    .document('Xi2BQ9KuCwOR2MeHIHUPH5G7bTc2')
                    .collection('weeks')
                    .document(id)
                    .collection('days')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) return const Text('Loading...');
                  List<DocumentSnapshot> documents = snapshot.data.documents;
                  List<Widget> surveysList = [];
                  documents.sort((a,b) => a['index'].compareTo(b['index']));
                  documents.forEach((doc) {
                    surveysList.add(ListTile(
                      title: Text(doc['date']),
                      subtitle: Text(doc['target']),
                      trailing: Icon(Icons.keyboard_arrow_right),
                       onTap: () {
                        // print(doc.documentID);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DayScreen(
                              weekId: id,
                              dayId: doc['id'],
                              date: doc['date'],
                              target: doc['target'],
                              exercises: doc['exercises'],
                              cardio: doc['cardio'],
                            ),
                          ),
                        );
                      },
                    ));

                    // PageStorageKey _surveyKey =
                    //     new PageStorageKey('${doc.documentID}');
                    // if (doc['id'] == id) { 
                    //   doc['exercises'].forEach((exercise) {
                    //     surveysList.add(ListTile(
                    //       // key: _surveyKey,
                    //       title: Text(exercise['name'].toString()),
                    //     ));
                    //   });
                    // }
                  });
                  return Column(children: surveysList);
                }),
          ],
        )

          // child: Column(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   crossAxisAlignment: CrossAxisAlignment.center,
          //   children: <Widget>[
          //     Text('description'),
          //     RaisedButton(
          //         child: Text('Back To HomeScreen'),
          //         color: Theme.of(context).primaryColor,
          //         textColor: Colors.white,
          //         onPressed: () => Navigator.pop(context)),
          //   ],
          // ),
          ),
    );
  }
}
