import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/handler/schedule_template_db_handler.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/screens/common/tutorials.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/add_event_dialog.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/calendar_page.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/calendar_data_manager.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/tag_and_template_page.dart';
import 'package:flutter_calandar_app/frontend/screens/common/plain_appbar.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/task_data_manager.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';



class TemplateInputForm extends ConsumerStatefulWidget {
  StateSetter setosute;

  TemplateInputForm({super.key, 
     required this.setosute
  });

  @override
  _TemplateInputFormState createState() => _TemplateInputFormState();
}

class _TemplateInputFormState extends ConsumerState<TemplateInputForm> {

  @override
  void initState() {
    super.initState();
    ref.read(scheduleFormProvider).clearContents();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final scheduleForm = ref.watch(scheduleFormProvider);
    scheduleForm.isAllDay = false;
    return Scaffold(
      appBar:CustomAppBar(backButton: true,),
      body: 
      SingleChildScrollView(child:Padding(
        padding: const EdgeInsets.only(right:10,left:10),
        child:Column(

        crossAxisAlignment: CrossAxisAlignment.start,
        children:[
        
        SizedBox(
          height: SizeConfig.blockSizeVertical! * 1,
          width: SizeConfig.blockSizeHorizontal! * 80
        ),


          Row(
            children: [
              SizedBox(width: SizeConfig.blockSizeHorizontal! * 3),
              Image.asset('lib/assets/eye_catch/eyecatch.png',
                  height: 30, width: 30),
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "新しいテンプレートを追加…",
                    style: TextStyle(
                      fontSize: SizeConfig.blockSizeHorizontal! * 6,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.clip,
                  )
                )
            ],
          ),

         const Divider(indent: 7,endIndent: 7,thickness: 3),

          SizedBox(
            height: SizeConfig.blockSizeVertical! * 1,
            width: SizeConfig.blockSizeHorizontal! * 80
          ),



          SizedBox(
            height: SizeConfig.blockSizeVertical! *10,
            child: TextFormField(
              controller: scheduleForm.scheduleController,
              onFieldSubmitted: (value) {
                ref.read(scheduleFormProvider.notifier).updateDateTimeFields();
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'テンプレート予定名*',
                labelStyle: TextStyle(color: Colors.red),
              ),
            ),
          ),


         Row(children:[
          ElevatedButton(
           onPressed: ()async {
              DateTime now = DateTime.now();
              await DatePicker.showTimePicker(context,
                showTitleActions: true,
                showSecondsColumn: false,
                onConfirm: (date) {
                  scheduleForm.timeStartController.text
                    = DateFormat("HH:mm").format(date);
                    setState((){});
                },
                currentTime: DateTime(now.year,now.month,now.day,12,00),
                locale: LocaleType.jp
              );
           },
           style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color?>(ACCENT_COLOR),
              ),
           child: const Text("+ 開始時刻",style:TextStyle(color:Colors.white))
          ),
          timeInputPreview(scheduleForm.timeStartController.text)
          ]),
          

          Row(children:[
          ElevatedButton(
           onPressed: ()async {
              DateTime now = DateTime.now();
              await DatePicker.showTimePicker(context,
                showTitleActions: true,
                showSecondsColumn: false,
                onConfirm: (date) {
                  scheduleForm.timeEndController.text
                    = DateFormat("HH:mm").format(date);
                    setState((){});
                },
                currentTime: DateTime(now.year,now.month,now.day,12,00),
                locale: LocaleType.jp
              );
           },
           style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color?>(ACCENT_COLOR),
              ),
           child: const Text("+ 終了時刻",style:TextStyle(color:Colors.white))
          ),
          timeInputPreview(scheduleForm.timeEndController.text)
          ]),
          
          tagEmptyFlag(ref,
            Row(children:[         
              ElevatedButton(
              onPressed: (){
              showTagDialogue(ref, context, setState);
              },
              style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color?>(ACCENT_COLOR),
                  ),
              child: const Text("+    タグ     ",style:TextStyle(color:Colors.white))
              ),
              timeInputPreview(returnTagData(scheduleForm.tagController.text,ref))
            ]),
          ),
          
          SizedBox(
              height: SizeConfig.blockSizeVertical! * 0.5,
              width: SizeConfig.blockSizeHorizontal! * 80),      

          
          SizedBox(
            width: SizeConfig.blockSizeHorizontal! * 80,
            height: SizeConfig.blockSizeVertical! * 0.5,
          ),
         
          const Divider(indent: 7,endIndent: 7,thickness: 3),

          SizedBox(
            width: SizeConfig.blockSizeHorizontal! * 80,
            height: SizeConfig.blockSizeVertical! * 1,
          ),

          Row(children: [
          ElevatedButton(
            onPressed: () {
             scheduleForm.clearContents();
             Navigator.pop(context);
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color?>(ACCENT_COLOR),
              fixedSize: WidgetStateProperty.all<Size>(
                Size(SizeConfig.blockSizeHorizontal! * 45,
                    SizeConfig.blockSizeHorizontal! * 7.5),
              ),
            ),
            child: const Text('戻る', style: TextStyle(color: Colors.white)),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: ()async {
              if (scheduleForm.scheduleController.text.isEmpty) {
                print("ボタン無効");
              } else {
                if(isConflict(scheduleForm.timeStartController.text, scheduleForm.timeEndController.text)){
                  print("ボタン無効");
                  }else{
                int intIspublic;
                if (scheduleForm.isPublic) {
                  intIspublic = 1;
                } else {
                  intIspublic = 0;
                }

                //共有用予定が空だったら、個人用予定と揃える
                if (scheduleForm.publicScheduleController.text.isEmpty) {
                  scheduleForm.publicScheduleController =
                      scheduleForm.scheduleController;
                }

                  Map<String, dynamic> schedule = {
                    "subject": scheduleForm.scheduleController.text,
                    "startTime": scheduleForm.timeStartController.text,
                    "endTime": scheduleForm.timeEndController.text,
                    "isPublic": intIspublic,
                    "publicSubject":scheduleForm.publicScheduleController.text,
                    "tag": scheduleForm.tagController.text,
                    "tagID" : returnTagId(scheduleForm.tagController.text, ref)
                  };
                  await ScheduleTemplateDatabaseHelper().resisterScheduleToDB(schedule);
                  ref.read(scheduleFormProvider).clearContents();
                  ref.read(calendarDataProvider.notifier).state = CalendarData();
                  ref.read(taskDataProvider).isRenewed = true;
                  while (ref.read(taskDataProvider).isRenewed != false) {
                    await Future.delayed(const Duration(microseconds:1));
                  }
                  widget.setosute((){});
                  Navigator.pop(context);
                  if(ref.read(calendarDataProvider).templateData.last["id"] == 1){
                    showTemplateGuide(context);
                  }
                  
                }
                  
              }
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) {
                // 条件によってボタンの色を選択
                if (scheduleForm.scheduleController.text.isEmpty) {
                  return Colors.grey;
                    } else {
                  if (scheduleForm.timeStartController.text.isEmpty &&
                  scheduleForm.timeEndController.text.isNotEmpty) {
                    return Colors.grey;
                    } else {
                      if(isConflict(scheduleForm.timeStartController.text, scheduleForm.timeEndController.text)){
                        return Colors.grey;
                      }else {
                        return MAIN_COLOR;
                      }
                    }
                  }
              }),
              fixedSize: WidgetStateProperty.all<Size>(Size(
                SizeConfig.blockSizeHorizontal! * 45,
                SizeConfig.blockSizeHorizontal! * 7.5,
              )),
            ),
            child: const Text('追加', style: TextStyle(color: Colors.white)),
          ),
        ],
       ),
     ]),
    )  
   )
   );
  }

  Widget dateInputPreview(List textList){
    String previewText = "なし";
    String convertedList = textList.join('\n');

    if(textList.isNotEmpty){previewText = convertedList;}

    return Expanded(
      child:Center(
        child:Text(
          previewText,
          style:const TextStyle(
            color:Colors.grey,
            fontWeight:FontWeight.bold,
            fontSize:30
            ),
          overflow: TextOverflow.visible,
        )
      ) 
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
            fontSize:30
            ),
          overflow: TextOverflow.visible,
        )
      ) 
    );
  }

  Widget addTemplateButton(){
    return ElevatedButton(
      onPressed: () {
        
      },
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color?>(MAIN_COLOR),
      ),
      child: const Row(children:[
        Spacer(),
        Icon(Icons.add,color:Colors.white),
        SizedBox(width:10),
        Text('テンプレート', style: TextStyle(color: Colors.white)),
        Spacer(),
      ]) ,
    );
  }


  Widget publicScheduleField(ref) {
    final scheduleForm = ref.watch(scheduleFormProvider);
    if (scheduleForm.isPublic == true) {
      return SizedBox(

        child: 
        Column(children:[        
          TextField(
          controller: scheduleForm.publicScheduleController,
          decoration: const InputDecoration(
              border: OutlineInputBorder(), labelText: 'フレンドに見せる予定名'),
         ),
        SizedBox(
            width: SizeConfig.blockSizeHorizontal! * 80,
            height: SizeConfig.blockSizeVertical! * 1,
          ),
       ]),
      );
    } else {
      scheduleForm.clearpublicScheduleController();
      return const SizedBox(width: 0, height: 0);
    }
  }

  Future<void> _showTextDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController textEditingController = TextEditingController();
        return AlertDialog(
          title: const Text('タグを入力…'),
          content: TextField(
            controller: textEditingController,
            decoration: const InputDecoration(
              labelText: '新しいタグ',
              border: OutlineInputBorder()
              ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('戻る'),
            ),
            TextButton(
              onPressed: () {
                ref.read(scheduleFormProvider).tagController.text = textEditingController.text;
                ref.read(scheduleFormProvider.notifier).updateDateTimeFields();
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  bool isConflict(String start , String end){
    if(end == ""){return false;}else{
    Duration startTime = Duration(hours: int.parse(start.substring(0,2)), minutes:int.parse(start.substring(3,5)));
    Duration endTime = Duration(hours: int.parse(end.substring(0,2)), minutes:int.parse(end.substring(3,5)));

    if(startTime <= endTime){return false;}else{return true;}
    }
  }
}

