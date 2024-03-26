import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_calandar_app/backend/DB/handler/schedule_import_db.dart';
import "./DB/handler/schedule_db_handler.dart";
import 'package:uuid/uuid.dart';
import "./DB/handler/schedule_id_db_handler.dart";

void resisterTask(String categories, String uid, taskMap) async {
// Add a new document with a generated ID
  // await db.collection(categories).add(taskMap).then((DocumentReference doc) =>
  //     print('DocumentSnapshot added with ID: ${doc.id}'));
}

Future<Map<String, List<Map<String, dynamic>>>> postScheduleToFB(
    int tagID) async {
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<Map<String, dynamic>> postScheduleList =
      await ScheduleDatabaseHelper().pickScheduleByTag(tagID);

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
  Map<String, List<Map<String, dynamic>>> schedule = {
    scheduleID: postScheduleList
  };
  ScheduleIDDatabaseHelper()
      .insertScheduleID({"scheduleID": scheduleID, "tagID": tagID});
  return schedule;
}

Future<Map<String, List<Map<String, dynamic>>>> receiveSchedule(
    String scheduleID) async {
  FirebaseFirestore db = FirebaseFirestore.instance;
  final docRef = db.collection("schedule").doc(scheduleID);

  try {
    DocumentSnapshot doc = await docRef.get();
    final data = doc.data();
    if (data is Map<String, dynamic>) {
      final datalist = data["schedule"] as List<dynamic>;
      ImportedScheduleDatabaseHelper()
          .importScheduleToDB(datalist.cast<Map<String, dynamic>>());

      return {scheduleID: datalist.cast<Map<String, dynamic>>()};
    } else {
      throw "データが予期せず不正な形式です";
    }
  } catch (e) {
    return {}; // エラーが発生した場合は空のリストを返す
  }
}
