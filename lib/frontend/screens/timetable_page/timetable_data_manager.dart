import 'package:flutter_riverpod/flutter_riverpod.dart';

final timeTableProvider = StateNotifierProvider<TimeTableNotifier, TimeTableData>(
  (ref) => TimeTableNotifier(),
);


class TimeTableNotifier extends StateNotifier<TimeTableData> {
  TimeTableNotifier() : super(TimeTableData(timeTableDataList: []));

  void addNewData(Map<String, dynamic> newDataMap) {
    final newtimeTableDataList = [...state.timeTableDataList, newDataMap];
    state = state.copyWith(taskDataList: newtimeTableDataList);
  }
}

class TimeTableData {
  List<Map<String, dynamic>> timeTableDataList = [];
  bool isInit = false;
  bool isRenewed = false;
  var sortedDataByWeekDay = {};
  var universityScheduleByWeekDay = {};
  int maxPeriod = 4;

  TimeTableData({
    List<Map<String, dynamic>> timeTableDataList = const [],
  })  : timeTableDataList = timeTableDataList;
        

  TimeTableData copyWith({
    List<Map<String, dynamic>>? taskDataList,
    int? taskPageIndex,
  }) {
    return TimeTableData(
      timeTableDataList: timeTableDataList ?? this.timeTableDataList,
    );
  }

  Future<void> getData(Future<List<Map<String, dynamic>>> data) async{
    timeTableDataList = await data;
  }

  void addNewData(Map<String, dynamic> newDataMap) {
    timeTableDataList = [...timeTableDataList, newDataMap];
    isInit =false;
  }

  Map<int, List<Map<String, dynamic>>> sortDataByWeekDay(TDList) {
    Map<int, List<Map<String, dynamic>>> sortedData = {};
    maxPeriod = 4;
    for (int i = 0; i < TDList.length; i++) {
        
        int? targetWeekDay = TDList[i]["weekDay"];
        int period = TDList[i]["period"] ?? 0;
        if(maxPeriod < period){
          maxPeriod = period;
        }

        if(sortedData.containsKey(targetWeekDay)) {
          sortedData[targetWeekDay]!.add(TDList.elementAt(i));
        }else{
          sortedData[targetWeekDay ?? 7] = [TDList.elementAt(i)];
        }
    }

    for(int i = 0; i < sortedData.length; i++){
      List<Map<String,dynamic>> data = sortedData.values.elementAt(i);
      int targetKey = sortedData.keys.elementAt(i);
      data.sort((a, b) => (a["period"] as int).compareTo(b["period"] as int));
      sortedData[targetKey] = data;
    }

    sortedDataByWeekDay = sortedData;
   return sortedData;
  }


  String returnStringClassTime(int thisYear,int semesterNum,int weekDay){
    List<Map<String,dynamic>> weekDayData = sortedDataByWeekDay[weekDay] ?? [];
    String startTime = "";
    String endTime = "";
    String result = "";
    List<Map<String,dynamic>> thisSemesterData = [];
    for(int i = 0; i < weekDayData.length; i++){
      Map<String,dynamic> target = weekDayData.elementAt(i);
      if(target["year"] == thisYear &&
         target["weekDay"] != null &&
         target["period"] != null){
      if(target["semester"] == currentQuaterID(semesterNum) ||
         target["semester"] == currentSemesterID(semesterNum)){
         thisSemesterData.add(target);
        }
      }
    }
    if(weekDayData.isNotEmpty && thisSemesterData.isNotEmpty){
      startTime = returnBeginningTime(thisSemesterData.first["period"]);
      endTime = returnEndTime(thisSemesterData.last["period"]);
      result = startTime +"~" + endTime;}
    return result;
  }

  void initUniversityScheduleByDay(int thisYear,int semesterNum){
    universityScheduleByWeekDay = {};
    universityScheduleByWeekDay[1] = returnStringClassTime(thisYear,semesterNum,1);
    universityScheduleByWeekDay[2] = returnStringClassTime(thisYear,semesterNum,2);
    universityScheduleByWeekDay[3] = returnStringClassTime(thisYear,semesterNum,3);
    universityScheduleByWeekDay[4] = returnStringClassTime(thisYear,semesterNum,4);
    universityScheduleByWeekDay[5] = returnStringClassTime(thisYear,semesterNum,5);
    universityScheduleByWeekDay[6] = returnStringClassTime(thisYear,semesterNum,6);
  }

  String currentQuaterID(int semesterNum){
    String result = "full_year";
    if(semesterNum == 1){
      result = "spring_quarter";
    }else if(semesterNum == 2){
      result = "summer_quarter";
    }else if(semesterNum == 3){
      result = "fall_quarter";
    }else if(semesterNum == 4){
      result = "winter_quarter";
    }else if(semesterNum == 5){
      result = "holiday";
    }
    return result;
  }

  String currentSemesterID(int semesterNum){
    String result = "full_year";
    if(semesterNum == 1 || semesterNum == 2){
      result = "spring_semester";
    }else if(semesterNum == 3 || semesterNum == 4){
      result = "fall_semester";
    }else if(semesterNum == 5){
      result = "holiday";
    }
    return result;
  }

  String returnBeginningTime(int period){
    switch(period) {
      case 1: return "08:50";
      case 2: return "10:40";
      case 3: return "13:10";
      case 4: return "15:05";
      case 5: return "17:00";
      case 6: return "18:55";
      default : return "20:45";
    }
  }

  DateTime returnBeginningDateTime(int period){
    DateTime now = DateTime.now();
    switch(period) {
      case 1: return DateTime(now.year,now.month,now.day,8,50);
      case 2: return DateTime(now.year,now.month,now.day,10,40);
      case 3: return DateTime(now.year,now.month,now.day,13,10);
      case 4: return DateTime(now.year,now.month,now.day,15,05);
      case 5: return DateTime(now.year,now.month,now.day,17,00);
      case 6: return DateTime(now.year,now.month,now.day,18,55);
      default : return DateTime(now.year,now.month,now.day,20,45);
    }
  }

  String returnEndTime(int period){
    switch(period) {
      case 1: return "10:30";
      case 2: return "12:20";
      case 3: return "14:50";
      case 4: return "16:45";
      case 5: return "18:40";
      case 6: return "20:35";
      default : return "21:35";
    }
  }

  DateTime returnEndDateTime(int period){
    DateTime now = DateTime.now();
    switch(period) {
      case 1: return DateTime(now.year,now.month,now.day,10,30);
      case 2: return DateTime(now.year,now.month,now.day,12,20);
      case 3: return DateTime(now.year,now.month,now.day,14,50);
      case 4: return DateTime(now.year,now.month,now.day,16,45);
      case 5: return DateTime(now.year,now.month,now.day,18,40);
      case 6: return DateTime(now.year,now.month,now.day,20,35);
      default : return DateTime(now.year,now.month,now.day,21,35);
    }
  }
  // TaskData copyWith({
  //   List<Map<String, dynamic>>? taskDataList,
  // }) {
  //   return TaskData()
  //     ..taskDataList = taskDataList ?? this.taskDataList;
  // }

  void clearContents() {
    timeTableDataList.clear();
  }
}