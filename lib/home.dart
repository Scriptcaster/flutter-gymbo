import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'functions/create_week.dart';
import 'functions/auth.dart';
import 'weeks.dart';

class Home extends StatefulWidget {
  Home({ this.uid, this.firestore });
  final Object uid;
  final Firestore firestore;
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.only(left: 12),
          child: IconButton(
            icon: Icon(Icons.person_outline),
            onPressed: () {
              authService.signOutGoogle();
              Navigator.pop(context);
            },
          ),
        ),
        title: Text(widget.uid.toString()),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => createWeek(widget.uid),
          )
        ],
      ),
      body: Center(
        child: StreamBuilder<QuerySnapshot>(

          stream: Firestore.instance.collection("data").document(
            widget.uid
            // 'Xi2BQ9KuCwOR2MeHIHUPH5G7bTc2'
          ).collection("weeks").snapshots(),
         
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            List<DocumentSnapshot> documents = snapshot.data.documents;
            return Weeks(
              uid: widget.uid, 
              // uid: 'Xi2BQ9KuCwOR2MeHIHUPH5G7bTc2',
              weeks: documents
            );
          },
          
        ),
      ),
    );
  }
}