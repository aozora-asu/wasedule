import 'package:cloud_firestore/cloud_firestore.dart';
import "./DB/handler/schedule_db_handler.dart";
import 'package:uuid/uuid.dart';

void resisterTask(String categories, String uid, taskMap) async {
// Add a new document with a generated ID
  // await db.collection(categories).add(taskMap).then((DocumentReference doc) =>
  //     print('DocumentSnapshot added with ID: ${doc.id}'));
}

Future<String> postScheduleToFB(String tag) async {
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<Map<String, dynamic>> postScheduleList =
      await ScheduleDatabaseHelper().pickScheduleByTag(tag);
  Map<String, List<Map<String, dynamic>>> postSchedule = {
    "schedule": postScheduleList
  };
  String scheduleID = "";
  while (true) {
    scheduleID = const Uuid().v4();
    final docRef = db.collection("schedule").doc(scheduleID);
    final snapshot = await docRef.get();
    if (!snapshot.exists) {
      db.collection("schedule").doc(scheduleID).set(postSchedule);
      break;
    }
  }
  return scheduleID;
}

Future<List<Map<String, dynamic>>> receiveSchedule(String scheduleID) async {
  FirebaseFirestore db = FirebaseFirestore.instance;
  final docRef = db.collection("schedule").doc(scheduleID);

  try {
    DocumentSnapshot doc = await docRef.get();
    final data = doc.data() as List<Map<String, dynamic>>;
    return data;
  } catch (e) {
    return []; // エラーが発生した場合は空のリストを返す
  }
}
