import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../backend/DB/handler/todo_db_handler.dart';
import 'dart:collection';


final dataProvider = StateNotifierProvider<DataNotifier, Data>(
  (ref) => DataNotifier(),
);

class DataNotifier extends StateNotifier<Data> {
  DataNotifier() : super(Data());
    void updateValues() {
    state = state.copyWith();
  }
}

class Data {
  var  dataList = [];
  var targetMonth;
  bool isRenewed = false;
  bool isInit = true;
  var  isTimerList = {};
  bool isVertical = true;
  var timerTargetMonthData = [];
  var templateDataList = {};

  // コピーを作成するメソッド
  Data copyWith({
    List<Map<String, dynamic>>? dataList,
    String? targetMonth,
  }) {
    return Data()
      ..dataList = dataList ?? this.dataList
      ..targetMonth = targetMonth ?? this.targetMonth;
  }

  void getData(List<Map<String, dynamic>> snapshot){
    dataList = [];
    var target = snapshot;
    dataList.addAll(target);
  }

  Future<void> getTemplateData()async{
    templateDataList = {};
    List<Map<String, Object?>> fetchedData = await TemplateDataBaseHelper().getAllDataFromMyTable();
      for(int i = 0; i < fetchedData.length; i++){
        templateDataList[int.parse(fetchedData.elementAt(i)["template_index"].toString())] = fetchedData.elementAt(i)["template"];
      }
    
  }

  Map<String,List<Map<String,dynamic>>> sortDataByMonth(){
  Map<String,List<Map<String,dynamic>>> monthList = {};
    for(int i = 0; i < dataList.length; i++){
       String targetMonth = dataList.elementAt(i)["date"].substring(0, 7);
       Map<String,dynamic> targetValue = dataList.elementAt(i);
       String targetDate = targetValue["date"];

      if(monthList.keys.contains(targetMonth)){
       monthList[targetMonth]!.add(targetValue);
      }else{
       monthList[targetMonth] = [targetValue];
      }
    }

    var sortedData = SplayTreeMap<String, dynamic>.from(monthList);

    Map<String,List<Map<String,dynamic>>> convertedData = {};
    sortedData.forEach((key, value) {
      convertedData[key] = value;
    });

    Map<String,List<Map<String,dynamic>>> reversedMapData = {};
    int repeatNum = convertedData.length;
    for(int i = 0; i < repeatNum; i++){
      reversedMapData[convertedData.keys.last] = convertedData.values.last;
      convertedData.remove(convertedData.keys.last);
    }
    return reversedMapData;
  }

void generateIsTimerList(List<Map<String,dynamic>> targetMonthData){
  isTimerList = {};
  for(int i = 0; i < targetMonthData.length; i++){
   if(targetMonthData.elementAt(i)["timeStamp"].length.isOdd){
    isTimerList[targetMonthData.elementAt(i)["date"]] = false;
   }else{
    isTimerList[targetMonthData.elementAt(i)["date"]] = true;
   }
    
  }
}

  void clearContents() {
    dataList.clear();
  }
}