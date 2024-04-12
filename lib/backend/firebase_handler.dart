import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter_calandar_app/backend/DB/handler/task_db_handler.dart";
import "package:intl/intl.dart";
import 'package:ulid/ulid.dart';

import "DB/handler/schedule_metaInfo_db_handler.dart";
import "DB/handler/arbeit_db_handler.dart";
import "DB/handler/schedule_template_db_handler.dart";
import 'package:flutter_calandar_app/backend/DB/handler/tag_db_handler.dart';
import "./DB/handler/schedule_db_handler.dart";
import "DB/handler/todo_db_handler.dart";
import "DB/handler/user_info_db_handler.dart";

String insertHyphens(String input) {
  const chunkSize = 4;
  final chunks = <String>[];

  for (var i = 0; i < input.length; i += chunkSize) {
    var end = (i + chunkSize <= input.length) ? i + chunkSize : input.length;
    chunks.add(input.substring(i, end));
  }

  return chunks.join('-');
}

bool isValidInput(String input) {
  int len = 0;

  for (int i = 0; i < input.length; i++) {
    RegExp regex = RegExp(r'[ -~]');
    len += regex.hasMatch(input[i]) ? 1 : 2;
  }

  return len <= 32;
}

Future<bool> isResisteredScheduleID(String scheduleID) async {
  FirebaseFirestore db = FirebaseFirestore.instance;
  final docRef = db.collection("schedule").doc(scheduleID);
  final snapshot = await docRef.get();
  return snapshot.exists;
}

Future<bool> postScheduleToFB(
    String scheduleID, String tagID, int remainDay) async {
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<Map<String, dynamic>> postScheduleList =
      await ScheduleDatabaseHelper().pickScheduleByTag(tagID);
  Map<String, dynamic> tag = await TagDatabaseHelper().getTagByTagID(tagID);
  String expireDate = DateFormat("yyyy-MM-dd 00:00:00.000000")
      .format(DateTime.now().add(Duration(days: remainDay + 1)));
  Map<String, dynamic> postSchedule = {
    "schedule": postScheduleList,
    "tag": tag,
    "dtEnd": expireDate
  };
  try {
    await db.collection("schedule").doc(scheduleID).set(postSchedule);

    await ScheduleMetaDatabaseHelper().exportSchedule({
      "scheduleID": scheduleID,
      "tagID": tagID,
      "scheduleType": "export",
      "dtEnd": expireDate
    });
    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> receiveSchedule(String scheduleID) async {
  FirebaseFirestore db = FirebaseFirestore.instance;
  final docRef = db.collection("schedule").doc(scheduleID);

  try {
    DocumentSnapshot doc = await docRef.get();
    final data = doc.data();
    if (data is Map<String, dynamic>) {
      final scheduleList = (data["schedule"] as List<dynamic>)
          .map((item) => item as Map<String, dynamic>)
          .toList();
      final tagData = data["tag"] as Map<String, dynamic>;

      await TagDatabaseHelper().resisterTagToDB(tagData);
      await ScheduleDatabaseHelper().resisterScheduleListToDB(scheduleList);
      await ScheduleMetaDatabaseHelper().importSchedule({
        "scheduleID": scheduleID,
        "tagID": tagData["tagID"],
        "scheduleType": "import",
        "dtEnd": null
      });

      return true;
    } else {
      throw "データが予期せず不正な形式です";
    }
  } catch (e) {
    return false; // エラーが発生した場合は空のリストを返す
  }
}

Future<String?> backup() async {
  const int remainDay = 7;
  Map<String, String?> backupInfo = await UserDatabaseHelper().getBackupInfo();

  String? backupID = backupInfo["backupID"];
  late String expireDate;
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<Map<String, dynamic>> scheduleList =
      await ScheduleDatabaseHelper().getScheduleFromDB();
  List<Map<String, dynamic>> tagList = await TagDatabaseHelper().getTagFromDB();
  List<Map<String, dynamic>> scheduleTemplateList =
      await ScheduleTemplateDatabaseHelper().getScheduleTemplateFromDB();
  List<Map<String, dynamic>> scheduleMetaInfoList =
      await ScheduleMetaDatabaseHelper().getScheduleMetaInfoFromDB();
  List<Map<String, dynamic>> toDoList =
      await DataBaseHelper().getAllDataFromMyTable();
  List<Map<String, dynamic>> toDoTemplateList =
      await TemplateDataBaseHelper().getAllDataFromMyTable();
  List<Map<String, dynamic>> arbeitList =
      await ArbeitDatabaseHelper().getArbeitFromDB();
  List<Map<String, dynamic>> taskList =
      await TaskDatabaseHelper().getTaskFromDB();
  String? url = await UserDatabaseHelper().getUrl();

  if (backupID == null) {
    while (true) {
      backupID = Ulid().toString();
      final docRef = db.collection("backup").doc(backupID);
      final snapshot = await docRef.get();
      if (!snapshot.exists) {
        break;
      }
    }
    await UserDatabaseHelper().setBackupID(backupID);
  }
  expireDate = DateFormat("yyyy-MM-dd 00:00:00.000000")
      .format(DateTime.now().add(const Duration(days: (remainDay + 1))));

  db.collection("backup").doc(backupID).set({
    "dtEnd": expireDate,
    "schedule": scheduleList,
    "tag": tagList,
    "schedule_template": scheduleTemplateList,
    "schedule_metaInfo": scheduleMetaInfoList,
    "toDo": toDoList,
    "toDoTemplate": toDoTemplateList,
    "arbeit": arbeitList,
    "task": taskList,
    "url": url
  });
  await UserDatabaseHelper().setExpireDate(expireDate);

  return backupID;
}

Future<bool> recoveryBackup(String backupID) async {
  FirebaseFirestore db = FirebaseFirestore.instance;
  final docRef = db.collection("backup").doc(backupID);

  try {
    DocumentSnapshot doc = await docRef.get();
    final data = doc.data();
    if (data is Map<String, dynamic>) {
      final scheduleList = (data["schedule"] as List<dynamic>)
          .map((item) => item as Map<String, dynamic>)
          .toList();
      await ScheduleDatabaseHelper().resisterScheduleListToDB(scheduleList);
      final tagList = (data["tag"] as List<dynamic>)
          .map((item) => item as Map<String, dynamic>)
          .toList();
      await TagDatabaseHelper().resisterTagListToDB(tagList);
      final scheduleTemplateList = (data["schedule_template"] as List<dynamic>)
          .map((item) => item as Map<String, dynamic>)
          .toList();
      await ScheduleTemplateDatabaseHelper()
          .resisterScheduleTemplateListToDB(scheduleTemplateList);
      final scheduleMetaInfoList = (data["schedule_metaInfo"] as List<dynamic>)
          .map((item) => item as Map<String, dynamic>)
          .toList();
      await ScheduleMetaDatabaseHelper()
          .resisterSchedulemetaInfoListToDB(scheduleMetaInfoList);
      final toDoList = (data["toDo"] as List<dynamic>)
          .map((item) => item as Map<String, dynamic>)
          .toList();
      await DataBaseHelper().resisterToDoListToDB(toDoList);
      final toDoTemplateList = (data["toDoTemplate"] as List<dynamic>)
          .map((item) => item as Map<String, dynamic>)
          .toList();
      await TemplateDataBaseHelper().resisterToDoTemplateDB(toDoTemplateList);

      final arbeitList = (data["arbeit"] as List<dynamic>)
          .map((item) => item as Map<String, dynamic>)
          .toList();
      await ArbeitDatabaseHelper().resisterArbeitListToDB(arbeitList);
      final taskList = (data["task"] as List<dynamic>)
          .map((item) => item as Map<String, dynamic>)
          .toList();
      await TaskDatabaseHelper().resisterTaskListToDB(taskList);
      final url = data["url"] as String;
      await UserDatabaseHelper().resisterUserInfo(url);

      return true;
    } else {
      throw "データが予期せず不正な形式です";
    }
  } catch (e) {
    return false; // エラーが発生した場合は空のリストを返す
  }
}

Future<bool> exsistBackupIDinFB(String backupID) async {
  FirebaseFirestore db = FirebaseFirestore.instance;
  final docRef = db.collection("backup").doc(backupID);
  DocumentSnapshot doc = await docRef.get();
  return doc.exists;
}
