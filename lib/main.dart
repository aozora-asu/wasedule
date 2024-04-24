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
import "./backend/firabase_fcm_notification.dart";

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
  FCMnotificationSetting();
  runApp(ProviderScope(child: MyApp()));
}
