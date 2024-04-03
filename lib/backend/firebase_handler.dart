import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_calandar_app/backend/DB/handler/schedule_import_db.dart';
import 'package:flutter_calandar_app/backend/DB/handler/tag_db_handler.dart';
import 'package:intl/intl.dart';
import "./DB/handler/schedule_db_handler.dart";
import 'package:uuid/uuid.dart';
import "DB/handler/schedule_metaInfo_db_handler.dart";

Future<String> postScheduleToFB(String tagID, int remainDay) async {
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<Map<String, dynamic>> postScheduleList =
      await ScheduleDatabaseHelper().pickScheduleByTag(tagID);
  Map<String, dynamic> tag = await TagDatabaseHelper().getTagByTagID(tagID);
  String expireDate = DateTime.now().add(Duration(days: remainDay)).toString();
  Map<String, dynamic> postSchedule = {
    "schedule": postScheduleList,
    "tag": tag,
    "dtEnd": expireDate
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

  await ScheduleMetaDatabaseHelper().exportSchedule({
    "scheduleID": scheduleID,
    "tagID": tagID,
    "scheduleType": "export",
    "dtEnd": expireDate
  });
  return scheduleID;
}

Future<void> receiveSchedule(String scheduleID) async {
  FirebaseFirestore db = FirebaseFirestore.instance;
  final docRef = db.collection("schedule").doc(scheduleID);

  try {
    DocumentSnapshot doc = await docRef.get();
    final data = doc.data();
    if (data is Map<String, dynamic>) {
      final scheduleList = data["schedule"] as List<dynamic>;
      final tagData = data["tag"] as Map<String, dynamic>;
      final dtEnd = data["dtEnd"] as String;
      await TagDatabaseHelper().resisterTagToDB(tagData);
      await ScheduleDatabaseHelper()
          .resisterScheduleListToDB(scheduleList.cast<Map<String, dynamic>>());
      await ScheduleMetaDatabaseHelper().importSchedule({
        "scheduleID": scheduleID,
        "tagID": tagData["tagID"],
        "scheduleType": "import",
        "dtEnd": dtEnd
      });

      return;
    } else {
      throw "データが予期せず不正な形式です";
    }
  } catch (e) {
    return; // エラーが発生した場合は空のリストを返す
  }
}
