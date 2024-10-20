import 'package:flutter_calandar_app/static/constant.dart';
import 'package:flutter_calandar_app/static/converter.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:http/retry.dart';
import 'package:uuid/uuid.dart';
import 'package:html/dom.dart';
import "syllabus_query_result.dart";
import "../DB/sharepreference.dart";
import "../DB/chache.dart";

class SyllabusRequestQuery {
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
  Term? p_gakki;
  DayOfWeek? p_youbi;
  Lesson? p_jigen;
  String? p_gengo;
  Department? p_gakubu;
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
  String? pLng;
//オープン科目の検索時0に設定
  bool p_open;
  //科目区分検索時学部IDを設定
  SubjectClassification? subjectClassification;
  String? p_keyb;
  String? p_searcha;
  String? p_searchb;

  String boundary = '----WebKitFormBoundary${const Uuid().v4()}';

  SyllabusRequestQuery({
    this.p_number,
    this.p_page,
    required this.keyword,
    // this.s_bunya1_hid,
    // this.s_bunya2_hid,
    // this.s_bunya3_hid,
    this.area_type,
    this.area_value,
    this.s_level_hid,
    required this.kamoku,
    this.kyoin,
    required this.p_gakki,
    required this.p_youbi,
    required this.p_jigen,
    required this.p_gengo,
    required this.p_gakubu,
    this.hidreset,
    //this.pfrontPage,
    this.pchgFlg,
    this.bunya1_hid,
    this.bunya2_hid,
    this.bunya3_hid,
    this.level_hid,
    // this.ControllerParameters,
    required this.p_open,
    required this.subjectClassification,
    this.pOcw,
    this.pType,
    this.pLng,
  });

  Map<String, dynamic> _toMap() {
    Map<String, dynamic> normalQuery = {
      "p_number": p_number ?? "100",
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
      'p_gakki': p_gakki?.indexForSyllabusQuery,
      'p_youbi': p_youbi?.index,
      'p_jigen':
          p_jigen != null ? "${p_jigen?.period}${p_jigen?.period}" : null,
      //フルオンデマンドを選択した時
      'p_gengo': p_gengo,
      'p_gakubu': p_gakubu?.departmentID,
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
      'pLng': pLng ?? "jp",
    };
    if (p_open) {
      normalQuery.addAll({"p_open[]": 0});
    }
    if (subjectClassification != null) {
      normalQuery.addAll({
        "p_keya": subjectClassification!.p_keya,
        "p_keyb": "",
        "p_searcha": "a",
        "p_searchb": "b",
        "p_gakubu": subjectClassification!.parentDepartmentID
      });
    }

    return normalQuery;
  }

  SyllabusRequestQuery copyWith({
    String? keyword,
    String? kamoku,
    Term? p_gakki,
    DayOfWeek? p_youbi,
    Lesson? p_jigen,
    Department? p_gakubu,
    String? p_gengo,
    bool? p_open,
    SubjectClassification? subjectClassification,
  }) {
    return SyllabusRequestQuery(
      keyword: keyword ?? this.keyword,
      kamoku: kamoku ?? this.kamoku,
      p_gakki: p_gakki ?? this.p_gakki,
      p_youbi: p_youbi ?? this.p_youbi,
      p_jigen: p_jigen ?? this.p_jigen,
      p_gakubu: p_gakubu ?? this.p_gakubu,
      p_gengo: p_gengo ?? this.p_gengo,
      p_open: p_open ?? this.p_open,
      subjectClassification:
          subjectClassification ?? this.subjectClassification,
    );
  }

  String _makeBody() {
    Map<String, dynamic> map = _toMap();
    String body = map.entries
        .map((e) =>
            "--$boundary\nContent-Disposition: form-data; name=\"${e.key}\"\n\n${e.value ?? ""}\n")
        .join("");
    body += "--$boundary--";

    return body;
  }

  Map<String, String> _makeHeader() {
    // リクエストのヘッダーとボディを設定
    final headers = <String, String>{
      'Content-Type': 'multipart/form-data; boundary=$boundary',
    };
    return headers;
  }

  Future<List<Element>> fetchSyllabusSearchResults() async {
    // リクエストを送信
    final response = await http.post(
      Uri.parse('https://www.wsl.waseda.jp/syllabus/JAA101.php'),
      headers: _makeHeader(),
      body: _makeBody(),
    );

    // レスポンスを処理
    if (response.statusCode == 200) {
      SharepreferenceHandler()
          .setValue(SharepreferenceKeys.recentSyllabusQueryIsOpen, p_open);
      SharepreferenceHandler()
          .setValue(SharepreferenceKeys.recentSyllabusQueryKamoku, kamoku);
      SharepreferenceHandler()
          .setValue(SharepreferenceKeys.recentSyllabusQueryKeyword, keyword);

      return html_parser
          .parse(response.body)
          .querySelectorAll('.ct-vh > tbody > tr');
    } else {
      print('Request failed with status: ${response.statusCode}');
      return [];
    }
  }

  Future<List<String>> _getSyllabusURLs(
      String? perfectMatchedCourseName) async {
    List<Element> trElements = await fetchSyllabusSearchResults();

    if (trElements.isEmpty) {
      return [];
    } else {
      trElements.removeAt(0);
      List<String> syllabusURLs = [
        for (var e in trElements)
          if (_getSyllabusURL(e, perfectMatchedCourseName) != null)
            _getSyllabusURL(e, perfectMatchedCourseName)!
      ];

      return syllabusURLs;
    }
  }

  String? _getSyllabusURL(Element e, String? perfectMatchedCourseName) {
    final anchor = e.querySelectorAll("td")[2].querySelector("a");
    var match = RegExp(r"post_submit\('JAA104DtlSubCon', '(.*)'\)")
        .firstMatch(anchor!.attributes['onclick']!);
    String? syllabusURL = match?.group(1) != null
        ? "https://www.wsl.waseda.jp/syllabus/JAA104.php?pKey=${match?.group(1)}"
        : null;

    if (perfectMatchedCourseName == null) {
      return syllabusURL;
    } else {
      if (e.querySelectorAll("td")[2].text == perfectMatchedCourseName) {
        return syllabusURL;
      } else {
        return null;
      }
    }
  }

  Stream<SyllabusQueryResult> fetchAllSyllabusInfo() async* {
    List<String> syllabusURLs = await _getSyllabusURLs(null);

    for (var syllabusURL in syllabusURLs) {
      SyllabusQueryResult res = await getSingleSyllabusInfo(syllabusURL);
      yield res;
    }
  }

  static Future<SyllabusQueryResult> getSingleSyllabusInfo(
      String syllabusURL) async {
    SyllabusQueryResult? res = await syllabusQueryCache.get(syllabusURL);
    if (res != null) {
      return res;
    } else {
      final response = await http.post(
        Uri.parse(syllabusURL),
      );
      final Document document = html_parser.parse(response.body);
      List<Element> cMblocks = document.getElementById("cEdit")?.children ?? [];
      Element courseInfo = cMblocks.first;
      Element syllabusInfo = cMblocks[1];
      List<Element> courseTrElements =
          courseInfo.querySelectorAll("table > tbody > tr");
      int year = Term.whenSchoolYear(DateTime.now());
      late String courseName;

      String? subjectClassification;
      String? department;
      late String classRoom;
      int? credit;
      String? teacher;
      String? campus;
      String? allocatedYear;
      String? lectureSystem;
      late String semesterAndWeekdayAndPeriod;

      for (var trElement in courseTrElements) {
        List<Element> ths = trElement.querySelectorAll("th");
        for (var th in ths) {
          switch (th.text.trim()) {
            case "開講年度":
              year = int.parse(RegExp(r"(....)年度")
                  .firstMatch(th.nextElementSibling!.text)!
                  .group(1)!);
            case "科目名":
              courseName = zenkaku2hankaku(th.nextElementSibling!.text);
            case "科目区分":
              subjectClassification =
                  zenkaku2hankaku(th.nextElementSibling!.text);
            case "開講箇所":
              department = zenkaku2hankaku(th.nextElementSibling!.text);
            case "使用教室":
              classRoom = zenkaku2hankaku(th.nextElementSibling!.text);
            case "単位数":
              credit =
                  int.tryParse(zenkaku2hankaku(th.nextElementSibling!.text));

            case "担当教員":
              teacher = zenkaku2hankaku(th.nextElementSibling!.text);
            case "学期曜日時限":
              semesterAndWeekdayAndPeriod =
                  zenkaku2hankaku(th.nextElementSibling!.text);
            case "キャンパス":
              campus = zenkaku2hankaku(th.nextElementSibling!.text);
            case "配当年次":
              allocatedYear = zenkaku2hankaku(th.nextElementSibling!.text);
            case "授業方法区分":
              lectureSystem = zenkaku2hankaku(th.nextElementSibling!.text);
          }
        }
      }
      List<Element> syllabusTrElements =
          syllabusInfo.querySelectorAll("table > tbody > tr");
      String? abstract;
      String? agenda;
      String? textbook;
      String? reference;
      String? criteria;
      String? remark;
      for (var trElement in syllabusTrElements) {
        List<Element> ths = trElement.querySelectorAll("th");
        for (var th in ths) {
          switch (th.text.trim()) {
            case "授業概要":
              abstract = zenkaku2hankaku(html_parser
                      .parseFragment(th.nextElementSibling!.innerHtml
                          .replaceAll("<br>", "<p>\n</p>")
                          .replaceAll("</p>", "\n</p>")
                          .replaceAll("</td>", "\n</td>")
                          .replaceAll("</div>", "\n</div>")
                          .replaceAllMapped(
                              RegExp(r"<style>(.+)</style>"), (match) => ""))
                      .text!)
                  .replaceAllMapped(RegExp(r":(\n+)"), (match) => " :  ")
                  .replaceAllMapped(RegExp(r"\n+"), (match) => "\n")
                  .trim();
            case "授業計画":
              agenda = zenkaku2hankaku(html_parser
                      .parseFragment(th.nextElementSibling!.innerHtml
                          .replaceAll("<br>", "<p>\n</p>")
                          .replaceAll("</p>", "\n</p>")
                          .replaceAll("</td>", "\n</td>")
                          .replaceAll("</div>", "\n</div>")
                          .replaceAllMapped(
                              RegExp(r"<style>(.+)</style>"), (match) => ""))
                      .text!)
                  .replaceAllMapped(RegExp(r":(\n+)"), (match) => " :  ")
                  .replaceAllMapped(RegExp(r"\n+"), (match) => "\n")
                  .trim();
            case "教科書":
              textbook = zenkaku2hankaku(th.nextElementSibling!.text);
            case "参考文献":
              reference = zenkaku2hankaku(th.nextElementSibling!.text).trim();
            case "成績評価方法":
              criteria =
                  trimCriteria(zenkaku2hankaku(th.nextElementSibling!.text));
            case "備考・関連URL":
              remark = zenkaku2hankaku(html_parser
                      .parseFragment(th.nextElementSibling!.innerHtml
                          .replaceAll("<br>", "<p>\n</p>")
                          .replaceAll("</p>", "\n</p>")
                          .replaceAll("</td>", "\n</td>")
                          .replaceAll("</div>", "\n</div>")
                          .replaceAllMapped(
                              RegExp(r"<style>(.+)</style>"), (match) => ""))
                      .text!)
                  .replaceAllMapped(RegExp(r":(\n+)"), (match) => " :  ")
                  .replaceAllMapped(RegExp(r"\n+"), (match) => "\n")
                  .trim();
          }
        }
      }
      res = SyllabusQueryResult(
          courseName: courseName,
          classRoom: classRoom,
          year: year,
          semesterAndWeekdayAndPeriod: semesterAndWeekdayAndPeriod,
          syllabusID: syllabusURL,
          teacher: teacher,
          credit: credit,
          criteria: criteria,
          department: department,
          subjectClassification: subjectClassification,
          abstract: abstract,
          agenda: agenda,
          reference: reference,
          remark: remark,
          textbook: textbook,
          lectureSystem: lectureSystem,
          campus: campus,
          allocatedYear: allocatedYear);

      await syllabusQueryCache.set(syllabusURL, res);

      return res;
    }
  }

  Future<SyllabusQueryResult?> getFirstSingleSyllabusInfo(
      String? perfectMatchedCourseName) async {
    List<String> syllabusURLs =
        await _getSyllabusURLs(perfectMatchedCourseName);

    if (syllabusURLs.isEmpty) {
      return null;
    } else {
      return await getSingleSyllabusInfo(syllabusURLs.first);
    }
  }

  static String trimCriteria(String str) {
    String pritterStr;
    pritterStr = str.replaceAll("割合", "");
    pritterStr = pritterStr.replaceAll("評価基準", "");
    pritterStr = pritterStr.replaceAll(RegExp(r"\n\n"), "\n");
    pritterStr = pritterStr.replaceAllMapped(
        RegExp(r":\n(.+)\n"), (match) => " : ${match.group(1)}\n    ");
    return pritterStr.trim();
  }
}
