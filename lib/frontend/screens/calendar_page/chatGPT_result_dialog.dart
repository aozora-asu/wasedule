

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/handler/schedule_db_handler.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/add_event_dialog.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/calendar_data_manager.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/calendar_page.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/tag_and_template_page.dart';
import 'package:flutter_calandar_app/frontend/screens/common/dateTimePicker_modal.dart';
import 'package:flutter_calandar_app/frontend/screens/common/ui_components.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ScheduleCandidatesFromGPT {
  late List classCandidateList;

  ScheduleCandidatesFromGPT({
    required this.classCandidateList,
  });

  List<Schedule> convertData(){
    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    DateFormat timeFormat = DateFormat("hh:mm");


    List<Schedule> result = [];
    for(int i = 0; i < classCandidateList.length; i++){
      Map scheduleMap = classCandidateList.elementAt(i);
      bool isValid = true;

      if(scheduleMap["startTime"] != null){
        DateTime? startTime = timeFormat.tryParse(scheduleMap["startTime"]);
        if(startTime == null){
          isValid =false;
        }
      }

      if(scheduleMap["endTime"] != null){
        DateTime? endTime = timeFormat.tryParse(scheduleMap["endTime"]);
        if(endTime == null){
          isValid = false;
        }
      }

      if(scheduleMap["startDate"] != null){
        DateTime? startDate = dateFormat.tryParse(scheduleMap["startDate"]);
        if(startDate == null){
          isValid = false;
        }
      }

      if(isValid){
        result.add(
          Schedule(
            id: i,
            subject: scheduleMap["subject"],
            startDate: scheduleMap["startDate"],
            startTime: scheduleMap["startTime"],
            endTime: scheduleMap["endTime"])
        );
      }

    }
    return result;
  }


  String errorCause = "";

Future<bool> dialog(BuildContext context,WidgetRef ref) async {
  List<Schedule> scheduleList = convertData();
  bool isSubmitted = false;

  await showModalBottomSheet(
    backgroundColor: FORGROUND_COLOR,
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState){
          return Container(
            padding:const EdgeInsets.symmetric(horizontal:0,vertical: 15),
            width: double.maxFinite, // サイズを調整
            child: Column(children:[
              ModalSheetHeader(),
              const SizedBox(height: 5),
              const Text("生成した予定",style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),

              Expanded(child:
                ListView.builder(
                  itemCount: scheduleList.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    Schedule target = scheduleList.elementAt(index);

                    TextEditingController subjectController = TextEditingController();
                    subjectController.text = target.subject;

                    ScheduleController scheduleController = ScheduleController();
                    scheduleController.setInitDateTimeFromString(
                      target.startDate,
                      target.startTime,
                      null,
                      target.endTime,
                    );

                    String formatedDate = "日付を設定してください！";
                    if(target.startDate != null){
                      formatedDate = DateFormat("yyyy年MM月dd日(E)","ja_jp").format(
                        DateTime.parse(target.startDate!));
                    }

                    String timeStartController = target.startTime ?? "";
                    String timeEndController = target.endTime ?? "";
                    String dateStartAndEnd = "終日";
                    if (timeStartController != "" && timeEndController != "") {
                      dateStartAndEnd = "$timeStartController～$timeEndController";
                    } else if (timeStartController != "") {
                      dateStartAndEnd = timeStartController;
                    }

                    String? tagIDController = target.tagID;


                     return Container(
                        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                        decoration: roundedBoxdecoration(radiusType: 2,backgroundColor: BACKGROUND_COLOR),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Row(children:[
                              const SizedBox(width: 1),
                              Expanded(child:
                              tagEmptyFlag(ref,
                                tagEditButton(ref,context,tagIDController,
                                (value){
                                  setState((){
                                    tagIDController = returnTagId(value, ref) ;
                                    scheduleList[index].tagID = returnTagId(value, ref) ;
                                    scheduleList[index].tag = value;
                                  });
                                },setState
                              ))),
                            ]),

                            CupertinoTextField(
                              controller: subjectController,
                              onChanged: (value) {
                                scheduleList[index].subject = subjectController.text;
                              },),

                            Row(children:[

                              Expanded(
                                child:GestureDetector(
                                onTap :()async{
                                  await scheduleController.showDatePickerModal(context,showEndDate: false);
                                  setState((){
                                    scheduleList[index].startDate = scheduleController.valueString().startDate;
                                  });
                                },
                                child: Text(formatedDate,
                                  style:const TextStyle(fontSize: 18,color: Colors.blue)))
                              ),
 
                              GestureDetector(
                                  onTap: () async{
                                    await timeBottomSheet(
                                      context,
                                      timeStartController,
                                      timeEndController,
                                      (startValue,endValue){
                                        setState((){
                                          scheduleList[index].startTime = startValue;
                                          scheduleController.valueString().startTime = startValue;
                                          scheduleList[index].endTime = endValue;
                                          scheduleController.valueString().endTime = endValue;
                                        });
                                      });
                                  },
                                  child: Container(
                                      padding:
                                          const EdgeInsets.symmetric(horizontal: 2.5),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(7.5),
                                      ),
                                      child: Row(children: [
                                        Text(dateStartAndEnd),
                                        const SizedBox(width: 0),
                                        const Icon(Icons.arrow_drop_down,
                                            color: Colors.grey)
                                      ])),
                              ),
                            ])
                          ],
                        ),
                      
                    );
                
                  }
                )
              ),

            const Text("この機能は実験的試みです。ご利用にあたっては生成内容をよくお確かめください。",
              style: TextStyle(fontSize: 12,color: Colors.grey,overflow: TextOverflow.clip)),

            Row(children:[
              const SizedBox(width: 15),
              Expanded(
                child:buttonModel(
                  () {
                    isSubmitted = false;
                    Navigator.of(context).pop(); // ダイアログを閉じる
                  },
                  Colors.red,
                  'キャンセル',
              )),
              Expanded(
                child:buttonModel(
                  () async{
                    if(isValid(scheduleList, ref)){

                      for(var scheduleItem in scheduleList){
                          await ScheduleDatabaseHelper()
                            .resisterScheduleToDB(scheduleItem.toMap());
                      }
                      ref.read(calendarDataProvider.notifier).state = CalendarData();
                      isSubmitted = true;
                      Navigator.of(context).pop(); // ダイアログを閉じる

                    }else{

                    }
                  },
                  isValid(scheduleList, ref) ? BLUEGREY : Colors.grey,
                  "登録",
              )),
              const SizedBox(width: 15),
            ]),

            const SizedBox(height: 10)

            ])
          );
    },
  );
  });
  return isSubmitted;
}

  Future<void> timeBottomSheet(
    BuildContext context,
    String timeStartController,
    String timeEndController,
    Function(String?,String?) onSelected
  ) async {
    await showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        enableDrag: true,
        barrierColor: Colors.black.withOpacity(0.5),
        builder: (context) {
          return StatefulBuilder(builder: (context, settiState) {
            return Container(
                height: 200,
                decoration: BoxDecoration(
                  color: FORGROUND_COLOR,
                  borderRadius:const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                margin: const EdgeInsets.only(top: 10),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Row(children: [
                        const Spacer(),
                        GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child:const Text(
                              "完了",
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontSize:15),
                            )),
                        const SizedBox(width: 10)
                      ]),
                      Row(children: [
                        ElevatedButton(
                            onPressed: () async {
                              DateTime now = DateTime.now();
                              await DatePicker.showTimePicker(context,
                                  showTitleActions: true,
                                  showSecondsColumn: false, onConfirm: (date) {
                                timeStartController =
                                    DateFormat("HH:mm").format(date);

                              },
                                  currentTime: DateTime(
                                      now.year, now.month, now.day, 12, 00),
                                  locale: LocaleType.jp);
                              settiState(() {});
                            },
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all<Color?>(
                                  Colors.blueAccent),
                            ),
                            child: const Text("+ 開始時刻",
                                style: TextStyle(color: Colors.white))),
                        timeInputPreview(timeStartController),
                        IconButton(
                            onPressed: () {
                              timeStartController = "";
                              settiState(() {});
                            },
                            icon: const Icon(Icons.delete))
                      ]),
                      Row(children: [
                        ElevatedButton(
                            onPressed: () async {
                              DateTime now = DateTime.now();
                              await DatePicker.showTimePicker(context,
                                  showTitleActions: true,
                                  showSecondsColumn: false, onConfirm: (date) {
                                timeEndController =
                                    DateFormat("HH:mm").format(date);
                              },
                                  currentTime: DateTime(
                                      now.year, now.month, now.day, 12, 00),
                                  locale: LocaleType.jp);
                              settiState(() {});
                            },
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all<Color?>(
                                  Colors.blueAccent),
                            ),
                            child: const Text("+ 終了時刻",
                                style: TextStyle(color: Colors.white))),
                        timeInputPreview(timeEndController),
                        IconButton(
                            onPressed: () {
                                timeEndController = "";
                              settiState(() {});
                            },
                            icon: const Icon(Icons.delete))
                      ]),
                    ],
                  ),
                ));
          });
        });

        onSelected(timeStartController,timeEndController);
  }


  Widget timeInputPreview(String text) {
    String previewText = "なし";
    if (text != "") {
      previewText = text;
    }

    return Expanded(
        child: Center(
            child: Text(
      previewText,
      style: const TextStyle(
          color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 20),
      overflow: TextOverflow.visible,
    )));
  }

  bool isValid(List<Schedule> scheduleList,ref){
    bool _isValid = true;
    for(var schedule in scheduleList){
      if(isConflict(
        schedule.startTime ?? "",
        schedule.endTime ?? "",
        schedule.tagID ?? "",
        ref)){
        _isValid = false;
      }
      if(schedule.startDate == "" || schedule.startDate == null){
        _isValid = false;
      }
    }
    return _isValid;
  }

  bool isConflict(String start, String end, String tagId, WidgetRef ref) {
    errorCause = "";
    if (returnTagIsBeit(
                returnTagId(ref.watch(scheduleFormProvider).tagController.text,
                        ref) ??
                    "",
                ref) ==
            1 &&
        (start == "" || end == "")) {
      errorCause = "*開始時間と終了時間の両方を入力してください。";
      return true;
    } else if (end == "") {
      return false;
    } else if (start == "" && end != "") {
      errorCause = "*開始時間を入力してください。";
      return true;
    } else {
      Duration startTime = Duration(
          hours: int.parse(start.substring(0, 2)),
          minutes: int.parse(start.substring(3, 5)));
      Duration endTime = Duration(
          hours: int.parse(end.substring(0, 2)),
          minutes: int.parse(end.substring(3, 5)));

      if (startTime >= endTime) {
        errorCause = "*開始時間を終了時間より前にしてください。";
        return true;
      } else {
        return false;
      }
    }
  }

  Widget tagEditButton(ref,context,String? tagIDController,Function(String) onSelected,StateSetter setState) {

    Widget tagObject = Container(
      height: 25,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.only(right: 15, left: 5),
      child:const Row(children: [
        Icon(CupertinoIcons.tag_fill,color:Colors.blue,size: 18,),
        Text(
          " タグを追加…",
          style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.normal,
              fontSize: 15,
              overflow: TextOverflow.ellipsis),
        ),
      ]),
    );

    if (tagIDController != "" && tagIDController != null) {
      tagObject = tagChip(tagIDController, ref);
    }

    return GestureDetector(
        onTap: () async {
          tagIDController = await showTagDialogue(ref, context,setState);
          onSelected(tagIDController ?? "");
          setState((){});
        },
        child: tagObject);
  }

}

class Schedule{
  int? id;
  String subject;
  String? startDate;
  String? startTime;
  String? endDate = "";
  String? endTime;
  int? isPublic = 0;
  String? publicSubject = "";
  String? tag;
  String? tagID;

  Schedule(
    {
      this.id,
      required this.subject,
      required this.startDate,
      required this.startTime,
      this.endDate,
      required this.endTime,
      this.isPublic,
      this.publicSubject,
      this.tag,
      this.tagID,
    }
  );

  Map<String,dynamic> toMap(){
    return {
      "subject": subject,
      "startDate":startDate,
      "startTime":startTime,
      "endDate":endDate,
      "endTime": endTime,
      "isPublic": isPublic,
      "publicSubject": publicSubject,
      "tag": tag,
      "tagID": tagID,
    };
  }

}