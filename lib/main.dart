import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/services.dart';
import 'frontend/screens/common/eyecatch_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import "frontend/screens/moodle_view_page/syllabus.dart";
import "./frontend/screens/moodle_view_page/my_course_db.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Bindingの初期化
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: '.env');
  // タイムゾーンデータベースの初期化
  tz.initializeTimeZones();
  // ローカルロケーションのタイムゾーンを東京に設定
  tz.setLocalLocation(tz.getLocation("Asia/Tokyo"));

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await initializeDateFormatting(); // 初期化
  //以下swift連携用の設定
  // プラットフォームチャンネルの作成
  const platform = MethodChannel('com.example.flutter_app/channel');

  // 外部から呼び出される関数の実装
  platform.setMethodCallHandler((call) async {
    if (call.method == 'getNextCourse') {
      // 値を取得する処理を行う
      List<Map<String, dynamic>>? nextCourseList =
          await MyCourseDatabaseHandler().getNextCourseInfo(DateTime.now());
      return nextCourseList;
    }
    return null;
  });
  runApp(ProviderScope(child: MyApp()));
}
