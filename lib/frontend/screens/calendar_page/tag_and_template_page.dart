import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_calandar_app/backend/DB/handler/schedule_template_db_handler.dart';
import 'package:flutter_calandar_app/backend/DB/handler/tag_db_handler.dart';
import 'package:flutter_calandar_app/frontend/assist_files/tutorials.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/add_event_button.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/add_template_button.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/schedule_data_manager.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/time_input_page.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/data_manager.dart';


class TagAndTemplatePage extends ConsumerStatefulWidget {


 @override
   _TagAndTemplatePageState createState() => _TagAndTemplatePageState();
}

class _TagAndTemplatePageState extends ConsumerState<TagAndTemplatePage> {

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
                    ' 入力テンプレート',
                    style: TextStyle(
                        fontSize: SizeConfig.blockSizeHorizontal! *7,
                        color:Colors.grey),
                  ),
                ]),
              ),
             SizedBox(
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
                color: Colors.blue[100],
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
                  MaterialPageRoute(builder: (context) => TemplateInputForm(setosute: setState,)),
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
             tagDialog();         
            }
          ),
          const SizedBox(height:15) 
          ]),
            const Divider(thickness:3, indent: 10,endIndent: 10,),

            SizedBox(height:SizeConfig.blockSizeVertical! *10),
          ])
        ),                      
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
                Row(children:[
                  dateTimeData,
                  const SizedBox(width:15),
                  tagChip(data.templateData.elementAt(index)["tag"], ref)
                  ]),
              
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
               showDeleteDialogue(
                context,
                data.templateData.elementAt(index)["subject"],
                () async{
                  await ScheduleTemplateDatabaseHelper().deleteSchedule(
                  data.templateData.elementAt(index)["id"]
                  );
                ref.read(scheduleFormProvider).clearContents();
                ref.read(calendarDataProvider.notifier).state = CalendarData();
                ref.read(taskDataProvider).isRenewed = true;
                while (ref.read(taskDataProvider).isRenewed != false) {
                  await Future.delayed(const Duration(microseconds:1));
                }
                setState((){});
              });  
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
    final tagData = ref.watch(calendarDataProvider);
    List sortedData = 
    tagData.tagData;


      return ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            Widget dateTimeData = Container();
              dateTimeData =
                  const Text(
                    "通常タグ",
                    style: TextStyle(color:Colors.white,fontSize: 15,fontWeight: FontWeight.bold),
                  );
            
            if(sortedData.elementAt(index)["isBeit"] == 1){
              dateTimeData = Row(children:[
                const Text(
                  "アルバイトタグ",
                  style: TextStyle(color:Colors.white,fontSize: 13,fontWeight: FontWeight.bold,
                  backgroundColor: Colors.red),
                ),
                const SizedBox(width:15),
               Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children:[
                Text(
                    "時給：" + sortedData.elementAt(index)["wage"].toString() + "円",
                    style: const TextStyle(color:Colors.white,fontSize: 15,fontWeight: FontWeight.bold),
                  ),
                Text(
                    "交通費：" + sortedData.elementAt(index)["fee"].toString() + "円",
                    style: const TextStyle(color:Colors.white,fontSize: 15,fontWeight: FontWeight.bold),
                  )
                ])
               
              ]);
            }

           return  Column(children:[
           InkWell(
            onTap:(){
              editTagDialog(sortedData.elementAt(index));
            },
            child:Container(
             width: SizeConfig.blockSizeHorizontal! *95,
             padding: const EdgeInsets.all(16.0),
             decoration: BoxDecoration(
              color: sortedData.elementAt(index)["color"], // コンテナの背景色
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
            child: Row(children:[
              
              Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                dateTimeData,
                Text(sortedData.elementAt(index)["title"] ?? "(詳細なし)",
                style: const TextStyle(color:Colors.white,fontSize: 25,fontWeight: FontWeight.bold),)
          ]),
          const Spacer(),
            IconButton(
              icon: const Icon(Icons.delete,color:Colors.white),
              onPressed: (){
               showDeleteDialogue(
                context,
                sortedData.elementAt(index)["title"] ?? "(詳細なし)",
                ()async{
                  await TagDatabaseHelper().deleteTag(
                  sortedData.elementAt(index)["id"]
                  );
                ref.read(scheduleFormProvider).clearContents();
                ref.read(calendarDataProvider.notifier).state = CalendarData();
                ref.read(taskDataProvider).isRenewed = true;
                while (ref.read(taskDataProvider).isRenewed != false) {
                  await Future.delayed(const Duration(microseconds:1));
                }
                setState((){});
               }
              );
            },
          ),      
        ]),
      ),
    ),          
          const SizedBox(height:15)   
         ]);    
        },
        itemCount:
            sortedData.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      );
    }
  



  void inittodaiarogu(Map targetData){
    final provider = ref.watch(scheduleFormProvider);
    provider.timeStartController.text = targetData["startTime"];
    provider.timeEndController.text = targetData["endTime"];
    provider.tagController.text = targetData["tag"];  
  }

  Future<void> _showTextDialog(BuildContext context,Map targetData) async {
    final provider = ref.read(scheduleFormProvider);
    TextEditingController titlecontroller = TextEditingController();
    titlecontroller.text = targetData["subject"];



    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('テンプレートの編集...',style:TextStyle(fontSize:20)),
          actions: <Widget>[ 
          StatefulBuilder(
           builder: (BuildContext context, StateSetter setState) {
            return Column(
              children:[TextField(
               controller: titlecontroller,
               decoration: const InputDecoration(
                labelText: 'テンプレート予定名',
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
                 setState: setState,
                )
              ),
            );
           },
           style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color?>(ACCENT_COLOR),
              ),
           child: const Text("+ 開始時刻",style:TextStyle(color:Colors.white))
          ),
          timeInputPreview(provider.timeStartController.text)
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
                 setState: setState,
                )
              ),
            );
           },
           style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color?>(ACCENT_COLOR),
              ),
           child: const Text("+ 終了時刻",style:TextStyle(color:Colors.white))
          ),
          timeInputPreview(provider.timeEndController.text)
          ]),
          

          Row(children:[         
            ElevatedButton(
            onPressed: (){
              showTagDialogue(ref, context, setState);
            },
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color?>(ACCENT_COLOR),
                ),
            child: const Text("+    タグ     ",style:TextStyle(color:Colors.white))
            ),
            timeInputPreview(returnTagData(provider.tagController.text,ref))

         ])
        ]);
       },
      ),


          
            TextButton(
              onPressed: () async{
              Map<String,dynamic>newMap = {};
              newMap["subject"] = titlecontroller.text;
              newMap["startTime"] = provider.timeStartController.text;
              newMap["endTime"] = provider.timeEndController.text;
              newMap["isPublic"] = targetData["isPublic"];
              newMap["publicSubject"] = targetData["publicSubject"];
              newMap["tag"] = provider.tagController.text;
              newMap["id"] = targetData["id"];
              await ScheduleTemplateDatabaseHelper().updateSchedule(newMap);
              ref.read(scheduleFormProvider).clearContents();
              ref.read(taskDataProvider).isRenewed = true;
              ref.read(calendarDataProvider.notifier).state = CalendarData();
              while (ref.read(taskDataProvider).isRenewed != false) {
                await Future.delayed(const Duration(microseconds:1));
              }
              setState((){});
              Navigator.pop(context);
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

  void tagDialog(){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TagDialog(setosute:setState); // カスタムダイアログを表示
      },
    );
  }

  void editTagDialog(tagData){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditTagDialog(tagData:tagData,setosute:setState); // カスタムダイアログを表示
      },
    );
  }

}

class TagDialog extends ConsumerStatefulWidget {
  StateSetter setosute;

  TagDialog({
   required this.setosute
  });

  @override
  _TagDialogState createState() => _TagDialogState();
}

class _TagDialogState extends ConsumerState<TagDialog> {
  TextEditingController titleController = TextEditingController();
  TextEditingController wageController = TextEditingController();
  TextEditingController feeController = TextEditingController();
  late Color tagColor;
  late bool isBeit;


  @override
  void initState() {
    super.initState();
    isBeit = false;
    tagColor = Colors.redAccent; // コンテナの背景色
    wageController.text = "0";
    feeController.text = "0";
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("タグの新規追加...",style:TextStyle(fontSize:20)),

            const SizedBox(height: 10),

            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "タグ名",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 5),

            Row(children:[
              ElevatedButton(
              style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(ACCENT_COLOR)),
              onPressed: () {
                colorPickerDialogue();
              },
              child: const Text('  色を選択 ',style:TextStyle(color:Colors.white)),
              ),
              const SizedBox(width:10),
            Expanded(
              child:Container(
                height:30,
                color:tagColor
              ))
            ]),

            Row(children:[
              ElevatedButton(
              style:ElevatedButton.styleFrom(
                // ボタンの背景色を条件に応じて変更する
                backgroundColor: isBeit ? ACCENT_COLOR: Colors.grey,
                // その他のスタイル設定
                textStyle: const TextStyle(color: Colors.white),
                // 他のスタイルプロパティを設定する
              ),
              onPressed: () {
                setState((){
                  if(isBeit){
                    isBeit = false;
                  }else{
                    isBeit = true;
                  }
                });
              },
              child: const Text('アルバイト',style:TextStyle(color:Colors.white)),
              ),
              const SizedBox(width:10),
            Expanded(
              child:wageField())
            ]),

            const SizedBox(height: 10),

            SizedBox(
            width:500,
            child:
             ElevatedButton(
              style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(MAIN_COLOR)),
              onPressed: ()async{
                if(wageController.text == ""){wageController.text = "0";}
                if(feeController.text == ""){feeController.text = "0";}
                await TagDatabaseHelper().resisterTagToDB({
                  "title" : titleController.text,
                  "color" : tagColor,
                  "isBeit" : boolToInt(isBeit),
                  "wage" : int.parse(wageController.text),
                  "fee" : int.parse(feeController.text)
                });
                ref.read(scheduleFormProvider).clearContents();
                ref.read(taskDataProvider).isRenewed = true;
                ref.read(calendarDataProvider.notifier).state = CalendarData();
                while (ref.read(taskDataProvider).isRenewed != false) {
                  await Future.delayed(const Duration(microseconds:1));
                }
                widget.setosute((){});
                Navigator.pop(context);
                if(ref.read(calendarDataProvider).tagData.last["id"] == 1){
                   showTagGuide(context);
                }
                
              },
              child:  const Text('追加',style:TextStyle(color:Colors.white)),
            ),
          )
          ],
        ),
      ),
    );
  }

  int boolToInt(bool){
    if(bool){
      return 1;
    }else{
      return 0;
    }
  }


  Widget wageField(){
    if(isBeit){
       return Column(children:[
        SizedBox(
        height:40,
        child:TextField(
              controller: wageController,
              decoration: const InputDecoration(
                labelText: "時給*",
                labelStyle: TextStyle(color:Colors.red),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')), // 半角数字のみ許可
              ],
            )
          ),
        const SizedBox(height:10),
        SizedBox(
        height:40,
        child:TextField(
              controller: feeController,
              decoration: const InputDecoration(
                labelText: "片道交通費",
                labelStyle: TextStyle(color:Colors.grey),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')), // 半角数字のみ許可
              ],
            )
          )
        ]);
    }else{
      return const Text("OFF",style:TextStyle(color:Colors.grey,fontWeight:FontWeight.bold,fontSize:20));
    }
  }

  void colorPickerDialogue(){
      showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('タグの色を選択...'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor:Colors.redAccent,
              onColorChanged:(color){
               setState((){tagColor = color;}); 
              }
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('選択'),
              onPressed: () {
                Navigator.of(context)
                    .pop();
              },
            ),
          ],
        );
      });
  }


  // @override
  // void dispose() {
  //   titleController.dispose();
  //   wageController.dispose();
  //   super.dispose();
  // }
}


class EditTagDialog extends ConsumerStatefulWidget {
  Map<String,dynamic> tagData;
  StateSetter setosute;

  EditTagDialog({
    required this.tagData,
    required this.setosute
  });
  @override
  _EditTagDialogState createState() => _EditTagDialogState();
}

class _EditTagDialogState extends ConsumerState<EditTagDialog> {
  TextEditingController titleController = TextEditingController();
  TextEditingController wageController = TextEditingController();
  TextEditingController feeController = TextEditingController();
  late Color tagColor;
  late bool isBeit;


  @override
  void initState() {
    super.initState();
    titleController.text = widget.tagData["title"];
    isBeit = intToBool(widget.tagData["isBeit"]);
    tagColor = widget.tagData["color"];
    wageController.text = widget.tagData["wage"].toString();
    feeController.text = widget.tagData["fee"].toString();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("タグの編集...",style:TextStyle(fontSize:20)),

            const SizedBox(height: 10),

            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "タグ名",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 5),

            Row(children:[
              ElevatedButton(
              style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(ACCENT_COLOR)),
              onPressed: () {
                colorPickerDialogue();
              },
              child: const Text('  色を選択 ',style:TextStyle(color:Colors.white)),
              ),
              const SizedBox(width:10),
            Expanded(
              child:Container(
                height:30,
                color:tagColor
              ))
            ]),

            Row(children:[
              ElevatedButton(
              style:ElevatedButton.styleFrom(
                // ボタンの背景色を条件に応じて変更する
                backgroundColor: isBeit ? ACCENT_COLOR: Colors.grey,
                // その他のスタイル設定
                textStyle: const TextStyle(color: Colors.white),
                // 他のスタイルプロパティを設定する
              ),
              onPressed: () {
              },
              child: const Text('アルバイト',style:TextStyle(color:Colors.white)),
              ),
              const SizedBox(width:10),
            Expanded(
              child:wageField())
            ]),

            const SizedBox(height: 10),

            SizedBox(
            width:500,
            child:
             ElevatedButton(
              style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(MAIN_COLOR)),
              onPressed: ()async{
                if(feeController.text == ""){feeController.text  = "0";}
                if(wageController.text == ""){wageController.text = "0";}
                await TagDatabaseHelper().updateTag({
                  "id" : widget.tagData["id"],
                  "title" : titleController.text,
                  "color" : colorToInt(tagColor),
                  "isBeit" : boolToInt(isBeit),
                  "wage" : int.parse(wageController.text),
                  "fee" : int.parse(feeController.text)
                });
                ref.read(scheduleFormProvider).clearContents();
                ref.read(taskDataProvider).isRenewed = true;
                ref.read(calendarDataProvider.notifier).state = CalendarData();
                while (ref.read(taskDataProvider).isRenewed != false) {
                  await Future.delayed(const Duration(microseconds:1));
                }
                widget.setosute((){});
                Navigator.pop(context);
              },
              child:  const Text('変更',style:TextStyle(color:Colors.white)),
            ),
          )
          ],
        ),
      ),
    );
  }

  bool intToBool(int){
    if(int == 1){
      return true;
    }else{
      return false;
    }
  }


  int boolToInt(bool){
    if(bool){
      return 1;
    }else{
      return 0;
    }
  }

  // Color型からint型への変換関数
  int colorToInt(Color? color) {
    if (color == null){color = MAIN_COLOR;}
    // 16進数の赤、緑、青、アルファの値を結合して1つの整数に変換する
    return (color.alpha << 24) | (color.red << 16) | (color.green << 8) | color.blue;
  }

  Widget wageField(){
    if(isBeit){
       return Column(children:[
        SizedBox(
        height:40,
        child:TextField(
              controller: wageController,
              decoration: const InputDecoration(
                labelText: "時給*",
                labelStyle: TextStyle(color:Colors.red),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')), // 半角数字のみ許可
              ],
            )
          ),
        const SizedBox(height:10),
        SizedBox(
        height:40,
        child:TextField(
              controller: feeController,
              decoration: const InputDecoration(
                labelText: "片道交通費",
                labelStyle: TextStyle(color:Colors.grey),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')), // 半角数字のみ許可
              ],
            )
          )
        ]);
    }else{
      return const Text("OFF",style:TextStyle(color:Colors.grey,fontWeight:FontWeight.bold,fontSize:20));
    }
  }

  void colorPickerDialogue(){
      showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('タグの色を選択...'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor:Colors.redAccent,
              onColorChanged:(color){
               setState((){tagColor = color;}); 
              }
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('選択'),
              onPressed: () {
                Navigator.of(context)
                    .pop();
              },
            ),
          ],
        );
      });
  }



}



Future<void> showTagDialogue(WidgetRef ref, BuildContext context, StateSetter setState) async{
final data = ref.read(calendarDataProvider);
List tagMap = data.tagData;
showDialog(
context: context,
builder: (BuildContext context) {
  return AlertDialog(
    title: const Text("タグを選択："),
  actions:[
    Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children:[
      const Text("登録  タグ一覧",style:(TextStyle(fontWeight: FontWeight.bold))),
      SizedBox(
        width: double.maxFinite,
        height:listViewHeight(65,tagMap.length),
        child:ListView.separated(
          separatorBuilder: (context, index) {
            if(tagMap.isEmpty){
            return const SizedBox();
            }else{
              return const SizedBox(height:5);
            }
          },
          itemBuilder: (BuildContext context, index){
            if(tagMap.isEmpty){
              return const SizedBox();
            }else{
              Widget dateTimeData = Container();
                dateTimeData =
                    const Text(
                      "通常タグ",
                      style: TextStyle(color:Colors.white,fontSize: 10,fontWeight: FontWeight.bold),
                    );
              
              if(data.tagData.elementAt(index)["isBeit"] == 1){
                dateTimeData = Row(children:[
                  const Text(
                    "アルバイトタグ",
                    style: TextStyle(color:Colors.white,fontSize: 8,fontWeight: FontWeight.bold,
                    backgroundColor: Colors.red),
                  ),
                  const SizedBox(width:15),
                Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children:[                
                  Text(
                        "時給：" + data.tagData.elementAt(index)["wage"].toString() + "円",
                        style: const TextStyle(color:Colors.white,fontSize: 10,fontWeight: FontWeight.bold),
                      ),
                  Text(
                        "交通費：" + data.tagData.elementAt(index)["fee"].toString() + "円",
                        style: const TextStyle(color:Colors.white,fontSize: 10,fontWeight: FontWeight.bold),
                      )
                  ])

                ]);
              }



              return InkWell(
                onTap: () async{
                  final inputform = ref.watch(scheduleFormProvider);
                  setState((){inputform.tagController.text = data.tagData.elementAt(index)["id"].toString();});
                  Navigator.pop(context);
                },
                child:Container(
            
                decoration:BoxDecoration(
                  color:data.tagData.elementAt(index)["color"],
                  borderRadius:const BorderRadius.all(Radius.circular(20))
                ),
                child:Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:[
                    Padding(
                    child:dateTimeData,
                    padding:const EdgeInsets.only(left:15,top:3)
                    )
                    ,
                  Text("  " + data.tagData.elementAt(index)["title"],
                        style: const TextStyle(fontSize: 20,color:Colors.white),
                        overflow: TextOverflow.ellipsis,)
                ])
                )
              );
            }
          },
          shrinkWrap: true,
          itemCount: tagMap.length,
        )
      ),
      ElevatedButton(
        style: const ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(Colors.blueAccent),
          minimumSize: MaterialStatePropertyAll(Size(1000, 35))
          ),
        onPressed:(){
          setState((){ref.read(scheduleFormProvider).tagController.text = "";});
          Navigator.pop(context);
        },
        child: const Text(" - タグをクリア",style:TextStyle(color:Colors.white)),
      ),
    ]),
  ],
);

}
);
}

String returnTagData(String id, WidgetRef ref){
    final data = ref.read(calendarDataProvider);
    List tagMap = data.tagData;
    if(id == ""){
    return "";
  }else{
    for (var data in tagMap) {
      if (data["id"] == int.parse(id)) {
        return data["title"];
      }
    }
  
  return "無効なタグです";
 }
}


int returnTagIsBeit(String id, WidgetRef ref){
    final data = ref.read(calendarDataProvider);
    List tagMap = data.tagData;
    if(id == ""){
    return 0;
  }else{
    for (var data in tagMap) {
      if (data["id"] == int.parse(id)) {
        return data["isBeit"];
      }
    }
  
  return 0;
 }
}

Color? returnTagColor(String id, WidgetRef ref){
    final data = ref.read(calendarDataProvider);
    List tagMap = data.tagData;
    if(id == ""){
    return null;
  }else{
    for (var data in tagMap) {
      if (data["id"] == int.parse(id)) {
        return data["color"];
      }
    }
  return null;
 }
}



Widget tagChip(String id, WidgetRef ref){
  final data = ref.read(calendarDataProvider);
  List tagMap = data.tagData;
  if(id == ""){
    return const SizedBox();
  }else{
    for (var data in tagMap) {
      if (data["id"] == int.parse(id)) {
        
        return Container(
          height: 25,
          decoration: BoxDecoration(
            color: data["color"],
            borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey[700]!,
                  spreadRadius: 1,
                  blurRadius: 0,
                  offset: const Offset(0, 0)
                ),
              ],
          ),
          padding: const EdgeInsets.only(right:15,left:5),
          child:Row(children:[
          Container(
                      width: 10,
                      height: 10,
                      decoration:  BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[700],
                      ),
                    ),
            Text(
              "  " + truncateString(data["title"]),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                overflow: TextOverflow.ellipsis
              ),
            ),
          ]),

        );

      }
    }
  return  Container(
          height: 25,
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey[700]!,
                  spreadRadius: 1,
                  blurRadius: 0,
                  offset: const Offset(0, 0)
                ),
              ],
          ),
          padding: const EdgeInsets.only(right:15,left:5),
          child:Row(children:[
          Container(
                      width: 10,
                      height: 10,
                      decoration:  BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[700],
                      ),
                    ),
           const Text(
              " ! 無効なタグ",
              style:  TextStyle(
                color: Colors.white,
                fontSize: 15,
                overflow: TextOverflow.ellipsis
              ),
            ),
          ]),

        );
 }
}

String truncateString(String input) {
  if (input.length <= 8) {
    return input;
  } else {
    return input.substring(0, 8) + "…";
  }
}

void showDeleteDialogue(BuildContext context, String name, VoidCallback onTap) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('削除の確認'),
        content: Text('$name を削除しますか？'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // ダイアログを閉じる
            },
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              onTap();
              Navigator.of(context).pop(); // ダイアログを閉じる
            },
            child: const Text(
              '削除',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      );
    }
  );
}