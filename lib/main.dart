import 'package:flutter/material.dart';

import 'package:intl/date_symbol_data_local.dart';

import 'frontend/screenManager.dart';
import 'backend/db_Manager.dart';

import 'backend/temp_file.dart';
import './frontend/screens/pages/calendar_page.dart';
import 'backend/DB/database_helper.dart';

void main() async {
  await initializeDateFormatting(); // 初期化
  runApp(MaterialApp(
    home: FirstPage(),
  ));
}
