import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/http_request.dart';

import 'package:intl/date_symbol_data_local.dart';

import 'frontend/screenManager.dart';
import 'backend/DB/db_Manager.dart';
import 'backend/DB/database_helper.dart';

import 'backend/temp_file.dart';

void main() async {
  await initializeDateFormatting(); // 初期化
  runApp(MaterialApp(
    home: FirstPage(),
  ));

  //ここの引数にurl_y or url_tを入力するとコンソールにデータベースが出力されます
}
