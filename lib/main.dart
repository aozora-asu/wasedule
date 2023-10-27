import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/widgets.dart';

import 'frontend/colors.dart';
import 'frontend/screenManager.dart';
import 'backend/DB/db_Manager.dart';

void main() async {
  await initializeDateFormatting(); // 初期化
  runApp(MaterialApp(
    home: FirstPage(),
  ));
  await resisterTaskToDb(
      "https://wsdmoodle.waseda.jp/calendar/export_execute.php?userid=135654&authtoken=9b0e0c9a3d8be79d1ed9211cfd6f1194a40ec330&preset_what=all&preset_time=recentupcoming");
}
