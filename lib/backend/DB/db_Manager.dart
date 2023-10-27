import "./models/task_item.dart";
import './database_helper.dart';
import "../http_request.dart";

import "../status_code.dart";

Future<void> resisterTaskToDb(String urlString) async {
  // データベースヘルパークラスのインスタンスを作成
  TaskDatabaseHelper databaseHelper = TaskDatabaseHelper();
  // データベースの初期化
  await databaseHelper.initDatabase();
  Map<String, dynamic> taskData = await getTaskData(urlString);
  TaskItem taskItem;
  int result = 0;

  for (int i = 0; i < taskData["events"].length; i++) {
    // 1. TaskItemオブジェクトを作成
    taskItem = _makeTaskItem(taskData["events"][i]);
    // 2. データベースヘルパークラスを使用してデータベースに挿入
    result = await databaseHelper.insertTask(taskItem);
  }

  if (result != 0) {
    print("新しいタスクがデータベースに登録されました。");
  } else {
    print("タスクのデータベースへの登録に失敗しました.");
  }
}

TaskItem _makeTaskItem(Map<String, dynamic> taskMap) {
  return TaskItem(
    summary: taskMap["SUMMARY"],
    description: taskMap["DESCRIPTION"],
    dtEnd: taskMap["DTEND"],
    categories: taskMap["CATEGORIES"],
    isDone: STATUS_YET,
  );
}
