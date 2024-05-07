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

  void getData(List<Map<String, dynamic>> data) {
    timeTableDataList = data;
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
    sortedDataByWeekDay = sortedData;
   return sortedData;
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