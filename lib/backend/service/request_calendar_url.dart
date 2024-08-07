// import 'package:flutter/material.dart';
// import 'package:flutter_calandar_app/frontend/screens/moodle_view_page/moodle_view_page.dart';
// import 'package:http/http.dart' as http;
// import 'package:html/parser.dart' show parse;
// import 'package:html/dom.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, dynamic>> checkSession() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String sessionKey = prefs.getString('sessionKey') ?? "";
  String cookies = prefs.getString('cookies') ?? "";
  bool isAllowAutoLogin = prefs.getBool("isAllowAutoLogin") ?? false;
  return {
    "sessionKey": sessionKey,
    "cookies": cookies,
    "isAllowAutoLogin": isAllowAutoLogin
  };
}

Future<void> saveSession(
    String sessionKey, String cookies, bool isAllowAutoLogin) async {
  if (isAllowAutoLogin) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('sessionKey', sessionKey);
    await prefs.setString('cookies', cookies);
  }
}

Future<void> acceptAutoLogin(bool isAllowAutoLogin) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isAllowAutoLogin', isAllowAutoLogin);
}

Future<String> getSessKey() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('sessionKey') ?? "";
}
