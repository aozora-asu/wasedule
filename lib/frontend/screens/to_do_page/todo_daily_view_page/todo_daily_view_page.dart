import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/handler/task_db_handler.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/add_event_dialog.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/calendar_data_manager.dart';
import 'package:flutter_calandar_app/backend/DB/handler/todo_db_handler.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/task_data_manager.dart';
import 'package:flutter_calandar_app/frontend/screens/to_do_page/stats_page/stats_page.dart';
import 'package:flutter_calandar_app/frontend/screens/to_do_page/todo_daily_view_page/time_input_page.dart';
import 'package:flutter_calandar_app/frontend/screens/to_do_page/todo_daily_view_page/timer_view.dart';
import 'package:flutter_calandar_app/frontend/screens/to_do_page/todo_assist_files/data_receiver.dart';
import 'package:flutter_calandar_app/frontend/screens/to_do_page/todo_assist_files/size_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import 'package:intl/intl.dart';


class DaylyViewPage extends ConsumerStatefulWidget {
  //Future<List<Map<String, dynamic>>>? events;
  //AsyncSnapshot<List<Map<String, dynamic>>> snapshot;
  BuildContext context;

  DaylyViewPage({super.key, 
    //this.events,
    //required this.snapshot,
    required this.context
  });

  @override
   _DaylyViewPageState createState() =>  _DaylyViewPageState();
}

class _DaylyViewPageState extends ConsumerState<DaylyViewPage> {
  late String targetMonth = "";
  String thisMonth = "${DateTime.now().year}/${DateTime.now().month.toString().padLeft(2, '0')}";
  String today = "${DateTime.now().year}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().day.toString().padLeft(2, '0')}";

  @override
  void initState() {
    super.initState();
    targetMonth = thisMonth;
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.read(dataProvider);
    return 
    Scaffold(
      body:pageHead(),
      floatingActionButton:showButtonOrNot(context,ref),
    );
  }
    Widget showButtonOrNot(context,ref){
    final data = ref.watch(dataProvider);
    if(data.dataList.isEmpty){
      return Container();
    }else{
      return Container(
        child:FloatingActionButton.extended(
          label: Text("統計",style: TextStyle(color:FORGROUND_COLOR),),
          backgroundColor: ACCENT_COLOR,
          icon:  Icon(Icons.insert_chart_outlined_rounded,color:FORGROUND_COLOR,size: 20,),
          onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StatsPage()),
            );
          },
        ),
      );
    }
  }

  
  Widget pageHead(){
    SizeConfig().init(context);
    final data = ref.read(dataProvider);
    
    return 
Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:[
        TimerView(
          targetMonthData: data.sortDataByMonth()[targetMonth],
          thisMonthData:data.sortDataByMonth()[thisMonth],
          //events:widget.events,
          context:widget.context,
          //snapshot: widget.snapshot,
        ),
        SizedBox(
          child: Row(
            children:[
              IconButton(
                onPressed:(){
                  decreasePgNumber();
                }, 
                icon:const  Icon(Icons.arrow_back_ios), 
                iconSize: 20
              ),
              Text(
                targetMonth,
                style: const TextStyle(fontSize:25,fontWeight:FontWeight.w700,),  
              ),
              IconButton(
                onPressed:(){
                  setState((){increasePgNumber();});
                }, 
                icon: const Icon(Icons.arrow_forward_ios), 
                iconSize: 20
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(timeSum(),style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold)),
                  Text(monthSum(),style: const TextStyle(fontSize: 10,color:Colors.grey)),
                ]
              ),
              const Spacer(),
              SizedBox(width:55,height:40,child: switchViewButton())
            ]
          ),
        ),
        const Divider(height:1),
        pageBody(),

      ]
    )
    ;    
  }

  Widget switchViewButton(){
   if(ref.watch(dataProvider).isVertical){
    return TextButton(
      onPressed:()=> setState((){ref.read(dataProvider).isVertical = false;}),
      child:const Text("畳む",style:TextStyle(color: Colors.grey,fontSize: 13),)
      );
   }else{
    return TextButton(
      onPressed:()=> setState((){ref.read(dataProvider).isVertical = true;}),
      child:const Text("展開",style:TextStyle(color: Colors.grey,fontSize: 13),)
      );
   }
  }

  String timeSum(){
      final data = ref.watch(dataProvider);
      if(data.sortDataByMonth()[targetMonth] == null){
      return "";
    }else{
      List<Map<String,dynamic>> targetMonthData = data.sortDataByMonth()[targetMonth]!;
      Duration timeSum = const Duration(hours: 0,minutes: 0);
      for (int index = 0; index < targetMonthData.length; index++){
        Duration newDuration = targetMonthData.elementAt(index)["time"]!;
        timeSum += newDuration;
      }
    return "計 ${timeSum.inHours}時間${timeSum.inMinutes % 60}分";
    }
  }

  String monthSum(){
      final data = ref.watch(dataProvider);
      if(data.sortDataByMonth()[targetMonth] == null){
      return "";
    }else{
      List<Map<String,dynamic>> targetMonthData = data.sortDataByMonth()[targetMonth]!;
      int monthLength = LengthOfMonth(targetMonth);
      Duration timeSum = const Duration(hours: 0,minutes: 0);

      for (int index = 0; index < monthLength; index++){
        Duration newDuration =const  Duration(days:1);
        timeSum += newDuration;
      }

      Duration timeSumForPersent = Duration.zero;
      for (int index = 0; index < targetMonthData.length; index++){
        Duration newDuration = targetMonthData.elementAt(index)["time"]!;
        timeSumForPersent += newDuration;
      }

    double persent = timeSumForPersent.inMinutes / timeSum.inMinutes *100;
    String fixedPersent = persent.round().toString();

      return "/${timeSum.inHours}時間(月全体の$fixedPersent%)";
    }
  }

  Widget pageBody(){
   final data = ref.read(dataProvider);

   if(ref.read(dataProvider).isRenewed && data.sortDataByMonth()[targetMonth] == null){
    return const Expanded(
      child: Center(
        child:CircularProgressIndicator(color: MAIN_COLOR,strokeWidth:7)
        )
      );
   }else if(data.sortDataByMonth()[targetMonth] == null){
     ref.read(dataProvider).isRenewed = false;
     return 
     Expanded(child:
      Center(child:
       Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children:[
        
        const Text("この月の学習記録はありません。",style:TextStyle(fontWeight:FontWeight.bold,fontSize:20)),
        ElevatedButton(
          onPressed:(){
            setState((){AddNewPage(targetMonth);});
            ref.read(dataProvider.notifier).state = Data();
            ref.read(dataProvider).isRenewed = true;
          },
          
          style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll(MAIN_COLOR)),
          child: Text("ページの作成",style: TextStyle(color:FORGROUND_COLOR),),
        ),
        ])
       )
      );
   }else{
     ref.read(dataProvider).isRenewed = false;
     List<Map<String,dynamic>> targetMonthData = data.sortDataByMonth()[targetMonth]!;
      return 
       Expanded(child:
        ListView.separated(
        separatorBuilder: (context, index) {
         return const  Divider(height: 1);
        },
        itemBuilder: (BuildContext context, index){
        Map<String,dynamic> targetDayData = targetMonthData.elementAt(index);
        TextEditingController scheduleController = TextEditingController(text:targetDayData["schedule"]);
        String formattedDuration = '${targetDayData["time"].inHours}h${(targetDayData["time"].inMinutes % 60).toString().padLeft(2, '0')}m';
        DateTime formattedDateData = DateTime(int.parse(targetDayData["date"].substring(0,4)),int.parse(targetDayData["date"].substring(5,7)),int.parse(targetDayData["date"].substring(8,10)));

        return Container(
          color: highLightTodayTile(targetDayData["date"],formattedDuration),
          width:SizeConfig.blockSizeHorizontal! *100,
          child:Column(children:[
           Row(
            children:[
            Column(
             
             children:<Widget>[
              Text(
              " " + targetDayData["date"].substring(5,10) + weekDay(formattedDateData.weekday),
              style: highLightToday(targetDayData["date"]),
            ),
            Column(children:[
             InkWell(
              child:Text(formattedDuration),
              onTap:(){
                Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TimeInputPage(targetDayData:targetDayData)),
               );
              },
             ),
             InkWell(
              onTap:()async{
                if(data.isTimerList[targetDayData["date"]] == false){
                List<DateTime?> newList = targetDayData["timeStamp"];
                newList.add(DateTime.now());
                await DataBaseHelper().upDateDB(
                targetDayData["date"],
                targetDayData["time"], 
                targetDayData["schedule"], 
                targetDayData["plan"],
                targetDayData["record"],
                newList,
                );
                ref.read(dataProvider.notifier).state = Data();
                ref.read(dataProvider).isRenewed = true;}
              },
              child:timerButton(targetDayData)
            )
          ]),
        ]),    
            Expanded(
            child:Column(
             crossAxisAlignment:CrossAxisAlignment.start,
             children:[
              
              Row(children:[
               const SizedBox(width:7),
               const Icon(Icons.calendar_month,size:10,color:Colors.grey),
               const Text("予定 ",style: TextStyle(fontSize:10,color:Colors.grey),),
               const SizedBox(width:4),
               Expanded(child:
               Text(calendarData(index),
                style: const TextStyle(fontSize:12,color:Colors.grey),
               ),
               )
              ]),


              Row(children:[
               const SizedBox(width:7),
               const Icon(Icons.edit,size:10,color:Colors.grey),
               const Text("メモ ",style: TextStyle(fontSize:10,color:Colors.grey),),
               const SizedBox(width:4),
               Expanded(child:               
               TextField(
                style: const TextStyle(fontSize:12),
                controller:scheduleController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true
                ),
               onSubmitted:(value)async{
                 await DataBaseHelper().upDateDB(
                  targetDayData["date"],
                  targetDayData["time"], 
                  value,
                  targetDayData["plan"], 
                  targetDayData["record"],
                  targetDayData["timeStamp"]
                 );
                 ref.read(dataProvider.notifier).state = Data();
                 ref.read(dataProvider).isRenewed = true;
               },
               ),
               )
              ]),


              Row(children:[
                const SizedBox(width:4),
                circularButton(Colors.greenAccent,index,targetMonthData),
                const SizedBox(width:6),     
                TextFieldList(
                onSubmitted:(value)async{

                }, 
                targetDayData: targetDayData, 
                targetCategory: "plan",
                backGroundColor: Colors.greenAccent,
                ),
              ]),

              const SizedBox(height:1.5),
              //dividerVertical(),
              const SizedBox(height:1.5),

              Row(children:[
                const SizedBox(width:4),
                circularButton(Colors.blueAccent,index,targetMonthData),
                const SizedBox(width:6),                
                TextFieldList(
                onSubmitted:(value){
                 
                },
                targetDayData: targetDayData, 
                targetCategory: "record",
                backGroundColor:Colors.blueAccent ,
                )]),

            ])
           ) 
         ]),
        ]
       )
       );

      },
      itemCount: targetMonthData.length,
      shrinkWrap: true,
      //physics: const NeverScrollableScrollPhysics(),
     ));
  }
}

String calendarData(index){
  String targetDay = "${targetMonth.substring(0,4)}-${targetMonth.substring(5,7)}-${(index + 1).toString().padLeft(2,"0")}";
  
  final calendarData = ref.read(calendarDataProvider);

  if(calendarData.sortedDataByDay.keys.contains(targetDay)){
    List<String> subJectList = [];
    for(int i = 0; i < calendarData.sortedDataByDay[targetDay].length; i++){
      subJectList.add(calendarData.sortedDataByDay[targetDay].elementAt(i)["subject"]);
    }
    return subJectList.join('、');
  }else{
    return "";
  }
}


Widget dividerVertical(){
 if(ref.watch(dataProvider).isVertical){
   return const Divider(thickness: 1,height: 2,);
  }else{
   return const SizedBox();
  }
 
}


bool isToday(String date){
  if(date == today){
    return true;
  }else{
    return false;
  }
}

Widget timerButton(Map targetDayData){
  final data = ref.watch(dataProvider);
  DateTime yesterDayDT = DateTime.now().subtract(const Duration(days: 1));
  String yesterDay = "${yesterDayDT.year}/${yesterDayDT.month.toString().padLeft(2, '0')}/${yesterDayDT.day.toString().padLeft(2, '0')}";

  if(isToday(targetDayData["date"]) || targetDayData["date"] == yesterDay){

    if(data.isTimerList[targetDayData["date"]]){

    return const  Row(children:[
            Icon(Icons.timer,color:Colors.red,size:12),
            Text("作動中",style: TextStyle(color:Colors.red,fontSize:11,fontWeight: FontWeight.bold),)
    ]);

    }else{

    if(data.isTimerList[targetDayData["date"]] == false && data.isTimerList.values.contains(true)){
      return const SizedBox();
    }else{

      return const Row(children:[
              Icon(Icons.timer,color:Colors.grey,size:13),
              Text("起動",style: TextStyle(color:Colors.grey,fontSize:13),)
              ]);

    }
   }
  }else{
    return const SizedBox();
  }

}

TextStyle highLightToday(String date){
 if(isToday(date) == true){
   return const TextStyle(color: Colors.redAccent,fontWeight: FontWeight.bold);
 }else{
   return const TextStyle(fontWeight: FontWeight.bold);
 }
}

Color highLightTodayTile(String date,String formattedDuration){
 if(isToday(date) == true){
   return const Color.fromARGB(255, 255, 220, 220);
 }else{
  if(formattedDuration == "0h00m"){
   return FORGROUND_COLOR;
  }else{
   return const Color.fromARGB(255, 255, 255, 212);
  }
 }
}


void AddNewPage(String targetMonth){
  setState((){
    for(int i = 0; i < LengthOfMonth(targetMonth); i++){
     String targetDate = "$targetMonth/${(i + 1).toString().padLeft(2, '0')}";
     DataBaseHelper().insertNewData(
      targetDate, 
      const Duration(hours:0,minutes:0),
      "",
      [],
      [],
      []);
   }});


}



 void increasePgNumber(){
   final data = ref.watch(dataProvider);
   String increasedMonth = "";
    
    if(targetMonth.substring(5,7) == "12"){
    int year = int.parse(targetMonth.substring(0,4));
    year += 1;
      setState((){increasedMonth =  "$year/01";});
    }else{
     int month = int.parse(targetMonth.substring(5,7));
     month += 1;
     setState((){increasedMonth = targetMonth.substring(0,5) + month.toString().padLeft(2, '0');});
    }

    targetMonth = increasedMonth;
  }

 void decreasePgNumber(){
   final data = ref.watch(dataProvider);
   String decreasedMonth = "";
    
    if(targetMonth.substring(5,7) == "01"){
    int year = int.parse(targetMonth.substring(0,4));
    year -= 1;
      setState((){decreasedMonth =  "$year/12";});
    }else{
     int month = int.parse(targetMonth.substring(5,7));
     month -= 1;
     setState((){decreasedMonth = targetMonth.substring(0,5) + month.toString().padLeft(2, '0');});
    }

    targetMonth = decreasedMonth;
  }

  String weekDay(weekday){
    String dayOfWeek = '';
      switch (weekday) {
    case 1:
      dayOfWeek = '(月)';
      break;
    case 2:
      dayOfWeek = '(火)';
      break;
    case 3:
      dayOfWeek = '(水)';
      break;
    case 4:
      dayOfWeek = '(木)';
      break;
    case 5:
      dayOfWeek = '(金)';
      break;
    case 6:
      dayOfWeek = '(土)';
      break;
    case 7:
      dayOfWeek = '(日)';
      break;
    }
   return dayOfWeek;
  }

  Widget circularButton(Color color, int index,List<Map<String,dynamic>> targetMonthData) {
    final data = ref.watch(dataProvider);
    Map<String,dynamic> targetDayData = targetMonthData.elementAt(index);
    
    return SizedBox(
      width:40,
      height:15,
      child:ElevatedButton(
      onPressed: () async{
        if(color == Colors.greenAccent){

              List<String> newList = targetDayData["plan"];
                newList.add("ここに入力…");
                await DataBaseHelper().upDateDB(
                  targetDayData["date"],
                  targetDayData["time"], 
                  targetDayData["schedule"],
                  newList,
                  targetDayData["record"], 
                  targetDayData["timeStamp"]
                );
              ref.read(dataProvider.notifier).state = Data();
              ref.read(dataProvider).isRenewed = true;

        }else{
            showImputDialogue(targetDayData);
        } 
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        backgroundColor: color,
      ),
      child: Text(
         buttonText(color),
        style:  TextStyle(
          fontSize: 10.0,
          fontWeight: FontWeight.bold,
          color: FORGROUND_COLOR,
        ),
      ),
    )
  );
  }


  String buttonText (color) {
        if(color == Colors.greenAccent){
          return "  計画 +  ";
        }else{
          return "  達成 +  ";
        } 
  }

  Future<void> showTemplateDialogue (targetDayData) async{
    final data = ref.read(dataProvider);
    final taskData = ref.read(taskDataProvider);
    Map taskMap = taskData.sortedDataByDTEnd;
   
    showDialog(
      context: context,
      builder: (BuildContext context) { 
      return AlertDialog(
        title:const  Text("計画を追加…"),
        actions:[
         Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            const Text("タスクから選択:",style:(TextStyle(fontWeight: FontWeight.bold))),
            SizedBox(
              width: double.maxFinite,
              height:200,  //listViewHeight(40,targetDayData["plan"].length),
              child:ListView.separated(
                separatorBuilder: (context, index) {
                 if(taskMap.isEmpty){
                  return const SizedBox();
                 }else{
                    return const  SizedBox(height:5);
                  }
                },
                itemBuilder: (BuildContext context, index){
                 if(taskMap.isEmpty){
                   return const SizedBox(height:200,child:Center(child:Text("登録されているタスクはありません。")));
                 }else if(taskData.taskDataList.isEmpty){
                    return const SizedBox(height:200,child:Center(child:Text("登録されているタスクはありません。")));
                 }else{
                  late String date;
                  date = DateFormat('yyyy年MM月dd日').format(taskMap.keys.elementAt(index));
                  
                  return Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children:[
                    Text(date),
                    ListView.separated(
                    itemBuilder:(context,ind){
                    String taskCategory = taskMap.values.elementAt(index).elementAt(ind)["title"];
                    String taskTitle = taskMap.values.elementAt(index).elementAt(ind)["summary"];
                    int isDone = taskMap.values.elementAt(index).elementAt(ind)["isDone"];
                    if(isDone == 0){
                     return InkWell(
                      child:
                        Container(
                          padding: const EdgeInsets.all(7.5),
                          decoration:  BoxDecoration(
                            color:FORGROUND_COLOR,
                            borderRadius:const BorderRadius.all(Radius.circular(20))
                          ),
                          child:SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child:Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:[
                                Text(taskCategory,
                                    style:const TextStyle(fontSize: 10,color:Colors.grey),
                                  ),
                                Text(taskTitle,
                                    style:const TextStyle(fontSize: 15,color:Colors.black),
                                  ),
                            ])
                              
                          )            
                        ),
                        onTap:()async{
                          List<String> newList = targetDayData["plan"];
                            newList.add("【${truncateString(taskCategory)}】$taskTitle");
                                await DataBaseHelper().upDateDB(
                                targetDayData["date"],
                                targetDayData["time"], 
                                targetDayData["schedule"],
                                newList,
                                targetDayData["record"], 
                                targetDayData["timeStamp"]
                                );
                                ref.read(dataProvider.notifier).state = Data();
                                ref.read(dataProvider).isRenewed = true;
                                Navigator.pop(context);
                              }
                         );
                    }else{
                        return const SizedBox();
                      }
                    },
                    separatorBuilder:(context,ind){
                      return const SizedBox(height:5);
                    },
                    itemCount: taskMap.values.elementAt(index).length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    )]);
                  }
                },
                shrinkWrap: true,
                itemCount: notToBeZero(taskMap.length),
              )
            ),
            const Text("新規追加:",style:(TextStyle(fontWeight: FontWeight.bold))),
            ElevatedButton(
            onPressed:()async{
              List<String> newList = targetDayData["plan"];
                newList.add("ここに入力…");
                await DataBaseHelper().upDateDB(
                  targetDayData["date"],
                  targetDayData["time"], 
                  targetDayData["schedule"],
                  newList,
                  targetDayData["record"], 
                  targetDayData["timeStamp"]
                );
              ref.read(dataProvider.notifier).state = Data();
              ref.read(dataProvider).isRenewed = true;
              Navigator.pop(context);
            },
            style:const  ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.greenAccent),
              minimumSize: WidgetStatePropertyAll(Size(1000, 35))
              ),
            child:  Text("+ アイテムを追加…",style:TextStyle(color:FORGROUND_COLOR)),
            )
          ]),
        ],
      );
      }
    );
  }

  int notToBeZero(int length){
   if(length == 0){
    return 1;
   }else{
    return length;
   }
  }

  int accurateLength(List<String> rawList){
    int result = 0;
    for(int i = 0; i < rawList.length; i++){
     if(rawList.elementAt(i).trim() != ""){
      result++;
     }
    }
    return result;
  }

  String truncateString(String input, {int maxLength = 10}) {
    if (input.length <= maxLength) {
      return input;
    } else {
      return '${input.substring(0, maxLength - 3)}…';
    }
  }

  void showImputDialogue (targetDayData){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:const  Text("達成した計画を選択:"),
        actions:[
         Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            //const Text("計画から選択:",style:(TextStyle(fontWeight: FontWeight.bold))),
            SizedBox(
              width: double.maxFinite,
              height:listViewHeight(40,notToBeZero(accurateLength(targetDayData["plan"]))),
              child:ListView.separated(
                separatorBuilder: (context, index) {
                if(targetDayData["plan"].elementAt(index).trim() == ""){
                   return const SizedBox();
                }else{
                  return const SizedBox(height:5);
                  }
                },
                itemBuilder: (BuildContext context, index){
                if(accurateLength(targetDayData["plan"]) == 0){
                  return const SizedBox(height:40,child:Center(child:Text("この日の計画はありません。")));
                }else if(targetDayData["plan"].elementAt(index).trim() == ""){
                   return const SizedBox();
                }else{
                  return InkWell(child:Container(
                    height:35,
                    decoration: const BoxDecoration(
                      color:Colors.greenAccent,
                      borderRadius: BorderRadius.all(Radius.circular(20))
                    ),
                    child:
                     Padding(
                      padding:const EdgeInsets.only(left:10,top:5,bottom:5),
                      child:SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child:Text(
                          targetDayData["plan"].elementAt(index).trim(),
                          style: TextStyle(
                            color:FORGROUND_COLOR,
                            fontSize:20
                      ),
                  )) 
                 )
                ),
                onTap:()async{
                  List<String> newList = targetDayData["record"];
                  newList.add(targetDayData["plan"].elementAt(index));
                    await DataBaseHelper().upDateDB(
                    targetDayData["date"],
                    targetDayData["time"], 
                    targetDayData["schedule"], 
                    targetDayData["plan"], 
                    newList,
                    targetDayData["timeStamp"]
                    );
                  ref.read(dataProvider.notifier).state = Data();
                  ref.read(dataProvider).isRenewed = true;
                  Navigator.pop(context);
                      }
                    );
                  }
                },
                shrinkWrap: true,
                itemCount: targetDayData["plan"].length,
              )
            ),
            // const SizedBox(height:5),
            // const Text("新規追加:",style:(TextStyle(fontWeight: FontWeight.bold))),
            // ElevatedButton(
            // onPressed:()async{
            // List<String> newList = targetDayData["record"];
            // newList.add("ここに入力…");
            // await DataBaseHelper().upDateDB(
            // targetDayData["date"],
            // targetDayData["time"], 
            // targetDayData["schedule"], 
            // targetDayData["plan"], 
            // newList,
            // targetDayData["timeStamp"]
            // );
            // ref.read(dataProvider.notifier).state = Data();
            // ref.read(dataProvider).isRenewed = true;
            // Navigator.pop(context);
            // },
            
            // style:const  ButtonStyle(
            //   backgroundColor: MaterialStatePropertyAll(Colors.blueAccent),
            //   minimumSize: MaterialStatePropertyAll(Size(1000, 35))
            //   ),
            // child:const Text("+ アイテムを追加…",style:TextStyle(color:WHITE)),
            // )
          ]),
        ],
      );
 
      }
    );

  }

  Future<void> showTaskDeleteDialogue(targetDayData) async{
    final taskData = ref.read(taskDataProvider);
    Map taskMap = taskData.sortedDataByDTEnd;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:const  Text("タスクを完了状態にしますか？"),
        actions:[
         Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            const Text("完了したタスクを選択:",style:(TextStyle(fontWeight: FontWeight.bold))),
            SizedBox(
              width: double.maxFinite,
              height: SizeConfig.blockSizeVertical! *30,
              child:ListView.separated(
                separatorBuilder: (context, index) {
                 if(taskMap.isEmpty){
                  return const SizedBox();
                 }else{
                    return const  SizedBox(height:5);
                  }
                },
                itemBuilder: (BuildContext context, index){
                 if(taskMap.isEmpty){
                   return const SizedBox(height:200,child:Center(child:Text("登録されているタスクはありません。")));
                 }else if(taskData.taskDataList.isEmpty){
                   return const SizedBox(height:200,child:Center(child:Text("登録されているタスクはありません。")));
                 }else{
                  late String date;
                  date = DateFormat('yyyy年MM月dd日').format(taskMap.keys.elementAt(index));
                  return Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children:[
                    Text(date),
                    ListView.separated(
                    itemBuilder:(context,ind){
                    String taskCategory = taskMap.values.elementAt(index).elementAt(ind)["title"];
                    String taskTitle = taskMap.values.elementAt(index).elementAt(ind)["summary"];
                    int isDone = taskMap.values.elementAt(index).elementAt(ind)["isDone"];
                    if(isDone == 0){
                     return InkWell(
                      child:
                        Container(
                          padding: const EdgeInsets.all(7.5),
                          decoration: BoxDecoration(
                            color:FORGROUND_COLOR,
                            borderRadius: BorderRadius.all(Radius.circular(20))
                          ),
                          child:SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child:Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:[
                                Text(taskCategory,
                                    style:const TextStyle(fontSize: 10,color:Colors.grey),
                                  ),
                                Text(taskTitle,
                                    style:const TextStyle(fontSize: 15,color:Colors.black),
                                  ),
                            ])
                              
                          )            
                        ),
                  onTap:()async{
                          await TaskDatabaseHelper().unDisplay(
                            taskMap.values.elementAt(index).elementAt(ind)["id"]
                          );
                          ref.read(dataProvider.notifier).state = Data();
                          ref.read(dataProvider).isRenewed = true;
                          Navigator.pop(context);
                        }
                      );
                    }else{
                     return const SizedBox();
                     }
                    },
                    separatorBuilder:(context,ind){
                      return const SizedBox(height:5);
                    },
                    itemCount: taskMap.values.elementAt(index).length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    )]);
                  }
                },
                shrinkWrap: true,
                itemCount: notToBeZero( taskMap.length),
              )
            ),
            ElevatedButton(
              onPressed:(){
                Navigator.pop(context);
              },
            style:const  ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(ACCENT_COLOR),
              minimumSize: WidgetStatePropertyAll(Size(1000, 35))
              ),
            child: Text("とじる",style:TextStyle(color:FORGROUND_COLOR)),
            )
          ]),
        ],
      );
      }
    );
  }


  Future<void> showMyalog(BuildContext context,targetDayData) async {
    final data = ref.read(dataProvider);
    Map tempLateMap = data.templateDataList;
    TextEditingController controller = TextEditingController();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('新規テンプレートを追加…'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 300.0,
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0), // 角丸の半径を指定
                      
                    ),
                   filled: true,
                   fillColor: Colors.greenAccent,
                  ),
                  style:TextStyle(color:FORGROUND_COLOR,fontSize:20),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // ダイアログを閉じる
              },
              style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.redAccent)),
              child: Text('戻る',style:TextStyle(color:FORGROUND_COLOR)),
            ),
            ElevatedButton(
              onPressed: () async{
                int nextIndex = 0;
                if(tempLateMap.isNotEmpty){
                  nextIndex += int.parse(tempLateMap.keys.last.toString()) + 1;
                }

                String enteredText = controller.text;
                await TemplateDataBaseHelper().insertNewTemplateData(
                  nextIndex,
                  enteredText
                );
                setState((){
                  ref.read(dataProvider.notifier).state = Data();
                  ref.read(dataProvider).isRenewed = true;
                });


                List<String> newList = targetDayData["plan"];
                  newList.add(controller.text);
                      await DataBaseHelper().upDateDB(
                      targetDayData["date"],
                      targetDayData["time"], 
                      targetDayData["schedule"],
                      newList,
                      targetDayData["record"], 
                      targetDayData["timeStamp"]
                      );
                      ref.read(dataProvider.notifier).state = Data();
                      ref.read(dataProvider).isRenewed = true;

                       Navigator.of(context).pop();
              },
              style:const  ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.greenAccent)),
              child: Text('ＯＫ',style:TextStyle(color:FORGROUND_COLOR)),
            ),
          ],
        );
      },
    );
  }

}


class TextFieldList extends ConsumerStatefulWidget {
  late void Function(String) onSubmitted;
  late Map<String,dynamic> targetDayData;
  late String targetCategory;
  late Color backGroundColor;

 TextFieldList({super.key, 
    required this.onSubmitted,
    required this.targetDayData,
    required this.targetCategory,
    required this.backGroundColor,
  });

  @override
   _TextFieldListState createState() =>  _TextFieldListState();
}

class  _TextFieldListState extends ConsumerState<TextFieldList> {
  @override
  Widget build(BuildContext context){
    return  Container(
       height: switchHeight(ref.read(dataProvider).isVertical),
       width:SizeConfig.blockSizeHorizontal! *67,
       color: FORGROUND_COLOR,
       child:SizedBox(
        child:ListView.separated(
          separatorBuilder: (context, index) {
            if(widget.targetDayData[widget.targetCategory].elementAt(index).trim() == ""){
                return const SizedBox();
            }else{
              return const SizedBox(width:6,height:3);
            }
          },
          itemBuilder: (BuildContext context, index){
            return TextFieldObject(
              textData:modifyTextLsit(widget.targetDayData[widget.targetCategory]).elementAt(index),
              index:index,
              targetDayData:widget.targetDayData,
              backGroundColor:widget.backGroundColor
             
             
            );
          
        },
      itemCount: widget.targetDayData[widget.targetCategory].length,
      scrollDirection: switchAxis(ref.read(dataProvider).isVertical),
      shrinkWrap: true,
      physics:  switchPhysics(ref.read(dataProvider).isVertical),
      )
   ),
  );
  }

  Axis switchAxis(bool isVertical){
    if(isVertical){
     return  Axis.vertical;
    }else{
     return Axis.horizontal;
    }
  } 

  ScrollPhysics switchPhysics(bool isVertical){
    if(isVertical){
     return const NeverScrollableScrollPhysics();
    }else{
     return const AlwaysScrollableScrollPhysics();
    }
  } 

  double? switchHeight(bool isVertical){
    if(isVertical){
     return  null;
    }else{
     return SizeConfig.blockSizeVertical! *2.2;
    }
  } 

  double? switchWidth(bool isVertical){
    if(isVertical){
     return SizeConfig.blockSizeVertical! *52;
    }else{
     return  null;
    }
  } 

  List<String> modifyTextLsit(List<String> rawList){
    for (var element in rawList) {
      String newElement = element;
      if(element.length > 1){
      int index = 0;
      while(index < element.length && element[index] == " "){
        newElement = element.substring(1);
        index++;
      }
    }
  }
    return(rawList);
  }

}

class TextFieldObject extends ConsumerStatefulWidget {
  late String textData;
  late int index;
  late Color backGroundColor;
  late Map<String,dynamic> targetDayData;

  TextFieldObject({super.key, 
    required this.textData,
    required this.index,
    required this.backGroundColor,
    required this.targetDayData
  });

  @override
   _TextFieldObjectState createState() =>  _TextFieldObjectState();
}

class  _TextFieldObjectState extends ConsumerState<TextFieldObject> {
  double _textFieldWidth = 100.0;
  late TextEditingController controller = TextEditingController();
  late String _textFieldValue;
  @override
  void initState() {
    super.initState();
    _textFieldValue = widget.textData;
    controller = TextEditingController(text:_textFieldValue.trim()); 
    controller.addListener(_updateTextFieldWidth);
  }

  void _updateTextFieldWidth() {
    // テキストが変更されるたびに横幅を更新
    setState(() {
      _textFieldWidth = _calculateWidth();
    });
  }

  double _calculateWidth() {
    // 任意の基準値に文字数を乗じて横幅を計算
    const baseWidthPerCharacter = 11.0;
    return baseWidthPerCharacter * controller.text.length + 8.0;
  }


  double countCharacters(String input) {
  double count = 0;

  for (var char in Characters(input)) {
    if (char.codeUnits.length == 1) {
      // 半角文字
      count += 0.5;
    } else {
      // 全角文字
      count += 1.0;
    }
  }
  return count;
  }


  Axis switchAxis(bool isVertical){
    if(isVertical){
     return  Axis.vertical;
    }else{
     return Axis.horizontal;
    }
  } 

  ScrollPhysics switchPhysics(bool isVertical){
    if(isVertical){
     return const AlwaysScrollableScrollPhysics();
    }else{
     return const NeverScrollableScrollPhysics();
    }
  } 

 @override
  Widget build(BuildContext context){
  _updateTextFieldWidth();
  if(widget.textData.trim() == ""){
   return const SizedBox();
  }else{
   return Container(
    width: _textFieldWidth,
    height:15,
    decoration: BoxDecoration(
      color:widget.backGroundColor,
      borderRadius: const BorderRadius.all(Radius.circular(20))
    ),
     child:TextField(
      controller: controller,
      onSubmitted: (value) async{
        if(widget.backGroundColor == Colors.greenAccent){
          List<String> newList = widget.targetDayData["plan"];
          newList[widget.index] = value;
           await DataBaseHelper().upDateDB(
            widget.targetDayData["date"],
            widget.targetDayData["time"], 
            widget.targetDayData["schedule"], 
            newList, 
            widget.targetDayData["record"],
            widget.targetDayData["timeStamp"]
            );
            ref.read(dataProvider.notifier).state = Data();
            ref.read(dataProvider).isRenewed = true;
        }else{
          List<String> newList = widget.targetDayData["record"];
          newList[widget.index] = value;
            await DataBaseHelper().upDateDB(
            widget.targetDayData["date"],
            widget.targetDayData["time"], 
            widget.targetDayData["schedule"], 
            widget.targetDayData["plan"],
            newList,
            widget.targetDayData["timeStamp"]
            );
            ref.read(dataProvider.notifier).state = Data();
            ref.read(dataProvider).isRenewed = true;
        }

      },
      style: TextStyle(
       fontSize: 10, // フォントサイズ
       color: FORGROUND_COLOR, // 文字色,
       fontWeight:FontWeight.bold
      ),
      scrollPhysics:  switchPhysics(ref.read(dataProvider).isVertical),
      decoration: 
      const InputDecoration(
        contentPadding: EdgeInsets.only(left: 4,right: 4),
        border: InputBorder.none,
        isDense: true
      ),
      onChanged: (value) {
        setState((){
          _updateTextFieldWidth();
          _textFieldValue = value;});
        },
      )
    );
  }
}

  String modifyTextData(rawText,length){
    
    if (rawText.startsWith(' ')) {
      rawText = rawText.substring(length);
    }
    return(rawText);
  }

  List<String> modifyTextLsit(List<String> rawList){
    
    for (var element in rawList) {
      if(element.isNotEmpty){
      int index = 0;
      while(element[index] != " "){
        element = "${element.substring(0, index)}${element.substring(index + 1)}";
        index++;
      }
    }
  }
    return(rawList);
  }

  

   @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

int LengthOfMonth(String targetMonth){
  int targetMonthNum = int.parse(targetMonth.substring(5,7));
  switch(targetMonthNum){
    case 1: return 31;
    case 2: if(int.parse(targetMonth.substring(0,4))% 4 == 0){return 29;}else{return 28;}
    case 3: return 31;
    case 4: return 30;
    case 5: return 31;
    case 6: return 30;
    case 7: return 31;
    case 8: return 31;
    case 9: return 30;
    case 10: return 31;
    case 11: return 30;
    case 12: return 31;
    default: return 31;
  }
}