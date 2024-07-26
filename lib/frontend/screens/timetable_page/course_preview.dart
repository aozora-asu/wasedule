import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/static/constant.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/frontend/assist_files/ui_components.dart';
import 'package:flutter_calandar_app/backend/DB/handler/my_course_db.dart';
import 'package:flutter_calandar_app/frontend/screens/common/attendance_dialog.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/task_modal_sheet.dart';
import 'package:flutter_calandar_app/frontend/screens/timetable_page/syllabus_webview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

class CoursePreview extends ConsumerStatefulWidget {
  late Map target;
  late StateSetter setTimetableState;
  late List<Map<String, dynamic>> taskList;
  CoursePreview(
      {super.key,
      required this.target,
      required this.setTimetableState,
      required this.taskList});
  @override
  _CoursePreviewState createState() => _CoursePreviewState();
}

class _CoursePreviewState extends ConsumerState<CoursePreview> {
  TextEditingController memoController = TextEditingController();
  TextEditingController classNameController = TextEditingController();
  TextEditingController classRoomController = TextEditingController();
  late int viewMode;

  @override
  void initState() {
    super.initState();
    Map target = widget.target;
    memoController.text = target["memo"] ?? "";
    classRoomController.text = target["classRoom"] ?? "";
    classNameController.text = target["courseName"] ?? "";
    viewMode = 0;
  }

  @override
  Widget build(BuildContext context) {
    final bottomSpace = MediaQuery.of(context).viewInsets.bottom;
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 5);
    // if (viewMode == 1) {
    //   padding = EdgeInsets.zero;
    // }
    return GestureDetector(onTap: () {
      Navigator.pop(context);
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
                  child: Center(
                      child: SingleChildScrollView(
                          child: Padding(
                              padding: padding,
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 20),
                                    courseInfo(),
                                    const SizedBox(height: 15),
                                    relatedTasks(),
                                    const SizedBox(height: 15),
                                    attendMenuPanel(),
                                    const SizedBox(height: 20),
                                  ])))))));
    }));
  }

  Widget courseInfo() {
    Map target = widget.target;
    Widget dividerModel = const Divider(
      height: 2,
    );
    EdgeInsets padding = const EdgeInsets.all(12.5);
    // if (viewMode == 1) {
    //   padding = const EdgeInsets.symmetric(vertical: 12.5);
    // }
    int id;

    return GestureDetector(
        onTap: () {},
        child: Container(
            decoration: roundedBoxdecorationWithShadow(),
            width: SizeConfig.blockSizeHorizontal! * 95,
            child: Padding(
                padding: padding,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            textFieldModel("授業名を入力…", classNameController,
                                FontWeight.bold, 22.0, (value) async {
                              id = target["id"];
                              //＠ここに授業名変更関数を登録！！！
                              await MyCourseDatabaseHandler()
                                  .updateCourseName(id, value);
                              widget.setTimetableState(() {});
                            }),
                            descriptionModeSwitch(),
                          ]),
                      switchViewMode(dividerModel, target),
                      const SizedBox(height: 5),
                      Row(children: [
                        viewModeSwitch(),
                        const Spacer(),
                        GestureDetector(
                            child: const Icon(Icons.delete, color: Colors.grey),
                            onTap: () async {
                              id = target["id"];
                              //＠ここに削除実行関数！！！
                              await MyCourseDatabaseHandler()
                                  .deleteMyCourse(id);
                              widget.setTimetableState(() {});
                              Navigator.pop(context);
                            }),
                        SizedBox(width: SizeConfig.blockSizeHorizontal! * 1),
                      ]),
                    ]))));
  }

  Widget switchViewMode(dividerModel, target) {
    if (viewMode == 0) {
      return summaryContent(dividerModel, target);
    } else {
      return SyllabusWebView(pageID: widget.target["syllabusID"]);
    }
  }

  Widget viewModeSwitch() {
    Map target = widget.target;
    if (target["syllabusID"] != null && target["syllabusID"] != "") {
      if (viewMode == 0) {
        return buttonModel(() {
          setState(() {
            viewMode = 1;
          });
        }, Colors.blueAccent, " シラバス詳細 ");
      } else {
        return const SizedBox();
      }
    } else {
      return const SizedBox();
    }
  }

  Widget descriptionModeSwitch() {
    Map target = widget.target;
    if (target["syllabusID"] != null && target["syllabusID"] != "") {
      if (viewMode == 0) {
        return const SizedBox();
      } else {
        return buttonModel(() {
          setState(() {
            viewMode = 0;
          });
        }, Colors.blueAccent, " もどる ");
      }
    } else {
      return const SizedBox();
    }
  }

  Widget summaryContent(dividerModel, target) {
    return Column(children: [
      dividerModel,
      Row(children: [
        SizedBox(width: MediaQuery.of(context).size.width * 0.01),
        const Icon(Icons.access_time, color: Colors.blue),
        SizedBox(width: MediaQuery.of(context).size.width * 0.03),
        Text(
          "${"日月火水木金土"[target["weekday"] % 7]}曜日 ${target["period"]}限",
          style:const TextStyle(
            fontSize: 20,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(child:
          Text(
            "${target["year"]} ${Term.terms.firstWhereOrNull((e) => e.value == target["semester"])?.fullText ?? Term.fullYear.fullText}",
            style:const TextStyle(
                fontSize: 20,
                color: Colors.grey),
            overflow: TextOverflow.clip,
          )),
      ]),
      dividerModel,
      Row(children: [
        SizedBox(width: SizeConfig.blockSizeHorizontal! * 1),
        const Icon(Icons.group, color: Colors.blue),
        SizedBox(width: SizeConfig.blockSizeHorizontal! * 3),
        classRoomSelector(context, target)
      ]),
      dividerModel,
      Row(children: [
        SizedBox(width: MediaQuery.of(context).size.width * 0.01),
        const Icon(Icons.sticky_note_2, color: Colors.blue),
        SizedBox(width: MediaQuery.of(context).size.width * 0.03),
        textFieldModel("メモを入力…", memoController, FontWeight.normal, 20.0,
            (value) async {
          int id = target["id"];
          //＠ここに教室のアップデート関数！！！
          await MyCourseDatabaseHandler().updateMemo(id, value);
          widget.setTimetableState(() {});
        })
      ]),
      dividerModel,
    ]);
  }

  Widget classRoomSelector(BuildContext context, Map<String, dynamic> target) {
    List<String> classRooms = target["classRoom"].toString().split("\n");
    Map<String, bool> selectedRooms = {};
    int id;
    for (var classroom in classRooms) {
      selectedRooms[classroom] = true;
    }

    if (classRooms.length <= 2) {
      return textFieldModel(
          "教室を入力…", classRoomController, FontWeight.bold, 20.0, (value) async {
        id = target["id"];
        //＠ここに教室のアップデート関数！！！
        await MyCourseDatabaseHandler().updateClassRoom(id, value);
        widget.setTimetableState(() {});
      });
    } else {
      return IntrinsicHeight(
        child: Row(children: [
          GestureDetector(
            onTap: () async {
              showModalBottomSheet(
                context: context,
                backgroundColor: BACKGROUND_COLOR,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(20.0), // Set corner radius
                ),
                builder: (BuildContext context) {
                  return StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return ListView(
                          physics: const NeverScrollableScrollPhysics(),
                          children: classRooms.map((classRoom) {
                            return CheckboxListTile(
                              title: Text(classRoom),
                              value: selectedRooms[classRoom] ?? true,
                              onChanged: (bool? value) {
                                setState(() {
                                  selectedRooms[classRoom] = value!;
                                });
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    20.0), // Set corner radius
                              ),
                              activeColor: ACCENT_COLOR,
                              controlAffinity: ListTileControlAffinity.leading,
                              tileColor: Colors.white,
                              selectedTileColor: Colors.white,
                            );
                          }).toList());
                    },
                  );
                },
              ).whenComplete(() async {
                id = target["id"];
                String selectedRoomValue = selectedRooms.entries
                    .where((entry) => entry.value)
                    .map((entry) => entry.key)
                    .join("\n")
                    .trimRight();

                await MyCourseDatabaseHandler()
                    .updateClassRoom(id, selectedRoomValue);
                setState(() {});
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 2.5),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: const Color.fromARGB(255, 100, 100, 100),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(children: [
                Text(classRooms.join(" ")),
                const Icon(
                  Icons.arrow_drop_down,
                  color: Color.fromARGB(255, 100, 100, 100),
                )
              ]),
            ),
          ),
        ]),
      );
    }
  }

  Widget textFieldModel(String hintText, TextEditingController controller,
      FontWeight weight, double fontSize, Function(String) onChanged) {
    return Expanded(
        child: Material(
      child: TextField(
          controller: controller,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          //textInputAction: TextInputAction.done,
          decoration: InputDecoration.collapsed(
              fillColor: FORGROUND_COLOR,
              filled: true,
              border: InputBorder.none,
              hintText: hintText),
          style: TextStyle(
              fontSize: fontSize, color: Colors.black, fontWeight: weight),
          onChanged: onChanged),
    ));
  }

  int maxAbsentNum = 0;
  int totalClassNum = 0;
  bool isClassNumSettingInit = true;
  bool isExpandSettingPanel = false;

  void initClassNumSetting() {
    Map myCourseData = widget.target;
    if (isClassNumSettingInit) {
      maxAbsentNum = myCourseData["remainAbsent"];
      totalClassNum = myCourseData["classNum"] ?? 0;
      isClassNumSettingInit = false;
    }
  }

  Widget attendMenuPanel() {
    initClassNumSetting();
    return GestureDetector(
        onTap: () {},
        child: Container(
            decoration: roundedBoxdecorationWithShadow(),
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
            width: SizeConfig.blockSizeHorizontal! * 95,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Text("出席管理",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 22.5)),
                const Spacer(),
                remainingAbesentViewBuilder()
              ]),
              const SizedBox(height: 5),
              attendRecordView(),
              const Divider(),
              attendSettingsPanel(),
            ])));
  }

  Widget attendSettingsPanel() {
    return Material(
        child: ExpandablePanel(
            controller:
                ExpandableController(initialExpanded: isExpandSettingPanel),
            header: GestureDetector(
                child: const Text("設定",
                    style: TextStyle(fontSize: 20, color: Colors.grey))),
            collapsed: const SizedBox(),
            expanded: remainingAbsentSetting()));
  }

  Widget remainingAbesentViewBuilder() {
    return FutureBuilder(
        future: MyCourseDatabaseHandler()
            .getAttendStatusCount(widget.target["id"], AttendStatus.absent),
        builder: (context, snapShot) {
          if (snapShot.connectionState == ConnectionState.done) {
            if (snapShot.data == null) {
              return remainingAbesentView(maxAbsentNum);
            } else {
              int remainingLife = maxAbsentNum - snapShot.data!;
              if (remainingLife <= 0) {
                remainingLife = 0;
              }
              return remainingAbesentView(remainingLife);
            }
          } else {
            return remainingAbesentView(maxAbsentNum);
          }
        });
  }

  Widget remainingAbesentView(int absentNum) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          color: BACKGROUND_COLOR, borderRadius: BorderRadius.circular(5)),
      child: Row(children: [
        const Text("残機 ",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        const Icon(Icons.favorite, color: Colors.redAccent, size: 22),
        Text("×${absentNum.toString()}",
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 20, color: Colors.grey)),
      ]),
    );
  }

  Widget remainingAbsentSetting() {
    EdgeInsets containerPadding = const EdgeInsets.all(10);
    BoxDecoration containerDecoration = BoxDecoration(
      color: BACKGROUND_COLOR,
      border: Border.all(color: Colors.grey),
      borderRadius: BorderRadius.circular(15),
    );

    return Row(children: [
      const Spacer(),
      Column(children: [
        Container(
          padding: containerPadding,
          decoration: containerDecoration,
          child: Row(children: [
            decreseRemainAbsent(),
            Text(maxAbsentNum.toString(),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            increaceRemainAbsent()
          ]),
        ),
        const Text("最大欠席可能数",
            style: TextStyle(fontSize: 15, color: Colors.grey)),
      ]),
      const Spacer(),
      const Column(children: [
        Text(" / ", style: TextStyle(fontSize: 40, color: Colors.grey)),
        Text("  ", style: TextStyle(fontSize: 15)),
      ]),
      const Spacer(),
      Column(children: [
        Container(
          padding: containerPadding,
          decoration: containerDecoration,
          child: Row(children: [
            decreseClassNum(),
            Text(totalClassNum.toString(),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            increaceClassNum()
          ]),
        ),
        const Text("授業数", style: TextStyle(fontSize: 15, color: Colors.grey)),
      ]),
      const Spacer(),
    ]);
  }

  Widget increaceClassNum() {
    IconData buttonIcon = Icons.arrow_forward_ios;
    return GestureDetector(
        child: Icon(
          buttonIcon,
          color: Colors.grey,
          size: 17,
        ),
        onTap: () async {
          isExpandSettingPanel = true;
          totalClassNum = totalClassNum + 1;
          await MyCourseDatabaseHandler()
              .updateClassNum(widget.target["id"], totalClassNum);
          setState(() {});
          widget.setTimetableState(() {});
        });
  }

  Widget decreseClassNum() {
    IconData buttonIcon = Icons.arrow_back_ios;
    return GestureDetector(
        child: Icon(
          buttonIcon,
          color: Colors.grey,
          size: 17,
        ),
        onTap: () async {
          isExpandSettingPanel = true;
          totalClassNum =
              totalClassNum <= maxAbsentNum ? maxAbsentNum : totalClassNum - 1;
          await MyCourseDatabaseHandler()
              .updateClassNum(widget.target["id"], totalClassNum);
          setState(() {});
          widget.setTimetableState(() {});
        });
  }

  Widget increaceRemainAbsent() {
    IconData buttonIcon = Icons.arrow_forward_ios;
    return GestureDetector(
        child: Icon(
          buttonIcon,
          color: Colors.grey,
          size: 17,
        ),
        onTap: () async {
          maxAbsentNum =
              maxAbsentNum >= totalClassNum ? totalClassNum : maxAbsentNum + 1;
          await MyCourseDatabaseHandler()
              .updateRemainAbsent(widget.target["id"], maxAbsentNum);
          setState(() {});
          widget.setTimetableState(() {});
        });
  }

  Widget decreseRemainAbsent() {
    IconData buttonIcon = Icons.arrow_back_ios;
    return GestureDetector(
        child: Icon(
          buttonIcon,
          color: Colors.grey,
          size: 17,
        ),
        onTap: () async {
          maxAbsentNum = maxAbsentNum <= 0 ? 0 : maxAbsentNum - 1;
          await MyCourseDatabaseHandler()
              .updateRemainAbsent(widget.target["id"], maxAbsentNum);
          setState(() {});
          widget.setTimetableState(() {});
        });
  }

  Widget attendRecordView() {
    return Material(
        child: ExpandablePanel(
            controller: ExpandableController(initialExpanded: true),
            header: const Text("出欠記録",
                style: TextStyle(fontSize: 20, color: Colors.grey)),
            collapsed: const SizedBox(),
            expanded: Column(
                children: [attendRecordListBuilder(), addRecordButton()])));
  }

  Widget attendRecordListBuilder() {
    return FutureBuilder(
        future: MyCourseDatabaseHandler()
            .getAttendanceRecordFromDB(widget.target["id"]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data == null || snapshot.data!.isEmpty) {
              return const SizedBox();
              const Center(
                  child: Text("データはありません。",
                      style: TextStyle(color: Colors.grey, fontSize: 20)));
            } else {
              return attendRecordList(snapshot.data!);
            }
          } else {
            return const Center();
          }
        });
  }

  Widget attendRecordList(List attendRecordList) {
    return ListView.builder(
        itemCount: attendRecordList.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return attendRecordListPanel(attendRecordList.elementAt(index));
        });
  }

  Widget attendRecordListPanel(Map attendRecord) {
    String attendStatusText =
        AttendStatus.values[attendRecord["attendStatus"]]!.text;
    Color attendStatusColor =
        AttendStatus.values[attendRecord["attendStatus"]]!.color;

    return GestureDetector(
        onTap: () async {
          showIndividualCourseEditDialog(context, widget.target,
              initData: attendRecord, () {
            setState(() {});
            widget.setTimetableState(() {});
          });
        },
        child: Container(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
            margin: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
                color: BACKGROUND_COLOR,
                borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              Text(attendRecord["attendDate"],
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                margin: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                    color: attendStatusColor,
                    borderRadius: BorderRadius.circular(10)),
                child: Text(
                  attendStatusText,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.white),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                  onTap: () async {
                    await MyCourseDatabaseHandler()
                        .deleteAttendRecord(attendRecord["id"]);
                    widget.setTimetableState(() {});
                    setState(() {});
                  },
                  child: const Icon(Icons.delete, color: BLUEGREY)),
            ])));
  }

  Widget addRecordButton() {
    return GestureDetector(
        onTap: () async {
          showIndividualCourseEditDialog(context, widget.target, () {
            setState(() {});
            widget.setTimetableState(() {});
          });
        },
        child: Container(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
            margin: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
                color: BACKGROUND_COLOR,
                borderRadius: BorderRadius.circular(10)),
            child: const Center(
                child: Icon(Icons.add, color: Colors.grey, size: 30))));
  }

  Widget relatedTasks() {
    if (widget.taskList.isNotEmpty) {
      return Container(
          decoration: roundedBoxdecorationWithShadow(),
          padding: const EdgeInsets.all(10.0),
          width: SizeConfig.blockSizeHorizontal! * 95,
          child: Column(children: [
            Row(
              children: [
                const SizedBox(width: 10),
                const Text("関連する課題",
                    style:
                        TextStyle(fontSize: 22.5, fontWeight: FontWeight.bold)),
                const Spacer(),
                lengthBadge(widget.taskList.length, 17.5, false),
                const SizedBox(width: 10),
              ],
            ),
            const SizedBox(height: 5),
            ListView.separated(
              itemBuilder: (context, index) {
                return taskListChild(widget.taskList.elementAt(index));
              },
              separatorBuilder: (context, index) {
                return const SizedBox(height: 5);
              },
              itemCount: widget.taskList.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
            )
          ]));
    } else {
      return const SizedBox();
    }
  }

  Widget taskListChild(Map<String, dynamic> target) {
    DateTime dtEnd = DateTime.fromMillisecondsSinceEpoch(
      target["dtEnd"],
    );
    String endDate = DateFormat("MM/dd").format(dtEnd);
    String endTime = DateFormat("HH:mm").format(dtEnd);

    Duration remainingTime = dtEnd.difference(DateTime.now());
    String formatDuration(Duration duration) {
      int days = duration.inDays;
      int hours = duration.inHours % 24;
      if (days == 0) {
        return 'あと$hours時間';
      } else {
        return 'あと$days日$hours時間';
      }
    }

    String remainingTimeInString = formatDuration(remainingTime);
    return GestureDetector(
        onTap: () async {
          await bottomSheet(context, target, widget.setTimetableState);
        },
        child: Row(children: [
          Column(children: [
            Text(
              endDate,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Text(endTime,
                style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey)),
          ]),
          const SizedBox(width: 5),
          Expanded(
              child: Container(
                  decoration: BoxDecoration(
                      color: FORGROUND_COLOR,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10)),
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(remainingTimeInString,
                            style: const TextStyle(color: Colors.redAccent)),
                        Text(
                          target["summary"],
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        )
                      ])))
        ]));
  }
}
