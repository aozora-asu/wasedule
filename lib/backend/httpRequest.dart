//import 'dart:io';
//import 'dart:convert';
import 'package:http/http.dart' as http;
import "./tempFile.dart";

String url_string = url_y;

Map<String, dynamic> parseICalendarData(String iCalendarData) {
  final lines = iCalendarData.split('\n'); // 行ごとに分割

  final iCalInfo = <String, dynamic>{
    'events': [], // イベントの情報を格納するリスト
  };

  Map<String, dynamic>? currentEvent; // 変数をNullableに変更

  for (final line in lines) {
    final trimmedLine = line.trim();
    if (trimmedLine.startsWith('BEGIN:VEVENT')) {
      // 新しいイベントの開始
      currentEvent = <String, dynamic>{};
    } else if (trimmedLine.startsWith('END:VEVENT')) {
      // イベントの終了
      if (currentEvent != null) {
        iCalInfo['events'].add(currentEvent);
        currentEvent = null; // イベント終了後にcurrentEventを初期化
      }
    } else if (currentEvent != null) {
      final parts = trimmedLine.split(':');
      if (parts.length == 2) {
        final key = parts[0];
        final value = parts[1];
        currentEvent[key] = value;
      }
    }
  }

  // iCalInfoをJSONに変換

  final ICalData = _ICalpretter(iCalInfo);

  return ICalData;
}

Future<String> getICalendarData(String url_string) async {
  Uri url = Uri.parse(url_string);
  var response = await http.post(url);
  return response.body;
}

Map<String, dynamic> _ICalpretter(Map<String, dynamic> events) {
  for (int i = 0; i < events["events"].length; i++) {
    events["events"][i].remove("UID");
    events["events"][i].remove("CLASS");
    events["events"][i].remove("LAST-MODIFIED");
    events["events"][i].remove("DTSTAMP");
    events["events"][i].remove("DTSTART");
    events["events"][i]["DTEND"] = _StrToDt(events["events"][i]["DTEND"]);
  }
  return events;
}

DateTime _StrToDt(String dateStr) {
  int year = int.parse(dateStr.substring(0, 4));
  int month = int.parse(dateStr.substring(4, 6));
  int day = int.parse(dateStr.substring(6, 8));
  int hour = int.parse(dateStr.substring(9, 11));
  int minute = int.parse(dateStr.substring(11, 13));
  int second = int.parse(dateStr.substring(13, 15));

  DateTime dateTime = DateTime.utc(year, month, day, hour, minute, second);
  // 9時間を加えて日本時間に変換
  DateTime japanTime = dateTime.add(Duration(hours: 9));

  // 日本時間をフォーマット
  return japanTime;
}

Future<Map<String, dynamic>> getEventInfo(url_string) async {
  final Task_string = await getICalendarData(url_string);
  Map<String, dynamic> TaskCalendar = parseICalendarData(Task_string);
  return TaskCalendar;
}
