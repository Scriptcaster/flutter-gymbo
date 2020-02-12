import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../home.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({Key key, this.email}) : super(key: key);
  final String email;
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();
  TextEditingController emailInputController;
  TextEditingController pwdInputController;
  TextEditingController confirmPwdInputController;

  final storage = new FlutterSecureStorage();

  @override
  initState() {
    emailInputController = new TextEditingController();
    pwdInputController = new TextEditingController();
    confirmPwdInputController = new TextEditingController();
    emailInputController.text = widget.email;
    super.initState();
  }

  String emailValidator(String value) {
    Pattern pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Email format is invalid';
    } else {
      return null;
    }
  }

  String pwdValidator(String value) {
    if (value.length < 8) {
      return 'Password must be longer than 8 characters';
    } else {
      return null;
    }
  }

  Widget showEmailInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
      child: new TextFormField(
        decoration: new InputDecoration(
        hintText: 'Email',
        icon: new Icon(
          Icons.mail,
          color: Colors.grey,
        )),
        controller: emailInputController,
        keyboardType: TextInputType.emailAddress,
        validator: emailValidator,
      ),
    );
  }

  Widget showPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
      child: new TextFormField(
          decoration: new InputDecoration(
          hintText: 'Password',
          icon: new Icon(
            Icons.lock,
            color: Colors.grey,
          )),
        controller: pwdInputController,
        obscureText: true,
        validator: pwdValidator,
      ),
    );
  }

   Widget showConfirmPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
      child: new TextFormField(
          decoration: new InputDecoration(
          hintText: 'Confirm Password',
          icon: new Icon(
            Icons.lock,
            color: Colors.grey,
          )),
        controller: confirmPwdInputController,
        obscureText: true,
        validator: pwdValidator,
      ),
    );
  }

  Widget showPrimaryButton() {
    return new Padding(
      padding: EdgeInsets.fromLTRB(0.0, 40.0, 0.0, 30.0),
      child: SizedBox(
        height: 40.0,
        child: new RaisedButton(
          elevation: 2.0,
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30.0)),
          color: Colors.blue,
          child: new Text(
            // _isLoginForm ? 
            'Sign Up',
            // : 'Create account',
            style: new TextStyle(fontSize: 20.0, color: Colors.white)),
             onPressed: () async {
              if (_registerFormKey.currentState.validate()) {
                if (pwdInputController.text == confirmPwdInputController.text) {
                  await storage.deleteAll();
                  await storage.write(key: 'email', value:  emailInputController.text);
                  await storage.write(key: 'password', value: pwdInputController.text);
                  final FirebaseAuth auth = FirebaseAuth.instance;
                  AuthResult result = await auth.createUserWithEmailAndPassword(email: emailInputController.text, password: pwdInputController.text);
                  final FirebaseUser currentUser = result.user;
                  // FirebaseAuth.instance.createUserWithEmailAndPassword(email: emailInputController.text, password: pwdInputController.text).then((currentUser) => 
                  Firestore.instance.collection("users").document(currentUser.uid).setData({
                    "uid": currentUser.uid,
                    "email": emailInputController.text,
                  }).then((result) => {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(
                        title: 'Home',
                        uid: currentUser.uid,
                      )
                    ), (_) => false),
                  emailInputController.clear(),
                  pwdInputController.clear(),
                  confirmPwdInputController.clear()
                })
                .catchError((err) => print(err));
                // .catchError((err) => print(err)
              } else {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Error"),
                        content: Text("The passwords do not match"),
                        actions: <Widget>[
                          FlatButton(
                            child: Text("Close"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          )
                        ],
                      );
                    });
                  }
                }
              },
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Register"),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(16.0),
            child: new Form(
              key: _registerFormKey,
              child: new ListView(
                shrinkWrap: true,
                children: <Widget>[
                  showEmailInput(),
                  showPasswordInput(),
                  showConfirmPasswordInput(),
                  showPrimaryButton(),
                  Text("Already have an account?", textAlign: TextAlign.center,),
                  FlatButton(
                    child: Text("Login here!"),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              ),
            )
          ),
        ],
      ),
    );
  }


}