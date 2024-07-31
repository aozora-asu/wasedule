import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/isar_collection/isar_handler.dart';
import 'package:flutter_calandar_app/backend/service/home_widget.dart';
import 'package:flutter_calandar_app/frontend/screens/moodle_view_page/syllabus_query_result.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'frontend/screens/common/eyecatch_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'backend/firebase/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/services.dart';
import "backend/DB/sharepreference.dart";
import "./frontend/screens/moodle_view_page/syllabus_query_request.dart";

import "./static/constant.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: '.env');
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation("Asia/Tokyo"));
  isar = await IsarHandler().initIsar();
  pref = await SharepreferenceHandler().initSharepreference();
  await initializeDateFormatting();
  NextCourseHomeWidget().updateNextCourse();
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const ProviderScope(child: MyApp()));
  });
}
