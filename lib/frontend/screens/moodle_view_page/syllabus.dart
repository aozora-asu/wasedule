import 'package:flutter_calandar_app/backend/DB/isar_collection/isar_handler.dart';
import 'package:flutter_calandar_app/backend/DB/isar_collection/vacant_room.dart';
import 'package:flutter_calandar_app/static/converter.dart';

import 'package:http/http.dart' as http;

import "./classRoom.dart";
import 'package:html/parser.dart' as html_parser;

import 'package:uuid/uuid.dart';
import "../../../backend/DB/handler/my_course_db.dart";

class RequestQuery {
  String? p_number;
  String? p_page;
  String? keyword;
  String s_bunya1_hid = "大分類を絞ってください";
  String s_bunya2_hid = "中分類を絞ってください";
  String s_bunya3_hid = "小分類を絞ってください";
  String? area_type;
  String? area_value;
  String? s_level_hid;
  String? kamoku;
  String? kyoin;
  String? p_gakki;
  String? p_youbi;
  String? p_jigen;
  String? p_gengo;
  String? p_gakubu;
  String? hidreset;
  String pfrontPage = "now";
  String? pchgFlg;
  String? bunya1_hid;
  String? bunya2_hid;
  String? bunya3_hid;
  String? level_hid;
  String ControllerParameters = "JAA103SubCon";
  String? pOcw;
  String? pType;
  String? pLng = "jp";

  String boundary = '----WebKitFormBoundary${const Uuid().v4()}';

  RequestQuery({
    this.p_number,
    this.p_page,
    this.keyword,
    // this.s_bunya1_hid,
    // this.s_bunya2_hid,
    // this.s_bunya3_hid,
    this.area_type,
    this.area_value,
    this.s_level_hid,
    this.kamoku,
    this.kyoin,
    this.p_gakki,
    this.p_youbi,
    this.p_jigen,
    this.p_gengo,
    this.p_gakubu,
    this.hidreset,
    //this.pfrontPage,
    this.pchgFlg,
    this.bunya1_hid,
    this.bunya2_hid,
    this.bunya3_hid,
    this.level_hid,
    // this.ControllerParameters,
    this.pOcw,
    this.pType,
    this.pLng,
  });

  Map<String, String?> _toMap() {
    return {
      "p_number": p_number,
      "p_page": p_page,
      'keyword': keyword,
      's_bunya1_hid': s_bunya1_hid,
      's_bunya2_hid': s_bunya2_hid,
      's_bunya3_hid': s_bunya3_hid,
      'area_type': area_type,
      'area_value': area_value,
      's_level_hid': s_level_hid,
      'kamoku': kamoku,
      'kyoin': kyoin,
      'p_gakki': p_gakki,
      'p_youbi': p_youbi,
      'p_jigen': p_jigen,
      'p_gengo': p_gengo,
      'p_gakubu': p_gakubu,
      'hidreset': hidreset,
      'pfrontPage': pfrontPage,
      'pchgFlg': pchgFlg,
      'bunya1_hid': bunya1_hid,
      'bunya2_hid': bunya2_hid,
      'bunya3_hid': bunya3_hid,
      'level_hid': level_hid,
      'ControllerParameters': ControllerParameters,
      'pOcw': pOcw,
      'pType': pType,
      'pLng': pLng,
    };
  }

  String makeBody() {
    String body = "";
    Map<String, String?> map = _toMap();
    for (var entry in map.entries) {
      var key = entry.key;
      var value = entry.value ?? "";

      body +=
          "--$boundary\nContent-Disposition: form-data; name=\"$key\"\n\n$value\n";
    }
    body += "--$boundary--";
    return body;
  }

  Map<String, String> makeHeader() {
    // リクエストのヘッダーとボディを設定
    final headers = <String, String>{
      'Content-Type': 'multipart/form-data; boundary=$boundary',
    };
    return headers;
  }
}

Future<String> fetchSyllabusResults(RequestQuery requestQuery) async {
  // リクエストを送信
  final response = await http.post(
    Uri.parse('https://www.wsl.waseda.jp/syllabus/JAA101.php'),
    headers: requestQuery.makeHeader(),
    body: requestQuery.makeBody(),
  );

  // レスポンスを処理
  if (response.statusCode == 200) {
    return response.body;
  } else {
    print('Request failed with status: ${response.statusCode}');
    return "";
  }
}

List<SyllabusQueryResult>? _getFirstCourse(String htmlString) {
  final document = html_parser.parse(htmlString);
  final trElements = document.querySelectorAll('.ct-vh > tbody >tr');
  List<SyllabusQueryResult> syllabusQueryResultList = [];
  if (trElements.isNotEmpty) {
    final tdElements = trElements[1].querySelectorAll("td");
    final anchor = tdElements[2].querySelector("a");
    var match = RegExp(r"post_submit\('JAA104DtlSubCon', '(.*)'\)")
        .firstMatch(anchor!.attributes['onclick']!);
    var extractedString = match?.group(1);

    List<Map<String, int?>> periodAndDateList =
        extractDayAndPeriod(zenkaku2hankaku(tdElements[6].text));

    for (var periodAndDate in periodAndDateList) {
      SyllabusQueryResult syllabusResult = SyllabusQueryResult(
          courseName: tdElements[2].text,
          classRoom: extractClassRoom(zenkaku2hankaku(
              tdElements[7].innerHtml.replaceAll("<br>", "\n"))),
          period: periodAndDate["period"],
          weekday: periodAndDate["weekday"],
          semester: convertSemester(tdElements[5].text),
          year: int.parse(tdElements[0].text),
          syllabusID: extractedString);
      syllabusQueryResultList.add(syllabusResult);
    }

    return syllabusQueryResultList;
  } else {
    return null;
  }
}

Future<List<MyCourse>?> getMyCourse(MoodleCourse moodleCourse) async {
  List<MyCourse>? myCourseList = [];
  List<SyllabusQueryResult>? syllabusQueryResultList;
  RequestQuery requestQuery = RequestQuery(
      kamoku: moodleCourse.courseName.replaceAll("・", " "),
      keyword: moodleCourse.department);

  syllabusQueryResultList =
      _getFirstCourse(await fetchSyllabusResults(requestQuery));

  if (syllabusQueryResultList != null) {
    for (var syllabusQueryResult in syllabusQueryResultList) {
      MyCourse myCourse = MyCourse(
          classRoom: syllabusQueryResult.classRoom,
          color: moodleCourse.color,
          courseName: moodleCourse.courseName,
          pageID: moodleCourse.pageID,
          period: syllabusQueryResult.period,
          semester: syllabusQueryResult.semester,
          syllabusID: syllabusQueryResult.syllabusID,
          weekday: syllabusQueryResult.weekday,
          year: syllabusQueryResult.year,
          criteria: null);
      myCourseList.add(myCourse);
    }
  } else {
    return null;
  }

  return myCourseList;
}

List<Map<String, int?>> extractDayAndPeriod(String input) {
  // 「月3時限」タイプの抽出
  RegExp pattern1 = RegExp(r'([月火水木金土日])(\d)時限');
  // 「月3-4」タイプの抽出
  RegExp pattern2 = RegExp(r'([月火水木金土日])(\d)-(\d)');

  RegExp pattern3 = RegExp(r'無その他');

  List<Map<String, int?>> result = [];
  if (pattern2.hasMatch(input)) {
    Iterable<RegExpMatch> matches = pattern2.allMatches(input);
    for (var match in matches) {
      result.add({
        'weekday': weekdayToNumber(match.group(1)),
        'period': int.tryParse(match.group(2)!)
      });
      result.add({
        'weekday': weekdayToNumber(match.group(1)),
        'period': int.tryParse(match.group(3)!)
      });
    }
  }

  if (pattern1.hasMatch(input)) {
    Iterable<RegExpMatch> matches = pattern1.allMatches(input);
    for (var match in matches) {
      result.add({
        'weekday': weekdayToNumber(match.group(1)),
        'period': int.tryParse(match.group(2)!)
      });
    }
  }
  if (pattern3.hasMatch(input)) {
    result.add({'weekday': null, 'period': null});
  }
  if (result.isEmpty) {
    result.add({'weekday': null, 'period': null});
  }

  return result;
}

String extractClassRoom(String input) {
  RegExp pattern3 = RegExp(r'\d+:(.*)\s');
  Iterable<RegExpMatch> matches = pattern3.allMatches(input);
  List<String> result = [];
  if (matches.isEmpty) {
    result.add(input);
  } else {
    for (var match in matches) {
      result.add(match.group(1)!);
    }
  }

  return result.join("\n").trimRight();
}

Future<void> resisterVacantRoomList(String buildingNum) async {
  List<String> classRoomList = classMap[buildingNum] ?? [];
  Map<String, Map<String, Map<String, List<String>>>> copyQuarterClassRoomList =
      {};
  RequestQuery requestQuery;
  String htmlString;
  List<Map<String, int?>> periodAndDateList;
  DateTime now = DateTime.now();

  List<String> quarterList = [];
  copyQuarterClassRoomList =
      _createQuarterClassRoomMap(buildingNum: buildingNum);
  for (var classRoom in classRoomList) {
    requestQuery = RequestQuery(
      // p_gakki: "1",
      keyword: classRoom,
      p_number: "100",
    );
    htmlString = await fetchSyllabusResults(requestQuery);
    final document = html_parser.parse(htmlString);
    final trElements = document.querySelectorAll('.ct-vh > tbody > tr');
    if (trElements.isNotEmpty) {
      trElements.removeAt(0);

      for (var trElement in trElements) {
        final tdElements = trElement.querySelectorAll("td");
        periodAndDateList =
            extractDayAndPeriod(zenkaku2hankaku(tdElements[6].text));
        String? semester = convertSemester(tdElements[5].text);
        if (semester != null) {
          quarterList = semester2quarterList(semester);

          //クォーター制に分割して、合致するところにデータを挿入する
          for (var quarter in quarterList) {
            //時限-曜日が複数羅列している時の処理
            for (var periodAndDate in periodAndDateList) {
              if (periodAndDate["weekday"] != null &&
                  periodAndDate["period"] != null) {
                int weekday = periodAndDate["weekday"]!;
                int period = periodAndDate["period"]!;

                IsarHandler().resisterClassRoom(
                    isar!,
                    Building(buildingName: buildingNum),
                    ClassRoom(classRoomName: classRoom),
                    HasClass(
                        weekday: weekday, period: period, quarter: quarter));
              }
            }
          }
          //await Future.delayed(const Duration(milliseconds: 500));
        } else {
          continue;
        }
      }
    } else {
      continue;
    }
  }
}

Map<String, Map<String, Map<String, List<String>>>> _createQuarterClassRoomMap(
    {required String buildingNum}) {
  Map<String, Map<String, Map<String, List<String>>>> quarterClassRoomMap = {};

  // Define quarters
  List<String> quarters = [
    "spring_quarter",
    "summer_quarter",
    "fall_quarter",
    "winter_quarter"
  ];
  // Iterate over quarters
  for (String quarter in quarters) {
    quarterClassRoomMap.putIfAbsent(quarter, () => {});

    // Iterate over days (Monday to Friday)
    for (int day = 1; day <= 5; day++) {
      quarterClassRoomMap[quarter]!.putIfAbsent(day.toString(), () => {});

      // Iterate over periods (1st to 6rd)
      for (int period = 1; period <= 6; period++) {
        quarterClassRoomMap[quarter]![day.toString()]!
            .putIfAbsent(period.toString(), () => []);

        // Insert classRoomList based on buildingNum
        List<String> classRoomList = classMap[buildingNum] ?? [];
        quarterClassRoomMap[quarter]![day.toString()]![period.toString()]!
            .addAll(classRoomList);
      }
    }
  }
  return quarterClassRoomMap;
}
