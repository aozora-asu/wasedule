import 'package:http/http.dart' as http;

import 'package:html/parser.dart' as html_parser;

import 'package:uuid/uuid.dart';

import 'package:html/dom.dart';

import 'dart:async';

import 'dart:io';
// ignore: unnecessary_import

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:flutter/material.dart';

import '../../frontend/assist_files/screen_manager.dart';
import "../DB/handler/task_db_handler.dart";

import "../DB/handler/my_course_db.dart";
import 'dart:convert';
import "../../frontend/screens/common/eyecatch_page.dart";
import "../../static/constant.dart";
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import "../DB/sharepreference.dart";

import 'package:intl/date_symbol_data_local.dart';

void document(String str) {
  final document = html_parser.parse(str);
  print(document.querySelectorAll("td")[0].innerHtml);
}
