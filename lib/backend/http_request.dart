import 'package:http/http.dart' as http;

List<Map<String, dynamic>> _parsedTaskData(String iCalendarData) {
  final lines = iCalendarData.split('\n'); // 行ごとに分割

  final List<Map<String, dynamic>> iCalInfo = [];

  Map<String, dynamic>? currentEvent; // 変数をNullableに変更
  String? key;
  List<String> parts;
  String value;
  for (final line in lines) {
    final trimmedLine = line.trim();
    if (trimmedLine.startsWith('BEGIN:VEVENT')) {
      // 新しいイベントの開始
      currentEvent = <String, dynamic>{};
    } else if (trimmedLine.startsWith('END:VEVENT')) {
      // イベントの終了
      if (currentEvent != null) {
        iCalInfo.add(currentEvent);
        currentEvent = null; // イベント終了後にcurrentEventを初期化
      }
    } else if (currentEvent != null) {
      if (line.contains(RegExp(r"^[A-Z-]+:"))) {
        // 行に':'が含まれる場合はキーと値を抽出
        parts = line.split(':');
        key = parts[0];
        value = parts.sublist(1).join(':').trim();
        currentEvent[key] = value;
      } else if (key != null) {
        // 直前の行がキーに対する値の一部である場合は、値を連結
        currentEvent[key] += line.trim();
      }
    }
  }

  // iCalInfoをJSONに変換

  return iCalInfo;
}

Future<String> _getTask(String urlString) async {
  // headersの作成
  final headers = {'Content-type': 'application/json; charset=UTF-8'};
  final url = Uri.parse(urlString);

// POSTリクエストの作成
  final response = await http.post(url, headers: headers);

  return response.body;
}

List<Map<String, dynamic>> _pretterTask(List<Map<String, dynamic>> events) {
  //events["events"].removeAt(0);
  if (events.isNotEmpty) {
    for (int i = 0; i < events.length; i++) {
      events[i].remove("CLASS");
      events[i].remove("LAST-MODIFIED");
      events[i].remove("DTSTAMP");
      events[i].remove("DTSTART");
      events[i]["DTEND"] = DateTime.parse(events[i]["DTEND"])
          .millisecondsSinceEpoch; //これはエポックミリ秒 int型
      if (events[i]["CATEGORIES"] != null) {
        events[i]["CATEGORIES"] =
            events[i]["CATEGORIES"].replaceAll(RegExp(r'\([\dA-Z]+\)'), '');
      }

      if (events[i]["DESCRIPTION"] != null) {
        events[i]["DESCRIPTION"] =
            events[i]["DESCRIPTION"].replaceAll(RegExp(r'\\n+'), "\n");
      }
    }
  }

  return events;
}

//リクエストurlを受け取って以下のようなMapとListのキメラを返す関数
//@param String urlSttring
Future<List<Map<String, dynamic>>> getTaskFromHttp(String urlString) async {
  final String taskString = await _getTask(urlString);
  final List<Map<String, dynamic>> iCalInfo = _parsedTaskData(taskString);

  final tasks = _pretterTask(iCalInfo);

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
