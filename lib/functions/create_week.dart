import 'package:cloud_firestore/cloud_firestore.dart';

// Future <LoginPage> _signOut()  async {
  //   print('signout');
  //   await FirebaseAuth.instance.signOut();
  //   return new LoginPage();
  // }

  // Future getCurrentUser() async {
  //   FirebaseUser _user = await FirebaseAuth.instance.currentUser();
  //   print("User: ${_user.uid ?? "None"}");
  //   return _user;
  // }

  // Future<String> inputData() async {
  //   final FirebaseUser user = await FirebaseAuth.instance.currentUser();
  //   final String uid = user.uid.toString();
  // return uid;
  // }

  // FirebaseAuth auth = FirebaseAuth.instance;


  // getUID() async {
  //   final FirebaseUser user = await auth.currentUser();
  //   final uid = user.uid;
  //  return  uid;
  // }

  // final documentId = await getUID();

// final weeksCollection = Firestore.instance.collection("data").document('Xi2BQ9KuCwOR2MeHIHUPH5G7bTc2').collection("weeks");
// final exercisesCollection = Firestore.instance.collection("data").document('Xi2BQ9KuCwOR2MeHIHUPH5G7bTc2').collection("exercises");

var i = 0;
var weeksId;

Future<void> createWeek(String uid) async {

  List defaultExercises = [{'name': 'Bench Press', 'volume': 5760, 'sets': [{ 'weight': 120, 'set': 4, 'rep': 12 }] }];

  final weeksCollection = Firestore.instance.collection("data").document(uid).collection("weeks");

  QuerySnapshot weeksQuerySnapshot = await weeksCollection.orderBy('date', descending: false).getDocuments();
  if(weeksQuerySnapshot.documents.length > 0) {
    
    QuerySnapshot weekQuerySnapshot = await weeksCollection.document(weeksQuerySnapshot.documents.last['id']).collection('days').getDocuments();

    DocumentReference weekRef = await weeksCollection.add({ 'date': new DateTime.now(), 'number': i++,});
    weeksCollection.document(weekRef.documentID).updateData({'id': weekRef.documentID});

    List lastExercises = [];
    weekQuerySnapshot.documents.forEach((day){ lastExercises.add(day.data); });

    lastExercises.sort((a, b) => a['index'].compareTo(b['index']));

    DocumentReference monRef = await weeksCollection.document(weekRef.documentID).collection('days').add({ 
      'index': 0, 
      'date': 'Monday', 
      'target': 'Chest & Triceps', 
      'exercises': lastExercises[0]['exercises']
    });
    weeksCollection.document(weekRef.documentID).collection('days').document(monRef.documentID).updateData({'id': monRef.documentID});

    DocumentReference tueRef = await weeksCollection.document(weekRef.documentID).collection('days').add({ 
      'index': 1, 
      'date': 'Tuesday', 
      'target': 'Legs & Abs', 
      'exercises': lastExercises[1]['exercises']
    });
    weeksCollection.document(weekRef.documentID).collection('days').document(tueRef.documentID).updateData({'id': tueRef.documentID});

    DocumentReference wedRef = await weeksCollection.document(weekRef.documentID).collection('days').add({ 
      'index': 2, 
      'date': 'Wednesday', 
      'target': 'Day Off', 
      'exercises': lastExercises[2]['exercises']
    });
    weeksCollection.document(weekRef.documentID).collection('days').document(wedRef.documentID).updateData({'id': wedRef.documentID});

    DocumentReference thuRef = await weeksCollection.document(weekRef.documentID).collection('days').add({ 
      'index': 3, 
      'date': 'Thursday', 
      'target': 'Back & Biceps', 
      'exercises': lastExercises[3]['exercises']
    });
    weeksCollection.document(weekRef.documentID).collection('days').document(thuRef.documentID).updateData({'id': thuRef.documentID});

    DocumentReference friRef = await weeksCollection.document(weekRef.documentID).collection('days').add({ 
      'index': 4, 
      'date': 'Friday', 
      'target': 'Shoulders & Abs', 
      'exercises': lastExercises[4]['exercises']
    });
    weeksCollection.document(weekRef.documentID).collection('days').document(friRef.documentID).updateData({'id': friRef.documentID});

    DocumentReference satRef = await weeksCollection.document(weekRef.documentID).collection('days').add({ 
      'index': 5, 
      'date': 'Saturday', 
      'target': 'Day Off', 
      'exercises': lastExercises[5]['exercises']
    });
    weeksCollection.document(weekRef.documentID).collection('days').document(satRef.documentID).updateData({'id': satRef.documentID});

    DocumentReference sunRef = await weeksCollection.document(weekRef.documentID).collection('days').add({ 
      'index': 6, 
      'date': 'Sunday', 
      'target': 'Day Off', 
      'exercises': lastExercises[6]['exercises']
    });
    weeksCollection.document(weekRef.documentID).collection('days').document(sunRef.documentID).updateData({'id': sunRef.documentID});

    final exercisesCollection = Firestore.instance.collection("data").document(uid).collection("exercises");
    lastExercises.forEach((item) {
      item['exercises'].forEach((exercise) {
        if(exercise['volume'] > exercise['bestVolume']) {
          exercisesCollection.document(exercise['bestVolumeId']).updateData({'bestVolume': exercise['volume'] });
        }
      });
    });

  } else {

    final exercisesCollection = Firestore.instance.collection("data").document(uid).collection("exercises");
    DocumentReference exerciseRef = await exercisesCollection.add({});
    exercisesCollection.document(exerciseRef.documentID).updateData({'id': exerciseRef.documentID});

    DocumentReference weekRef = await weeksCollection.add({ 'date': new DateTime.now(), 'number': i++,});
    weeksCollection.document(weekRef.documentID).updateData({'id': weekRef.documentID});

    DocumentReference monRef = await weeksCollection.document(weekRef.documentID).collection('days').add({'index': 0, 'date': 'Monday'});
    weeksCollection.document(weekRef.documentID).collection('days').document(monRef.documentID).updateData({'id': monRef.documentID});

    DocumentReference tueRef = await weeksCollection.document(weekRef.documentID).collection('days').add({'index': 1, 'date': 'Tuesday'});
    weeksCollection.document(weekRef.documentID).collection('days').document(tueRef.documentID).updateData({'id': tueRef.documentID});

    DocumentReference wedRef = await weeksCollection.document(weekRef.documentID).collection('days').add({'index': 2, 'date': 'Wednesday'});
    weeksCollection.document(weekRef.documentID).collection('days').document(wedRef.documentID).updateData({'id': wedRef.documentID});

    DocumentReference thuRef = await weeksCollection.document(weekRef.documentID).collection('days').add({'index': 3, 'date': 'Thursday'});
    weeksCollection.document(weekRef.documentID).collection('days').document(thuRef.documentID).updateData({'id': thuRef.documentID});

    DocumentReference friRef = await weeksCollection.document(weekRef.documentID).collection('days').add({'index': 4, 'date': 'Friday' });
    weeksCollection.document(weekRef.documentID).collection('days').document(friRef.documentID).updateData({'id': friRef.documentID});

    DocumentReference satRef = await weeksCollection.document(weekRef.documentID).collection('days').add({'index': 5, 'date': 'Saturday' });
    weeksCollection.document(weekRef.documentID).collection('days').document(satRef.documentID).updateData({'id': satRef.documentID});

    DocumentReference sunRef = await weeksCollection.document(weekRef.documentID).collection('days').add({'index': 6, 'date': 'Sunday' });
    weeksCollection.document(weekRef.documentID).collection('days').document(sunRef.documentID).updateData({'id': sunRef.documentID});
  }
}