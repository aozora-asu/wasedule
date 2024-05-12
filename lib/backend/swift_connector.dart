import 'package:flutter/services.dart';
import "../frontend/screens/moodle_view_page/my_course_db.dart";

MethodChannel _methodChannel = MethodChannel('com.example.show');

void main() {
  //以下swift連携用の設定
  // プラットフォームチャンネルの作成
  const platform = MethodChannel('com.example.flutter_app/channel');

  // 外部から呼び出される関数の実装
  platform.setMethodCallHandler((call) async {
    if (call.method == 'getnextCourse') {
      // 値を取得する処理を行う
      List<Map<String, dynamic>>? nextCourseList =
          await MyCourseDatabaseHandler().getNextCourseInfo(DateTime.now());
      return nextCourseList;
    }
    return null;
  });
}
