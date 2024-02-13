import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/handler/schedule_db_handler.dart';
import 'package:flutter_calandar_app/backend/DB/handler/schedule_template_db_handler.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/add_event_button.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/add_template_button.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/schedule_data_manager.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/time_input_page.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/add_data_card_button.dart';
import 'package:intl/intl.dart';
import 'package:easy_autocomplete/easy_autocomplete.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../common/app_bar.dart';
import '../common/burger_menu.dart';
import '../../../backend/DB/models/task.dart';
import '../../../backend/DB/handler/task_db_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/data_manager.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/task_view_page.dart';


class TagAndTemplatePage extends ConsumerStatefulWidget {


 @override
   DailyViewPageState createState() => DailyViewPageState();
}

class DailyViewPageState extends ConsumerState<TagAndTemplatePage> {

  @override
  Widget build(BuildContext context) {
    ref.watch(taskDataProvider);
    return Scaffold(
        appBar: AppBar(
        leading: const BackButton(color:Colors.white),
        backgroundColor: MAIN_COLOR,
        elevation: 10,
        title: Column(
          children:<Widget>[
            Row(children:[
            const Icon(
              Icons.tag,
              color:WIDGET_COLOR,
              ),
              SizedBox(width: SizeConfig.blockSizeHorizontal! *4,),
            Text(
              'タグとテンプレート',
              style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal! *5,
                fontWeight: FontWeight.w800,
                color:Colors.white
              ),
            ),
            ]
            )
          ],
        ),
      ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child:
                    Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  SizedBox(width: SizeConfig.blockSizeHorizontal! * 5),
                  Text(
                    'テンプレート',
                    style: TextStyle(
                        fontSize: SizeConfig.blockSizeHorizontal! *7,
                        color:Colors.grey),
                  ),
                ]),
              ),
              Container(
                width: SizeConfig.blockSizeHorizontal! * 100,
                child: listView(),
              ),
              SizedBox(
                width: SizeConfig.blockSizeHorizontal! * 90,
                height: SizeConfig.blockSizeHorizontal! * 3,
              ),
            
            Column(children:[
             InkWell(
              child:Container(
               width: SizeConfig.blockSizeHorizontal! *95,
               padding: const EdgeInsets.all(16.0),
               decoration: BoxDecoration(
                color: Colors.blue[100], // コンテナの背景色
                borderRadius: BorderRadius.circular(12.0), // 角丸の半径
               ),
              child:const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
                Text("  +   テンプレートの追加...",
                     style:TextStyle(color:Colors.white,fontSize: 25,fontWeight: FontWeight.bold),)
              ]),
            ),
            onTap: (){
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => TemplateInputForm()),
                );
            }
          ),
          const SizedBox(height:15) 
          ]),

            const Divider(thickness:3, indent: 10,endIndent: 10,),

              const SizedBox(height:5),
              Align(
                alignment: Alignment.centerLeft,
                child:
                  Row(
                  children: [
                   SizedBox(width: SizeConfig.blockSizeHorizontal! * 5),
                   Text(
                    'タグ',
                    style: TextStyle(
                        fontSize: SizeConfig.blockSizeHorizontal! *7,
                        color:Colors.grey),
                  ),
                  SizedBox(width: SizeConfig.blockSizeHorizontal! * 2),
              ]),
            ),
            tagDataList(),
            SizedBox(width: SizeConfig.blockSizeHorizontal! * 5),
                        Column(children:[
             InkWell(
              child:Container(
               width: SizeConfig.blockSizeHorizontal! *95,
               padding: const EdgeInsets.all(16.0),
               decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 239, 218), // コンテナの背景色
                borderRadius: BorderRadius.circular(12.0), // 角丸の半径
                boxShadow: [
                BoxShadow(
                  color:
                      Colors.grey.withOpacity(0.5), // 影の色と透明度
                  spreadRadius: 2, // 影の広がり
                  blurRadius: 4, // 影のぼかし
                  offset: const Offset(0, 2), // 影の方向（横、縦）
                ),
            ],
               ),
              child:const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
                Text("  +   タグの追加...",
                     style:TextStyle(color:Colors.grey,fontSize: 25,fontWeight: FontWeight.bold),)
              ]),
            ),
            onTap: (){
              Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TaskInputForm()),
            );
            }
          ),
          const SizedBox(height:15) 
          ]),
            const Divider(thickness:3, indent: 10,endIndent: 10,),

            SizedBox(height:SizeConfig.blockSizeVertical! *10),
          ])
        ),
        floatingActionButton:
            Row(
              children:[
                const Spacer(),
                FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  backgroundColor: ACCENT_COLOR,
                  label: 
                    SizedBox(
                      width: SizeConfig.blockSizeHorizontal! *80,
                      child:const 
                       Center(child:Text('戻る', style: TextStyle(color: Colors.white)),)
                      )
                ),
              ])
              
                
      );
  }

  Widget listView(){
    final taskData = ref.read(taskDataProvider);
    final data = ref.read(calendarDataProvider);
    ref.watch(calendarDataProvider);

     List targetData = data.templateData;
   return
     ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            Widget dateTimeData = Container();
            if (targetData.elementAt(index)["startTime"].trim() != "" && targetData.elementAt(index)["endTime"].trim() != ""){
              dateTimeData =
                  Text(
                    " " + targetData.elementAt(index)["startTime"] + "～" + targetData.elementAt(index)["endTime"],
                    style: const TextStyle(color:Colors.white,fontSize: 13,fontWeight: FontWeight.bold),
                  );
            } else if (targetData.elementAt(index)["startTime"].trim() != ""){
              dateTimeData =
                  Text(
                    " " + targetData.elementAt(index)["startTime"],
                    style: const TextStyle(color:Colors.white,fontSize: 13,fontWeight: FontWeight.bold),
                  );
            } else {
              dateTimeData = const Text(
                    " 終日",
                    style: TextStyle(color:Colors.white,fontSize: 13,fontWeight: FontWeight.bold),
                  );
            }


           return  Column(children:[
            InkWell(
             onTap:(){
              inittodaiarogu(data.templateData.elementAt(index));
              _showTextDialog(context,data.templateData.elementAt(index));
             },
             child:Container(
             width: SizeConfig.blockSizeHorizontal! *95,
             padding: const EdgeInsets.all(16.0),
             decoration: BoxDecoration(
              color: Colors.blue[100], // コンテナの背景色
              borderRadius: BorderRadius.circular(12.0), // 角丸の半径
            ),
            child:
            Row(children:[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
              dateTimeData,
               SizedBox(
                width:SizeConfig.blockSizeHorizontal! *70,
                child:Text(data.templateData.elementAt(index)["subject"],
                   overflow: TextOverflow.clip,
                   style: const TextStyle(color:Colors.white,fontSize: 25,fontWeight: FontWeight.bold),
                  )
                )
                
            ]),
            const Spacer(),
            Column(children:[
              IconButton(
              icon: const Icon(Icons.delete,color:Colors.white),
              onPressed: ()async{
                await ScheduleTemplateDatabaseHelper().deleteSchedule(
                  data.templateData.elementAt(index)["id"]
                  );
                ref.read(calendarDataProvider.notifier).state = CalendarData();
                Navigator.of(context).pop();
              },
              ),
            ])

          ])
         )
        ),
          const SizedBox(height:15)   
         ]);    
        },
        itemCount:
            data.templateData.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      );
    }

  Widget tagDataList(){
    final taskData = ref.watch(taskDataProvider);
    Map<DateTime, List<Map<String, dynamic>>> sortedData = 
    taskData.sortDataByDtEnd(taskData.taskDataList);

    // if(sortedData.keys.contains(widget.target)){
    //   return ListView.builder(
    //       itemBuilder: (BuildContext context, int index) {
    //         Widget dateTimeData = Container();
    //           dateTimeData =
    //               Text(
    //                 sortedData[widget.target]!.elementAt(index)["title"],
    //                 style: const TextStyle(color:Colors.grey,fontSize: 13,fontWeight: FontWeight.bold),
    //               );

    //        return  Column(children:[
    //         Container(
    //          width: SizeConfig.blockSizeHorizontal! *95,
    //          padding: const EdgeInsets.all(16.0),
    //          decoration: BoxDecoration(
    //           color: Colors.white, // コンテナの背景色
    //           borderRadius: BorderRadius.circular(12.0), // 角丸の半径
    //           boxShadow: [
    //            BoxShadow(
    //             color:
    //                 Colors.grey.withOpacity(0.5), // 影の色と透明度
    //             spreadRadius: 2, // 影の広がり
    //             blurRadius: 4, // 影のぼかし
    //             offset: const Offset(0, 2), // 影の方向（横、縦）
    //           ),
    //         ],
    //         ),
    //         child: Column(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children:[
    //           dateTimeData,
    //           Text(sortedData[widget.target]!.elementAt(index)["summary"] ?? "(詳細なし)",
    //                         style: const TextStyle(color:Colors.black,fontSize: 25,fontWeight: FontWeight.bold),)
    //         ]),
    //       ),
    //       const SizedBox(height:15)   
    //      ]);    
    //     },
    //     itemCount:
    //         sortedData[widget.target]!.length,
    //   shrinkWrap: true,
    //   physics: const NeverScrollableScrollPhysics(),
    //   );

    // }else{

      return  const SizedBox();
    }

  void inittodaiarogu(Map targetData){
    final provider = ref.watch(scheduleFormProvider);
    provider.timeStartController.text = targetData["startTime"];
    provider.timeEndController.text = targetData["endTime"];
  }

  Future<void> _showTextDialog(BuildContext context,Map targetData) async {
    final provider = ref.watch(scheduleFormProvider);
    TextEditingController titlecontroller = TextEditingController();
    titlecontroller.text = targetData["subject"];
    dynamic dtStartcontroller = targetData["startDate"];
    
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        ref.watch(scheduleFormProvider.notifier);
        return AlertDialog(
          title: const Text('テンプレートの編集...'),
          content: StatefulBuilder(
           builder: (BuildContext context, StateSetter setState) {
            ref.watch(scheduleFormProvider.notifier);
            String tagcontroller = targetData["tag"];

            return Column(children:[TextField(
             controller: titlecontroller,
             decoration: const InputDecoration(
              labelText: '予定',
              border:OutlineInputBorder()
              ),
            ),
          
         Row(children:[
          ElevatedButton(
           onPressed: () {
           
              Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                TimeInputPage(
                 target:DateTime.now(),
                 inputCategory:"startTime",
                )
              ),
            );
             setState((){});
           },
           style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color?>(ACCENT_COLOR),
              ),
           child: const Text("+ 開始時刻",style:TextStyle(color:Colors.white))
          ),
          //timeInputPreview(provider.timeStartController.text)
          ]),
          

          Row(children:[
          ElevatedButton(
           onPressed: (){
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => 
                TimeInputPage(
                 target:DateTime.now(),
                 inputCategory:"endTime",
                )
              ),
            );
           },
           style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color?>(ACCENT_COLOR),
              ),
           child: const Text("+ 終了時刻",style:TextStyle(color:Colors.white))
          ),
          //timeInputPreview(provider.timeEndController.text)
          ]),
          

          Row(children:[         
            ElevatedButton(
            onPressed: (){
             
            },
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color?>(ACCENT_COLOR),
                ),
            child: const Text("+    タグ     ",style:TextStyle(color:Colors.white))
            ),
            timeInputPreview(tagcontroller)

         ])
        ]);
       },
      ),


          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('戻る'),
            ),
            TextButton(
              onPressed: () async{
              Map<String,dynamic>newMap = {};
              newMap["subject"] = titlecontroller.text;
              newMap["startTime"] = provider.timeStartController.text;
              newMap["endTime"] = provider.timeEndController.text;
              newMap["isPublic"] = targetData["isPublic"];
              newMap["publicSubject"] = targetData["publicSubject"];
              newMap["tag"] = targetData["tag"];
              newMap["id"] = targetData["id"];
              await ScheduleTemplateDatabaseHelper().updateSchedule(newMap);
              ref.read(calendarDataProvider.notifier).state = CalendarData();
              Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('変更'),
            ),
          ],
        );
      },
    );
  }



  Widget timeInputPreview(String text){
    String previewText = "なし";
    if(text != ""){previewText = text;}

    return Expanded(
      child:Center(
        child:Text(
          previewText,
          style:const TextStyle(
            color:Colors.grey,
            fontWeight:FontWeight.bold,
            fontSize:20
            ),
          overflow: TextOverflow.visible,
        )
      ) 
    );
  }

}