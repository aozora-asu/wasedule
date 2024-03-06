import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/backend/DB/handler/todo_db_handler.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/data_manager.dart';
import 'package:flutter_calandar_app/frontend/screens/to_do_page/task_progress_indicator.dart';
import 'package:flutter_calandar_app/frontend/screens/to_do_page/todo_assist_files/data_receiver.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';



class TimerView extends ConsumerStatefulWidget {
  List<Map<String,dynamic>>? targetMonthData;
  // Future<List<Map<String, dynamic>>>? events;
  // AsyncSnapshot<List<Map<String, dynamic>>> snapshot;
  BuildContext context;

  TimerView({
    this.targetMonthData,
    // this.events,
    // required this.snapshot,
    required this.context
  });

  @override
   _TimerViewState createState() =>  _TimerViewState();
}

class  _TimerViewState extends ConsumerState<TimerView> {
  late Timer timer; // Timerを保持する変数

  @override
  void initState() {
    super.initState();
    // 100ミリ秒ごとにタイマーを更新する
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {}); // タイマーが更新されるたびに画面を再構築
    });
  }

  @override
  void dispose() {
    // タイマーを破棄する
    timer.cancel();
    super.dispose();
  }


  Widget build(BuildContext context){
  final data = ref.watch(dataProvider);

   SizeConfig().init(context);
   if(widget.targetMonthData == null){
    return buildTaskProgressIndicator(
                              widget.context, ref.read(taskDataProvider).taskDataList);
   }else{
    data.generateIsTimerList(widget.targetMonthData!);
    return SizedBox(
      child:ListView.builder(itemBuilder:(context,index){
        final String date = widget.targetMonthData!.elementAt(index)["date"];
        Map<String,dynamic> targetDayData = widget.targetMonthData!.elementAt(index);
        String formattedDuration = '${targetDayData["time"].inHours}h${(targetDayData["time"].inMinutes % 60).toString().padLeft(2, '0')}m';
        DateTime? startTime = targetDayData["timeStamp"].elementAt(targetDayData["timeStamp"].length-1) ?? DateTime.now();

        if(widget.targetMonthData!.elementAt(index)["timeStamp"].length.isEven){
         return SizedBox(
          height:SizeConfig.blockSizeVertical! *40,
          child: Column(children:[          
            Row(children:[
              const Icon(Icons.timer,color:Colors.grey,size:20),
              Text(" " + date + "：タイマー作動中",style: const TextStyle(color:Colors.grey,fontSize:17,),)
            ]),
            buildTimer(startTime,formattedDuration,targetDayData),
            ElevatedButton(
              onPressed:()async{
                List<DateTime?> newList = targetDayData["timeStamp"];
                newList.add(DateTime.now());
                Duration newDuration = targetDayData["time"];
                newDuration += DateTime.now().difference(startTime!);

                await DataBaseHelper().upDateDB(
                targetDayData["date"],
                newDuration, 
                targetDayData["schedule"], 
                targetDayData["plan"],
                targetDayData["record"],
                newList,
                );
                showOtsukareDialogue(startTime,targetDayData,formattedDuration);
                ref.read(dataProvider.notifier).state = Data();
                ref.read(dataProvider).isRenewed = true;
            },
              style: ElevatedButton.styleFrom(
                fixedSize: Size(SizeConfig.blockSizeHorizontal! *100, SizeConfig.blockSizeVertical! *4,),
                backgroundColor: Colors.blueAccent, // ボタンの背景色
                textStyle: const TextStyle(color:Colors.white), // テキストの色
              ),
              child:const Row(
                children:[
                Spacer(),
                Icon(Icons.timer,color: Colors.white,),
                SizedBox(width:20),
                Text("記録に加算して停止",style:TextStyle(color:Colors.white)),
                Spacer(),
                ]), // ボタンのテキスト
          ),
          ElevatedButton(
              onPressed: () {
               showConfirmDialogue(startTime,targetDayData,formattedDuration);
              },
              style: ElevatedButton.styleFrom(
                fixedSize: Size(SizeConfig.blockSizeHorizontal! *100, SizeConfig.blockSizeVertical! *4,),
                backgroundColor: Colors.redAccent, // ボタンの背景色
                textStyle: const TextStyle(color:Colors.white),/// テキストの色
              ),
              child:const Row(
                children:[
                Spacer(),
                Icon(Icons.delete,color: Colors.white,),
                SizedBox(width:20),
                Text("記録せずに停止",style:TextStyle(color:Colors.white),),
                Spacer(),
                ]),
          ),
          const SizedBox(height:5),
          const Divider(thickness: 1,height: 1,)
          ])
         );
        }else{
         if(index == 1 && data.isTimerList.values.contains(true) == false){
         return buildTaskProgressIndicator(
                              widget.context,  ref.read(taskDataProvider).taskDataList);
         }else{
          return const SizedBox();
         }
        }
      },
      shrinkWrap: true,
      itemCount:widget.targetMonthData!.length,
      )
    );
   }
  }

  Widget buildTimer(startTime,formattedDuration,targetDayData) {
    Duration elapsedDuration = DateTime.now().difference(startTime);
    Duration estimatedSum = DateTime.now().difference(startTime) + targetDayData["time"];

    String formattedEstSum = '${estimatedSum.inHours}h${(estimatedSum.inMinutes % 60).toString().padLeft(2, '0')}m';

    int hours = elapsedDuration.inHours;
    int minutes = (elapsedDuration.inMinutes % 60);
    int seconds = (elapsedDuration.inSeconds % 60);
    int milliseconds = (elapsedDuration.inMilliseconds % 100);

    String fixedMinutes = minutes.toString().padLeft(2,'0');
    String fixedSeconds = seconds.toString().padLeft(2,"0");
    String fixedMilliseconds = milliseconds.toString().padLeft(2,"0");

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children:[
      SizedBox(height:SizeConfig.blockSizeVertical! *4),
      Text(
      hours.toString() + "h " + fixedMinutes + "m " + fixedSeconds + "s",
      style: TextStyle(fontSize: 60,fontWeight: FontWeight.bold),
     ),
     SizedBox(height:SizeConfig.blockSizeVertical! *4),
     Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children:[
      Text("+ この日の勉強記録 " + formattedDuration + " = ",style: TextStyle(color:Colors.grey,fontSize:17),),
      Text(formattedEstSum + " ↓",style: TextStyle(color:Colors.redAccent,fontSize:17,fontWeight: FontWeight.bold),),
      ])
     
    ]);
  }

  void showConfirmDialogue(startTime,targetDayData,formattedDuration){
    Duration elapsedDuration = DateTime.now().difference(startTime);

    int hours = elapsedDuration.inHours;
    int minutes = (elapsedDuration.inMinutes % 60);

    String fixedMinutes = minutes.toString().padLeft(2,'0');
    String toBeAddedDuration = hours.toString() + "h " + fixedMinutes + "m";
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content:
            Row(
             crossAxisAlignment: CrossAxisAlignment.start, 
             children:[
              const Icon(Icons.warning_amber_rounded,color: Colors.red,size:40),
              Expanded(child:
               Text(
                "今回の記録 " + 
                toBeAddedDuration + 
                " は、今日の勉強時間 " +
                formattedDuration +
                " に加算されずに破棄されます。よろしいですか？",
                style: TextStyle(fontWeight: FontWeight.bold,fontSize:17), 
                )
            ),]),
          
        actions:[
             ElevatedButton(
              onPressed:()async{
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
                ref.read(dataProvider).isRenewed = true;
             Navigator.pop(context);
            },
            
            style:const  ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(Colors.redAccent),
              ),
            child:const  Row(children:[Spacer(),Text("はい",style:TextStyle(color:Colors.white)),Spacer(),]),
            ),
          ElevatedButton(
            onPressed:(){
             Navigator.pop(context);
            },
            
            style: const ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(Colors.greenAccent),
              ),
            child: const Row(children:[Spacer(),Text("もどる",style:TextStyle(color:Colors.white)),Spacer(),]),
            ),
          ]
        );
      }
    );
  }

  void showOtsukareDialogue(startTime,targetDayData,formattedDuration){
    Duration elapsedDuration = DateTime.now().difference(startTime);

    int hours = elapsedDuration.inHours;
    int minutes = (elapsedDuration.inMinutes % 60);

    String fixedMinutes = minutes.toString().padLeft(2,'0');
    String toBeAddedDuration = hours.toString() + "h " + fixedMinutes + "m";

    Duration estimatedSum = DateTime.now().difference(startTime) + targetDayData["time"];

    String formattedEstSum = '${estimatedSum.inHours}h${(estimatedSum.inMinutes % 60).toString().padLeft(2, '0')}m';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:Text("お疲れさまでした！",style: TextStyle(fontWeight: FontWeight.bold),),
          content:
            Row(
             crossAxisAlignment: CrossAxisAlignment.start, 
             children:[
              Icon(Icons.edit_document,color: Colors.greenAccent,size:40),
              Expanded(child:
               Text(
                "今日の勉強時間 " +
                 formattedDuration +
                " に " +
                toBeAddedDuration + 
                " が加算され,合計 " +
                formattedEstSum +
                " になりました！"
                ,
                style: TextStyle(fontWeight: FontWeight.bold,fontSize:17), 
                )
            ),]),
          
        actions:[
          ElevatedButton(
            onPressed:(){
             Navigator.pop(context);
            },
            child: Row(children:[Spacer(),Text("OK",style:TextStyle(color:Colors.white)),Spacer(),]),
            style: ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(Colors.greenAccent),
              ),
            ),
          ]
        );
      }
    );
  }

}