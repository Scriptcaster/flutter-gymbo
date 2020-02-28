class User {
  final String uid;

  const User({
    this.uid,
  });

  Map<String, dynamic> toJson() => {
    'uid': uid,
  };

Future getCurrentUserId() async {
  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
  final AuthCredential credential = GoogleAuthProvider.getCredential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );
  final AuthResult authResult = await _auth.signInWithCredential(credential);
  final FirebaseUser user = authResult.user;
  String toString(){
    return "{id: $user.uid }";
  }
}

  // String toString(){
  //   return "{id: $id, name: $name, bestVolume: $bestVolume}";
  // }
}