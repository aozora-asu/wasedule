import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final calendarDataProvider =
    StateNotifierProvider<CalendarDataNotifier, CalendarData>(
  (ref) => CalendarDataNotifier(),
);

class CalendarDataNotifier extends StateNotifier<CalendarData> {
  CalendarDataNotifier() : super(CalendarData());

  void setTaskPageIndex(int newIndex) {}

  void addNewData(Map<String, dynamic> newDataMap) {}
}

class CalendarData {
  var calendarData = [];
  var dataForShare = [];
  var templateData = [];
  var tagData = [];
  var arbeitData = [];
  var configData = [];
  var sortedDataByDay = {};
  var sortedDataByDayForShare = {};
  var sortedDataByMonth = {};
  var backUpDtEnd = DateTime.now();

  String? userID;
  var uploadData = {};
  var downloadData = {};

  CalendarData();

  void getData(List<Map<String, dynamic>> data) {
    calendarData = data;
  }

  void getDataForShare(List<dynamic> data) {
    dataForShare = data;
  }

  Future<void> getTemplateData(Future<List<Map<String, dynamic>>> data) async {
    List<Map<String, dynamic>> fetchedTemplateData = await data;
    templateData = fetchedTemplateData;
  }

  void getUserID(String? data) async {
    String? fetchedData = data;
    userID = fetchedData;
  }

  void getUploadData(Future<Map<String, dynamic>> data) async {
    Map<String, dynamic> fetchedData = await data;
    uploadData = fetchedData;
  }

  void getDownloadData(Future<Map<String, dynamic>> data) async {
    Map<String, dynamic> fetchedData = await data;
    downloadData = fetchedData;
  }

  Future<void> getTagData(Future<List<Map<String, dynamic>>> data) async {
    var fetchedTagData = await data;
    var fixedData = [];

    for (int i = 0; i < fetchedTagData.length; i++) {
      fixedData.add({
        "id": fetchedTagData.elementAt(i)["id"],
        "tagID": fetchedTagData.elementAt(i)["tagID"],
        "title": fetchedTagData.elementAt(i)["title"],
        "color": intToColor(fetchedTagData.elementAt(i)["color"]),
        "isBeit": fetchedTagData.elementAt(i)["isBeit"],
        "wage": fetchedTagData.elementAt(i)["wage"],
        "fee": fetchedTagData.elementAt(i)["fee"],
      });
    }
    tagData = fixedData;
  }

  Future<void> getArbeitData(Future<List<Map<String, dynamic>>> data) async {
    var fetchedArbeitData = await data;
    arbeitData = fetchedArbeitData;
  }

  Future<void> getConfigData(Future<List<Map<String, dynamic>>> data) async {
    var fetchedConfigData = await data;
    configData = fetchedConfigData;
  }

  void sortDataByDay() {
    sortedDataByDay = {};

    for (int i = 0; i < calendarData.length; i++) {
      if (sortedDataByDay.keys
          .contains(calendarData.elementAt(i)["startDate"])) {
        sortedDataByDay[calendarData.elementAt(i)["startDate"]]!
            .add(calendarData.elementAt(i));
      } else {
        sortedDataByDay[calendarData.elementAt(i)["startDate"]] = [
          calendarData.elementAt(i)
        ];
      }
    }

    for (int i = 0; i < sortedDataByDay.length; i++) {
      List targetList = sortedDataByDay.values.elementAt(i);
      String targetKey = sortedDataByDay.keys.elementAt(i);

      List validEvents =
          targetList.where((event) => event['startTime'] != "").toList();
      List invalidEvents =
          targetList.where((event) => event['startTime'] == "").toList();

      // "startTime"でソート
      validEvents.sort((a, b) {
        // "startTime"を時間型に変換して比較

        Duration timeA = Duration(
            hours: int.parse(a['startTime'].substring(0, 2)),
            minutes: int.parse(a['startTime'].substring(3, 5)));
        Duration timeB = Duration(
            hours: int.parse(b['startTime'].substring(0, 2)),
            minutes: int.parse(b['startTime'].substring(3, 5)));
        return timeA.compareTo(timeB);
      });

      // ソートされた予定で元のリストを更新
      targetList = invalidEvents;
      targetList.addAll(validEvents);

      sortedDataByDay[targetKey] = targetList;
    }
  }

  void sortDataByDayForShare() {
    sortedDataByDayForShare = {};

    for (int i = 0; i < dataForShare.length; i++) {
      if (sortedDataByDayForShare.keys
          .contains(dataForShare.elementAt(i)["startDate"])) {
        sortedDataByDayForShare[dataForShare.elementAt(i)["startDate"]]!
            .add(dataForShare.elementAt(i));
      } else {
        sortedDataByDayForShare[dataForShare.elementAt(i)["startDate"]] = [
          dataForShare.elementAt(i)
        ];
      }
    }

    for (int i = 0; i < sortedDataByDayForShare.length; i++) {
      List targetList = sortedDataByDayForShare.values.elementAt(i);
      String targetKey = sortedDataByDayForShare.keys.elementAt(i);

      List validEvents =
          targetList.where((event) => event['startTime'] != "").toList();
      List invalidEvents =
          targetList.where((event) => event['startTime'] == "").toList();

      // "startTime"でソート
      validEvents.sort((a, b) {
        // "startTime"を時間型に変換して比較
        DateTime timeA = DateFormat("H:mm").parse(a['startTime']);
        DateTime timeB = DateFormat("H:mm").parse(b['startTime']);
        return timeA.compareTo(timeB);
      });

      targetList = invalidEvents;
      targetList.addAll(validEvents);

      sortedDataByDayForShare[targetKey] = targetList;
    }
  }

  Future<void> sortDataByMonth() async {
    var rawData = sortedDataByDay;
    var result = {};
    for (int i = 0; i < rawData.length; i++) {
      String targetKey = rawData.keys.elementAt(i).substring(0, 7);
      if (result.keys.contains(targetKey)) {
        result[targetKey][rawData.keys.elementAt(i)] =
            rawData.values.elementAt(i);
      } else {
        result[targetKey] = {
          rawData.keys.elementAt(i): rawData.values.elementAt(i)
        };
      }
    }
    sortedDataByMonth = result;
  }

  // int型からColor型への変換関数
  Color intToColor(int value) {
    // 16進数から赤、緑、青、アルファの値を抽出してColorオブジェクトを作成する
    return Color(value);
  }
}
