import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

final taskDataProvider = StateNotifierProvider<TaskDataNotifier, TaskData>(
  (ref) => TaskDataNotifier(),
);

class TaskDataNotifier extends StateNotifier<TaskData> {
  TaskDataNotifier() : super(TaskData(taskDataList: []));

  void addNewData(Map<String, dynamic> newDataMap) {
    final newTaskDataList = [...state.taskDataList, newDataMap];
    state = state.copyWith(taskDataList: newTaskDataList);
  }
}


class TaskData {
  List<Map<String, dynamic>> taskDataList = [];
  late bool isInit = false;
  late bool isRenewed = false;

  TaskData({
    List<Map<String, dynamic>> taskDataList = const [],
  }) : taskDataList = taskDataList;

  TaskData copyWith({
    List<Map<String, dynamic>>? taskDataList,
  }) {
    return TaskData(
      taskDataList: taskDataList ?? this.taskDataList,
    );
  }

  void getData(List<Map<String, dynamic>> data) {
    taskDataList = data;
    print("GETDATA RAN");
  }

  List<String> extractTitles(List<Map<String, dynamic>> TDList){
    List<String> titles = ["その他"];
    for (int i = 0; i < TDList.length; i++) {
      String targetData = TDList.elementAt(i)["title"];
      if (TDList.elementAt(i)["isDone"] == 0) {
        if (titles.contains(targetData) == false) {
          titles.add(TDList.elementAt(i)["title"]);
        }
      }
    }
   print(titles);
   return titles;
  }

  void addNewData(Map<String, dynamic> newDataMap) {
    taskDataList = [...taskDataList, newDataMap];
    isInit =false;
  }

  Map<DateTime, List<Map<String, dynamic>>> sortDataByDtEnd(TDList) {
    Map<DateTime, List<Map<String, dynamic>>> sortedData = {};
    for (int i = 0; i < TDList.length; i++) {
      DateTime targetDate = DateTime(
        DateTime.fromMillisecondsSinceEpoch(TDList[i]["dtEnd"]).year,
        DateTime.fromMillisecondsSinceEpoch(TDList[i]["dtEnd"]).month,
        DateTime.fromMillisecondsSinceEpoch(TDList[i]["dtEnd"]).day,
      );
      if (TDList.elementAt(i)["isDone"] == 0) {
        if (sortedData.containsKey(targetDate)) {
          sortedData[targetDate]!.add(TDList.elementAt(i));
        } else {
          sortedData[targetDate] = [TDList.elementAt(i)];
        }
      }
    }
   return sortedData;
  }

  // TaskData copyWith({
  //   List<Map<String, dynamic>>? taskDataList,
  // }) {
  //   return TaskData()
  //     ..taskDataList = taskDataList ?? this.taskDataList;
  // }

  void clearContents() {
    taskDataList.clear();
  }
}