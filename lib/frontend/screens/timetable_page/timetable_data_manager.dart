import 'package:flutter_calandar_app/static/converter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import "../../../static/constant.dart";
import 'package:intl/intl.dart';

final timeTableProvider =
    StateNotifierProvider<TimeTableNotifier, TimeTableData>(
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
  var currentSemesterClasses = {};
  var universityScheduleByWeekDay = {};
  int maxPeriod = 4;

  TimeTableData({
    List<Map<String, dynamic>> timeTableDataList = const [],
  }) : timeTableDataList = timeTableDataList;

  TimeTableData copyWith({
    List<Map<String, dynamic>>? taskDataList,
    int? taskPageIndex,
  }) {
    return TimeTableData(
      timeTableDataList: timeTableDataList ?? timeTableDataList,
    );
  }

  Future<void> getData(Future<List<Map<String, dynamic>>> data) async {
    timeTableDataList = await data;
  }

  void addNewData(Map<String, dynamic> newDataMap) {
    timeTableDataList = [...timeTableDataList, newDataMap];
    isInit = false;
  }

  Map<int, List<Map<String, dynamic>>> sortDataByWeekDay(TDList) {
    Map<int, List<Map<String, dynamic>>> sortedData = {};
    maxPeriod = 4;
    for (int i = 0; i < TDList.length; i++) {
      int targetWeekDay = TDList[i]["weekday"] ?? 7;
      int period = TDList[i]["period"] ?? 0;
      if (maxPeriod < period) {
        maxPeriod = period;
      }

      if (sortedData.containsKey(targetWeekDay)) {
        sortedData[targetWeekDay]!.add(TDList.elementAt(i));
      } else {
        sortedData[targetWeekDay] = [TDList.elementAt(i)];
      }
    }

    for (int i = 0; i < sortedData.length; i++) {
      List<Map<String, dynamic>> data = sortedData.values.elementAt(i);
      int targetKey = sortedData.keys.elementAt(i);
      if (targetKey != 7) {
        data.sort((a, b) => (a["period"] as int).compareTo(b["period"] as int));
        sortedData[targetKey] = data;
      }
    }
    sortedDataByWeekDay = sortedData;
    return sortedData;
  }

  String returnStringClassTime(int thisYear, int semesterNum, int weekDay) {
    List<Map<String, dynamic>> weekDayData = sortedDataByWeekDay[weekDay] ?? [];
    String startTime = "";
    String endTime = "";
    String result = "";
    List<Map<String, dynamic>> thisSemesterData = [];
    for (int i = 0; i < weekDayData.length; i++) {
      Map<String, dynamic> target = weekDayData.elementAt(i);
      if (target["year"] == thisYear &&
          target["weekday"] != null &&
          target["period"] != null) {
        if (target["semester"] == currentQuaterID(semesterNum) ||
            target["semester"] == currentSemesterID(semesterNum) ||
            target["semester"] == "full_year") {
          //年度・学期が条件に沿うデータのみを抽出
          thisSemesterData.add(target);
          int targetWeekDay = target["weekday"];
          if (currentSemesterClasses.containsKey(targetWeekDay)) {
            currentSemesterClasses[targetWeekDay]!.add(target);
          } else {
            currentSemesterClasses[targetWeekDay] = [target];
          }
        }
      }
    }
    if (weekDayData.isNotEmpty && thisSemesterData.isNotEmpty) {
      startTime = DateFormat("HH:mm")
          .format(Class.periods[thisSemesterData.first["period"]].start);
      endTime = DateFormat("HH:mm")
          .format(Class.periods[thisSemesterData.last["period"]].end);
      result = "$startTime~$endTime";
    }
    return result;
  }

  void initUniversityScheduleByDay(int thisYear, int semesterNum) {
    universityScheduleByWeekDay = {};
    currentSemesterClasses = {};
    universityScheduleByWeekDay[1] =
        returnStringClassTime(thisYear, semesterNum, 1);
    universityScheduleByWeekDay[2] =
        returnStringClassTime(thisYear, semesterNum, 2);
    universityScheduleByWeekDay[3] =
        returnStringClassTime(thisYear, semesterNum, 3);
    universityScheduleByWeekDay[4] =
        returnStringClassTime(thisYear, semesterNum, 4);
    universityScheduleByWeekDay[5] =
        returnStringClassTime(thisYear, semesterNum, 5);
    universityScheduleByWeekDay[6] =
        returnStringClassTime(thisYear, semesterNum, 6);
  }

  List<Map<String, dynamic>> targetDateClasses(DateTime target) {
    List<Map<String, dynamic>> result = [];
    int year = datetime2schoolYear(target);
    String semester = "";
    String quarter = "";
    String fullYear = "";
    int weekDay = target.weekday;
    if (datetime2termList(target).isNotEmpty) {
      semester = datetime2termList(target)[0];
      quarter = datetime2termList(target)[1];
      fullYear = datetime2termList(target)[2];
    }

    for (var item in timeTableDataList) {
      if (item["year"] == year && item["weekday"] == weekDay) {
        if (item["semester"] == semester ||
            item["semester"] == quarter ||
            item["semester"] == fullYear) {
          result.add(item);
        }
      }
    }
    result.sort((a, b) => a['period'].compareTo(b['period']));
    return result;
  }

  String currentQuaterID(int semesterNum) {
    String result = "full_year";
    if (semesterNum == 1) {
      result = "spring_quarter";
    } else if (semesterNum == 2) {
      result = "summer_quarter";
    } else if (semesterNum == 3) {
      result = "fall_quarter";
    } else if (semesterNum == 4) {
      result = "winter_quarter";
    } else if (semesterNum == 5) {
      result = "holiday";
    }
    return result;
  }

  String currentSemesterID(int semesterNum) {
    String result = "full_year";
    if (semesterNum == 1 || semesterNum == 2) {
      result = "spring_semester";
    } else if (semesterNum == 3 || semesterNum == 4) {
      result = "fall_semester";
    } else if (semesterNum == 5) {
      result = "holiday";
    }
    return result;
  }

  void clearContents() {
    timeTableDataList.clear();
  }
}
