import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_saver/file_saver.dart';

String userid = "135654";
String authtoken = "9b0e0c9a3d8be79d1ed9211cfd6f1194a40ec330";
String preset_what = "all";
String preset_time = "weeknow";
//var url=Uri.https("wsdmoodle.waseda.jp", "/calendar/export_execute.php?userid=$userid&authtoken=${authtoken}&preset_what=${preset_what}&preset_time=${preset_time}",{'q': 'Flutter'});
//https:///
var url_string =
    "https://wsdmoodle.waseda.jp/calendar/export_execute.php?userid=135654&authtoken=9b0e0c9a3d8be79d1ed9211cfd6f1194a40ec330&preset_what=all&preset_time=monthnow";

void parseICalendarData(String iCalendarData) {
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
  final jsonICalData = jsonEncode(iCalInfo);

  print(jsonICalData);
}

Future<String> getICalendarData(String url_string) async {
  Uri url = Uri.parse(url_string);
  var response = await http.post(url);
  return response.body;
}

void main() async {
  final Task = await getICalendarData(url_string);
  parseICalendarData(Task);
}
