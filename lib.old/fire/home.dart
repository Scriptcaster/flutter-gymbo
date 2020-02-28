import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'functions/create_week.dart';
import 'weeks.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title, this.uid}) : super(key: key);
  final String title;
  final String uid; 
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.only(left: 0),
          child: IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              FirebaseAuth.instance.signOut().then((result) => Navigator.pushReplacementNamed(context, "/login")).catchError((err) => print(err));
            },
          ),
        ),
        title: Text(widget.title.toString()),
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
            },
          )
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => createWeek(widget.uid),
        tooltip: 'Add',
        child: Icon(Icons.add),
      ),
    );
  }
}


// Version 1.0 with Observable
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'functions/auth.dart';
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
//           ).collection("weeks").snapshots(),
//           builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//             List<DocumentSnapshot> documents = snapshot.data.documents;
//             return Weeks(
//               uid: widget.uid, 
//               weeks: documents
//             );
//           },
          
//         ),
//       ),
//     );
//   }
// }