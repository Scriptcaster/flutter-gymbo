import 'package:cloud_firestore/cloud_firestore.dart';

var i = 0;

Future<void> createWeek(String uid) async {

  final weeksCollection = Firestore.instance.collection("data").document(uid).collection("weeks");
  QuerySnapshot weeksQuerySnapshot = await weeksCollection.orderBy('date', descending: false).getDocuments();

  if(weeksQuerySnapshot.documents.length > 0) {
    QuerySnapshot weekQuerySnapshot = await weeksCollection.document(weeksQuerySnapshot.documents.last['id']).collection('days').getDocuments();
    DocumentReference weekRef = await weeksCollection.add({ 'date': new DateTime.now(), 'number': i++,});
    weeksCollection.document(weekRef.documentID).updateData({'id': weekRef.documentID});
    List lastExercises = [];
    weekQuerySnapshot.documents.forEach((day){ lastExercises.add(day.data); });
    lastExercises.sort((a, b) => a['index'].compareTo(b['index']));

    DocumentReference monRef = await weeksCollection.document(weekRef.documentID).collection('days').add({'index': 0, 'date': 'Monday', 'target': lastExercises[0]['target'], 'exercises': lastExercises[0]['exercises']});
    weeksCollection.document(weekRef.documentID).collection('days').document(monRef.documentID).updateData({'id': monRef.documentID});

    DocumentReference tueRef = await weeksCollection.document(weekRef.documentID).collection('days').add({'index': 1, 'date': 'Tuesday', 'target': lastExercises[1]['target'], 'exercises': lastExercises[1]['exercises']});
    weeksCollection.document(weekRef.documentID).collection('days').document(tueRef.documentID).updateData({'id': tueRef.documentID});

    DocumentReference wedRef = await weeksCollection.document(weekRef.documentID).collection('days').add({'index': 2, 'date': 'Wednesday', 'target': lastExercises[2]['target'], 'exercises': lastExercises[2]['exercises']});
    weeksCollection.document(weekRef.documentID).collection('days').document(wedRef.documentID).updateData({'id': wedRef.documentID});

    DocumentReference thuRef = await weeksCollection.document(weekRef.documentID).collection('days').add({'index': 3, 'date': 'Thursday', 'target': lastExercises[3]['target'], 'exercises': lastExercises[3]['exercises']});
    weeksCollection.document(weekRef.documentID).collection('days').document(thuRef.documentID).updateData({'id': thuRef.documentID});

    DocumentReference friRef = await weeksCollection.document(weekRef.documentID).collection('days').add({'index': 4, 'date': 'Friday', 'target': lastExercises[4]['target'], 'exercises': lastExercises[4]['exercises']});
    weeksCollection.document(weekRef.documentID).collection('days').document(friRef.documentID).updateData({'id': friRef.documentID});

    DocumentReference satRef = await weeksCollection.document(weekRef.documentID).collection('days').add({'index': 5, 'date': 'Saturday', 'target': lastExercises[5]['target'], 'exercises': lastExercises[5]['exercises']});
    weeksCollection.document(weekRef.documentID).collection('days').document(satRef.documentID).updateData({'id': satRef.documentID});

    DocumentReference sunRef = await weeksCollection.document(weekRef.documentID).collection('days').add({'index': 6, 'date': 'Sunday', 'target': lastExercises[6]['target'], 'exercises': lastExercises[6]['exercises']});
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
    exercisesCollection.document(exerciseRef.documentID).updateData({'id': exerciseRef.documentID, 'name': 'Bench Press', 'bestVolume': 0});

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