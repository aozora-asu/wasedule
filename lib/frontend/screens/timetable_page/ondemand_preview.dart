import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/frontend/assist_files/ui_components.dart';
import 'package:flutter_calandar_app/backend/DB/handler/my_course_db.dart';
import 'package:flutter_calandar_app/backend/service/syllabus_query_result.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/task_modal_sheet.dart';
import 'package:flutter_calandar_app/frontend/screens/timetable_page/syllabus_description_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import "../../../static/constant.dart";

class OndemandPreview extends ConsumerStatefulWidget {
  late MyCourse target;
  late StateSetter setTimetableState;
  late List<Map<String, dynamic>> taskList;
  OndemandPreview(
      {super.key,
      required this.target,
      required this.setTimetableState,
      required this.taskList});
  @override
  _OndemandPreviewState createState() => _OndemandPreviewState();
}

class _OndemandPreviewState extends ConsumerState<OndemandPreview> {
  TextEditingController memoController = TextEditingController();
  TextEditingController classNameController = TextEditingController();
  late int viewMode;
  late Map<String, dynamic> target;

  @override
  void initState() {
    super.initState();
    target = widget.target as Map<String, dynamic>;
    memoController.text = target["memo"] ?? "";
    classNameController.text = target["courseName"] ?? "";
    viewMode = 0;
  }

  @override
  Widget build(BuildContext context) {
    final bottomSpace = MediaQuery.of(context).viewInsets.bottom;

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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 20),
                                    courseInfo(),
                                    const SizedBox(height: 30),
                                    relatedTasks(),
                                    const SizedBox(height: 20),
                                  ])))))));
    }));
  }

  Widget courseInfo() {
    MyCourse target = widget.target;
    Widget dividerModel = const Divider(
      height: 2,
    );
    int id;

    Widget _switchViewMode(dividerModel, target) {
      if (viewMode == 0) {
        return summaryContent(dividerModel, target);
      } else {
        print(target);
        return SizedBox(
            height: SizeConfig.blockSizeVertical! * 50,
            width: SizeConfig.blockSizeHorizontal! * 100,
            child: SyllabusDescriptonView(
                showHeader: false,
                syllabusQuery: SyllabusQueryResult(
                    courseName: target["courseName"],
                    classRoom: target["classRoom"],
                    year: target["year"],
                    syllabusID: target["syllabusID"],
                    semesterAndWeekdayAndPeriod: "ここに年度曜日時限のデータを加工して受け渡し",
                    teacher: null,
                    credit: null,
                    criteria: target["criteria"],
                    department: null,
                    subjectClassification: null,
                    abstract: null,
                    agenda: null,
                    reference: null,
                    remark: null,
                    textbook: null,
                    lectureSystem: null,
                    campus: null,
                    allocatedYear: null)));
      }
    }

    Widget _viewModeSwitch() {
      MyCourse target = widget.target;
      if (target.syllabusID != null && target.syllabusID != "") {
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

    Widget _descriptionModeSwitch() {
      MyCourse target = widget.target;
      if (target.syllabusID != null && target.syllabusID != "") {
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

    return GestureDetector(
        onTap: () {},
        child: Container(
            decoration: roundedBoxdecoration(),
            width: SizeConfig.blockSizeHorizontal! * 100,
            child: Padding(
                padding: const EdgeInsets.all(12.5),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        textFieldModel("授業名を入力…", classNameController,
                            FontWeight.bold, 25.0, (value) async {
                          id = target.id!;
                          //＠ここに授業名のアップデート関数！！！
                          await MyCourse.updateCourseName(id, value);
                        }),
                        _descriptionModeSwitch(),
                      ]),
                      _switchViewMode(dividerModel, target),
                      Row(children: [
                        _viewModeSwitch(),
                        const Spacer(),
                        GestureDetector(
                            child: const Icon(Icons.delete, color: Colors.grey),
                            onTap: () async {
                              id = target.id!;
                              //＠ここに削除実行関数！！！
                              await MyCourse.deleteMyCourse(id);
                              Navigator.pop(context);
                              widget.setTimetableState(() {});
                            }),
                        SizedBox(width: SizeConfig.blockSizeHorizontal! * 1),
                      ])
                    ]))));
  }

  Widget summaryContent(dividerModel, target) {
    String text = Term.byValue(target["semester"])?.fullText ?? "";

    return Column(children: [
      dividerModel,
      Row(children: [
        SizedBox(width: SizeConfig.blockSizeHorizontal! * 1),
        const Icon(Icons.info, color: MAIN_COLOR),
        SizedBox(width: SizeConfig.blockSizeHorizontal! * 3),
        const Text("オンデマンド/その他",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal)),
        SizedBox(width: SizeConfig.blockSizeHorizontal! * 3),
      ]),
      Row(children: [
        SizedBox(width: SizeConfig.blockSizeHorizontal! * 5),
        Text("${target["year"]} $text",
            style: const TextStyle(fontSize: 16, color: Colors.grey)),
        const Spacer(),
      ]),
      dividerModel,
      Row(children: [
        SizedBox(width: SizeConfig.blockSizeHorizontal! * 1),
        const Icon(Icons.sticky_note_2, color: MAIN_COLOR),
        SizedBox(width: SizeConfig.blockSizeHorizontal! * 3),
        textFieldModel("授業メモを入力…", memoController, FontWeight.normal, 20.0,
            (value) async {
          int id = target["id"];
          //＠ここにメモのアップデート関数！！！
          await MyCourse.updateMemo(id, value);
          widget.setTimetableState(() {});
        }),
      ]),
      dividerModel,
    ]);
  }

  Widget textFieldModel(String hintText, TextEditingController controller,
      FontWeight weight, double fontSize, Function(String) onSubmitted) {
    return Expanded(
        child: Material(
      child: TextField(
          controller: controller,
          maxLines: null,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration.collapsed(
              filled: true,
              fillColor: FORGROUND_COLOR,
              border: InputBorder.none,
              hintText: hintText),
          style: TextStyle(
              color: Colors.black, fontWeight: weight, fontSize: fontSize),
          onSubmitted: onSubmitted),
    ));
  }

  Widget relatedTasks() {
    if (widget.taskList.isNotEmpty) {
      return Container(
          decoration: roundedBoxdecoration(),
          padding: const EdgeInsets.all(10.0),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          child: Column(children: [
            const Text("関連する課題",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
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
