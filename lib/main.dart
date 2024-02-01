import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/notify/notify_setting.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/services.dart';
import 'frontend/screens/common/eyecatch_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Bindingの初期化
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await initializeNotification();

  await initializeDateFormatting(); // 初期化
  runApp(ProviderScope(child:MyApp()));
}
