import 'package:flutter/material.dart';

import 'package:intl/date_symbol_data_local.dart';

import 'frontend/screenManager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Bindingの初期化

  await initializeDateFormatting(); // 初期化

  runApp(MaterialApp(
    home: FirstPage(),
  ));
}
