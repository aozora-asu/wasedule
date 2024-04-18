import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_calandar_app/backend/DB/handler/schedule_db_handler.dart';
import 'package:flutter_calandar_app/frontend/screens/common/tutorials.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/add_event_button.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/add_template_button.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/calendar_page.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/calendar_data_manager.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/tag_and_template_page.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/time_input_page.dart';
import 'package:flutter_calandar_app/frontend/screens/menu_pages/arbeit_stats_page.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../backend/DB/models/task.dart';
import '../../../backend/DB/handler/task_db_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/task_data_manager.dart';

Future<void> registeTaskToDB(Map<String, dynamic> task) async {
  TaskItem taskItem;
  taskItem = TaskItem(
      uid: null,
      title: task["title"],
      dtEnd: task["dtEnd"],
      isDone: 0,
      summary: task["summary"],
      description: task["description"]);
  await TaskDatabaseHelper().insertTask(taskItem);
}

final inputFormProvider = StateNotifierProvider<InputFormNotifier, InputForm>(
  (ref) => InputFormNotifier(),
);

class InputFormNotifier extends StateNotifier<InputForm> {
  InputFormNotifier() : super(InputForm());

  void updateDateTimeFields() {
    state = state.copyWith();
  }
}

class InputForm {
  TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController summaryController = TextEditingController();
  final TextEditingController dtEndController = TextEditingController();

  InputForm copyWith({
    String? titleController,
    String? descriptionController,
    String? summaryController,
    String? dtEndController,
  }) {
    return InputForm()
      ..titleController.text = titleController ?? this.titleController.text
      ..descriptionController.text =
          descriptionController ?? this.descriptionController.text
      ..summaryController.text =
          summaryController ?? this.summaryController.text
      ..dtEndController.text = dtEndController ?? this.dtEndController.text;
  }

  void clearContents() {
    titleController.clear();
    descriptionController.clear();
    dtEndController.clear();
    summaryController.clear();
  }
}

class DailyViewPage extends ConsumerStatefulWidget {
  DateTime target;

  DailyViewPage({required this.target});

  @override
  DailyViewPageState createState() => DailyViewPageState();
}

class DailyViewPageState extends ConsumerState<DailyViewPage> {
  @override
  Widget build(BuildContext context) {
    ref.watch(taskDataProvider);
    return GestureDetector(
      child: Center(child: pageBody()),
      onTap: () {
        Navigator.pop(context);
      },
    );
  }

  Widget pageBody() {
    return SingleChildScrollView(
        child: Padding(
      padding: const EdgeInsets.only(left: 5, right: 5, top: 40),
      child: Column(children: [
        Container(
            decoration: roundedBoxdecorationWithShadow(),
            child: Column(children: [
              Container(
                height: 40,
                color: Colors.redAccent,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 10),
                    calendarIcon(Colors.white, 25),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          " " +
                              widget.target.year.toString() +
                              "/" +
                              widget.target.month.toString(),
                          style: TextStyle(
                              fontSize: SizeConfig.blockSizeHorizontal! * 6,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ))
                  ],
                ),
              ),
              Row(
                children: [
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        " " +
                            widget.target.day
                                .toString(), //+ weekDayEng(widget.target.weekday),
                        style: TextStyle(
                            fontSize: SizeConfig.blockSizeHorizontal! * 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.black),
                      )),
                  const Spacer(),
                  ElevatedButton(
                      onPressed: () async {
                        await addEmptyData();
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        backgroundColor: Colors.redAccent,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                      )),
                ],
              ),
              SizedBox(
                width: SizeConfig.blockSizeHorizontal! * 90,
                child: listView(),
              ),
              SizedBox(
                width: SizeConfig.blockSizeHorizontal! * 90,
                height: SizeConfig.blockSizeHorizontal! * 2,
              ),
            ])),
        const SizedBox(height: 50),
        Container(
            decoration: roundedBoxdecorationWithShadow(),
            child: Column(children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Row(children: [
                  SizedBox(width: SizeConfig.blockSizeHorizontal! * 4),
                  taskIcon(Colors.grey, 25),
                  SizedBox(width: SizeConfig.blockSizeHorizontal! * 1),
                  Text(
                    'この日が期限の課題',
                    style: TextStyle(
                        fontSize: SizeConfig.blockSizeHorizontal! * 7,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: SizeConfig.blockSizeHorizontal! * 2),
                  taskListLength(24.0),
                ]),
              ),
              const Divider(
                height: 1,
              ),
              SizedBox(height: SizeConfig.blockSizeVertical! * 1.5),
              taskDataList(),
            ]))
      ]),
    ));
  }

  Widget listView() {
    final taskData = ref.read(taskDataProvider);
    final data = ref.read(calendarDataProvider);
    ref.watch(calendarDataProvider);
    String targetKey = widget.target.year.toString() +
        "-" +
        widget.target.month.toString().padLeft(2, "0") +
        "-" +
        widget.target.day.toString().padLeft(2, "0");

    if (data.sortedDataByDay[targetKey] == null) {
      return GestureDetector(
          onTap: () async {
            await addEmptyData();
          },
          child: Column(children: [
            const Divider(
              height: 2,
              thickness: 2,
            ),
            SizedBox(
              height: SizeConfig.blockSizeHorizontal! * 8,
            ),
            const Text(
              "予定はありません。",
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
            SizedBox(
              height: SizeConfig.blockSizeHorizontal! * 5,
            ),
          ]));
    } else {
      List targetDayData = data.sortedDataByDay[targetKey];
      return ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          Widget dateTimeData = Container();
          if (targetDayData.elementAt(index)["startTime"].trim() != "" &&
              targetDayData.elementAt(index)["endTime"].trim() != "") {
            dateTimeData = Text(
              targetDayData.elementAt(index)["startTime"] +
                  "～" +
                  targetDayData.elementAt(index)["endTime"],
              style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            );
          } else if (targetDayData.elementAt(index)["startTime"].trim() != "") {
            dateTimeData = Text(
              targetDayData.elementAt(index)["startTime"],
              style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            );
          } else {
            dateTimeData = const Text(
              "終日",
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            );
          }

          return Column(children: [
            const Divider(
              height: 2,
              thickness: 2,
            ),
            Container(
                width: SizeConfig.blockSizeHorizontal! * 95,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const SizedBox(
                          width: 10,
                        ),
                        dateTimeData,
                        const SizedBox(width: 15, height: 40),
                        tagChip(
                            targetDayData.elementAt(index)["tagID"] ?? "", ref),
                        const Spacer(),
                      ]),
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                width: SizeConfig.blockSizeHorizontal! * 75,
                                child: Text(
                                  data.sortedDataByDay[targetKey]
                                      .elementAt(index)["subject"],
                                  overflow: TextOverflow.clip,
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold),
                                )),
                            const Spacer(),
                            PopupMenuButton(
                              icon: const Icon(Icons.edit, color: Colors.grey),
                              itemBuilder: (BuildContext context) {
                                return [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(children: [
                                      Icon(
                                        Icons.edit,
                                      ),
                                      SizedBox(width: 15),
                                      Text('編集')
                                    ]),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(children: [
                                      Icon(
                                        Icons.delete,
                                      ),
                                      SizedBox(width: 15),
                                      Text('削除')
                                    ]),
                                  ),
                                  PopupMenuItem(
                                    enabled: isPanelEnable(data
                                            .sortedDataByDay[targetKey]
                                            .elementAt(index)["tagID"]),
                                    value: 'deleteAll',
                                    child:const Row(children: [
                                      Icon(
                                        Icons.tag,
                                      ),
                                      SizedBox(width: 5),
                                      Text('一括削除')
                                    ]),
                                  ),
                                ];
                              },
                              onSelected: (value) async {
                                if (value == "edit") {
                                  inittodaiarogu(data.sortedDataByDay[targetKey]
                                      .elementAt(index));
                                  _showTextDialog(
                                      context,
                                      data.sortedDataByDay[targetKey]
                                          .elementAt(index),
                                      "予定の編集…");
                                } else if (value == "delete") {
                                  showDeleteDialogue(
                                      context,
                                      data.sortedDataByDay[targetKey]
                                          .elementAt(index)["subject"],
                                      () async {
                                    await ScheduleDatabaseHelper()
                                        .deleteSchedule(data
                                            .sortedDataByDay[targetKey]
                                            .elementAt(index)["id"]);
                                    ref.read(taskDataProvider).isRenewed = true;
                                    ref
                                        .read(calendarDataProvider.notifier)
                                        .state = CalendarData();
                                    while (
                                        ref.read(taskDataProvider).isRenewed !=
                                            false) {
                                      await Future.delayed(
                                          const Duration(microseconds: 1));
                                    }
                                    setState(() {});
                                  });
                                } else if(value == "deleteAll"){
                                  showDeleteDialogue(
                                    context,
                                    "タグ「" + returnTagTitle(data.sortedDataByDay[targetKey]
                                          .elementAt(index)["tagID"],ref)
                                    + "」が紐づいているすべての予定",
                                    () async {
                                      await deleteAllScheduleWithTag(data
                                                .sortedDataByDay[targetKey]
                                                .elementAt(index)["tagID"], ref, setState);
                                      setState(() {});
                                    }
                                  );
                      }
                    },
                  ),
                ])
              ])
            ),
          ]);
        },
        itemCount: data.sortedDataByDay[targetKey].length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
      );
    }
  }

  Future<void> addEmptyData() async {
    String startDate = DateFormat('yyyy-MM-dd').format(widget.target);
    Map<String, dynamic> schedule = {
      "subject": "",
      "startDate": startDate,
      "startTime": "",
      "endDate": startDate,
      "endTime": "",
      "isPublic": 1,
      "publicSubject": "",
      "tag": "",
      //★ "tagID" : ""
    };
    await ScheduleDatabaseHelper().resisterScheduleToDB(schedule);

    ref.read(scheduleFormProvider).clearContents();

    ref.read(calendarDataProvider.notifier).state = CalendarData();
    ref.read(taskDataProvider).isRenewed = true;
    while (ref.read(taskDataProvider).isRenewed != false) {
      await Future.delayed(const Duration(milliseconds: 1));
    }
    setState(() {});
    final data = ref.read(calendarDataProvider);
    List dateData = data.sortedDataByDay[startDate];

    inittodaiarogu(data.calendarData.last);
    _showTextDialog(context, data.calendarData.last, "予定の追加…");
  }

  String weekDay(weekday) {
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

  String weekDayEng(weekday) {
    String dayOfWeek = '';
    switch (weekday) {
      case 1:
        dayOfWeek = 'Mon.';
        break;
      case 2:
        dayOfWeek = 'Tue.';
        break;
      case 3:
        dayOfWeek = 'Wed.';
        break;
      case 4:
        dayOfWeek = 'Thu.';
        break;
      case 5:
        dayOfWeek = 'Fri.';
        break;
      case 6:
        dayOfWeek = 'Sat.';
        break;
      case 7:
        dayOfWeek = 'Sun.';
        break;
    }
    return dayOfWeek;
  }

  Widget taskListLength(fontSize) {
    final taskData = ref.watch(taskDataProvider);
    Map<DateTime, List<Map<String, dynamic>>> sortedData =
        taskData.sortDataByDtEnd(taskData.taskDataList);
    return Container(
        decoration: const BoxDecoration(
          color: Colors.redAccent,
          shape: BoxShape.circle,
        ),
        padding: EdgeInsets.all(fontSize / 3),
        child: Text(
          (sortedData[widget.target]?.length ?? 0).toString(),
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: fontSize),
        ));
  }

  Widget taskDataList() {
    final taskData = ref.watch(taskDataProvider);
    Map<DateTime, List<Map<String, dynamic>>> sortedData =
        taskData.sortDataByDtEnd(taskData.taskDataList);

    if (sortedData.keys.contains(widget.target)) {
      return ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          Widget dateTimeData = Container();
          dateTimeData = Text(
            sortedData[widget.target]!.elementAt(index)["title"],
            style: const TextStyle(
                color: Colors.grey, fontSize: 15, fontWeight: FontWeight.bold),
          );
          DateTime dtEnd = DateTime.fromMillisecondsSinceEpoch(
              sortedData[widget.target]!.elementAt(index)["dtEnd"]);

          return Column(children: [
            Row(children: [
              const Spacer(),
              Text(
                dtEnd.hour.toString().padLeft(2, "0") +
                    ":" +
                    dtEnd.minute.toString().padLeft(2, "0"),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const Spacer(),
              Container(
                width: SizeConfig.blockSizeHorizontal! * 80,
                padding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sortedData[widget.target]!
                                .elementAt(index)["summary"] ??
                            "(詳細なし)",
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      dateTimeData,
                    ]),
              ),
              const Spacer(),
            ]),
            const SizedBox(height: 15)
          ]);
        },
        itemCount: sortedData[widget.target]!.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
      );
    } else {
      return Column(children: [
        SizedBox(
          height: SizeConfig.blockSizeHorizontal! * 4,
        ),
        const Text(
          "課題はありません。",
          style: TextStyle(fontSize: 20, color: Colors.grey),
        ),
        SizedBox(
          height: SizeConfig.blockSizeHorizontal! * 6,
        ),
      ]);
    }
  }

  void inittodaiarogu(Map targetData) {
    final provider = ref.watch(scheduleFormProvider);
    ref.read(scheduleFormProvider).clearContents();
    provider.timeStartController.text = targetData["startTime"];
    provider.timeEndController.text = targetData["endTime"];
    provider.tagController.text = targetData["tag"] ?? "";
    provider.isPublic = izuPabu(targetData["isPublic"]);
  }

  bool izuPabu(int izuPab) {
    if (izuPab == 0) {
      return false;
    } else {
      return true;
    }
  }

  String errorCause = "";

  Future<void> _showTextDialog(
      BuildContext context, Map targetData, String title) async {
    final provider = ref.watch(scheduleFormProvider);
    TextEditingController titlecontroller = TextEditingController();
    titlecontroller.text = targetData["subject"];
    dynamic dtStartcontroller = targetData["startDate"];

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        ref.watch(scheduleFormProvider.notifier);
        return AlertDialog(
          title: Text(title),
          actions: <Widget>[
            StatefulBuilder(
              builder: (BuildContext context, StateSetter setoState) {
                ref.watch(scheduleFormProvider.notifier);

                String tagcontroller = targetData["tag"] ?? "";

                return Column(children: [
                  TextField(
                    controller: titlecontroller,
                    decoration: const InputDecoration(
                        labelText: '予定', border: OutlineInputBorder()),
                  ),
                  templateEmptyFlag(
                      ref,
                      Column(children: [
                        SizedBox(
                          width: SizeConfig.blockSizeHorizontal! * 80,
                          height: SizeConfig.blockSizeVertical! * 0.5,
                        ),
                        addTemplateButton(setoState, titlecontroller),
                        SizedBox(
                          width: SizeConfig.blockSizeHorizontal! * 80,
                          height: SizeConfig.blockSizeVertical! * 0.5,
                        ),
                      ])),
                  Row(children: [
                    ElevatedButton(
                        onPressed: () async {
                          dtStartcontroller = await _selectDateMultipul(
                                  context, dtStartcontroller, setState) ??
                              dtStartcontroller;
                          setoState(() {});
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color?>(ACCENT_COLOR),
                        ),
                        child: const Text(" + 日付       ",
                            style: TextStyle(color: Colors.white))),
                    timeInputPreview(dtStartcontroller)
                  ]),
                  Row(children: [
                    ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => TimeInputPage(
                                      target: widget.target,
                                      inputCategory: "startTime",
                                      setState: setoState,
                                    )),
                          );
                          setState(() {});
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color?>(ACCENT_COLOR),
                        ),
                        child: const Text("+ 開始時刻",
                            style: TextStyle(color: Colors.white))),
                    timeInputPreview(provider.timeStartController.text)
                  ]),
                  Row(children: [
                    ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => TimeInputPage(
                                      target: widget.target,
                                      inputCategory: "endTime",
                                      setState: setoState,
                                    )),
                          );
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color?>(ACCENT_COLOR),
                        ),
                        child: const Text("+ 終了時刻",
                            style: TextStyle(color: Colors.white))),
                    timeInputPreview(provider.timeEndController.text)
                  ]),
                  tagEmptyFlag(
                    ref,
                    Row(children: [
                      ElevatedButton(
                          onPressed: () {
                            showTagDialogue(ref, context, setoState);
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color?>(ACCENT_COLOR),
                          ),
                          child: const Text("+    タグ     ",
                              style: TextStyle(color: Colors.white))),
                      timeInputPreview(
                          returnTagData(provider.tagController.text, ref))
                    ]),
                  ),
                  Row(children: [
                    ElevatedButton(
                        onPressed: () {
                          setoState(() {
                            if (provider.isPublic) {
                              provider.isPublic = false;
                            } else {
                              provider.isPublic = true;
                            }
                          });
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color?>(ACCENT_COLOR),
                        ),
                        child: const Text("共有時表示",
                            style: TextStyle(color: Colors.white))),
                    isPublicPreview(provider.isPublic),
                  ]),
                ]);
              },
            ),

            const SizedBox(height: 50),

            // TextButton(
            //   onPressed: () async{
            //     if(isConflict(provider.timeStartController.text,provider.timeEndController.text)){
            //       print("ボタン無効");
            //     }else{
            //       bool boolIsPublic = false;
            //       if(targetData["isPublic"] == 1){boolIsPublic = true;}

            //       Map<String,dynamic>newMap = {};
            //       newMap["subject"] = titlecontroller.text;
            //       newMap["startDate"] = dtStartcontroller;
            //       newMap["startTime"] = provider.timeStartController.text;
            //       newMap["endDate"] = dtStartcontroller;
            //       newMap["endTime"] = provider.timeEndController.text;
            //       newMap["isPublic"] = provider.isPublic;
            //       newMap["publicSubject"] = targetData["publicSubject"];
            //       newMap["tag"] = provider.tagController.text;
            //       newMap["id"] = targetData["id"];
            //       await ScheduleDatabaseHelper().updateSchedule(newMap);
            //       ref.read(taskDataProvider).isRenewed = true;
            //       ref.read(calendarDataProvider.notifier).state = CalendarData();
            //       while (ref.read(taskDataProvider).isRenewed != false) {
            //         await Future.delayed(const Duration(microseconds:1));
            //       }
            //       setState((){});
            //       Navigator.pop(context);
            //       if(ref.read(calendarDataProvider).calendarData.last["id"] == 1){
            //         showTagAndTemplateGuide(context);
            //       }
            //     }
            //   },
            //   child: const Text('登録'),
            // ),

            ElevatedButton(
              onPressed: () async {
                if (isConflict(provider.timeStartController.text,
                    provider.timeEndController.text)) {
                  print("ボタン無効");
                } else {
                  Map<String, dynamic> newMap = {};
                  newMap["subject"] = titlecontroller.text;
                  newMap["startDate"] = dtStartcontroller;
                  newMap["startTime"] = provider.timeStartController.text;
                  newMap["endDate"] = dtStartcontroller;
                  newMap["endTime"] = provider.timeEndController.text;
                  newMap["isPublic"] = provider.isPublic;
                  newMap["publicSubject"] = targetData["publicSubject"];
                  newMap["tag"] = provider.tagController.text;
                  newMap["id"] = targetData["id"];

                  newMap["tagID"] =
                      returnTagId(provider.tagController.text, ref);

                  await ScheduleDatabaseHelper().updateSchedule(newMap);
                  ref.read(taskDataProvider).isRenewed = true;
                  ref.read(calendarDataProvider.notifier).state =
                      CalendarData();
                  while (ref.read(taskDataProvider).isRenewed != false) {
                    await Future.delayed(const Duration(microseconds: 1));
                  }
                  setState(() {});
                  Navigator.pop(context);
                  if (ref.read(calendarDataProvider).calendarData.last["id"] ==
                      1) {
                    showTagAndTemplateGuide(context);
                  }
                }
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                  if (isConflict(provider.timeStartController.text,
                      provider.timeEndController.text)) {
                    print("ボタン無効");
                    return Colors.grey; // ボタンが無効の場合の色
                  } else {
                    return MAIN_COLOR; // ボタンが通常の場合の色
                  }
                }),
                fixedSize: MaterialStateProperty.all<Size>(Size(
                  SizeConfig.blockSizeHorizontal! * 100,
                  SizeConfig.blockSizeHorizontal! * 7.5,
                )),
              ),
              child: const Text('登録', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget addTemplateButton(
      StateSetter setosute, TextEditingController titleController) {
    return ElevatedButton(
      onPressed: () {
        showTemplateDialogue(setosute, titleController);
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color?>(ACCENT_COLOR),
      ),
      child: const Row(children: [
        Spacer(),
        Icon(Icons.add, color: Colors.white),
        SizedBox(width: 10),
        Text('テンプレート', style: TextStyle(color: Colors.white)),
        Spacer(),
      ]),
    );
  }

  bool isConflict(String start, String end) {
    errorCause = "";
    if (returnTagIsBeit(
                returnTagId(ref.watch(scheduleFormProvider).tagController.text,ref) ?? "", ref) ==
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
        errorCause = "*開始時を終了時間より前にしてください。";
        return true;
      } else {
        return false;
      }
    }
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

  Widget isPublicPreview(bool isPublic) {
    String previewText = "表示しない";
    if (isPublic) {
      previewText = "表示する";
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

  Future<String?> _selectDateMultipul(
      BuildContext context, String controller, StateSetter setState) async {
    Completer<String?> completer = Completer<String?>();
    await showDialog(
        context: context,
        builder: (_) {
          return SimpleDialog(
            contentPadding: const EdgeInsets.all(0.0),
            titlePadding: const EdgeInsets.all(0.0),
            title: SizedBox(
              height: 400,
              child: Scaffold(
                body: SizedBox(
                  child: SfDateRangePicker(
                    headerHeight: 60,
                    todayHighlightColor: MAIN_COLOR,
                    selectionColor: MAIN_COLOR,
                    headerStyle: const DateRangePickerHeaderStyle(
                        backgroundColor: MAIN_COLOR,
                        textStyle: TextStyle(color: Colors.white)),
                    view: DateRangePickerView.month,
                    initialSelectedDate: DateTime.now(),
                    selectionMode: DateRangePickerSelectionMode.single,
                    allowViewNavigation: true,
                    navigationMode: DateRangePickerNavigationMode.snap,
                    showNavigationArrow: true,
                    showActionButtons: true,
                    onSubmit: (dynamic value) {
                      String result = DateFormat('yyyy-MM-dd').format(value);
                      completer.complete(result);
                      Navigator.pop(context);
                    },
                    onCancel: () {
                      completer.complete(null);
                      Navigator.pop(context);
                    },
                    confirmText: "ＯＫ",
                    cancelText: "戻る",
                  ),
                ),
              ),
            ),
          );
        });
    return completer.future;
  }

  Future<void> showTemplateDialogue(
      StateSetter setosute, TextEditingController titleController) async {
    final data = ref.read(calendarDataProvider);
    List tempLateMap = data.templateData;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("テンプレート選択"),
          actions: [
            SizedBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "テンプレート:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    width: double.maxFinite,
                    height: listViewHeight(50, tempLateMap.length),
                    child: ListView.separated(
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 5),
                      itemCount: tempLateMap.length,
                      itemBuilder: (BuildContext context, index) => InkWell(
                        onTap: () async {
                          final inputform = ref.watch(scheduleFormProvider);
                          inputform.scheduleController.text =
                              data.templateData.elementAt(index)["subject"];
                          titleController.text =
                              data.templateData.elementAt(index)["subject"];
                          inputform.timeStartController.text =
                              data.templateData.elementAt(index)["startTime"];
                          inputform.timeEndController.text =
                              data.templateData.elementAt(index)["endTime"];
                          inputform.tagController.text =
                              data.templateData.elementAt(index)["tag"];
                          setosute(() {});

                          Navigator.pop(context);
                        },
                        child: Container(
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                timedata(index),
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.white),
                              ),
                              Text(
                                "  " +
                                    ref
                                        .read(calendarDataProvider)
                                        .templateData
                                        .elementAt(index)["subject"],
                                style: const TextStyle(
                                    fontSize: 20, color: Colors.white),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 1700,
                    child: ElevatedButton(
                      style: const ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll(Colors.blueAccent)),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                TemplateInputForm(setosute: setosute),
                          ),
                        );
                      },
                      child: const Text(
                        "+ テンプレートを追加…",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String timedata(index) {
    if (ref
                .read(calendarDataProvider)
                .templateData
                .elementAt(index)["startTime"] ==
            "" &&
        ref
                .read(calendarDataProvider)
                .templateData
                .elementAt(index)["endTime"] ==
            "") {
      return "      終日";
    } else {
      return "      " +
          ref
              .read(calendarDataProvider)
              .templateData
              .elementAt(index)["startTime"] +
          " ～ " +
          ref
              .read(calendarDataProvider)
              .templateData
              .elementAt(index)["endTime"];
    }
  }
}

Future<void> deleteAllScheduleWithTag(String tagID, WidgetRef ref, StateSetter setState)async{
  List allData = ref.read(calendarDataProvider).calendarData;
  for(int i = 0; i < allData.length; i++){
    if(allData.elementAt(i)["tagID"] == tagID){
        await ScheduleDatabaseHelper()
          .deleteSchedule(allData.elementAt(i)["id"]);
      }
    }
      ref.read(taskDataProvider).isRenewed = true;
      ref.read(calendarDataProvider.notifier).state = CalendarData();
      while (
          ref.read(taskDataProvider).isRenewed !=
              false) {
      await Future.delayed(
          const Duration(microseconds: 1));
      setState((){});
  }
}

bool isPanelEnable(String? tagID){
  if(tagID == null || tagID == ""){
    return false;
  }else{
    return true;
  }
}