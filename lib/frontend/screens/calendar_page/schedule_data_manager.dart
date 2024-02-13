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
  var sortedDataByDay = {};
  CalendarData();

  void getData(List<Map<String, dynamic>> data) {
    calendarData = data;
  }

  void getTemplateData(Future<List<Map<String, dynamic>>> data) async {
    List<Map<String, dynamic>> fetchedTemplateData = await data;
    templateData = fetchedTemplateData;
    print("テンプレデータだよ" + templateData.toString());
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


}