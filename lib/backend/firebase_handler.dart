import 'package:cloud_firestore/cloud_firestore.dart';

void resisterTask(String categories, String uid, taskMap) async {
  FirebaseFirestore db = FirebaseFirestore.instance;

// Add a new document with a generated ID
  // await db.collection(categories).add(taskMap).then((DocumentReference doc) =>
  //     print('DocumentSnapshot added with ID: ${doc.id}'));
  db.collection(categories).doc(uid).set(taskMap, SetOptions(merge: true));
}
