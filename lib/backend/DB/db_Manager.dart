import "./models/task_item.dart";
import './database_helper.dart';
import "../http_request.dart";

import "../status_code.dart";

Future<Map<String, dynamic>> resisterTaskToDb(String urlString) async {
  // データベースヘルパークラスのインスタンスを作成
  TaskDatabaseHelper databaseHelper = TaskDatabaseHelper();
  // データベースの初期化
  await databaseHelper.initDatabase();
  Map<String, dynamic> taskData = await getTaskData(urlString);
  TaskItem taskItem;
  int result = 0;

  for (int i = 0; i < taskData["events"].length; i++) {
    // 1. TaskItemオブジェクトを作成
    taskItem = TaskItem(
        summary: taskData["SUMMARY"],
        description: taskData["DESCRIPTION"],
        dtEnd: taskData["DTEND"],
        categories: taskData["CATEGORIES"],
        isDone: STATUS_YET,
        memo: taskData["MEMO"]);
    // 2. データベースヘルパークラスを使用してデータベースに挿入
    result = await databaseHelper.insertTask(taskItem);
  }
  return databaseHelper.getTaskFromDB();
}
