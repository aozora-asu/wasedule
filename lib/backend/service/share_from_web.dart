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
import 'package:flutter/services.dart'; // MethodChannelを使用するために追加

void document(String str) {
  final document = html_parser.parse(str);
  print(document.querySelectorAll("td")[0].innerHtml);
}

const MethodChannel platform = MethodChannel('com.example.wasedule/navigation');
Future<void> methodChannel(MethodCall call) async {
  if (call.method == 'navigateTo') {
    // Base64 エンコードされた文字列をデコード
    String base64UrlEncodedData = call.arguments as String;
    try {
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
      // URLに基づいて画面遷移
      navigateBasedOnURL(jsonData);
    } catch (e) {
      print('Failed to decode JSON data: $e');
    }
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
