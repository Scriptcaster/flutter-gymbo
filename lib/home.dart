// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'functions/create_week.dart';
// import 'functions/auth.dart';
import 'weeks.dart';

// class Home extends StatefulWidget {
//   Home({ this.uid, this.firestore });
//   final Object uid;
//   final Firestore firestore;
//   @override
//   _HomeState createState() => _HomeState();
// }

// class _HomeState extends State<Home> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: Padding(
//           padding: EdgeInsets.only(left: 12),
//           child: IconButton(
//             icon: Icon(Icons.person_outline),
//             onPressed: () {
//               authService.signOutGoogle();
//               Navigator.pop(context);
//             },
//           ),
//         ),
//         title: Text(widget.uid.toString()),
//         actions: <Widget>[
//           IconButton(
//             icon: Icon(Icons.add),
//             onPressed: () => createWeek(widget.uid),
//           )
//         ],
//       ),
//       body: Center(
//         child: StreamBuilder<QuerySnapshot>(

//           stream: Firestore.instance.collection("data").document(
//             widget.uid
//             // 'Xi2BQ9KuCwOR2MeHIHUPH5G7bTc2'
//           ).collection("weeks").snapshots(),
         
//           builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//             List<DocumentSnapshot> documents = snapshot.data.documents;
//             return Weeks(
//               uid: widget.uid, 
//               // uid: 'Xi2BQ9KuCwOR2MeHIHUPH5G7bTc2',
//               weeks: documents
//             );
//           },
          
//         ),
//       ),
//     );
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth/customCard.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title, this.uid}) : super(key: key); //update this to include the uid in the constructor
  final String title;
  final String uid; //include this

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController taskTitleInputController;
  TextEditingController taskDescripInputController;
  FirebaseUser currentUser;

  @override
  initState() {
    taskTitleInputController = new TextEditingController();
    taskDescripInputController = new TextEditingController();
    // this.getCurrentUser();
    print(widget.title);
    super.initState();
  }

  // void getCurrentUser() async {
  //   currentUser = await FirebaseAuth.instance.currentUser();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          FlatButton(
            child: Text("Log Out"),
            textColor: Colors.white,
            onPressed: () {
              FirebaseAuth.instance.signOut().then((result) => Navigator.pushReplacementNamed(context, "/login")).catchError((err) => print(err));
            },
          )
        ],
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance.collection("data").document(widget.uid).collection('weeks').snapshots(),
            // builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            //   if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
            //   switch (snapshot.connectionState) {
            //     case ConnectionState.waiting: return new Text('Loading...');
            //     default: return new ListView(
            //       children: snapshot.data.documents.map((DocumentSnapshot document) {
            //         return new CustomCard(
            //           title: document['title'],
            //           description: document['description'],
            //         );
            //       }).toList(),
            //     );
            //   }
            // },
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if(!snapshot.hasData) { 
                return CircularProgressIndicator();
              } else {
                List<DocumentSnapshot> documents = snapshot.data.documents;
                 return Weeks(
                  uid: widget.uid, 
                  weeks: documents
                );
              }

              // if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
              // switch (snapshot.connectionState) {
              //   case ConnectionState.waiting: return new Text('Loading...');
              //   default: 
              //   return Weeks(
              //     uid: widget.uid, 
              //     weeks: documents
              //   );
                // return new ListView(
                //   children: snapshot.data.documents.map((DocumentSnapshot document) {
                //     return new CustomCard(
                //       title: document['title'],
                //       description: document['description'],
                //     );
                //   }).toList(),
                // );
              // }
            },
          )
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // onPressed: _showDialog,
        onPressed: () => createWeek(widget.uid),
        tooltip: 'Add',
        child: Icon(Icons.add),
      ),
    );
  }

  _showDialog() async {
    await showDialog<String>(
      context: context,
      child: AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: Column(
          children: <Widget>[
            Text("Please fill all fields to create a new task"),
            Expanded(
              child: TextField(
                autofocus: true,
                decoration: InputDecoration(labelText: 'Task Title*'),
                controller: taskTitleInputController,
              ),
            ),
            Expanded(
              child: TextField(
                decoration: InputDecoration(labelText: 'Task Description*'),
                controller: taskDescripInputController,
              ),
            )
          ],
        ),
        actions: <Widget>[
          FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                taskTitleInputController.clear();
                taskDescripInputController.clear();
                Navigator.pop(context);
              }),
          FlatButton(
              child: Text('Add'),
              onPressed: () => createWeek(widget.uid),
              // onPressed: () {
              //   if (taskDescripInputController.text.isNotEmpty &&
              //       taskTitleInputController.text.isNotEmpty) {
              //     Firestore.instance
              //         .collection("data")
              //         .document(widget.uid)
              //         .collection('weeks')
              //         .add({
              //           "title": taskTitleInputController.text,
              //           "description": taskDescripInputController.text
              //         })
              //         .then((result) => {
              //               Navigator.pop(context),
              //               taskTitleInputController.clear(),
              //               taskDescripInputController.clear(),
              //             })
              //         .catchError((err) => print(err));
              //   }
              // }
            )
        ],
      ),
    );
  }
}