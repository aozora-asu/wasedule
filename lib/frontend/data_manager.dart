import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

final taskDataProvider = StateNotifierProvider<TaskDataNotifier, TaskData>(
  (ref) => TaskDataNotifier(),
);

class TaskDataNotifier extends StateNotifier<TaskData> {
  TaskDataNotifier() : super(TaskData());

  // void updateTaskData() {
  //   state = state.copyWith();
  // }

}

class TaskData {
  late List<Map<String,dynamic>> taskDataList = [];
 
 void getData(List<Map<String,dynamic>> data){
  taskDataList = data;
 }

 Map<DateTime,List<Map<String,dynamic>>>sortDataByDtEnd(taskDataList){
  Map<DateTime,List<Map<String,dynamic>>> sortedData = {};
  for(int i = 0; i < taskDataList.length; i++){
   DateTime targetDate = DateTime(
     DateTime.fromMillisecondsSinceEpoch(taskDataList[i]["dtEnd"]).year,
     DateTime.fromMillisecondsSinceEpoch(taskDataList[i]["dtEnd"]).month,
     DateTime.fromMillisecondsSinceEpoch(taskDataList[i]["dtEnd"]).day);
  
  if(taskDataList.elementAt(i)["isDone"] == 0){
   if(sortedData.containsKey(targetDate)){
     sortedData[targetDate]!.add(taskDataList.elementAt(i));
     }else{
     sortedData[targetDate] = [taskDataList.elementAt(i)];
     }
  }
   }
 return sortedData;
 }
  // TaskData copyWith({
  //   String? titleController,
  //   String? descriptionController,
  //   String? summaryController,
  //   String? dtEndController,
  // }) {
  //   return TaskData()
  //     ..titleController.text = titleController ?? this.titleController.text
  //     ..descriptionController.text = descriptionController ?? this.descriptionController.text
  //     ..summaryController.text = summaryController ?? this.summaryController.text
  //     ..dtEndController.text = dtEndController ?? this.dtEndController.text;
  // }

    void clearContents() {
    taskDataList.clear();
  }

}