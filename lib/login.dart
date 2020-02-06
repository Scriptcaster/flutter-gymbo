import 'package:flutter/material.dart';
import 'home.dart';
import 'functions/auth.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  Map<String, dynamic> _profile;
  bool _loading = false;

  @override
  void initState() {
    authService.profile.listen((state) => setState(() => _profile = state));
    authService.loading.listen((state) => setState(() => _loading = state));
    print(_profile);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FlutterLogo(size: 150),
              SizedBox(height: 50),
              _signInButton(),

              IconButton(
                icon: Icon(Icons.person_outline),
                onPressed: () {
                  print(_profile['username']);
                },
              ),

              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                   authService.signOutGoogle();
                },
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _signInButton() {
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: () {
        // authService.signInWithGoogle();
        authService.signInWithGoogle().whenComplete(() {
          // Navigator.of(context).push(

           
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Home(uid: _profile['uid']),
                  ),
                );
              
            // MaterialPageRoute(
            //   builder: (context) {
            //     return Home();
            //   },
            // ),
          // );
        });
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      highlightElevation: 0,
      borderSide: BorderSide(color: Colors.grey),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(image: AssetImage("assets/google_logo.png"), height: 35.0),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text( 'Sign in with Google',
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
            )
          ],
        ),
      ),
    );
  }
}


