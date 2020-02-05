
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'functions/create_week.dart';
import 'functions/auth.dart';
import 'weeks.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({this.firestore});
  final Firestore firestore;
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic> _profile;
  bool _loading = false;

  @override
  void initState() {
    authService.profile.listen((state) => setState(() => _profile = state));
    authService.loading.listen((state) => setState(() => _loading = state));
    super.initState();
  }

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
        title: Text(_profile['uid'].toString()),
        // title: Text('My Weeks'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => createWeek(),
          )
        ],
      ),
      body: Center(
        child: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collection("data").document(_profile['uid']).collection("weeks").snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            List<DocumentSnapshot> documents = snapshot.data.documents;
            return CustomWeek(weeks: documents);
          },
        ),
      ),
    );
  }
}
