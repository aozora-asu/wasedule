import 'DB/models/task_item.dart';
import 'DB/database_helper.dart';
import 'http_request.dart';

import 'status_code.dart';

class DBManager extends TaskDatabaseHelper {
  TaskDatabaseHelper databaseHelper = TaskDatabaseHelper();

  Future<void> resisterTaskToDB(String urlString) async {
    // データベースヘルパークラスのインスタンスを作成

    // データベースの初期化

    Map<String, dynamic> taskData = await getTaskData(urlString);
    TaskItem taskItem;
    int result = 0;

    for (int i = 0; i < taskData["events"].length; i++) {
      // 1. TaskItemオブジェクトを作成
      taskItem = TaskItem(
        uid: taskData["events"][i]['UID'],
        title: taskData["events"][i]['CATEGORIES'],
        dtEnd: taskData["events"][i]['DTEND'],
        summary: taskData["events"][i]['SUMMARY'],
        description: taskData["events"][i]["DESCRIPTION"],

        isDone: 0, // データベースの1をtrueにマップ
      );
      // 2. データベースヘルパークラスを使用してデータベースに挿入
      result = await databaseHelper.insertTask(taskItem);
    }
  }

  Future<List<Map<String, dynamic>>> displayTaskForCalendarPage() async {
    return databaseHelper.taskListForCalendarPage();
  }

  Future<List<Map<String, dynamic>>> displayTaskforTaskPage() async {
    return databaseHelper.taskListForTaskPage();
  }
}
