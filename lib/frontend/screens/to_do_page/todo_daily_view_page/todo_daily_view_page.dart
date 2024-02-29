import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/schedule_data_manager.dart';
import 'package:flutter_calandar_app/frontend/screens/common/app_bar.dart';
import 'package:flutter_calandar_app/backend/DB/handler/todo_db_handler.dart';
import 'package:flutter_calandar_app/frontend/screens/to_do_page/stats_page/stats_page.dart';
import 'package:flutter_calandar_app/frontend/screens/to_do_page/todo_daily_view_page/time_input_page.dart';
import 'package:flutter_calandar_app/frontend/screens/to_do_page/todo_daily_view_page/timer_view.dart';
import 'package:flutter_calandar_app/frontend/screens/to_do_page/todo_assist_files/data_receiver.dart';
import 'package:flutter_calandar_app/frontend/screens/to_do_page/todo_assist_files/size_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';


class DaylyViewPage extends ConsumerStatefulWidget {
  Future<List<Map<String, dynamic>>>? events;
  AsyncSnapshot<List<Map<String, dynamic>>> snapshot;
  BuildContext context;

  DaylyViewPage({
    this.events,
    required this.snapshot,
    required this.context
  });

  @override
   _DaylyViewPageState createState() =>  _DaylyViewPageState();
}

class _DaylyViewPageState extends ConsumerState<DaylyViewPage> {
  late String targetMonth = "";
  String thisMonth = DateTime.now().year.toString() + "/" + DateTime.now().month.toString().padLeft(2, '0');
  String today = DateTime.now().year.toString() + "/" + DateTime.now().month.toString().padLeft(2, '0') + "/" + DateTime.now().day.toString().padLeft(2, '0');

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
          label: const Text("統計",style: TextStyle(color:Colors.white),),
          backgroundColor: ACCENT_COLOR,
          icon: const Icon(Icons.insert_chart_outlined_rounded,color:Colors.white,size: 20,),
          onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => StatsPage()),
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
          targetMonthData:data.sortDataByMonth()[thisMonth],
          events:widget.events,
          context:widget.context,
          snapshot: widget.snapshot,
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

  // double calculateHeight(){
  //  final data = ref.watch(dataProvider);
  //  if(data.isTimerList.containsValue(true)){
  //   return 50 - 17.75;
  //  }else{
  //   return 50;
  //  }
  // }

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
    return "計 " +
    timeSum.inHours.toString() +
    "時間" +
    (timeSum.inMinutes % 60).toString() +
    "分";
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

      return "/" +
    timeSum.inHours.toString() +
    "時間(月全体の" +
    fixedPersent +
    "%)";
    }
  }


  Widget pageBody(){
   final data = ref.read(dataProvider);

   if(ref.read(dataProvider).isRenewed && data.sortDataByMonth()[targetMonth] == null){
    return Container(
      height:SizeConfig.blockSizeVertical! *70,
      width:SizeConfig.blockSizeHorizontal! *100,
      child:const Center(
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
          
          style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(MAIN_COLOR)),
          child:const Text("ページの作成",style: TextStyle(color:Colors.white),),
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
            Text(
              " " + targetDayData["date"].substring(5,10) + weekDay(formattedDateData.weekday),
              style: highLightToday(targetDayData["date"]),
            ),
            const VerticalDivider(thickness: 10,width: 10,color: Colors.grey,indent: 0,endIndent: 0,),
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

              const SizedBox(height:1),
              dividerVertical(),
              const SizedBox(height:1),

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

            ]))
            
          ]
         ),
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
  String targetDay = targetMonth.substring(0,4) + "-" +targetMonth.substring(5,7) +  "-" + (index + 1).toString().padLeft(2,"0");
  
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
  DateTime yesterDayDT = DateTime.now().subtract(Duration(days: 1));
  String yesterDay = yesterDayDT.year.toString() + "/" + yesterDayDT.month.toString().padLeft(2, '0') + "/" + yesterDayDT.day.toString().padLeft(2, '0');

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
   return const TextStyle();
 }
}

Color highLightTodayTile(String date,String formattedDuration){
 if(isToday(date) == true){
   return const Color.fromARGB(255, 255, 220, 220);
 }else{
  if(formattedDuration == "0h00m"){
   return Colors.white;
  }else{
   return const Color.fromARGB(255, 255, 255, 212);
  }
 }
}


void AddNewPage(String targetMonth){
  setState((){
    for(int i = 0; i < LengthOfMonth(targetMonth); i++){
     String targetDate = targetMonth + "/" + (i + 1).toString().padLeft(2, '0');
     DataBaseHelper().insertNewData(
      targetDate, 
      const Duration(hours:0,minutes:0),
      "",
      [],
      [],
      []);
   }});


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

 void increasePgNumber(){
   final data = ref.watch(dataProvider);
   String increasedMonth = "";
    
    if(targetMonth.substring(5,7) == "12"){
    int year = int.parse(targetMonth.substring(0,4));
    year += 1;
      setState((){increasedMonth =  year.toString() + "/" + "01";});
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
      setState((){decreasedMonth =  year.toString() + "/" + "12";});
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
    
    return Container(
      width:40,
      height:15,
      child:ElevatedButton(
      onPressed: () async{
        if(color == Colors.greenAccent){
           showTemplateDialogue (targetDayData);
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
        style:const  TextStyle(
          fontSize: 10.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    )
  );
  }


  String buttonText (color) {
        if(color == Colors.greenAccent){
          return "  計画 +  ";
        }else{
          return "  完了 +  ";
        } 
  }

  Future<void> showTemplateDialogue (targetDayData) async{
    final data = ref.read(dataProvider);
    Map tempLateMap = data.templateDataList;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("計画を追加…"),
        actions:[
         Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            Text("テンプレート(ダブルタップで追加):",style:(TextStyle(fontWeight: FontWeight.bold))),
            Container(
              child:ListView.separated(
                separatorBuilder: (context, index) {
                 if(tempLateMap.isEmpty){
                  return const SizedBox();
                 }else{
                  if(tempLateMap.values.elementAt(index).trim() == ""){//ここにテンプレDBから呼び出し。
                    return SizedBox();
                  }else{
                    return SizedBox(height:5);
                  }
                 }
                },
                itemBuilder: (BuildContext context, index){
                 if(tempLateMap.isEmpty){
                   return const SizedBox();
                 }else{
                  if(tempLateMap.values.elementAt(index).trim() == ""){
                    return SizedBox();
                  }else{
                    late TextEditingController controller = TextEditingController();
                    late String _textFieldValue;
                    _textFieldValue = tempLateMap.values.elementAt(index).trim();
                    controller = TextEditingController(text:_textFieldValue.trim()); 

                    return InkWell(
                      child:Container(
                      height:35,
                      decoration: BoxDecoration(
                        color:Colors.blueAccent,
                        borderRadius: BorderRadius.all(Radius.circular(20))
                      ),
                      child:TextField(
                          controller: controller,
                          onSubmitted: (value) async{
                            int i = tempLateMap.keys.elementAt(index);
                            String enteredText = value;

                            await TemplateDataBaseHelper().upDateDB(
                              i,
                              enteredText
                            );
                            setState((){
                              ref.read(dataProvider.notifier).state = Data();
                              ref.read(dataProvider).isRenewed = true;
                            });

                            Navigator.pop(context);
                          },
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(left:10,bottom: 10,top:10)
                          ),
                          style: TextStyle(fontSize: 20,color:Colors.white),
                        ),
                      ),
                  onDoubleTap:()async{
                    List<String> newList = targetDayData["plan"];
                      newList.add(tempLateMap.values.elementAt(index).trim());
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
                    }
                  }
                },
                shrinkWrap: true,
                itemCount: tempLateMap.length,
              )
            ),
            ElevatedButton(
            onPressed:()async{
              showMyalog(context,targetDayData);
            },
            
            style: const  ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(Colors.blueAccent),
              minimumSize: MaterialStatePropertyAll(Size(1000, 35))
              ),
            child: const Text("+ テンプレートを追加…",style:TextStyle(color:Colors.white)),
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
            child: Text("+ アイテムを追加…",style:TextStyle(color:Colors.white)),
            style: ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(Colors.greenAccent),
              minimumSize: MaterialStatePropertyAll(Size(1000, 35))
              ),
            )
          ]),
        ],
      );
 
      }
    );
  }

  void showImputDialogue (targetDayData){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("完了アイテムを追加…"),
        actions:[
         Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            Text("計画から選択:",style:(TextStyle(fontWeight: FontWeight.bold))),
            Container(
              child:ListView.separated(
                separatorBuilder: (context, index) {
                if(targetDayData["plan"].elementAt(index).trim() == ""){
                   return SizedBox();
                }else{
                  return SizedBox(height:5);
                  }
                },
                itemBuilder: (BuildContext context, index){
                
                if(targetDayData["plan"].elementAt(index).trim() == ""){
                   return SizedBox();
                }else{
                  return InkWell(child:Container(
                    height:35,
                    decoration: BoxDecoration(
                      color:Colors.greenAccent,
                      borderRadius: BorderRadius.all(Radius.circular(20))
                    ),
                    child:
                     Padding(
                      padding:EdgeInsets.only(left:10,top:5,bottom:5),
                      child:SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child:Text(
                          targetDayData["plan"].elementAt(index).trim(),
                          style: TextStyle(
                            color:Colors.white,
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
            SizedBox(height:5),
            Text("新規追加:",style:(TextStyle(fontWeight: FontWeight.bold))),
            ElevatedButton(
            onPressed:()async{
            List<String> newList = targetDayData["record"];
            newList.add("ここに入力…");
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
            },
            child: Text("+ アイテムを追加…",style:TextStyle(color:Colors.white)),
            style: ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(Colors.blueAccent),
              minimumSize: MaterialStatePropertyAll(Size(1000, 35))
              ),
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
    TextEditingController _controller = TextEditingController();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('新規テンプレートを追加…'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 300.0,
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0), // 角丸の半径を指定
                      
                    ),
                   filled: true,
                   fillColor: Colors.greenAccent,
                  ),
                  style: TextStyle(color:Colors.white,fontSize:20),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // ダイアログを閉じる
              },
              style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.redAccent)),
              child: Text('戻る',style:TextStyle(color:Colors.white)),
            ),
            ElevatedButton(
              onPressed: () async{
                int nextIndex = 0;
                if(tempLateMap.isNotEmpty){
                  nextIndex += int.parse(tempLateMap.keys.last.toString()) + 1;
                }

                String enteredText = _controller.text;
                await TemplateDataBaseHelper().insertNewTemplateData(
                  nextIndex,
                  enteredText
                );
                setState((){
                  ref.read(dataProvider.notifier).state = Data();
                  ref.read(dataProvider).isRenewed = true;
                });


                List<String> newList = targetDayData["plan"];
                  newList.add(_controller.text);
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
              style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.greenAccent)),
              child: Text('ＯＫ',style:TextStyle(color:Colors.white)),
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

 TextFieldList({
    required this.onSubmitted,
    required this.targetDayData,
    required this.targetCategory,
    required this.backGroundColor,
  });

  @override
   _TextFieldListState createState() =>  _TextFieldListState();
}

class  _TextFieldListState extends ConsumerState<TextFieldList> {
  
  Widget build(BuildContext context){
    return Container(
      height: switchWidth(ref.read(dataProvider).isVertical),
      width:SizeConfig.blockSizeHorizontal! *52,
      child:ListView.separated(
        separatorBuilder: (context, index) {
        if(widget.targetDayData[widget.targetCategory].elementAt(index).trim() == ""){
            return SizedBox();
        }else{
          return SizedBox(width:6,height:3);
        }
        },
        itemBuilder: (BuildContext context, index){
          return Row(children:[
          TextFieldObject(
            textData:modifyTextLsit(widget.targetDayData[widget.targetCategory]).elementAt(index),
            index:index,
            targetDayData:widget.targetDayData,
            backGroundColor:widget.backGroundColor
          ),
        ]);
        
      },
     itemCount: widget.targetDayData[widget.targetCategory].length,
     scrollDirection: switchAxis(ref.read(dataProvider).isVertical),
     shrinkWrap: true,
    )
  );
  }

  Axis switchAxis(bool isVertical){
    if(isVertical){
     return  Axis.vertical;
    }else{
     return Axis.horizontal;
    }
  } 

  double? switchWidth(bool isVertical){
    if(isVertical){
     return  null;
    }else{
     return SizeConfig.blockSizeVertical! *2.2;
    }
  } 

  List<String> modifyTextLsit(List<String> rawList){
    rawList.forEach((element) {
      String newElement = element;
      if(element.length > 1){
      int index = 0;
      while(index < element.length && element[index] == " "){
        newElement = element.substring(1);
        index++;
      }
    }
  }
  );
    return(rawList);
  }

}

class TextFieldObject extends ConsumerStatefulWidget {
  late String textData;
  late int index;
  late Color backGroundColor;
  late Map<String,dynamic> targetDayData;

  TextFieldObject({
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

 Widget build(BuildContext context){
  _updateTextFieldWidth();
  if(widget.textData.trim() == ""){
   return SizedBox();
  }else{
   return Container(
    width: _textFieldWidth,
    height:15,
    decoration: BoxDecoration(
      color:widget.backGroundColor,
      borderRadius: BorderRadius.all(Radius.circular(20))
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
       color: Colors.white, // 文字色
      ),
      scrollPhysics: NeverScrollableScrollPhysics(),
      decoration: InputDecoration(
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
    
    rawList.forEach((element) {
      if(element.length > 0){
      int index = 0;
      while(element[index] != " "){
        element = element.substring(0, index) + "" + element.substring(index + 1);
        index++;
      }
    }
  }
  );
    return(rawList);
  }

  

   @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}