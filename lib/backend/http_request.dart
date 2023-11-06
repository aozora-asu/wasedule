import 'package:http/http.dart' as http;
import 'temp_file.dart';

Map<String, dynamic> _parsedTaskData(String iCalendarData) {
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

  final iCalData = _pretterTask(iCalInfo);

  return iCalData;
}

Future<String> _getTask(String urlString) async {
  Uri url = Uri.parse(urlString);
  var response = await http.post(url);
  //print(response.body.substring(1200, 2200));
  return response.body.replaceAll("\\n", "");
}

Map<String, dynamic> _pretterTask(Map<String, dynamic> events) {
  //events["events"].removeAt(0);
  for (int i = 0; i < events["events"].length; i++) {
    events["events"][i].remove("CLASS");
    events["events"][i].remove("LAST-MODIFIED");
    events["events"][i].remove("DTSTAMP");
    events["events"][i].remove("DTSTART");

    events["events"][i]["DTEND"] = DateTime.parse(events["events"][i]["DTEND"])
        .add(const Duration(hours: 9))
        .millisecondsSinceEpoch; //これはエポックミリ秒 int型
    events["events"][i]["CATEGORIES"] = events["events"][i]["CATEGORIES"]
        .replaceAll(RegExp(r'[A-Za-z()\d]'), '');
  }

  return events;
}

//リクエストurlを受け取って以下のようなMapとListのキメラを返す関数
//@param String urlSttring
Future<Map<String, dynamic>> getTaskFromHttp(String urlString) async {
  final taskString = await _getTask(urlString);
  Map<String, dynamic> tasks = _parsedTaskData(taskString);

  return tasks;
}

//@return {"events":[{
// 						"SUMMARY":"#1 アンケート (アンケート開始)",
// 						"DESCRIPTION":"#1 アンケート",
// 						"DTEND":20231022035900000Z,
// 						"CATEGORIES":"素数の魅力と暗号理論　０２(20239S0200010202)"
// 						},{
// 						"SUMMARY":"#2 アンケート (アンケート開始)",
// 						"DESCRIPTION":"#2 アンケート",
// 						"DTEND":20231023000000000Z,
// 						"CATEGORIES":"素数の魅力と暗号理論　０２(20239S0200010202)"
// 						},{
// 						"SUMMARY":"質問申請フォーム/Question Application Form (アンケート開始)",
// 						"DESCRIPTION":"質問申請フォーム/Question Application Form",
// 						"DTEND":20231005050000000Z,
// 						"CATEGORIES":"グローバルエデュケーションセンター情報対面指導室/Global Education Center IT Personal Tut"
// 						},
// 						]
