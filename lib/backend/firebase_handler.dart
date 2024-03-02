import 'package:cloud_firestore/cloud_firestore.dart';

void resisterTask(taskMap) async {
  FirebaseFirestore db = FirebaseFirestore.instance;

// Add a new document with a generated ID
  await db.collection("assignment").add(taskMap).then((DocumentReference doc) =>
      print('DocumentSnapshot added with ID: ${doc.id}'));
}
