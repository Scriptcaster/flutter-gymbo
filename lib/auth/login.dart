import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../home.dart';

import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

// import 'package:flutter_biopass/flutter_biopass.dart';

// import 'package:flutter_keychain/flutter_keychain.dart';

// import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);
  final localAuth = LocalAuthentication();

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  TextEditingController emailInputController;
  TextEditingController pwdInputController;

  // final bioPass = BioPass();

  final storage = new FlutterSecureStorage();

  @override
  initState() {
    emailInputController = new TextEditingController();
    pwdInputController = new TextEditingController();
    super.initState();
  }

  // Create storage
  // final storage = new FlutterSecureStorage();
  // var _prefs = SharedPreferences.getInstance();

  // Future<bool> _setMobileToken(String username, String password) async {
  //   final SharedPreferences prefs = await _prefs;
  //   prefs.setString("username", username);
  //   prefs.setString("userID", password);
  // }

  final _localAuthentication = LocalAuthentication();

  // To check if any type of biometric authentication hardware is available.
  Future<bool> _isBiometricAvailable() async {

    // final checkResult = await widget.localAuth.canCheckBiometrics;
    // final getResult = await widget.localAuth.getAvailableBiometrics();

    bool isAvailable = false;
    try {
      isAvailable = await widget.localAuth.canCheckBiometrics;
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return isAvailable;
    isAvailable ? print('Biometric is available!') : print('Biometric is unavailable.');
    return isAvailable = true;
  }

  // To retrieve the list of biometric types
  Future<void> _getListOfBiometricTypes() async {
    List<BiometricType> listOfBiometrics;
    try {
      listOfBiometrics = await _localAuthentication.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;
    print(listOfBiometrics);
  }

  // Process of authentication user using biometrics.
  Future<void> _authenticateUser() async {
    bool isAuthenticated = false;
    try {
      isAuthenticated = await _localAuthentication.authenticateWithBiometrics(
        localizedReason: "Please authenticate to view your transaction overview",
        useErrorDialogs: true,
        stickyAuth: true,
      );
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;
    isAuthenticated ? print('User is authenticated!') : print('User is not authenticated.');
    if (isAuthenticated) {
      Map<String, String> allValues = await storage.readAll();
      final FirebaseAuth auth = FirebaseAuth.instance;
      AuthResult result = await auth.signInWithEmailAndPassword(email: allValues['email'], password: allValues['password']);
      final FirebaseUser currentUser = result.user;
      Firestore.instance.collection("users").document(currentUser.uid).get().then((DocumentSnapshot result) =>
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => HomePage(
            title: result["email"],
            uid: currentUser.uid,
          )
        ))
      ).catchError((err) => print(err));
    }
  }

  String emailValidator(String value) {
    Pattern pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value)) { return 'Email format is invalid'; } else { return null; }
  }

  String pwdValidator(String value) {
    if (value.length < 8) { return 'Password must be longer than 8 characters'; } else { return null; }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0), child: SingleChildScrollView(
          child: Form(
            key: _loginFormKey, child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                  labelText: 'Email*', hintText: "john.doe@gmail.com"),
                  controller: emailInputController,
                  keyboardType: TextInputType.emailAddress,
                  validator: emailValidator,
                ),
                TextFormField(
                  decoration: InputDecoration(
                      labelText: 'Password*', hintText: "********"),
                  controller: pwdInputController,
                  obscureText: true,
                  validator: pwdValidator,
                ),
                RaisedButton(
                  child: Text("Login"),
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  onPressed: () async {
                    if (_loginFormKey.currentState.validate()) {
                      final FirebaseAuth auth = FirebaseAuth.instance;
                      AuthResult result = await auth.signInWithEmailAndPassword(email: emailInputController.text, password: pwdInputController.text);
                      await storage.deleteAll();
                      await storage.write(key: 'email', value:  emailInputController.text);
                      await storage.write(key: 'password', value: pwdInputController.text);
                      final FirebaseUser currentUser = result.user;
                      Firestore.instance.collection("users").document(currentUser.uid).get().then((DocumentSnapshot result) =>
                        Navigator.pushReplacement(context, MaterialPageRoute(
                          builder: (context) => HomePage(
                            title: result["email"],
                            uid: currentUser.uid,
                          )
                        ))
                      ).catchError((err) => print(err));
                    }
                  },
                ),
                Text("Don't have an account yet?"),
                FlatButton(
                  child: Text("Register here!"),
                  onPressed: () {
                    Navigator.pushNamed(context, "/register");
                  },
                ),

                FlatButton(
                  child: Text("Finger ID"),
                  onPressed: () async {
                    if (await _isBiometricAvailable()) {
                      print('AVAILABLE!');
                      await _getListOfBiometricTypes();
                      await _authenticateUser();
                    }
                  },
                ),

                // FlatButton(
                //   child: Text("TEST"),
                //   onPressed: () async {
                //     await storage.deleteAll();
                //     await storage.write(key: 'email', value: 'oliver@email.com');
                //     await storage.write(key: 'password', value: 'tgi86shift');
                //   },
                // ),

              ],
            ),
          )
        )
      )
    );
  }
}