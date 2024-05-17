import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/home_widget.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'frontend/screens/common/eyecatch_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import './converter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: '.env');
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation("Asia/Tokyo"));
  await initializeDateFormatting();
  NextCourseHomeWidget().updateNextCourse();

  print(datetime2termList(DateTime(2024, 5, 1)));

  runApp(ProviderScope(child: MyApp()));
}
