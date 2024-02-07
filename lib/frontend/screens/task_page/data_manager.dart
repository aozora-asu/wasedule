import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

final taskDataProvider = StateNotifierProvider<TaskDataNotifier, TaskData>(
  (ref) => TaskDataNotifier(),
);

final taskPageIndexProvider = StateProvider<int>((ref) => ref.watch(taskDataProvider).taskPageIndex);
final deleteButtonIndexProvider = StateProvider<bool>((ref) => ref.watch(taskDataProvider).isButton);

class TaskDataNotifier extends StateNotifier<TaskData> {
  TaskDataNotifier() : super(TaskData(taskDataList: [], taskPageIndex: 0));

  void setTaskPageIndex(int newIndex) {
    state = state.copyWith(taskPageIndex: newIndex);
  }

  void addNewData(Map<String, dynamic> newDataMap) {
    final newTaskDataList = [...state.taskDataList, newDataMap];
    state = state.copyWith(taskDataList: newTaskDataList);
  }
}

class TaskData {
  List<Map<String, dynamic>> taskDataList = [];
  List<Map<String, dynamic>> deletedTaskDataList = [];
  bool isInit = false;
  bool isRenewed = false;
  bool isButton = false;
  int taskPageIndex = 0;
  int foldState = 0;
  var chosenTaskIdList = [];

  TaskData({
    List<Map<String, dynamic>> taskDataList = const [],
    int taskPageIndex = 0,
  })  : taskDataList = taskDataList,
        taskPageIndex = taskPageIndex;
        

  TaskData copyWith({
    List<Map<String, dynamic>>? taskDataList,
    int? taskPageIndex,
  }) {
    return TaskData(
      taskDataList: taskDataList ?? this.taskDataList,
      taskPageIndex: taskPageIndex ?? this.taskPageIndex,
    );
  }

  void getData(List<Map<String, dynamic>> data) {
    taskDataList = data;
    print(taskDataList);
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
   return titles;
  }

  void addNewData(Map<String, dynamic> newDataMap) {
    taskDataList = [...taskDataList, newDataMap];
    isInit =false;
  }

  Map<DateTime, List<Map<String, dynamic>>> sortDataByDtEnd(TDList) {
    Map<DateTime, List<Map<String, dynamic>>> sortedData = {};
    deletedTaskDataList = [];
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
      }else{
        deletedTaskDataList.add(TDList.elementAt(i));
      }
    }
   return sortedData;
  }

  Map<String, List<Map<String, dynamic>>> sortDataByCategory(TDList) {
    Map<String, List<Map<String, dynamic>>> sortedData = {};
    for (int i = 0; i < TDList.length; i++) {
      String targetCategory = TDList[i]["title"];
      if (TDList.elementAt(i)["isDone"] == 0) {
        if (sortedData.containsKey(targetCategory)) {
          sortedData[targetCategory]!.add(TDList.elementAt(i));
        } else {
          sortedData[targetCategory] = [TDList.elementAt(i)];
        }
      }
    }
   return sortedData;
  }


  void manageIsButton(){
    if(chosenTaskIdList.isNotEmpty){
       isButton = true;
    }else{
       isButton = false;
    }
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