import 'package:flutter_calandar_app/frontend/screens/calendar_page/calendar_page.dart';
import 'package:flutter_calandar_app/frontend/screens/moodle_view_page/moodle_view_page.dart';
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

import "../DB/handler/my_grade_db.dart";
import 'dart:convert';
import "../../frontend/screens/common/eyecatch_page.dart";

import 'package:flutter/services.dart'; // MethodChannelを使用するために追加

void document(String str) async {
  final document = html_parser.parse(str);
  final trElements = document.querySelectorAll(".operationboxf");

  var result = {};
  Map<String, dynamic> tempMap = {};
  Map<int, String> path = {};
  String text;
  for (var trElement in trElements) {
    final tdElements = trElement.children;

    text = tdElements[0].text;
    if (tdElements[1].text.trim().isEmpty) {
      if (text.startsWith("　　")) {
        path[2] = text.trim();
      } else if (text.startsWith("　")) {
        path[1] = text.trim();
      } else {
        path = {};
        path[0] = text.trim();
      }
    } else {
      tempMap = {
        "courseName": tdElements[0].text.trim(),
        "year": tdElements[1].text.trim(),
        "term": tdElements[2].text.trim(),
        "credit": tdElements[3].text.trim(),
        "grade": tdElements[4].text.trim(),
        "gradePoint": tdElements[5].text.trim()
      };

      if (result[path[0]] == null) {
        result[path[0]] = {};
      }
      if (result[path[0]][path[1]] == null) {
        result[path[0]][path[1]] = {};
      }
      if (result[path[0]][path[1]][path[2]] == null) {
        result[path[0]][path[1]][path[2]] = [];
      }

      result[path[0]][path[1]][path[2]].add(tempMap);
    }
  }

  MyGrade myGrade;
  for (var parentKey in result.keys) {
    for (var childKey in result[parentKey].keys) {
      for (var grandChild in result[parentKey][childKey].keys) {
        for (var map in result[parentKey][childKey][grandChild]) {
          myGrade = MyGrade(
              courseName: map["courseName"],
              credit: map["credit"],
              grade: map["grade"],
              gradePoint: map["gradePoint"],
              majorClassification: parentKey,
              middleClassification: childKey,
              minorClassification: grandChild,
              term: map["term"],
              year: map["year"]);
          await myGrade.resisterMyGrade();
        }
      }
    }
  }
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
  document(jsonData['data']["html"]);
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
