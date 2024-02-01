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
  var sortedDataByDay = {};
  CalendarData();

  void getData(List<Map<String, dynamic>> data) {
    calendarData = data;
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
 }


}