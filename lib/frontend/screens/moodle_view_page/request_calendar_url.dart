// import 'package:flutter/material.dart';
// import 'package:flutter_calandar_app/frontend/screens/moodle_view_page/moodle_view_page.dart';
// import 'package:http/http.dart' as http;
// import 'package:html/parser.dart' show parse;
// import 'package:html/dom.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// Future<void> getCalendarURL(String sessKey, String cookies,
//     Function(String) successCallback, Function(String) errorCallback) async {
//   final client = http.Client();
//   const String calendarExportUrl =
//       "https://wsdmoodle.waseda.jp/calendar/export.php?";

//   final headers = {
//     "Content-Type": "application/x-www-form-urlencoded",
//     "Cookie": cookies
//   };

//   final body = {
//     "sesskey": sessKey,
//     "_qf__core_calendar_export_form": "1",
//     "events[exportevents]": "courses",
//     "period[timeperiod]": "recentupcoming",
//     "generateurl": "カレンダーURLを取得する"
//   };

//   try {
//     http.Response response = await client.post(Uri.parse(calendarExportUrl),
//         headers: headers, body: body);

//     int redirectCount = 0;
//     while (response.isRedirect && redirectCount < 5) {
//       final location = response.headers['location'];
//       if (location != null) {
//         response = await client.get(Uri.parse(location), headers: headers);
//         redirectCount++;
//       } else {
//         break;
//       }
//     }

//     if (response.statusCode == 200) {
//       final document = parse(response.body);
//       final inputElement = document.querySelector('#calendarexporturl');
//       if (inputElement != null) {
//         successCallback(inputElement.attributes['value'] ?? '');
//       } else {
//         errorCallback("カレンダーURLが見つかりませんでした");
//       }
//     } else {
//       errorCallback("HTTPリクエストが失敗しました: ${response.statusCode}");
//     }
//   } catch (error) {
//     errorCallback("Fetch操作に問題が発生しました: $error");
//   } finally {
//     client.close();
//   }
// }

// Future<Map<String, dynamic>> checkSession() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   String sessionKey = prefs.getString('sessionKey') ?? "";
//   String cookies = prefs.getString('cookies') ?? "";
//   bool isAllowAutoLogin = prefs.getBool("isAllowAutoLogin") ?? false;
//   return {
//     "sessionKey": sessionKey,
//     "cookies": cookies,
//     "isAllowAutoLogin": isAllowAutoLogin
//   };
// }

// Future<void> saveSession(
//     String sessionKey, String cookies, bool isAllowAutoLogin) async {
//   if (isAllowAutoLogin) {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString('sessionKey', sessionKey);
//     await prefs.setString('cookies', cookies);
//   }
// }
