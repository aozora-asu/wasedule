import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/services.dart';
import 'frontend/screens/pages/eyecatch_page.dart';
import 'package:provider/provider.dart';
import 'frontend/screens/components/template/data_card.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Bindingの初期化
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await initializeDateFormatting(); // 初期化
  runApp(MyApp());
}
