import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../home.dart';

class SplashPage extends StatefulWidget {
  SplashPage({Key key}) : super(key: key);
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  initState() {
    FirebaseAuth.instance.currentUser().then((currentUser) => {
      if (currentUser == null) {
        Navigator.pushReplacementNamed(context, "/login")
      } else {
        Firestore.instance.collection("users").document(currentUser.uid).get().then((DocumentSnapshot result) =>
          Navigator.pushReplacement(context, 
            MaterialPageRoute(
              builder: (context) => HomePage(
                title: result["email"],
                uid: currentUser.uid,
              )
            )
          )
        ).catchError((err) => print(err))
      }
    }).catchError((err) => print(err));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
         Container(
            padding: EdgeInsets.all(16.0),
            child: new ListView(
              shrinkWrap: true,
              children: <Widget>[
                showLogo(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget showLogo() {
    return new Hero(
      tag: 'hero',
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 180.0, 0.0, 0.0),
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 100.0,
          child: Image.asset('assets/logo.png'),
        ),
      ),
    );
  }

}