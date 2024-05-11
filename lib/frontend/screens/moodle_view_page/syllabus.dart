import 'package:http/http.dart' as http;
import 'dart:math';

import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as html;
import 'package:uuid/uuid.dart';
import "./my_course_db.dart";

class RequestQuery {
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

Future<List<SyllabusQueryResult>?> fetchSyllabusResults(
    RequestQuery requestBody) async {
  // リクエストを送信
  final response = await http.post(
    Uri.parse('https://www.wsl.waseda.jp/syllabus/JAA101.php'),
    headers: requestBody.makeHeader(),
    body: requestBody.makeBody(),
  );

  // レスポンスを処理
  if (response.statusCode == 200) {
    return _get(response.body);
  } else {
    print('Request failed with status: ${response.statusCode}');
    return null;
  }
}

List<SyllabusQueryResult>? _get(String htmlString) {
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
          classRoom:
              zenkaku2hankaku(tdElements[7].innerHtml.replaceAll("<br>", "\n")),
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

  syllabusQueryResultList = await fetchSyllabusResults(requestQuery);

  if (syllabusQueryResultList != null) {
    for (var syllabusQueryResult in syllabusQueryResultList) {
      MyCourse myCourse = MyCourse(
          attendCount: null,
          classRoom: syllabusQueryResult.classRoom,
          color: moodleCourse.color,
          courseName: moodleCourse.courseName,
          memo: null,
          pageID: moodleCourse.pageID,
          period: syllabusQueryResult.period,
          semester: syllabusQueryResult.semester,
          syllabusID: syllabusQueryResult.syllabusID,
          weekday: syllabusQueryResult.weekday,
          year: syllabusQueryResult.year);
      myCourseList.add(myCourse);
    }
  } else {
    return null;
  }

  return myCourseList;
}

String? convertSemester(String? text) {
  switch (text) {
    case "春クォーター":
      return "spring_quarter";
    case "夏クォーター":
      return "summer_quarter";
    case "春学期":
      return "spring_semester";
    case "秋クォーター":
      return "fall_quarter";
    case "冬クォーター":
      return "winter_quarter";
    case "秋学期":
      return "fall_semester";
    case "通年":
      return "full_year";
    default:
      return null;
  }
}

int? _weekdayToNumber(String? weekday) {
  switch (weekday) {
    case '月':
      return 1;
    case '火':
      return 2;
    case '水':
      return 3;
    case '木':
      return 4;
    case '金':
      return 5;
    case '土':
      return 6;
    case '日':
      return 7;
    case null:
      return null;
    default:
      return null; // 不明な曜日の場合
  }
}

String zenkaku2hankaku(String fullWidthString) {
  const fullWidthChars =
      '０１２３４５６７８９ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ！＃＄％＆’（）＊＋，－．／：；＜＝＞？＠［￥］＾＿‘｛｜｝～';
  const halfWidthChars =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!#\$%&\'()*+,-./:;<=>?@[¥]^_`{|}~';
  final map = Map.fromIterables(fullWidthChars.runes, halfWidthChars.runes);

  final result = fullWidthString.runes.map((charCode) {
    return map[charCode] != null
        ? String.fromCharCode(map[charCode]!)
        : String.fromCharCode(charCode);
  }).join('');

  return result;
}

List<Map<String, int?>> extractDayAndPeriod(String input) {
  RegExp _pattern1 = RegExp(r'([月火水木金土日])\s*(\d+)時限');
  RegExp _pattern2 = RegExp(r'([月火水木金土日])\s*(\d+)-(\d+)');
  RegExp _pattern3 =
      RegExp(r'\d+:\s*([月火水木金土日])\s*(\d+)時限\s*(\d+:\s*)?([月火水木金土日])\s*(\d+)時限');
  List<Map<String, int?>> result = [];
  // 時限
  if (_pattern3.hasMatch(input)) {
    Iterable<RegExpMatch> matches = _pattern3.allMatches(input);
    for (var match in matches) {
      Map<String, int?> entry = {};
      entry['weekday'] = _weekdayToNumber(match.group(1)!);
      entry['period'] =
          match.group(2) != null ? int.tryParse(match.group(2)!) : null;
      result.add(entry);
      if (match.group(3) != null) {
        Map<String, int?> entry = {};
        entry['weekday'] = _weekdayToNumber(match.group(4)!);
        entry['period'] =
            match.group(5) != null ? int.tryParse(match.group(5)!) : null;
        result.add(entry);
      }
    }
  } else if (_pattern1.hasMatch(input)) {
    Match match = _pattern1.firstMatch(input)!;
    result.add({
      'weekday': _weekdayToNumber(match.group(1)!),
      'period': match.group(2) != null ? int.tryParse(match.group(2)!) : null
    });
  } else if (_pattern2.hasMatch(input)) {
    Match match = _pattern2.firstMatch(input)!;
    result.add({
      'weekday': _weekdayToNumber(match.group(1)!),
      'period': match.group(2) != null ? int.tryParse(match.group(2)!) : null
    });
    result.add({
      'weekday': _weekdayToNumber(match.group(1)!),
      'period': match.group(3) != null ? int.tryParse(match.group(3)!) : null
    });
  } else {
    return [
      {"weekday": null, "period": null}
    ];
  }

  return result;
}
