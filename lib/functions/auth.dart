import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';

class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final Firestore _db = Firestore.instance;

  String name;
  String email;

  // Future getCurrentUid() async {
  //   FirebaseUser _user = await FirebaseAuth.instance.currentUser();
  //   return _user.uid;
  // }

  Observable<FirebaseUser> user; // firebase user
  Observable<Map<String, dynamic>> profile; // custom user data in Firestore
  PublishSubject loading = PublishSubject();

  AuthService() {
    user = Observable(_auth.onAuthStateChanged);
    profile = user.switchMap((FirebaseUser u) {
      if (u != null) {
        return _db.collection('users').document(u.uid).snapshots().map((snap) => snap.data);
      } else {
        return Observable.just({});
      }
    });
  }

  Future<String> signInWithGoogle() async {
    loading.add(true);
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final AuthResult authResult = await _auth.signInWithCredential(credential);
    final FirebaseUser user = authResult.user;

    updateUserData(user);

    // updateData(user);

    loading.add(false);

    // _db.collection("data").document(user.uid).set('exercises')

    // DocumentReference monRef = await Firestore.instance.collection("data").add({'id': 'ok'});
    // Firestore.instance.collection("data").document(monRef.documentID).updateData({'id': monRef.documentID});
    
    // Checking if email and name is null
    assert(user.email != null);
    assert(user.displayName != null);
    name = user.displayName;
    email = user.email;
        
    // Only taking the first part of the name, i.e., First Name
    if (name.contains(" ")) {
      name = name.substring(0, name.indexOf(" "));
    }
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);
    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);
    return 'signInWithGoogle succeeded: $user';
  }

  void updateUserData(FirebaseUser user) async {
    DocumentReference ref = _db.collection('users').document(user.uid);
    return ref.setData({
      'uid': user.uid,
      'email': user.email,
    }, merge: true);
  }

  // void updateData(FirebaseUser user) async {
  //   DocumentReference ref = _db.collection('data').document(user.uid);
  //   return ref.setData({
  //     'id': user.uid,
  //   }, merge: true);
  // }

  void signOutGoogle() async {
    await googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
    print("User Sign Out");
  }
}
final AuthService authService = AuthService(); 