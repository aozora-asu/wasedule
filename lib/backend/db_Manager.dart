import "DB/models/task_item.dart";
import 'DB/database_helper.dart';
import "http_request.dart";

import "status_code.dart";

Future<List<Map<String, dynamic>>> resisterTaskToDB(String urlString) async {
  // データベースヘルパークラスのインスタンスを作成
  TaskDatabaseHelper databaseHelper = TaskDatabaseHelper();
  // データベースの初期化

  await databaseHelper.initDatabase();
  Map<String, dynamic> taskData = await getTaskData(urlString);
  TaskItem taskItem;

  int result;
  for (int i = 0; i < taskData["events"].length; i++) {
    // 1. TaskItemオブジェクトを作成
    taskItem = TaskItem(
      uid: taskData["events"][i]["UID"],
      summary: taskData["events"][i]["SUMMARY"],
      description: taskData["events"][i]["DESCRIPTION"],
      dtEnd: taskData["events"][i]["DTEND"],
      title: taskData["events"][i]["CATEGORIES"],
      isDone: STATUS_YET,
    );
    // 2. データベースヘルパークラスを使用してデータベースに挿入
    result = await databaseHelper.insertTask(taskItem);
  }

  return databaseHelper.getTaskFromDB();
}

Future<List<Map<String, dynamic>>> taskListForCalendarPage() async {
  TaskDatabaseHelper databaseHelper = TaskDatabaseHelper();
  await databaseHelper.initDatabase();
  return databaseHelper.taskListForCalendarPage();
}

Future<List<Map<String, dynamic>>> taskListforTaskPage() async {
  TaskDatabaseHelper databaseHelper = TaskDatabaseHelper();
  await databaseHelper.initDatabase();
  return databaseHelper.taskListForTaskPage();
}
