import 'package:flutter/material.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/services.dart';
import 'frontend/screens/common/eyecatch_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import './backend/firebase_handler.dart';

import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

// ...

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Bindingの初期化
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await initializeDateFormatting(); // 初期化

  runApp(ProviderScope(child: MyApp()));
}
