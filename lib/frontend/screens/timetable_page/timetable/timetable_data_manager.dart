import 'package:flutter/services.dart';
import 'package:flutter_calandar_app/backend/DB/handler/my_course_db.dart';

import "../../../../static/constant.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final timeTableProvider =
    StateNotifierProvider<TimeTableNotifier, TimeTableData>(
  (ref) => TimeTableNotifier(),
);

class TimeTableNotifier extends StateNotifier<TimeTableData> {
  TimeTableNotifier() : super(TimeTableData(timeTableDataList: []));

  void addNewData(MyCourse newDataMap) {
    final newtimeTableDataList = [...state.timeTableDataList, newDataMap];
    state = state.copyWith(taskDataList: newtimeTableDataList);
  }
}

class TimeTableData {
  List<MyCourse> timeTableDataList = [];
  bool isInit = false;
  bool isRenewed = false;
  Map<int, List<MyCourse>> sortedDataByWeekDay = {};
  Map<int, List<MyCourse>> currentSemesterClasses = {};
  Map<int, String> universityScheduleByWeekDay = {};
  int maxPeriod = 6;

  TimeTableData({
    List<MyCourse> timeTableDataList = const [],
  }) : timeTableDataList = timeTableDataList;

  TimeTableData copyWith({
    List<MyCourse>? taskDataList,
    int? taskPageIndex,
  }) {
    return TimeTableData(
      timeTableDataList: timeTableDataList ?? timeTableDataList,
    );
  }

  Future<void> getData(Future<List<MyCourse>> data) async {
    timeTableDataList = await data;
  }

  void addNewData(MyCourse newDataMap) {
    timeTableDataList = [...timeTableDataList, newDataMap];
    isInit = false;
  }

  Map<int, List<MyCourse>> sortDataByWeekDay(List<MyCourse> TDList) {
    Map<int, List<MyCourse>> sortedData = {};
    maxPeriod = 6;
    for (int i = 0; i < TDList.length; i++) {
      int targetWeekDay = TDList[i].weekday?.index ?? 7;
      int period = TDList[i].period?.period ?? 0;
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
      List<MyCourse> data = sortedData.values.elementAt(i);
      int targetKey = sortedData.keys.elementAt(i);
      if (targetKey != 7) {
        data.sort((a, b) => (a.period!.period).compareTo(b.period!.period));
        sortedData[targetKey] = data;
      }
    }
    sortedDataByWeekDay = sortedData;
    return sortedData;
  }

  String returnStringClassTime(int thisYear, List<Term> terms, int weekDay) {
    List<MyCourse> weekDayData = sortedDataByWeekDay[weekDay] ?? [];
    String startTime = "";
    String endTime = "";
    String result = "";

    List<MyCourse> thisSemesterData = [];
    for (int i = 0; i < weekDayData.length; i++) {
      MyCourse target = weekDayData.elementAt(i);
      if (target.year == thisYear &&
          target.weekday != null &&
          target.period != null) {
        if (terms
            .map((e) => e.value)
            .toList()
            .contains(target.semester?.value)) {
          //年度・学期が条件に沿うデータのみを抽出
          thisSemesterData.add(target);
          int targetWeekDay = target.weekday!.index;
          if (currentSemesterClasses.containsKey(targetWeekDay)) {
            currentSemesterClasses[targetWeekDay]!.add(target);
          } else {
            currentSemesterClasses[targetWeekDay] = [target];
          }
        }
      }
    }
    if (weekDayData.isNotEmpty && thisSemesterData.isNotEmpty) {
      startTime = thisSemesterData.first.period != null
          ? DateFormat("HH:mm").format(thisSemesterData.first.period!.start)
          : "";

      endTime = thisSemesterData.last.period != null
          ? DateFormat("HH:mm").format(thisSemesterData.last.period!.end)
          : "";
      result = "$startTime~$endTime";
    }
    return result;
  }

  void initUniversityScheduleByDay(int thisYear, List<Term> terms) {
    universityScheduleByWeekDay = {};
    currentSemesterClasses = {};
    universityScheduleByWeekDay[1] = returnStringClassTime(thisYear, terms, 1);
    universityScheduleByWeekDay[2] = returnStringClassTime(thisYear, terms, 2);
    universityScheduleByWeekDay[3] = returnStringClassTime(thisYear, terms, 3);
    universityScheduleByWeekDay[4] = returnStringClassTime(thisYear, terms, 4);
    universityScheduleByWeekDay[5] = returnStringClassTime(thisYear, terms, 5);
    universityScheduleByWeekDay[6] = returnStringClassTime(thisYear, terms, 6);
  }

  List<MyCourse> targetDateClasses(DateTime target) {
    List<MyCourse> result = [];
    int year = Term.whenSchoolYear(target);

    int weekDay = target.weekday;

    for (var item in timeTableDataList) {
      if (item.year == year && item.weekday?.index == weekDay) {
        if (Term.whenTerms(target)
            .map((e) => e.value)
            .toList()
            .contains(item.semester?.value)) {
          result.add(item);
        }
      }
    }
    result.sort((a, b) => a.period!.period.compareTo(b.period!.period));
    return result;
  }

  List<MyCourse> targetSemesterClasses(Term targetTerm,int targetYear){
    List<MyCourse> result = [];
    List<String> courseNameList = [];
    for(int i = 0; i < timeTableDataList.length; i++){
      MyCourse targetCourse = timeTableDataList.elementAt(i);
      if(targetCourse.year == targetYear){
        if(targetCourse.semester == targetTerm){

          if(!courseNameList.contains(targetCourse.courseName)){
            courseNameList.add(targetCourse.courseName);
            result.add(targetCourse);
          }

        }else if(targetTerm == Term.springSemester){
          if(targetCourse.semester == Term.springQuarter ||
            targetCourse.semester == Term.summerQuarter){

            if(!courseNameList.contains(targetCourse.courseName)){
              courseNameList.add(targetCourse.courseName);
              result.add(targetCourse);
            }

          }
        }else if(targetTerm == Term.fallSemester){
          if(targetCourse.semester == Term.fallQuarter ||
            targetCourse.semester == Term.winterQuarter){

            if(!courseNameList.contains(targetCourse.courseName)){
              courseNameList.add(targetCourse.courseName);
              result.add(targetCourse);
            }

          }
        }
      }
    }
    return result;
  }

  int creditsTotalSum(List<MyCourse> courses){
    int result = 0;
    for(var item in courses){
      if(item.credit != null){
        result += item.credit!;
      }
    }
    return result;
  }

  Map<String?,List<MyCourse>> sortDataByClassification(List<MyCourse> courseList){
    Map<String?,List<MyCourse>> result = {};
    for(var course in courseList){
      if(result.containsKey(course.subjectClassification)){
        result[course.subjectClassification]!.add(course);
      }else{
        result[course.subjectClassification] = [course];
      }
    }
    return result;
  }

  Map<Term?,List<MyCourse>> sortDataByQuarter(List<MyCourse> courseList){
    Map<Term?,List<MyCourse>> result = {};
    for(var course in courseList){
      if(result.containsKey(course.semester)){
        result[course.semester]!.add(course);
      }else{
        result[course.semester] = [course];
      }
    }
    return result;
  }  

  void clearContents() {
    timeTableDataList.clear();
  }
}
