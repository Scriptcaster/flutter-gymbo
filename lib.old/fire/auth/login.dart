import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../home_fire.dart';
import 'register.dart';

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

  bool _isLoading;
  String _errorMessage;

  @override
  initState() {
    emailInputController = new TextEditingController();
    pwdInputController = new TextEditingController();
    _isLoading = false;
    super.initState();
  }

  void resetForm() {
    _loginFormKey.currentState.reset();
    _errorMessage = "";
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
    } else {
      showDialog(context: context, builder: (BuildContext context) {
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

  String emailValidator(String value) {
    value = value.trim();
    Pattern pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value)) { return 'Email format is invalid'; } else { return null; }
  }

  String pwdValidator(String value) {
    if (value.length < 8) { return 'Password must be longer than 8 characters'; } else { return null; }
  }

  void validateAndSubmit() async {
    
    if (_loginFormKey.currentState.validate()) {
      setState(() {
        _errorMessage = "";
        _isLoading = true;
      });
      try {
        final FirebaseAuth auth = FirebaseAuth.instance;
        AuthResult result = await auth.signInWithEmailAndPassword(email: emailInputController.text.trim(), password: pwdInputController.text);
        await storage.deleteAll();
        await storage.write(key: 'email', value:  emailInputController.text.trim());
        await storage.write(key: 'password', value: pwdInputController.text);
        final FirebaseUser currentUser = result.user;
        Firestore.instance.collection("users").document(currentUser.uid).get().then((DocumentSnapshot result) =>
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => HomePage(
              title: currentUser.email,
              uid: currentUser.uid,
            )
          ))
        ).catchError((err) => print(err));
        setState(() {
          _isLoading = false;
        });
      } catch (e) {
        print('Error: $e');
        setState(() {
          _isLoading = false;
          _errorMessage = e.message;
          _loginFormKey.currentState.reset();
        });
        showDialog( context: context, builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error", textAlign: TextAlign.center,),
            content: Text(_errorMessage, textAlign: TextAlign.center,),
            actions: <Widget>[
              FlatButton(
                child: Text("Close", textAlign: TextAlign.center,),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Stack(
        children: <Widget>[
          _showForm(),
          _showCircularProgress(),
        ],
      ),
    );
  }

  Widget _showCircularProgress() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }

  Widget _showForm() {
    return new Container(
      padding: EdgeInsets.all(16.0),
      child: new Form(
        key: _loginFormKey,
        child: new ListView(
          shrinkWrap: true,
          children: <Widget>[
            showLogo(),
            showEmailInput(),
            showPasswordInput(),
            showPrimaryButton(),
            showSecondaryButton(),
            showFingerprintButton(),
          ],
        ),
      )
    );
  }

  Widget showLogo() {
    return new Hero(
      tag: 'hero',
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 60.0, 0.0, 0.0),
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 80.0,
          child: Image.asset('assets/logo.png'),
        ),
      ),
    );
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

  Widget showPrimaryButton() {
    return new Padding(
      padding: EdgeInsets.fromLTRB(0.0, 40.0, 0.0, 15.0),
      child: SizedBox(
        height: 40.0,
        child: new RaisedButton(
          elevation: 2.0,
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30.0)),
          color: Colors.blue,
          child: new Text(
            // _isLoginForm ? 
            'Login',
            // : 'Create account',
            style: new TextStyle(fontSize: 20.0, color: Colors.white)),
          onPressed: validateAndSubmit,
        ),
      )
    );
  }

  Widget showSecondaryButton() {
    return new FlatButton(
      child: new Text(
        // _isLoginForm ? 
        'Create an account', 
        // : 'Have an account? Sign in',
        style: new TextStyle(fontSize: 14.0, fontWeight: FontWeight.w300)),
      onPressed: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => 
            RegisterPage(
              email: emailInputController.text.trim(),
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              var begin = Offset(0.0, 1.0);
              var end = Offset.zero;
              var curve = Curves.ease;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          )
        );
      },
    );
  }

  Widget showFingerprintButton() {
    return new IconButton(
      color: Colors.blue,
      icon: Icon(Icons.fingerprint),
      onPressed: () async {
        if (await _isBiometricAvailable()) {
          await _getListOfBiometricTypes();
          await _authenticateUser();
        }
      },
    );
  }

}