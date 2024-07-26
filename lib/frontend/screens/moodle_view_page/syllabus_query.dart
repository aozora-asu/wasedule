import 'package:flutter_calandar_app/backend/DB/isar_collection/isar_handler.dart';
import 'package:flutter_calandar_app/backend/DB/isar_collection/vacant_room.dart';
import 'package:flutter_calandar_app/static/constant.dart';
import 'package:flutter_calandar_app/static/converter.dart';
import 'package:html/dom.dart';

import 'package:http/http.dart' as http;

import "./classRoom.dart";
import 'package:html/parser.dart' as html_parser;

import 'package:uuid/uuid.dart';
import "../../../backend/DB/handler/my_course_db.dart";
import 'package:collection/collection.dart';

class SearchSyllabus {
  Term? semester;
  Lesson? period;
  Lesson? weekday;
  bool? isOpenSubject;
  String? keyword;
  Department? department;
  SearchSyllabus(
      {required this.semester,
      required this.weekday,
      required this.period,
      required this.keyword,
      required this.isOpenSubject,
      required this.department});
}
