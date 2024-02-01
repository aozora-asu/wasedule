import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:intl/intl.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_calandar_app/frontend/screens/outdated/data_card.dart';
import 'package:form_field_validator/form_field_validator.dart';

import 'package:easy_autocomplete/easy_autocomplete.dart';
import '../../../backend/DB/handler/schedule_db_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

DateTime now = DateTime.now();

Map<String, dynamic> test_today_shedule = {
  'subject': "${now.day}日の予定だよん",
  'startDate': "${now.year}-${now.month}-${now.day}",
  'startTime': "08:00",
  'endDate': "${now.year}-${now.month}-${now.day}",
  'endTime': "15:00",
  'isPublic': 0,
  "publicSubject": "today's secret plan",
  "tag": "tags"
};

Map<String, dynamic> test_tommorrow_shedule = {
  'subject': "${now.day + 1}日の予定--",
  'startDate': "${now.year}-${now.month}-${now.day + 1}",
  'startTime': "13:00",
  'endDate': "${now.year}-${now.month}-${now.day}",
  'endTime': "21:00",
  'isPublic': 0,
  "publicSubject": "today's secret plan",
  "tag": "tags"
};
