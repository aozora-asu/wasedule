import "./models/task_item.dart";
import './database_helper.dart';
import "../http_request.dart";

import "../status_code.dart";

Future<Map<String, dynamic>> resisterTaskToDB(String urlString) async {
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
        summary: taskData["events"][i]["SUMMARY"],
        description: taskData["events"][i]["DESCRIPTION"],
        dtEnd: taskData["events"][i]["DTEND"],
        categories: taskData["events"][i]["CATEGORIES"],
        isDone: STATUS_YET,
        memo: taskData["events"][i]["MEMO"]);
    // 2. データベースヘルパークラスを使用してデータベースに挿入
    result = await databaseHelper.insertTask(taskItem);
  }
  return databaseHelper.getTaskFromDB();
}
