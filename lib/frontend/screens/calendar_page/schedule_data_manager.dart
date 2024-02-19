import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

final calendarDataProvider = StateNotifierProvider<CalendarDataNotifier, CalendarData>(
  (ref) => CalendarDataNotifier(),
);


class CalendarDataNotifier extends StateNotifier<CalendarData> {
  CalendarDataNotifier() : super(CalendarData());

  void setTaskPageIndex(int newIndex) {
  }

  void addNewData(Map<String, dynamic> newDataMap) {

  }
}

class CalendarData {
  var calendarData = [];
  var templateData = [];
  var tagData = [];
  var sortedDataByDay = {};
  var sortedDataByMonth = {};
  CalendarData();

  void getData(List<Map<String, dynamic>> data) {
    calendarData = data;
  }

  void getTemplateData(Future<List<Map<String, dynamic>>> data) async {
    List<Map<String, dynamic>> fetchedTemplateData = await data;
    templateData = fetchedTemplateData;
  }

  void getTagData(Future<List<Map<String, dynamic>>> data) async {
    var fetchedTagData = await data;
    var fixedData = [];

    for (int i = 0; i < fetchedTagData.length; i++) {
      fixedData.add({
        "id": fetchedTagData.elementAt(i)["id"],
        "title": fetchedTagData.elementAt(i)["title"],
        "color": intToColor(fetchedTagData.elementAt(i)["color"]),
        "isBeit": fetchedTagData.elementAt(i)["isBeit"],
        "wage": fetchedTagData.elementAt(i)["wage"],
      });
    }
    tagData = fixedData;
  }

  void sortDataByDay(){
   sortedDataByDay = {};

    for(int i = 0; i < calendarData.length; i++){
      if(sortedDataByDay.keys.contains(calendarData.elementAt(i)["startDate"])){
        sortedDataByDay[calendarData.elementAt(i)["startDate"]]!.add(calendarData.elementAt(i));
      }else{
        sortedDataByDay[calendarData.elementAt(i)["startDate"]] = [calendarData.elementAt(i)];
      }
   }

   for(int i = 0; i < sortedDataByDay.length; i++){
    List targetList = sortedDataByDay.values.elementAt(i);
    String targetKey = sortedDataByDay.keys.elementAt(i);

    List validEvents = targetList.where((event) => event['startTime'] != "").toList();
    List invalidEvents = targetList.where((event) => event['startTime'] == "").toList();

    // "startTime"でソート
    validEvents.sort((a, b) {
      // "startTime"を時間型に変換して比較
      Duration timeA = Duration(hours:int.parse(a['startTime'].substring(0,2)),minutes:int.parse(a['startTime'].substring(3,5)));
      Duration timeB = Duration(hours:int.parse(b['startTime'].substring(0,2)),minutes:int.parse(b['startTime'].substring(3,5)));
      return timeA.compareTo(timeB);
    });
    
    // ソートされた予定で元のリストを更新
    targetList = invalidEvents;
    targetList.addAll(validEvents);

    sortedDataByDay[targetKey] = targetList;
   
   }
 }

  void sortDataByMonth(){
   var rawData = sortedDataByDay;
   var result = {};
   for(int i = 0; i < rawData.length; i++){
    String targetKey = rawData.keys.elementAt(i).substring(0,7);
    if(result.keys.contains(targetKey)){
      result[targetKey][rawData.keys.elementAt(i)] = rawData.values.elementAt(i);
    }else{
      result[targetKey] = {rawData.keys.elementAt(i):rawData.values.elementAt(i)};
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