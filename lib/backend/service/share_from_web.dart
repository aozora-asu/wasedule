import 'package:collection/collection.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/calendar_page.dart';
import 'package:flutter_calandar_app/frontend/screens/moodle_view_page/moodle_view_page.dart';
import 'package:flutter_calandar_app/static/converter.dart';
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

import 'dart:convert';
import "../../frontend/screens/common/eyecatch_page.dart";
import "../DB/handler/my_grade_db.dart";
import 'package:flutter/services.dart'; // MethodChannelを使用するために追加

void getMyGrade(String str, List<MajorClass> list) async {
  if (list.isEmpty) return;
  final document = html_parser.parse(str);
  final trElements = document.querySelectorAll(".operationboxf");

  Map<String, dynamic> result = {};
  Map<String, dynamic> tempMap = {};
  Map<int, String> path = {};
  String text;

  for (var trElement in trElements) {
    final tdElements = trElement.children;

    text = tdElements[0].text;
    if (tdElements[1].text.trim().isEmpty) {
      if (text.startsWith("　　")) {
        path[2] =
            zenkaku2hankaku(text.trim().replaceAll(RegExp(r"[《》【】◎]"), ""));
      } else if (text.startsWith("　")) {
        path[1] =
            zenkaku2hankaku(text.trim().replaceAll(RegExp(r"[《》【】◎]"), ""));
      } else {
        path = {};
        path[0] =
            zenkaku2hankaku(text.trim().replaceAll(RegExp(r"[《》【】◎]"), ""));
      }
    } else {
      tempMap = {
        "courseName": zenkaku2hankaku(tdElements[0].text.trim()),
        "year": tdElements[1].text.trim(),
        "term": tdElements[2].text.trim(),
        "credit": int.parse(tdElements[3].text.trim()),
        "grade": tdElements[4].text.trim(),
        "gradePoint": tdElements[5].text.trim()
      };

      if (result[path[0]] == null) {
        result[path[0]!] = {};
      }
      if (result[path[0]][path[1]] == null) {
        result[path[0]][path[1]] = {};
      }
      if (result[path[0]][path[1]][path[2] ?? ""] == null) {
        result[path[0]][path[1]][path[2] ?? ""] = [];
      }

      result[path[0]][path[1]][path[2] ?? ""].add(tempMap);
    }
  }

  for (var majorClass in result.keys) {
    for (var middleKey in result[majorClass].keys) {
      for (var minorKey in result[majorClass][middleKey].keys) {
        for (var map in result[majorClass][middleKey][minorKey]) {
          for (MajorClass item in list) {
            if (item.text.contains(majorClass) ||
                majorClass.contains(item.text)) {
              for (MiddleClass ite in item.middleClass) {
                if (ite.text == middleKey) {
                  ite.myGrade.add(MyGrade(
                      courseName: map["courseName"],
                      credit: map["credit"],
                      grade: map["grade"],
                      gradePoint: map["gradePoint"],
                      term: map["term"],
                      year: map["year"]));

                  for (MinorClass it in ite.minorClass) {
                    if (it.text == minorKey) {
                      it.myGrade.add(MyGrade(
                          courseName: map["courseName"],
                          credit: map["credit"],
                          grade: map["grade"],
                          gradePoint: map["gradePoint"],
                          term: map["term"],
                          year: map["year"]));
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
  // printWrapped(const JsonEncoder.withIndent('  ')
  //     .convert(list.map((e) => e.toMap()).toList()));

  for (var majorClass in list) {
    await MyGradeDB().insertMajorClass(majorClass);
  }
  List<MajorClass> data = await MyGradeDB.getAllMajorClasses();
  for (var datum in data) {
    print(datum.toDisplay());
  }
}

List<MajorClass> getMyCredit(String str) {
  final document = html_parser.parse(str);
  final targetTable = document.querySelectorAll("table")[3];
  final trElements = targetTable.querySelectorAll(".operationboxf");
  List<MajorClass> list = [];

  late MinorClass minorClass = MinorClass(
      text: "",
      myGrade: [],
      requiredCredit: 0,
      acquiredCredit: 0,
      countedCredit: 0);
  late MiddleClass middleClass = MiddleClass(
      text: "",
      minorClass: [],
      requiredCredit: 0,
      acquiredCredit: 0,
      countedCredit: 0,
      myGrade: []);
  late MajorClass majorClass = MajorClass(
      text: "",
      middleClass: [],
      requiredCredit: 0,
      acquiredCredit: 0,
      countedCredit: 0);
  for (var trElement in trElements) {
    final tdElements = trElement.children;

    if (tdElements[0].text.trim().isNotEmpty) {
      majorClass = MajorClass(
          text: "",
          middleClass: [],
          requiredCredit: 0,
          acquiredCredit: 0,
          countedCredit: 0);

      majorClass.text = zenkaku2hankaku(tdElements[0].text.trim());
      if (majorClass.text == "他箇所聴講科目") {
        majorClass.middleClass.add(MiddleClass(
            text: "卒業不算入科目",
            minorClass: [],
            requiredCredit: 0,
            acquiredCredit: 0,
            countedCredit: 0,
            myGrade: []));
      }
    }
    if (!tdElements[1].text.startsWith("　　") &&
        tdElements[1].text.trim() != "小計") {
      middleClass = MiddleClass(
          text: "",
          minorClass: [],
          requiredCredit: 0,
          acquiredCredit: 0,
          countedCredit: 0,
          myGrade: []);
      middleClass.text = zenkaku2hankaku(tdElements[1].text.trim());
      middleClass.requiredCredit = int.tryParse(tdElements[2].text.trim());
      middleClass.acquiredCredit = int.parse(tdElements[3].text.trim());
      middleClass.countedCredit = int.parse(tdElements[4].text.trim());

      majorClass.middleClass.add(middleClass);
    } else if (tdElements[1].text.trim() != "小計") {
      minorClass = MinorClass(
          text: "",
          myGrade: [],
          requiredCredit: 0,
          acquiredCredit: 0,
          countedCredit: 0);
      minorClass.text = zenkaku2hankaku(tdElements[1].text.trim());
      minorClass.requiredCredit = int.tryParse(tdElements[2].text.trim());
      minorClass.acquiredCredit = int.parse(tdElements[3].text.trim());
      minorClass.countedCredit = int.parse(tdElements[4].text.trim());
      middleClass.minorClass.add(minorClass);
    } else {
      majorClass.requiredCredit = int.tryParse(tdElements[2].text.trim());
      majorClass.acquiredCredit = int.parse(tdElements[3].text.trim());
      majorClass.countedCredit = int.parse(tdElements[4].text.trim());

      list.add(majorClass);
    }
  }

  return list;
}

const MethodChannel platform = MethodChannel('com.example.wasedule/navigation');
Future<void> methodChannel(MethodCall call) async {
  if (call.method == 'navigateTo') {
    // Base64 エンコードされた文字列をデコード
    String base64UrlEncodedData = call.arguments as String;

// URL スキームからデータを取り出す
    Uri uri = Uri.parse(base64UrlEncodedData);
    String base64UrlData = uri.queryParameters['data'] ?? '';
    String cleanedBase64UrlData = base64UrlData.replaceAll(' ', '+');

// Base64URL デコード
    String base64Data = cleanedBase64UrlData
        .replaceAll('-', '+') // Base64URL の変換
        .replaceAll('_', '/') // Base64URL の変換
        .padRight((base64UrlData.length + 3) & ~3, '='); // パディングを追加
    String jsonString = utf8.decode(base64.decode(base64Data));

    // JSON 文字列を JSON オブジェクトに変換
    Map<String, dynamic> jsonData = json.decode(jsonString);
    navigateBasedOnURL(jsonData);
  }
}

// URLに基づいて画面を遷移させるロジックを実装する関数
void navigateBasedOnURL(Map<String, dynamic> jsonData) {
  // 例: JSON オブジェクトの "type" フィールドに基づいて遷移先を決定
  if (jsonData['type'] == 'shared_content') {
    // 共有されたコンテンツがある場合、特定の画面に遷移
    navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(
        builder: (_) => AppPage(initIndex: 1),
      ),
    );
  } else {
    // デフォルトの画面に遷移する
    navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(
        builder: (_) => AppPage(initIndex: 2),
      ),
    );
  }
}
