import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/frontend/screens/common/app_bar.dart';
import 'package:flutter_calandar_app/frontend/screens/to_do_page/todo_daily_view_page/timer_view.dart';
import 'package:flutter_calandar_app/frontend/screens/to_do_page/todo_assist_files/data_receiver.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fl_chart/fl_chart.dart';
import 'dart:async';

import 'package:intl/intl.dart';
import 'package:expandable/expandable.dart';

class StatsPage extends ConsumerStatefulWidget {
  @override
   _StatsPageState createState() =>  _StatsPageState();
}

class  _StatsPageState extends ConsumerState<StatsPage> {
  @override
  Widget build(BuildContext context) {
    final data = ref.read(dataProvider);
    return Scaffold(
      appBar:const  CustomAppBar(),
      body:StatsPageBody(),
      floatingActionButton: backButton(),
    );
  }
  Widget backButton(){
    return FloatingActionButton.extended(
      backgroundColor:MAIN_COLOR,
      onPressed: (){Navigator.pop(context);},
      label:const Text("戻る",style:TextStyle(color:Colors.white)),
      );
  }
}


class StatsPageBody extends ConsumerStatefulWidget {
  @override
   _StatsPageBodyState createState() =>  _StatsPageBodyState();
}

class  _StatsPageBodyState extends ConsumerState<StatsPageBody> {
  Map<String,Duration> timeSumByMonth = {};
  Map<String,Duration> timeAverageByMonth = {};
  Map<String,Duration> timeOfAllDays = {};
  Duration totalTimeSum = Duration.zero;
  Duration totalTimeAverage = Duration.zero;
  int totalDayWithRecord = 0;
  int totalDay = 0;
  num totalPlanSum = 0;
  num totalDoneSum = 0;
  Map<String,Duration> topThreeMonthes = {};
  Map<String,Duration> topThreeMonthesAvg = {};
  Map<String,Duration> topThreeDays = {};

  @override
  Widget build(BuildContext context){
    SizeConfig().init(context);
    final data = ref.read(dataProvider);
    Map<String, List<Map<String, dynamic>>> sortedData = data.sortDataByMonth();
    String thisMonth = DateTime.now().year.toString() + "/" + DateTime.now().month.toString().padLeft(2, '0');

    generateTimesumByMonth();
    generateTimeaverageByMonth();
    generateTotalTimesum();
    calculateTotalAverage();
    countTotalDaysWithRecord();
    numOfTotalPlanSum();
    numOfTotalDoneSum();
    topThreeMonthes = findTopThree(timeSumByMonth);
    topThreeMonthesAvg = findTopThree(timeAverageByMonth);
    generateTimeOfAllDays();
    topThreeDays = findTopTen(timeOfAllDays);
    

    return Container(
      child:
      Column(children:[
        //TimerView(targetMonthData:data.sortDataByMonth()[thisMonth]),
        
        SizedBox(
         height:SizeConfig.blockSizeVertical! *calculateHeight(),
         child:Column(children:[
          ExpandablePanel(
            header: const Padding(
              padding: EdgeInsets.only(top:6),
              child:Text("  全体の統計",style:TextStyle(fontSize: 20,fontWeight:FontWeight.bold))
              ),
            collapsed:const SizedBox(height:1,child:Divider(height:1)), 
            expanded: generalStats(),
            controller: ExpandableController(initialExpanded: true),
          ),
          Expanded(
            child:ListView.separated(
            itemBuilder: (context,index){
            List<Map<String, dynamic>> targetMonthData = sortedData.values.elementAt(index);
              return Card(child:
              ExpandablePanel(
                header: Text(" " + sortedData.keys.elementAt(index),style:TextStyle(fontSize: 25,fontWeight:FontWeight.bold)),
                collapsed: summary(targetMonthData),
                expanded:  stats(targetMonthData),
              ),
            );
            },
            separatorBuilder:(contaxt,index){
              return const SizedBox(height:8);
            },
            itemCount: sortedData.length,
            shrinkWrap: true,
            ))
          ])
          
          )

      ])
      
    );
  }

  double calculateHeight(){
   final data = ref.watch(dataProvider);
   if(data.isTimerList.containsValue(true)){
    return 89 - 40;
   }else{
    return 89;
   }
  }


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  Widget generalStats(){
  return SizedBox(height:SizeConfig.blockSizeVertical! *43,
   child:Column(children:[
    SizedBox(
     height:SizeConfig.blockSizeVertical! *42,
     child:
     
     SingleChildScrollView(child:
     Scrollbar(child: 

        Column(
          crossAxisAlignment:CrossAxisAlignment.start,
          children:[
          Row(children:[
            Column(

              crossAxisAlignment: CrossAxisAlignment.start,
              children:[     
              Row(children:[
                const Text("  総合計：",style:TextStyle(color:Colors.grey)),
                Text(totalTimeSum.inHours.toString() +"時間"+ (totalTimeSum.inMinutes%60).toString()+"分"),
              ]),
              Row(children:[
                const Text("  月平均：",style:TextStyle(color:Colors.grey)),
                Text(totalTimeAverage.inHours.toString() +"時間"+ (totalTimeAverage.inMinutes%60).toString()+"分"),
              ]),              
              Row(children:[
                const Text("  記録日数：",style:TextStyle(color:Colors.grey)),
                Text(totalDayWithRecord.toString() +"日/"+ totalDay.toString()+"日"),
              ]),
            ]),
 
             Column(

              crossAxisAlignment: CrossAxisAlignment.start,
              children:[           
                Row(children:[
                  const Text("  「計画」の総数：",style:TextStyle(color:Colors.grey)),
                  Text(totalPlanSum.toString() + "個"),
                ]),
                Row(children:[
                  const Text("  「完了」の総数：",style:TextStyle(color:Colors.grey)),
                  Text(totalDoneSum.toString() + "個 "),
                ]),
                const Row(children:[
                  Text("  ",style:TextStyle(color:Colors.grey)),
                  Text(""),
                ]),
            ])
          ]),
          const Divider(height:8,indent:10,endIndent:10),
          Container(
          height:SizeConfig.blockSizeVertical! *43,
          child:GeneralLineChartView(monthlyTimeSum: timeSumByMonth)
          ),
          const Divider(height:8,indent:10,endIndent:10),
          const Padding(
            padding: EdgeInsets.only(top:6),
            child:Text("  ランキング",style:TextStyle(fontSize: 20,color:Colors.black))
          ),
          Column(children:[
           
          monthlyLanking(),

          const Padding(
            padding: EdgeInsets.only(top:6,bottom:4),
            child:Text("  勉強時間(日)",style:TextStyle(fontSize: 17,color:Colors.grey))
          ),
          Row(children:[
            const Text("  １位：",style:TextStyle(color:Colors.grey)),
            Text(topThreeDays.keys.elementAt(0) +
                 "    "+ 
                 topThreeDays.values.elementAt(0).inHours.toString() +
                 "時間"+
                 (topThreeDays.values.elementAt(0).inMinutes%60).toString() +
                 "分"
                 ),
          ]),
          Row(children:[
            const Text("  ２位：",style:TextStyle(color:Colors.grey)),
            Text(topThreeDays.keys.elementAt(1) +
                 "    "+ 
                 topThreeDays.values.elementAt(1).inHours.toString() +
                 "時間"+
                 (topThreeDays.values.elementAt(1).inMinutes%60).toString() +
                 "分"
                 ),
          ]),
          Row(children:[
            const Text("  ３位：",style:TextStyle(color:Colors.grey)),
            Text(topThreeDays.keys.elementAt(2) +
                 "    "+ 
                 topThreeDays.values.elementAt(2).inHours.toString() +
                 "時間"+
                 (topThreeDays.values.elementAt(2).inMinutes%60).toString() +
                 "分"
                 ),
          ]),
          Row(children:[
            const Text("  ４位：",style:TextStyle(color:Colors.grey)),
            Text(topThreeDays.keys.elementAt(3) +
                 "    "+ 
                 topThreeDays.values.elementAt(3).inHours.toString() +
                 "時間"+
                 (topThreeDays.values.elementAt(3).inMinutes%60).toString() +
                 "分"
                 ),
          ]),
          Row(children:[
            const Text("  ５位：",style:TextStyle(color:Colors.grey)),
            Text(topThreeDays.keys.elementAt(4) +
                 "    "+ 
                 topThreeDays.values.elementAt(4).inHours.toString() +
                 "時間"+
                 (topThreeDays.values.elementAt(4).inMinutes%60).toString() +
                 "分"
                 ),
          ]),
          Row(children:[
            const Text("  ６位：",style:TextStyle(color:Colors.grey)),
            Text(topThreeDays.keys.elementAt(5) +
                 "    "+ 
                 topThreeDays.values.elementAt(5).inHours.toString() +
                 "時間"+
                 (topThreeDays.values.elementAt(5).inMinutes%60).toString() +
                 "分"
                 ),
          ]),
          Row(children:[
            const Text("  ７位：",style:TextStyle(color:Colors.grey)),
            Text(topThreeDays.keys.elementAt(6) +
                 "    "+ 
                 topThreeDays.values.elementAt(6).inHours.toString() +
                 "時間"+
                 (topThreeDays.values.elementAt(6).inMinutes%60).toString() +
                 "分"
                 ),
          ]),
          Row(children:[
            const Text("  ８位：",style:TextStyle(color:Colors.grey)),
            Text(topThreeDays.keys.elementAt(7) +
                 "    "+ 
                 topThreeDays.values.elementAt(7).inHours.toString() +
                 "時間"+
                 (topThreeDays.values.elementAt(7).inMinutes%60).toString() +
                 "分"
                 ),
          ]),
          Row(children:[
            const Text("  ９位：",style:TextStyle(color:Colors.grey)),
            Text(topThreeDays.keys.elementAt(8) +
                 "    "+ 
                 topThreeDays.values.elementAt(8).inHours.toString() +
                 "時間"+
                 (topThreeDays.values.elementAt(8).inMinutes%60).toString() +
                 "分"
                 ),
          ]),
          Row(children:[
            const Text(" 10位：",style:TextStyle(color:Colors.grey)),
            Text(topThreeDays.keys.elementAt(9) +
                 "    "+ 
                 topThreeDays.values.elementAt(9).inHours.toString() +
                 "時間"+
                 (topThreeDays.values.elementAt(9).inMinutes%60).toString() +
                 "分"
                 ),
          ]),

          const SizedBox(height:20)

      ])
    ]))
        
      ),
    ),
    const Divider(height:1),
    ])
   );
  }

Widget monthlyLanking(){
  if(topThreeMonthes.length < 3){
   return const SizedBox();
  }else{
   return Column(children:[
    const Padding(
      padding: EdgeInsets.only(top:6,bottom:4),
      child:Text("  総勉強時間(月)",style:TextStyle(fontSize: 17,color:Colors.grey))
    ),
    Row(children:[
      const Text("  １位：",style:TextStyle(color:Colors.grey)),
      Text(topThreeMonthes.keys.elementAt(0) +
            "    "+ 
            topThreeMonthes.values.elementAt(0).inHours.toString() +
            "時間"+
            (topThreeMonthes.values.elementAt(0).inMinutes%60).toString() +
            "分    (平均"+
            topThreeMonthesAvg.values.elementAt(0).inHours.toString() +
            "時間"+
            (topThreeMonthesAvg.values.elementAt(0).inMinutes%60).toString() +
            "分/日)"
            ),
    ]),
    Row(children:[
      Text("  ２位：",style:TextStyle(color:Colors.grey)),
      Text(topThreeMonthes.keys.elementAt(1)+
            "    "+ 
            topThreeMonthes.values.elementAt(1).inHours.toString() +
            "時間"+
            (topThreeMonthes.values.elementAt(1).inMinutes%60).toString()+
            "分    (平均"+
            topThreeMonthesAvg.values.elementAt(1).inHours.toString()+
            "時間"+
            (topThreeMonthesAvg.values.elementAt(1).inMinutes%60).toString() +
            "分/日)"
            ),
    ]),
    Row(children:[
      Text("  ３位：",style:TextStyle(color:Colors.grey)),
      Text(topThreeMonthes.keys.elementAt(2) +
            "    "+ 
            topThreeMonthes.values.elementAt(2).inHours.toString()+
            "時間"+
            (topThreeMonthes.values.elementAt(2).inMinutes%60).toString()+
            "分    (平均"+
            topThreeMonthesAvg.values.elementAt(2).inHours.toString() +
            "時間"+
            (topThreeMonthesAvg.values.elementAt(2).inMinutes%60).toString()+
            "分/日)"
            ),
     ]),
   ]);
  }
}


  void generateTimesumByMonth(){
    final data = ref.watch(dataProvider);
    for(int i = 0; i < data.sortDataByMonth().length; i++){
    List<Map<String, dynamic>> targetMonthData = data.sortDataByMonth().values.elementAt(i);
      Duration timeSum =const  Duration(hours: 0,minutes: 0);
      for (int index = 0; index < targetMonthData.length; index++){
        Duration newDuration = targetMonthData.elementAt(index)["time"]!;
        timeSum += newDuration;
      }
      timeSumByMonth[targetMonthData.elementAt(0)["date"].substring(0,7)] = timeSum;
    }
  }

  void generateTimeOfAllDays(){
    final data = ref.watch(dataProvider);
    for(int i = 0; i < data.sortDataByMonth().length; i++){
    List<Map<String, dynamic>> targetMonthData = data.sortDataByMonth().values.elementAt(i);
      for (int index = 0; index < targetMonthData.length; index++){
        Duration targDuration = targetMonthData.elementAt(index)["time"]!;
        timeOfAllDays[targetMonthData.elementAt(index)["date"]] = targDuration;
      }
    }
  }

  void generateTimeaverageByMonth(){
    final data = ref.watch(dataProvider);
    for(int i = 0; i < data.sortDataByMonth().length; i++){
    List<Map<String, dynamic>> targetMonthData = data.sortDataByMonth().values.elementAt(i);
      Duration timeSum = const Duration(hours: 0,minutes: 0);
      for (int index = 0; index < targetMonthData.length; index++){
        Duration newDuration = targetMonthData.elementAt(index)["time"]!;
        timeSum += newDuration;
      }
      timeAverageByMonth[targetMonthData.elementAt(0)["date"].substring(0,7)] = timeSum ~/ targetMonthData.length;
    }
  }

  void generateTotalTimesum(){
    totalTimeSum = Duration.zero;
    final data = ref.watch(dataProvider);
    for(int i = 0; i < data.sortDataByMonth().length; i++){
    List<Map<String, dynamic>> targetMonthData = data.sortDataByMonth().values.elementAt(i);
      Duration timeSum = const Duration(hours: 0,minutes: 0);
      for (int index = 0; index < targetMonthData.length; index++){
        Duration newDuration = targetMonthData.elementAt(index)["time"]!;
        timeSum += newDuration;
      }
      totalTimeSum += timeSum;
    }
  }

  void calculateTotalAverage(){
    totalTimeAverage = Duration.zero;
    final data = ref.watch(dataProvider);
    for(int i = 0; i < data.sortDataByMonth().length; i++){
      List<Map<String, dynamic>> targetMonthData = data.sortDataByMonth().values.elementAt(i);
      Duration timeSum =const  Duration(hours: 0,minutes: 0);
      Duration sum = Duration.zero;
        for(int i = 0; i < targetMonthData.length; i++){
          sum += targetMonthData.elementAt(i)["time"];
        }
      Duration average = sum ~/ targetMonthData.length;
      totalTimeAverage += average;
    }

    totalTimeAverage ~/ data.sortDataByMonth().keys.length;
  }

  void countTotalDaysWithRecord(){
  totalDayWithRecord = 0;
  totalDay = 0;
  final data = ref.watch(dataProvider);
  for(int i = 0; i < data.sortDataByMonth().length; i++){
    List<Map<String, dynamic>> targetMonthData = data.sortDataByMonth().values.elementAt(i);
    int count = 0;
     for(int i = 0; i < targetMonthData.length; i++){
      totalDay += 1;
       if(targetMonthData.elementAt(i)["time"] != Duration.zero){
        count += 1;
        }
      }
      totalDayWithRecord += count;
    }
  }

  void numOfTotalPlanSum(){
    totalPlanSum = 0;
    final data = ref.watch(dataProvider);
    for(int i = 0; i < data.sortDataByMonth().length; i++){
      List<Map<String, dynamic>> targetMonthData = data.sortDataByMonth().values.elementAt(i);
      num numberOfPlans = 0;
      for(int i =0; i<targetMonthData.length; i++){
       numberOfPlans += targetMonthData.elementAt(i)["plan"].length - 1;
      }
      totalPlanSum += numberOfPlans;
    }
  }

  void numOfTotalDoneSum(){
   totalDoneSum = 0;
   final data = ref.watch(dataProvider);
   for(int i = 0; i < data.sortDataByMonth().length; i++){
      List<Map<String, dynamic>> targetMonthData = data.sortDataByMonth().values.elementAt(i);
      num numberOfDone = 0;
        for(int i =0; i<targetMonthData.length; i++){
            numberOfDone += targetMonthData.elementAt(i)["record"].length - 1;
        }
      totalDoneSum += numberOfDone;
   }
  }


  Map<String, Duration> findTopThree(Map<String, Duration> inputMap) {
    List<MapEntry<String, Duration>> sortedEntries = inputMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    Map<String, Duration> result = {};

    for (int i = 0; i < sortedEntries.length && i < 3; i++) {
      result[sortedEntries[i].key] = sortedEntries[i].value;
    }

    return result;
  }

  Map<String, Duration> findTopFive(Map<String, Duration> durations) {
    List<MapEntry<String, Duration>> sortedList = durations.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    List<MapEntry<String, Duration>> top5Entries =
        sortedList.length >= 5 ? sortedList.sublist(0, 5) : sortedList;

    Map<String, Duration> top5Durations = Map.fromEntries(top5Entries);

    return top5Durations;
  }


  Map<String, Duration> findTopTen(Map<String, Duration> durations) {
    List<MapEntry<String, Duration>> sortedList = durations.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    List<MapEntry<String, Duration>> top10Entries =
        sortedList.length >= 10 ? sortedList.sublist(0, 10) : sortedList;

    Map<String, Duration> top10Durations = Map.fromEntries(top10Entries);

    return top10Durations;
  }
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  Widget summary(List<Map<String, dynamic>> targetMonthData){
    return 
     Row(children:[
      const Text("  平均：",style:TextStyle(color:Colors.grey)),
      Text(calculateAverage(targetMonthData)),
      const Text("  合計：",style:TextStyle(color:Colors.grey)),
      Text(timeSum(targetMonthData))
     ]);
  }

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  Widget stats(List<Map<String, dynamic>> targetMonthData){

    return 
    Column(children:[

      Row(children:[

       Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:[
        Row(children:[
          const Text("  平均：",style:TextStyle(color:Colors.grey)),
          Text(calculateAverage(targetMonthData)),
        ]),
        Row(children:[
          const Text("  合計：",style:TextStyle(color:Colors.grey)),
          Text(timeSum(targetMonthData))
        ]),
        Row(children:[
          const Text("  日数：",style:TextStyle(color:Colors.grey)),
          Text(countDaysWithRecord(targetMonthData).toString() + "日/" + targetMonthData.length.toString() + "日")
        ]),
        ]),

      
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children:[
      Row(children:[
        const Text("  最長：",style:TextStyle(color:Colors.grey)),
        Text(maxTimeandDay(targetMonthData)),
      ]),
      const Row(children:[
        Text("",style:TextStyle(color:Colors.grey)),
        Text("")
      ]),
      const Row(children:[
        Text("",style:TextStyle(color:Colors.grey)),
        Text("")
      ]),
     ])
   ]),
   const Divider(height:8,indent:8,endIndent:8),
    Row(children:[
      const Text("  立てた計画の総数：",style:TextStyle(color:Colors.grey)),
      Text(numOfPlanSum(targetMonthData).toString() + "個"),
    ]),
    Row(children:[
      const Text("  こなしたタスクの総数：",style:TextStyle(color:Colors.grey)),
      Text(numOfDoneSum(targetMonthData).toString() + "個 " + donePercentage(targetMonthData)),
    ]),
   LineChartView(targetMonthData:targetMonthData)
  ]);
  }


  String calculateAverage(List<Map<String, dynamic>> targetMonthData){
    Duration sum = Duration.zero;
    for(int i = 0; i < targetMonthData.length; i++){
      sum += targetMonthData.elementAt(i)["time"];
    }
    Duration average = sum ~/ targetMonthData.length;
    String formattedAverage = '${average.inHours}時間${(average.inMinutes % 60).toString().padLeft(2, '0')}分';

    return formattedAverage;
  }

  String timeSum(List<Map<String, dynamic>> targetMonthData){
      Duration timeSum =const  Duration(hours: 0,minutes: 0);
      for (int index = 0; index < targetMonthData.length; index++){
        Duration newDuration = targetMonthData.elementAt(index)["time"]!;
        timeSum += newDuration;
      }
    return 
    timeSum.inHours.toString() +
    "時間" +
    (timeSum.inMinutes % 60).toString() +
    "分";
  }


  int countDaysWithRecord(List<Map<String, dynamic>> targetMonthData){
    int count = 0;
     for(int i = 0; i < targetMonthData.length; i++){
       if(targetMonthData.elementAt(i)["time"] != Duration.zero){
        count += 1;
       }
     }
    return count;
  }
  
    List<int> generateTimeList(List<Map<String, dynamic>> targetMonthData){
    List<int> timeList = [];
    for(int i = 0; i < targetMonthData.length; i++){
      timeList.add(targetMonthData.elementAt(i)["time"].inMinutes);
    }
    return timeList;
  }

  String maxTimeandDay(List<Map<String, dynamic>> targetMonthData){
    List<int> timeList = generateTimeList(targetMonthData);
    List<int> sonomama = generateTimeList(targetMonthData);
    int maxNumber = timeList.reduce((value, element) => value > element ? value : element);
    int maxDate = sonomama.indexOf(maxNumber);
    Duration maxTime = Duration(minutes:maxNumber);
    String adjustedMaximumTime = maxTime.inHours.toString()+ "時間" + (maxTime.inMinutes % 60).toString() + "分";
    String adjustedMaximunDate = (maxDate+1).toString() + "日...";

    return adjustedMaximunDate + adjustedMaximumTime;
  }

  List<int> dateList(List<Map<String, dynamic>> targetMonthData){
    List<int> dateList = [];
    for(int i = 0; i < targetMonthData.length; i++){
      dateList.add(int.parse(targetMonthData.elementAt(i)["date"].substring(8,10)));
    }
    return dateList;
  }


  num numOfPlanSum(List<Map<String, dynamic>> targetMonthData){
    num numberOfPlans = 0;
   for(int i =0; i<targetMonthData.length; i++){
       numberOfPlans += targetMonthData.elementAt(i)["plan"].length - 1;
   }
   return numberOfPlans;
  }

  num numOfDoneSum(List<Map<String, dynamic>> targetMonthData){
    num numberOfDone = 0;
   for(int i =0; i<targetMonthData.length; i++){
       numberOfDone += targetMonthData.elementAt(i)["record"].length - 1;
   }
   return numberOfDone;
  }

  String donePercentage(List<Map<String, dynamic>> targetMonthData) {
    int donePercentage = 0;

    num numOfPlan = numOfPlanSum(targetMonthData);
    num numOfDone = numOfDoneSum(targetMonthData);

    if (numOfPlan != 0) {
      donePercentage = ((numOfDone / numOfPlan) * 100).round();
    }

    return "($donePercentage%)";
  }
}









class LineChartView extends StatefulWidget {
  late List<Map<String, dynamic>> targetMonthData;

  LineChartView({
  required this.targetMonthData,
  Key? key,
  }) : super(key: key);

  @override
  State<LineChartView> createState() => _LineChartViewState();
}

class _LineChartViewState extends State<LineChartView> {
  late FlTitlesData _titles;
  final TextStyle _labelStyle =
      const TextStyle(fontSize: 12, fontWeight: FontWeight.w800);
  final TextStyle _titleStyle =
      const TextStyle(fontSize: 18, fontWeight: FontWeight.w400,color:Colors.grey);

  void _initChartTitle() {
    _titles = FlTitlesData(
      topTitles: AxisTitles(
          axisNameWidget: Text(
            "月間勉強時間推移",
            style: _titleStyle,
          ),
          axisNameSize: 48),
      rightTitles:const  AxisTitles(
          sideTitles: SideTitles(
        showTitles: false,
      )),
      bottomTitles: AxisTitles(
        sideTitles: _bottomTitles(),
        axisNameWidget: Container(
          alignment: Alignment.centerRight,
          child: Text(
            "日",
            style: _labelStyle,
          ),
        ),
      ),
      leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) => Text(
              value.toInt().toString(),
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ),
          axisNameWidget: Text(
            "時間(分)",
            style: _labelStyle,
          ),
          axisNameSize: 32),
    );
  }

  SideTitles _bottomTitles() => SideTitles(
      showTitles: true,
      reservedSize: 24,
      interval: 1,
      getTitlesWidget: (month, meta) {
        const style = TextStyle(
          color: Colors.black,
          fontSize: 10,
        );
        String text;

        if (month.toInt() < 1 || month.toInt() > widget.targetMonthData.length || month.toInt() % 3 != 0 ) {
          text = "";
        } else {
          text = "${month.toInt()}";
        }

        return SideTitleWidget(
          axisSide: meta.axisSide,
          space: 12,
          child: Text(
            text,
            style: style,
          ),
        );
      });

  @override
  void initState() {
    super.initState();
    _initChartTitle();
  }

  @override
  Widget build(BuildContext context) {
    return
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.only(left: 8, right: 32),
              height: 320,
              width: double.infinity,
              child: LineChart(LineChartData(
                  backgroundColor: Colors.grey[200],
                  titlesData: _titles,
                  minY: 0,
                  maxY: maxTime() + 60,
                  //maxX: dateList().length.toDouble(),
                  lineBarsData: [
                    LineChartBarData(
                      color: Colors.greenAccent,
                      barWidth: 4,
                      dotData: const FlDotData(show: false),
                      spots: generateGraphData()
                    ),
                  ])),
            ),
          ]);
  }
  
  List<int> generateTimeList(){
    List<int> timeList = [];
    for(int i = 0; i < widget.targetMonthData.length; i++){
      timeList.add(widget.targetMonthData.elementAt(i)["time"].inMinutes);
    }
    return timeList;
  }

  double maxTime(){
    List<int> timeList = generateTimeList();
    int maxNumber = timeList.reduce((value, element) => value > element ? value : element);
    return maxNumber.toDouble();
  }

  List<int> dateList(){
    List<int> dateList = [];
    for(int i = 0; i < widget.targetMonthData.length; i++){
      dateList.add(int.parse(widget.targetMonthData.elementAt(i)["date"].substring(8,10)));
    }
    return dateList;
  }

  List<FlSpot> generateGraphData(){
    List<FlSpot> graphData = [];
    for(int i = 0; i < dateList().length; i++){
      graphData.add(FlSpot((i + 1).toDouble(),generateTimeList().elementAt(i).toDouble()));
    }
    return graphData;
  }
}


class GeneralLineChartView extends StatefulWidget {
  late Map<String, Duration> monthlyTimeSum;

  GeneralLineChartView({
  required this.monthlyTimeSum,
  Key? key,
  }) : super(key: key);

  @override
  State<GeneralLineChartView> createState() => _GeneralLineChartViewState();
}

class _GeneralLineChartViewState extends State<GeneralLineChartView> {
  late FlTitlesData _titles;
  final TextStyle _labelStyle =
      const TextStyle(fontSize: 12, fontWeight: FontWeight.w800);
  final TextStyle _titleStyle =
      const TextStyle(fontSize: 18, fontWeight: FontWeight.w400,color:Colors.grey);

  void _initChartTitle() {
    _titles = FlTitlesData(
      topTitles: AxisTitles(
          axisNameWidget: Text(
            "合計勉強時間推移",
            style: _titleStyle,
          ),
          axisNameSize: 50),
      rightTitles:const  AxisTitles(
          sideTitles: SideTitles(
        showTitles: false,
      )),
      bottomTitles: AxisTitles(
        sideTitles: _bottomTitles(),
        axisNameWidget: Container(
          alignment: Alignment.centerRight,
          child: Text(
            "年/月",
            style: _labelStyle,
          ),
        ),
      ),
      leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) => Text(
              value.toInt().toString(),
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ),
          axisNameWidget: Text(
            "勉強時間合計(時間)",
            style: _labelStyle,
          ),
          axisNameSize: 32),
    );
  }

  SideTitles _bottomTitles() => SideTitles(
      showTitles: true,
      reservedSize: 24,
      interval: 60 * 60 * 24 * 1000 *60,
      getTitlesWidget: (month, meta) {
        const style = TextStyle(
          color: Colors.black,
          fontSize: 10,
        );
        String text;

        if(month <= minMonth() || maxMonth() <= month){
          text = "";
        }else{
          text = formatEpochSeconds(month.toInt());
        }

        return SideTitleWidget(
          axisSide: meta.axisSide,
          angle:45,
          space: 10,
          child: Text(
            text,
            style: style,
          ),
        );
      });

  @override
  void initState() {
    super.initState();
    _initChartTitle();
  }

  @override
  Widget build(BuildContext context) {
    return
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.only(left: 8, right: 32),
              height: 300,
              width: double.infinity,
              child: LineChart(LineChartData(
                  backgroundColor: Colors.grey[200],
                  titlesData: _titles,
                  minY: 0,
                  maxY: maxTime() + 10,
                  //minX: 0,
                  //maxX: dateList().length.toDouble(),
                  lineBarsData: [
                    LineChartBarData(
                      color: Colors.greenAccent,
                      barWidth: 4,
                      dotData:const  FlDotData(show: true),
                      spots: generateGraphData()
                    ),
                  ])),
            ),
          ]);
  }
  
  List<int> generateTimeList(){
    List<int> timeList = [];
    for(int i = 0; i < widget.monthlyTimeSum.length; i++){
      timeList.add(widget.monthlyTimeSum.values.elementAt(i).inHours);
    }
    return timeList;
  }

  double maxTime(){
    List<int> timeList = generateTimeList();
    int maxNumber = timeList.reduce((value, element) => value > element ? value : element);
    return maxNumber.toDouble();
  }


  double minMonth(){
    List<double> dateLista = dateList();
    double minNumber = dateLista .reduce((min, current) => min < current ? min : current);
    return minNumber;
  }


  double maxMonth() {
    List<double> values = dateList();
    if (values.isEmpty) {
      // リストが空の場合は何もないのでエラーを返すか、適切な処理を行ってください。
      throw ArgumentError('リストが空です');
    }

    double maxValue = values[0];

    for (int i = 1; i < values.length; i++) {
      if (values[i] > maxValue) {
        maxValue = values[i];
      }
    }

    return maxValue;
  }


  List<double> dateList(){
    List<double> monthList = [];
    for(int i = 0; i < widget.monthlyTimeSum.length; i++){
      String targMonth = widget.monthlyTimeSum.keys.elementAt(i);
      double targYear = double.parse(targMonth.substring(2,4));
      double fixedMonth = double.parse(targMonth.substring(5,7)) / 100;
      double result = targYear + (fixedMonth);

      DateTime date = DateTime(int.parse(targMonth.substring(0,4)),int.parse(targMonth.substring(5,7)));
      double dtDesu = date.millisecondsSinceEpoch.toDouble();
      monthList.add(dtDesu);
    }
    return monthList;
  }

  List<FlSpot> generateGraphData(){
    List<FlSpot> graphData = [];
    for(int i = 0; i < dateList().length; i++){
      graphData.add(FlSpot(dateList().elementAt(i),generateTimeList().elementAt(i).toDouble()));
    }
    return graphData;
  }

String formatEpochSeconds(int epochSeconds) {
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(epochSeconds);
  String formattedDate = DateFormat('yyyy/MM').format(dateTime);
  return formattedDate;
}


}