import 'package:flutter_calandar_app/static/constant.dart';
import 'package:flutter_calandar_app/static/converter.dart';

import 'package:http/http.dart' as http;

import 'package:html/parser.dart' as html_parser;

import 'package:uuid/uuid.dart';

import 'package:html/dom.dart';
import "./syllabus_query_result.dart";

class SyllabusRequestQuery {
  String? p_number = "100";
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
  String? pLng = "jp";
//オープン科目の検索時0に設定
  bool p_open;
  //科目区分検索時学部IDを設定
  SubjectClassification? subjectClassification;
  String? p_keyb = "";
  String? p_searcha = "a";
  String? p_searchb = "b";

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
      'p_gakki': p_gakki?.indexForSyllabusQuery,
      'p_youbi': p_youbi?.index,
      'p_jigen': p_jigen?.period,
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

  String _makeBody() {
    Map<String, dynamic> map = _toMap();
    String body = map.entries
        .map((e) =>
            "--$boundary\nContent-Disposition: form-data; name=\"${e.key}\"\n\n${e.value != null ? e.value.toString() : ""}\n")
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
      yield await _getSingleSyllabusInfo(syllabusURL);
    }
  }

  Future<SyllabusQueryResult?> getFirstSingleSyllabusInfo(
      String? perfectMatchedCourseName) async {
    List<String> syllabusURLs =
        await _getSyllabusURLs(perfectMatchedCourseName);
    if (syllabusURLs.isEmpty) {
      return null;
    } else {
      return await _getSingleSyllabusInfo(syllabusURLs.first);
    }
  }

  Future<SyllabusQueryResult> _getSingleSyllabusInfo(String syllabusURL) async {
    final response = await http.post(
      Uri.parse(syllabusURL),
    );
    final Document document = html_parser.parse(response.body);
    List<Element> c_mblocks = document.getElementById("cEdit")?.children ?? [];
    Element courseInfo = c_mblocks.first;
    Element syllabusInfo = c_mblocks[1];
    List<Element> courseTrElements =
        courseInfo.querySelectorAll("table > tbody > tr");
    int _year = Term.whenSchoolYear(DateTime.now());
    late String _courseName;
    String? _subjectClassification = subjectClassification?.text;
    String? _department;
    late String _classRoom;
    String? _credit;
    String? _teacher;
    late String _semesterAndWeekdayAndPeriod;

    for (var trElement in courseTrElements) {
      List<Element> ths = trElement.querySelectorAll("th");
      for (var th in ths) {
        switch (th.text) {
          case "開講年度":
            _year = int.parse(RegExp(r"(....)年度")
                .firstMatch(th.nextElementSibling!.text)!
                .group(1)!);
          case "科目名":
            _courseName = zenkaku2hankaku(th.nextElementSibling!.text);
          case "科目区分":
            _subjectClassification =
                zenkaku2hankaku(th.nextElementSibling!.text);
          case "開講箇所":
            _department = zenkaku2hankaku(th.nextElementSibling!.text);
          case "使用教室":
            _classRoom = zenkaku2hankaku(th.nextElementSibling!.text);
          case "単位数":
            _credit = zenkaku2hankaku(th.nextElementSibling!.text);
          case "担当教員":
            _teacher = zenkaku2hankaku(th.nextElementSibling!.text);
          case "学期曜日時限":
            _semesterAndWeekdayAndPeriod =
                zenkaku2hankaku(th.nextElementSibling!.text);
        }
      }
    }
    List<Element> syllabusTrElements =
        syllabusInfo.querySelectorAll("table > tbody > tr");
    String? _abstract;
    String? _agenda;
    String? _textbook;
    String? _reference;
    String? _criteria;
    String? _remark;
    for (var trElement in syllabusTrElements) {
      List<Element> ths = trElement.querySelectorAll("th");
      for (var th in ths) {
        switch (th.text) {
          case "授業概要":
            _abstract = zenkaku2hankaku(th.nextElementSibling!.text);
          case "授業計画":
            _agenda = zenkaku2hankaku(th.nextElementSibling!.text);
          case "教科書":
            _textbook = zenkaku2hankaku(th.nextElementSibling!.text);
          case "参考文献":
            _reference = zenkaku2hankaku(th.nextElementSibling!.text);
          case "成績評価方法":
            _criteria = zenkaku2hankaku(th.nextElementSibling!.text);
          case "備考・関連URL":
            _remark = zenkaku2hankaku(th.nextElementSibling!.text);
        }
      }
    }

    return SyllabusQueryResult(
        courseName: _courseName,
        classRoom: _classRoom,
        year: _year,
        semesterAndWeekdayAndPeriod: _semesterAndWeekdayAndPeriod,
        syllabusID: syllabusURL,
        teacher: _teacher,
        credit: _credit,
        criteria: _criteria,
        department: _department,
        subjectClassification: _subjectClassification,
        abstract: _abstract,
        agenda: _agenda,
        reference: _reference,
        remark: _remark,
        textbook: _textbook);
  }
}
