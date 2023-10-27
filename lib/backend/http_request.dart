import 'package:http/http.dart' as http;
import 'temp_file.dart';

String urlString = url_y;

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
  return response.body;
}

Map<String, dynamic> _pretterTask(Map<String, dynamic> events) {
  for (int i = 0; i < events["events"].length; i++) {
    events["events"][i].remove("UID");
    events["events"][i].remove("CLASS");
    events["events"][i].remove("LAST-MODIFIED");
    events["events"][i].remove("DTSTAMP");
    events["events"][i].remove("DTSTART");
    events["events"][i]["DTEND"] =
        DateTime.parse(events["events"][i]["DTEND"]).millisecondsSinceEpoch;
  }
  return events;
}

/// @param dateStr 20231022035900000Z
DateTime _strToDt(String dateStr) {
  DateTime dateTime = DateTime.parse(dateStr);
  // タイムゾーンオフセットを設定（日本時間はUTC+9）
  Duration japanOffset = const Duration(hours: 9);
// タイムゾーンオフセットを適用して日本時間に変換
  DateTime japanTime = dateTime.toUtc().add(japanOffset);

  // 日本時間をフォーマット
  return japanTime;
}

/// @return DateTime(2023-10-22 03:59:00000Z)

//リクエストurlを受け取って以下のようなMapとListのキメラを返す関数
//@param String urlSttring
Future<Map<String, dynamic>> getTaskData(String urlString) async {
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
