import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/handler/schedule_db_handler.dart';
import 'package:flutter_calandar_app/frontend/assist_files/data_loader.dart';
import 'package:flutter_calandar_app/frontend/screens/common/ui_components.dart';
import 'package:flutter_calandar_app/frontend/screens/common/attendance_dialog.dart';
import 'package:flutter_calandar_app/frontend/screens/common/tutorials.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/add_event_dialog.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/add_template_dialog.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/calendar_page.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/calendar_data_manager.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/tag_and_template_page.dart';
import 'package:flutter_calandar_app/frontend/screens/timetable_page/timetable/course_preview.dart';
import 'package:flutter_calandar_app/frontend/screens/timetable_page/timetable/timetable_data_manager.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';

import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/task_data_manager.dart';
import "../../../static/constant.dart";
import "../../../backend/DB/handler/my_course_db.dart";

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

  DailyViewPage({super.key, required this.target});

  @override
  DailyViewPageState createState() => DailyViewPageState();
}

class DailyViewPageState extends ConsumerState<DailyViewPage> {
  @override
  Widget build(BuildContext context) {
    final bottomSpace = MediaQuery.of(context).viewInsets.bottom;
    ref.watch(taskDataProvider);
    return GestureDetector(onTap: () async {
      if (editingSchedule == null) {
        Navigator.pop(context);
      } else {
        if (isEdited) {
          bool isLeave = await showConfirmExitDialogue(context);
          if (isLeave) {
            setState(() {
              editingSchedule = null;
              isEdited = false;
            });
          }
        } else {
          setState(() {
            editingSchedule = null;
            isEdited = false;
          });
        }
      }
    }, child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
      return SingleChildScrollView(
          reverse: true,
          child: Padding(
              padding: EdgeInsets.only(bottom: bottomSpace / 2),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    minHeight: viewportConstraints.maxHeight,
                    maxHeight: viewportConstraints.maxHeight),
                child: Center(child: pageBody()),
              )));
    }));
  }

  Widget pageBody() {
    return SingleChildScrollView(
        child: Padding(
      padding: const EdgeInsets.only(left: 5, right: 5, top: 40),
      child: Column(children: [
        Container(
            decoration: roundedBoxdecoration(),
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
                          " ${widget.target.year}/${widget.target.month}",
                          style: const TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        )),
                    const Spacer(),
                    buttonModel(() {
                      showAttendanceDialog(context, widget.target, ref, true);
                    }, MAIN_COLOR, "この日の出欠記録",
                        verticalpadding: 5, horizontalPadding: 15),
                    const SizedBox(width: 5)
                  ],
                ),
              ),
              Row(
                children: [
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        " ${widget.target.day}", //+ weekDayEng(widget.target.weekday),
                        style: const TextStyle(
                            fontSize: 60,
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                //width: SizeConfig.blockSizeHorizontal! * 90,
                child: listView(),
              ),
              SizedBox(
                width: SizeConfig.blockSizeHorizontal! * 90,
                height: 10,
              ),
            ])),
        const SizedBox(height: 10),
        const SizedBox(height: 10),
        Container(
            decoration: BoxDecoration(
                color: BACKGROUND_COLOR,
                borderRadius: BorderRadius.circular(30)),
            child: Column(children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Row(children: [
                  SizedBox(width: SizeConfig.blockSizeHorizontal! * 4),
                  taskIcon(Colors.grey, 25),
                  SizedBox(width: SizeConfig.blockSizeHorizontal! * 1),
                  const Text(
                    'この日が期限の課題',
                    style: TextStyle(
                        fontSize: 25,
                        color: BLUEGREY,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: SizeConfig.blockSizeHorizontal! * 2),
                  taskListLength(23.0),
                ]),
              ),
              SizedBox(height: SizeConfig.blockSizeVertical! * 1.5),
              taskDataList(),
            ]))
      ]),
    ));
  }

  int? editingSchedule;

  Widget listView() {
    final tableData = ref.read(timeTableProvider);
    final data = ref.read(calendarDataProvider);
    ref.watch(calendarDataProvider);
    String targetKey =
        "${widget.target.year}-${widget.target.month.toString().padLeft(2, "0")}-${widget.target.day.toString().padLeft(2, "0")}";
    List<MyCourse> targetDayList = tableData.targetDateClasses(widget.target);


    if (data.sortedDataByDay[targetKey] == null &&
        targetDayList.isEmpty) {
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
      return scheduleListBody(targetKey);
    }
  }

  Widget scheduleListBody(targetKey) {
    final data = ref.read(calendarDataProvider);
    List targetDayData = data.sortedDataByDay[targetKey] ?? [];
    List<Map<DateTime, Widget>> mixedDataByTime = [];

    //まずは予定データの生成
    for (int index = 0; index < targetDayData.length; index++) {
      DateTime key = DateFormat("HH:mm").parse("00:00");
      if (targetDayData.elementAt(index)["startTime"].trim() != "") {
        key = DateFormat("HH:mm")
            .parse(targetDayData.elementAt(index)["startTime"]);
      }
      Widget value = const SizedBox();
      TextStyle dateTimeStyle = const TextStyle(
          color: Colors.grey, fontSize: 15, fontWeight: FontWeight.bold);
      if (targetDayData.elementAt(index)["id"] == editingSchedule) {
        dateTimeStyle = const TextStyle(
            color: Colors.black, fontSize: 15, fontWeight: FontWeight.normal);
      }

      Widget dateTimeData = Container();
      if (targetDayData.elementAt(index)["startTime"].trim() != "" &&
          targetDayData.elementAt(index)["endTime"].trim() != "") {
        dateTimeData = Text(
            targetDayData.elementAt(index)["startTime"] +
                "～" +
                targetDayData.elementAt(index)["endTime"],
            style: dateTimeStyle);
      } else if (targetDayData.elementAt(index)["startTime"].trim() != "") {
        dateTimeData = Text(targetDayData.elementAt(index)["startTime"],
            style: dateTimeStyle);
      } else {
        dateTimeData = Text("終日", style: dateTimeStyle);
      }

      if (targetDayData.elementAt(index)["id"] == editingSchedule) {
        value = editModeListChild(targetKey, index);
      } else {
        value = viewModeListChild(targetKey, index, dateTimeData);
      }
      mixedDataByTime.add({key: value});
    }

    //予定データが生成されたところに時間割データを混ぜる
    final timeTable = ref.read(timeTableProvider);
    List<MyCourse> targetDayList = timeTable.targetDateClasses(widget.target);

    for (int i = 0; i < targetDayList.length; i++) {
      MyCourse targetClass = targetDayList.elementAt(i);
      DateTime? key = targetClass.period?.start;

      Widget value = switchWidget(timeTableListChild(targetClass),
          ConfigDataLoader().searchConfigData("timetableInDailyView", ref));
      if (key != null) {
        mixedDataByTime.add({key: value});
      }
    }

    //グチャグチャなデータをソートする
    List<Map<DateTime, dynamic>> sortMapsByFirstKey(
        List<Map<DateTime, dynamic>> list) {
      list.sort((a, b) => a.keys.first.compareTo(b.keys.first));
      return list;
    }

    List<Map<DateTime, dynamic>> sortedList =
        sortMapsByFirstKey(mixedDataByTime);

    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        return sortedList.elementAt(index).values.first;
      },
      itemCount: sortedList.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
    );
  }

  Widget viewModeListChild(targetKey, index, dateTimeData) {
    final data = ref.read(calendarDataProvider);
    List targetDayData = data.sortedDataByDay[targetKey];

    return Column(children: [
      Container(
          decoration:roundedBoxdecoration(radiusType: 2,backgroundColor: BACKGROUND_COLOR),
          margin:const EdgeInsets.symmetric(vertical: 2,horizontal:0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 5),
            Row(children: [
              const SizedBox(
                width: 10,
              ),
              Expanded(
                  child:GestureDetector(
                  onTap: () => switchToEditMode(targetKey, index),
                  child: dateTimeData),
              ),
              Expanded(
                  child:GestureDetector(
                    onTap: () => switchToEditMode(targetKey, index),
                    child: tagChip(
                        targetDayData.elementAt(index)["tagID"] ?? "", ref))
              )
            ]),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              GestureDetector(
                onTap: () => switchToEditMode(targetKey, index),
                child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    width: SizeConfig.blockSizeHorizontal! * 75,
                    child: Text(
                      data.sortedDataByDay[targetKey]
                          .elementAt(index)["subject"],
                      overflow: TextOverflow.clip,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                          fontWeight: FontWeight.bold),
                    )),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => switchToEditMode(targetKey, index),
                child: const Icon(
                  Icons.edit,
                  color: Colors.grey,
                  size: 30,
                ),
              )
            ])
          ])),
    ]);
  }

  void switchToEditMode(targetKey, index) {
    final data = ref.read(calendarDataProvider);
    setState(() {
      isEdited = false;
      editingSchedule = data.sortedDataByDay[targetKey].elementAt(index)["id"];
      initEditDialog(data.sortedDataByDay[targetKey].elementAt(index));
    });
  }

  TextEditingController titleController = TextEditingController();
  String timeStartController = "";
  String timeEndController = "";
  TextEditingController tagController = TextEditingController();
  dynamic tagIDController = "";
  dynamic dtStartController = "";
  bool isPublic = true;
  bool isEdited = false;

  void initEditDialog(Map targetData) {
    if (!isEdited) {
      dtStartController = targetData["startDate"];
      titleController.text = targetData["subject"];
      tagController.text = targetData["tag"] ?? "";
      tagIDController = targetData["tagID"] ?? "";
      timeStartController = targetData["startTime"] ?? "";
      timeEndController = targetData["endTime"] ?? "";
    }
    isPublic = targetData["isPublic"] == 1;
  }

  Widget editModeListChild(targetKey, index) {
    final data = ref.read(calendarDataProvider);
    List targetDayData = data.sortedDataByDay[targetKey];
    ScrollController scrollController = ScrollController();
    String dateStartAndEnd = "終日";

    Widget multipleDeleteButton = const SizedBox();
    if (!isEdited) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      });
    }

    if (targetDayData.elementAt(index)["tagID"] != "" &&
        targetDayData.elementAt(index)["tagID"] != null) {
      multipleDeleteButton = GestureDetector(
          onTap: () {
            showDeleteDialogue(context,
                "タグ「${returnTagTitle(data.sortedDataByDay[targetKey].elementAt(index)["tagID"], ref)}」が紐づいているすべての予定",
                () async {
              await deleteAllScheduleWithTag(
                  targetDayData.elementAt(index)["tagID"], ref, setState);
              isEdited = false;
              editingSchedule = null;
              setState(() {});
            });
          },
          child: const Row(children: [
            Icon(
              Icons.tag,
            ),
            SizedBox(width: 5),
            Text('一括削除'),
            VerticalDivider(color: Colors.blueGrey, width: 20),
          ]));
    }

    Icon buttonIcon = const Icon(
      Icons.cancel,
      color: Colors.grey,
      size: 40,
    );
    if (isEdited) {
      buttonIcon = const Icon(
        Icons.done,
        color: Colors.blue,
        size: 40,
      );
    }

    if (timeStartController != "" && timeEndController != "") {
      dateStartAndEnd = "$timeStartController～$timeEndController";
    } else if (timeStartController != "") {
      dateStartAndEnd = timeStartController;
    }

    return GestureDetector(
        onTap: () {},
        child: Column(children: [
          Container(
              width: SizeConfig.blockSizeHorizontal! * 95,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          timeBottomSheet();
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
                      const SizedBox(width: 15, height: 40),
                      Expanded(
                        child:tagEmptyFlag(ref, tagEditButton(index, targetDayData)),
                      )
                    ]),
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2.5),
                              width: SizeConfig.blockSizeHorizontal! * 75,
                              child: Material(
                                child: TextField(
                                  controller: titleController,
                                  maxLines: null,
                                  textInputAction: TextInputAction.done,
                                  decoration: const InputDecoration(
                                      hintText: "予定名を入力…"),
                                  // overflow: TextOverflow.clip,
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold),
                                  onChanged: (value) {
                                    setState(() {
                                      isEdited = true;
                                    });
                                  },
                                ),
                              )),
                          const Spacer(),
                          GestureDetector(
                              onTap: () async {
                                if (isEdited) {
                                  if (isConflict(
                                      timeStartController, timeEndController)) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          content: Text(errorCause,
                                              style: const TextStyle(
                                                  color: Colors.red)),
                                        );
                                      },
                                    );
                                  } else {
                                    setState(() {
                                      editingSchedule = null;
                                      isEdited = false;
                                    });
                                    Map<String, dynamic> newMap = {};
                                    newMap["subject"] = titleController.text;
                                    newMap["startDate"] = dtStartController;
                                    newMap["startTime"] = timeStartController;
                                    newMap["endDate"] = dtStartController;
                                    newMap["endTime"] = timeEndController;
                                    newMap["isPublic"] = isPublic;
                                    newMap["publicSubject"] =
                                        titleController.text;
                                    newMap["tag"] = tagController.text;
                                    newMap["id"] =
                                        targetDayData.elementAt(index)["id"];
                                    newMap["tagID"] = tagIDController;

                                    await ScheduleDatabaseHelper()
                                        .updateSchedule(newMap);
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
                                    if (ref
                                            .read(calendarDataProvider)
                                            .calendarData
                                            .last["id"] ==
                                        1) {
                                      showTagAndTemplateGuide(context);
                                    }
                                  }
                                } else {
                                  setState(() {
                                    editingSchedule = null;
                                    isEdited = false;
                                  });
                                }
                              },
                              child: buttonIcon)
                        ]),
                    const SizedBox(height: 5),
                    Container(
                      width: SizeConfig.blockSizeHorizontal! * 95,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: BACKGROUND_COLOR,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: SizedBox(
                        height: 35,
                        child: Row(children: [
                          const Icon(Icons.arrow_left, color: Colors.grey),
                          Expanded(
                              child: ListView(
                                  controller: scrollController,
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  children: [
                                containScreenshotButton(),
                                dateSetButton(),
                                templateEmptyFlag(
                                    ref, templateButton(index, targetKey)),
                                backButton(),
                                multipleDeleteButton,
                                singleDeleteButton(index, targetKey),
                              ])),
                          const Icon(Icons.arrow_right, color: Colors.grey),
                        ]),
                      ),
                    ),
                  ])),
          const SizedBox(height: 5)
        ]));
  }

  Widget timeTableListChild(MyCourse classData) {
    final data = ref.read(timeTableProvider);
    Lesson? lesson = classData.period;
    String? startTime =
        lesson != null ? DateFormat("HH:mm").format(lesson.start) : null;
    String? endTime =
        lesson != null ? DateFormat("HH:mm").format(lesson.end) : null;

    return GestureDetector(
        onTap: () async {
         await showModalBottomSheet(
              context: context,
              isDismissible: true,
              isScrollControlled: true,
              backgroundColor: FORGROUND_COLOR,
              builder: (BuildContext context) {
                return CoursePreview(
                  target: classData,
                  setTimetableState: setState,
                  taskList: const [],
                  isOndemand: false,
                );
              });
        },
        child: Column(children: [
          Container(
            decoration:roundedBoxdecoration(radiusType: 2,backgroundColor: BACKGROUND_COLOR),
            margin:const EdgeInsets.symmetric(vertical: 2,horizontal:0),
            padding:const EdgeInsets.symmetric(vertical: 5,horizontal:0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const SizedBox(
                        width: 10,
                      ),
                      Text("$startTime~$endTime",
                          style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                              fontWeight: FontWeight.bold)),
                      const Spacer(),
                      const Icon(Icons.school, color: MAIN_COLOR, size: 20),
                      const SizedBox(
                        width: 10,
                      ),
                      Text("${classData.weekday!.text}曜日の授業",
                          style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12.5,
                              fontWeight: FontWeight.normal)),
                      const SizedBox(
                        width: 10,
                      ),
                    ]),
                    Row(children: [
                      Expanded(
                          child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                classData.courseName,
                                overflow: TextOverflow.clip,
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold),
                              ))),
                      SizedBox(
                        width: 80,
                        child:Text(
                          classData.classRoom,
                          overflow: TextOverflow.clip,
                          style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        )
                      ),
                    ])
                  ])),
        ]));
  }

  Future<void> timeBottomSheet() async {
    await showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        enableDrag: true,
        barrierColor: Colors.black.withOpacity(0.5),
        builder: (context) {
          return StatefulBuilder(builder: (context, settiState) {
            return Container(
                height: SizeConfig.blockSizeVertical! * 25,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
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
                            child: Text(
                              "完了",
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontSize:
                                      SizeConfig.blockSizeHorizontal! * 4.5),
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

                                setState(() {});
                              },
                                  currentTime: DateTime(
                                      now.year, now.month, now.day, 12, 00),
                                  locale: LocaleType.jp);
                              isEdited = true;
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
                              setState(() {
                                timeStartController = "";
                              });
                              isEdited = true;
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

                                setState(() {});
                              },
                                  currentTime: DateTime(
                                      now.year, now.month, now.day, 12, 00),
                                  locale: LocaleType.jp);
                              isEdited = true;
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
                              setState(() {
                                timeEndController = "";
                              });
                              isEdited = true;
                              settiState(() {});
                            },
                            icon: const Icon(Icons.delete))
                      ]),
                    ],
                  ),
                ));
          });
        });
  }

  Widget tagEditButton(index, targetDayData) {
    Widget tagObject = Container(
      height: 25,
      padding: const EdgeInsets.only(right: 15, left: 5),
      child: const Row(children: [
        Icon(CupertinoIcons.tag_fill,color:Colors.blue,size: 20,),
        Text(
          " タグを追加…",
          style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.normal,
              fontSize: 18,
              overflow: TextOverflow.ellipsis),
        ),
      ]),
    );

    if (tagIDController != "" && tagIDController != null) {
      tagObject = tagChip(tagIDController ?? "", ref, editMode: targetDayData.elementAt(index)["id"] == editingSchedule);
    }

    return GestureDetector(
        onTap: () async {
          isEdited = true;
          await showTagDialogue(ref, context, setState);
          tagIDController = returnTagId(
              ref.read(scheduleFormProvider).tagController.text, ref);
          setState(() {});
        },
        child: tagObject);
  }

  Widget containScreenshotButton() {
    final scheduleForm = ref.read(scheduleFormProvider);
    String label = "共有";
    TextDecoration decoration = TextDecoration.lineThrough;
    if (isPublic) {
      label = "共有";
      decoration = TextDecoration.none;
    }

    return GestureDetector(
        onLongPress: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const AlertDialog(
                content: Text("カレンダーのスクリーンショット共有時に、予定を非表示にすることができます。"),
              );
            },
          );
        },
        onTap: () {
          isEdited = true;
          setState(() {
            if (isPublic) {
              isPublic = false;
            } else {
              isPublic = true;
            }
          });
        },
        child: Row(children: [
          const Icon(Icons.camera_alt),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(decoration: decoration)),
          const VerticalDivider(color: Colors.blueGrey, width: 20),
        ]));
  }

  Widget dateSetButton() {
    return GestureDetector(
        onTap: () async {
          dtStartController =
              await _selectDateMultipul(context, dtStartController, setState) ??
                  dtStartController;
          isEdited = true;
          setState(() {});
        },
        child: Row(children: [
          const Icon(Icons.calendar_month),
          const SizedBox(width: 5),
          Text(dtStartController),
          const VerticalDivider(color: Colors.blueGrey, width: 20),
        ]));
  }

  Widget templateButton(index, targetKey) {
    final inputForm = ref.read(inputFormProvider);
    return GestureDetector(
        onTap: () async {
          isEdited = true;
          await showTemplateDialogue(setState, titleController);
          setState(() {});
        },
        child: const Row(children: [
          Icon(Icons.add),
          SizedBox(width: 5),
          Text('テンプレート'),
          VerticalDivider(color: Colors.blueGrey, width: 20),
        ]));
  }

  Widget singleDeleteButton(index, targetKey) {
    final data = ref.read(calendarDataProvider);
    return GestureDetector(
        onTap: () {
          showDeleteDialogue(context,
              data.sortedDataByDay[targetKey].elementAt(index)["subject"],
              () async {
            await ScheduleDatabaseHelper().deleteSchedule(
                data.sortedDataByDay[targetKey].elementAt(index)["id"]);
            ref.read(taskDataProvider).isRenewed = true;
            ref.read(calendarDataProvider.notifier).state = CalendarData();
            while (ref.read(taskDataProvider).isRenewed != false) {
              await Future.delayed(const Duration(microseconds: 1));
            }
            isEdited = false;
            editingSchedule = null;
            setState(() {});
          });
        },
        child: const Row(children: [
          Icon(Icons.delete),
          SizedBox(width: 5),
          Text('削除'),
          SizedBox(width: 10),
        ]));
  }

  Widget backButton() {
    if (isEdited) {
      return GestureDetector(
          onTap: () {
            setState(() {
              editingSchedule = null;
            });
          },
          child: const Row(children: [
            Icon(Icons.cancel),
            SizedBox(width: 5),
            Text("戻る"),
            VerticalDivider(color: Colors.blueGrey, width: 20),
          ]));
    } else {
      return const SizedBox();
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
      "tagID": ""
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
    setState(() {
      isEdited = false;
      editingSchedule = data.calendarData.last["id"];
      initEditDialog(data.calendarData.last);
    });
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
                color: Colors.grey,
                fontSize: 12.5,
                fontWeight: FontWeight.bold),
          );
          DateTime dtEnd = DateTime.fromMillisecondsSinceEpoch(
              sortedData[widget.target]!.elementAt(index)["dtEnd"]);

          return Column(children: [
            Row(children: [
              const Spacer(),
              Text(
                "${dtEnd.hour.toString().padLeft(2, "0")}:${dtEnd.minute.toString().padLeft(2, "0")}",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15, color: BLUEGREY),
              ),
              const Spacer(),
              GestureDetector(
                  onTap: () async {
                    // await bottomSheet(context,sortedData[widget.target]!.elementAt(index),setState);
                    // ref.read(taskDataProvider).isRenewed = true;
                    // ref
                    //     .read(calendarDataProvider.notifier)
                    //     .state = CalendarData();
                    // while (
                    //     ref.read(taskDataProvider).isRenewed !=
                    //         false) {
                    //   await Future.delayed(
                    ///       const Duration(microseconds: 1));
                    // }
                  },
                  child: Container(
                    width: SizeConfig.blockSizeHorizontal! * 80,
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 20),
                    decoration: BoxDecoration(
                        color: FORGROUND_COLOR,
                        borderRadius: BorderRadius.circular(25)),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sortedData[widget.target]!
                                    .elementAt(index)["summary"] ??
                                "(詳細なし)",
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                          dateTimeData,
                        ]),
                  )),
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

  String errorCause = "";
  bool isConflict(String start, String end) {
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
                      setState(() {});
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
    List<Map<String, dynamic>> tempLateList =
        data.templateData as List<Map<String, dynamic>>;

    await showDialog(
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
                    height: listViewHeight(50, tempLateList.length),
                    child: ListView.separated(
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 5),
                      itemCount: tempLateList.length,
                      itemBuilder: (BuildContext context, index) => InkWell(
                        onTap: () async {
                          final inputform = ref.watch(scheduleFormProvider);
                          inputform.scheduleController.text =
                              tempLateList[index]["subject"];
                          titleController.text = tempLateList[index]["subject"];
                          inputform.timeStartController.text =
                              tempLateList[index]["startTime"];
                          inputform.timeEndController.text =
                              tempLateList[index]["endTime"];
                          inputform.tagController.text =
                              tempLateList[index]["tag"];
                          titleController.text = tempLateList[index]["subject"];
                          timeStartController =
                              tempLateList[index]["startTime"];
                          timeEndController = tempLateList[index]["endTime"];
                          tagController.text = tempLateList[index]["tag"];
                          tagIDController = tempLateList[index]["tagID"];
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
                                "    ${tempLateList[index]["subject"]}",
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
                              WidgetStatePropertyAll(Colors.blueAccent)),
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
    String templateStartTime =
        ref.read(calendarDataProvider).templateData[index]["startTime"];
    String templateEndTime =
        ref.read(calendarDataProvider).templateData[index]["endTime"];
    if (templateStartTime == "" && templateEndTime == "") {
      return "      終日";
    } else {
      return "      $templateStartTime ～ $templateEndTime";
    }
  }

  Widget switchWidget(Widget widget, int isVisible) {
    if (isVisible == 1) {
      return Column(children: [widget]);
    } else {
      return const SizedBox();
    }
  }
}

Future<void> deleteAllScheduleWithTag(
    String tagID, WidgetRef ref, StateSetter setState) async {
  List allData = ref.read(calendarDataProvider).calendarData;
  for (int i = 0; i < allData.length; i++) {
    if (allData.elementAt(i)["tagID"] == tagID) {
      await ScheduleDatabaseHelper().deleteSchedule(allData.elementAt(i)["id"]);
    }
  }
  ref.read(taskDataProvider).isRenewed = true;
  ref.read(calendarDataProvider.notifier).state = CalendarData();
  while (ref.read(taskDataProvider).isRenewed != false) {
    await Future.delayed(const Duration(microseconds: 1));
    setState(() {});
  }
}

Future<bool> showConfirmExitDialogue(BuildContext context) async {
  bool result = false;
  await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          content: const Text('変更を保存せずに戻りますか？'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ダイアログを閉じる
              },
              child: const Text('いいえ'),
            ),
            TextButton(
              onPressed: () {
                result = true;
                Navigator.of(context).pop(); // ダイアログを閉じる
              },
              child: const Text(
                'はい',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      });
  return result;
}
