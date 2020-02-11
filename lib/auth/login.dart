import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../home.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  TextEditingController emailInputController;
  TextEditingController pwdInputController;

  final _localAuthentication = LocalAuthentication();
  final storage = new FlutterSecureStorage();

  bool _isLoginForm = true;
  bool _isLoading = false;
  String _errorMessage;

  @override
  initState() {
    emailInputController = new TextEditingController();
    pwdInputController = new TextEditingController();
    super.initState();
  }

  // Check if form is valid before perform login or signup
  bool validateAndSave() {
    final form = _loginFormKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void toggleFormMode() {
    // resetForm();
    setState(() {
      _isLoginForm = !_isLoginForm;
    });
  }


  // To check if any type of biometric authentication hardware is available.
  Future<bool> _isBiometricAvailable() async {
    bool isAvailable = false;
    try { isAvailable = await _localAuthentication.canCheckBiometrics; } on PlatformException catch (e) {print(e);}
    if (!mounted) return isAvailable;
    isAvailable ? print('Biometric is available!') : print('Biometric is unavailable.');
    return isAvailable = true;
  }

  // To retrieve the list of biometric types
  Future<void> _getListOfBiometricTypes() async {
    List<BiometricType> listOfBiometrics;
    try { 
      listOfBiometrics = await _localAuthentication.getAvailableBiometrics();
    } on PlatformException catch (e) { print(e); }
    if (!mounted) return;
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
    } on PlatformException catch (e) { print(e); }
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
            title: result['email'],
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

  Widget showCircularProgress() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }

  void validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });
    if (_loginFormKey.currentState.validate()) {
      try {
        if (_isLoginForm) {

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

        } else {

          await storage.deleteAll();
          await storage.write(key: 'email', value:  emailInputController.text);
          await storage.write(key: 'password', value: pwdInputController.text);
          final FirebaseAuth auth = FirebaseAuth.instance;
          AuthResult result = await auth.createUserWithEmailAndPassword(email: emailInputController.text, password: pwdInputController.text);
          final FirebaseUser currentUser = result.user;
          Firestore.instance.collection("users").document(currentUser.uid).setData({
            "uid": currentUser.uid,
            "email": emailInputController.text,
          }).then((result) => {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(
                title: emailInputController.text,
                uid: currentUser.uid,
              )
            ), (_) => false),
          emailInputController.clear(),
          pwdInputController.clear(),
        })
        .catchError((err) => print(err));

        }
        setState(() {
          _isLoading = false;
        });

        // if (userId.length > 0 && userId != null && _isLoginForm) {
        //   widget.loginCallback();
        // }
      } catch (e) {
        print('Error: $e');
        setState(() {
          _isLoading = false;
          _errorMessage = e.message;
          _loginFormKey.currentState.reset();
        });
      }
    }
  }

  Widget showLogo() {
    // if (!_isLoading) {
      return new Hero(
        tag: 'hero',
        child: Padding(
          padding: EdgeInsets.fromLTRB(0.0, 70.0, 0.0, 0.0),
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 60.0,
            child: Image.asset('assets/google_logo.png'),
          ),
        ),
      );
    // }
  }

  Widget showEmailInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
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
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
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

  Widget showPrimaryButton() {
    return new Padding(
      padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
      child: SizedBox(
        height: 40.0,
        child: new RaisedButton(
          elevation: 5.0,
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30.0)),
          color: Colors.blue,
          child: new Text(_isLoginForm ? 'Login' : 'Create account',
              style: new TextStyle(fontSize: 20.0, color: Colors.white)),
          onPressed: validateAndSubmit,
        ),
      )
    );
  }

  Widget showSecondaryButton() {
    return new FlatButton(
      child: new Text(
          _isLoginForm ? 'Create an account' : 'Have an account? Sign in',
          style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300)),
      onPressed: toggleFormMode
    );
  }

  Widget showErrorMessage() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return new Text(
        _errorMessage,
        style: TextStyle(
            fontSize: 13.0,
            color: Colors.red,
            height: 1.0,
            fontWeight: FontWeight.w300),
      );
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login Screen"),
         actions: <Widget>[
          IconButton(
            icon: Icon(Icons.fingerprint),
            onPressed: () async {
              if (await _isBiometricAvailable()) {
                await _getListOfBiometricTypes();
                await _authenticateUser();
              }
            },
          )
        ],
      ),

      body: Stack(
        children: <Widget>[
         Container(
            padding: EdgeInsets.all(16.0),
            child: new Form(
              key: _loginFormKey,
              child: new ListView(
                shrinkWrap: true,
                children: <Widget>[
                  showCircularProgress(),
                  showLogo(),
                  showEmailInput(),
                  showPasswordInput(),
                  showPrimaryButton(),
                  showSecondaryButton(),
                  // showErrorMessage(),
                ],
              ),
            )
          ),
        ],
      ),
    );
  }

}