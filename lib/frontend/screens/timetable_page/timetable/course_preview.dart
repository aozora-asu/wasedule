import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/sharepreference.dart';
import 'package:flutter_calandar_app/backend/service/syllabus_query_request.dart';
import 'package:flutter_calandar_app/backend/service/syllabus_query_result.dart';
import 'package:flutter_calandar_app/frontend/screens/common/loading.dart';
import 'package:flutter_calandar_app/frontend/screens/timetable_page/attend_record/attend_menu_panel.dart';
import 'package:flutter_calandar_app/frontend/screens/timetable_page/syllabus/syllabus_description_view.dart';
import 'package:flutter_calandar_app/frontend/screens/timetable_page/syllabus/syllabus_search_dialog.dart';
import 'package:flutter_calandar_app/static/constant.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/frontend/assist_files/ui_components.dart';
import 'package:flutter_calandar_app/backend/DB/handler/my_course_db.dart';
import 'package:flutter_calandar_app/frontend/screens/common/attendance_dialog.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/task_modal_sheet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class CoursePreview extends ConsumerStatefulWidget {
  late MyCourse target;
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
  TextEditingController classificationController = TextEditingController();
  late int viewMode;
  late bool searchMode;
  Widget space = const SizedBox(height: 7);
  Widget dividerModel = const Divider(height: 2);
  TextStyle titleStyle = const TextStyle(color:Colors.grey, fontSize: 20,fontWeight: FontWeight.normal);

  @override
  void initState() {
    super.initState();
    MyCourse target = widget.target;
    memoController.text = target.memo ?? "";
    classRoomController.text = target.classRoom;
    classNameController.text = target.courseName;
    classificationController.text = target.subjectClassification ?? "";
    viewMode = 0;
    searchMode = false;
  }

  @override
  Widget build(BuildContext context) {
    final bottomSpace = MediaQuery.of(context).viewInsets.bottom;
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 5);
 
    return GestureDetector(onTap: () {
      Navigator.pop(context);
    }, child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
      return SingleChildScrollView(
          physics: viewMode == 1
              ? const NeverScrollableScrollPhysics()
              : const ScrollPhysics(),
          reverse: true,
          child: Padding(
              padding: EdgeInsets.only(bottom: bottomSpace / 2),
              child: ConstrainedBox(
                  constraints: BoxConstraints(
                      minHeight: viewportConstraints.maxHeight,
                      maxHeight: viewportConstraints.maxHeight),
                  child: Center(
                      child: SingleChildScrollView(
                          physics: viewMode == 1
                              ? const NeverScrollableScrollPhysics()
                              : const ScrollPhysics(),
                          child: Padding(
                              padding: padding,
                              child: Container(
                                decoration: roundedBoxdecoration(
                                  backgroundColor: FORGROUND_COLOR,
                                ),
                                padding: const EdgeInsets.symmetric(horizontal:2),
                                child:Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    switchSearchMode(),
                                    relatedTasks(),
                                    space,
                                    Row(children:[
                                    Text(" 出欠  ",
                                        style: titleStyle)]),
                                    AttendMenuPanel(
                                        courseData: widget.target,
                                        setTimetableState:
                                            widget.setTimetableState,
                                        backgroundColor: BACKGROUND_COLOR,),
                                    const SizedBox(height:7)
                                  ])
                                )
                              )
                            )
                          )
                        )
                      )
                    );
      })
    );
  }

  Widget switchSearchMode() {
    Widget header = GestureDetector(
        onTap: () {},
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          margin: const EdgeInsets.symmetric(horizontal: 0),
          decoration: roundedBoxdecoration(radiusType: 1, shadow: true),
          child: Row(children: [
            const Icon(Icons.search, color: Colors.blue),
            const Text(" シラバス検索",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Spacer(),
            descriptionModeSwitch()
          ]),
        ));

    if (searchMode) {
      return Stack(children: [
        Column(children: [
          header,
          space,
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: SyllabusSearchDialog(
                  radiusType: 2,
                  gakki: widget.target.semester,
                  youbi: widget.target.weekday,
                  jigen: widget.target.period,
                  gakubu: Department.byValue(SharepreferenceHandler()
                      .getValue(SharepreferenceKeys.userDepartment)),
                  setTimetableState: widget.setTimetableState))
        ]),
        header
      ]);
    } else {
      return courseInfo();
    }
  }

  Widget courseInfo() {
    MyCourse target = widget.target;
    int id;

    Widget header = Container(
      decoration: dialogHeader(),
      margin: const EdgeInsets.symmetric(horizontal: 0),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        textFieldModel("授業名を入力…", classNameController, FontWeight.bold, 22.0,
            (value) async {
          id = target.id!;
          //＠ここに授業名変更関数を登録！！！
          await MyCourse.updateCourseName(id, value);
          widget.setTimetableState(() {});
        }),
        descriptionModeSwitch(),
        if (viewMode == 0)
          GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.cancel_rounded,
                  size: 20, color: Colors.red)),
        const SizedBox(width: 5)
      ]),
    );

    return GestureDetector(
        onTap: () {},
        child: Stack(
          alignment:const Alignment(0, -1),
          children: [
          Column(children: [
            header,
            space,
            Row(children: [
              Text(
                " 概要",style:titleStyle,
              ),
              const Spacer()
            ]),
            Container(
                decoration: roundedBoxdecoration(
                  radiusType: 2,
                  backgroundColor: viewMode == 0 ? BACKGROUND_COLOR : FORGROUND_COLOR),
                margin: const EdgeInsets.symmetric(horizontal: 5),
                child: Padding(
                    padding: const EdgeInsets.only(
                        left: 12.5, right: 12.5, top: 5, bottom: 10),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          switchViewMode(dividerModel, target),
                          const SizedBox(height: 5),
                          Row(children: [
                            viewModeSwitch(),
                            searchModeSwitch(),
                            const Spacer(),
                            GestureDetector(
                                child: const Icon(Icons.delete,
                                    color: Colors.grey),
                                onTap: () async {
                                  id = target.id!;
                                  await showConfirmDeleteDialog(
                                    context,
                                    target.courseName,
                                    ()async{ 
                                      //＠ここに削除実行関数！！！
                                      await MyCourse.deleteMyCourse(id);
                                      widget.setTimetableState(() {});
                                      Navigator.pop(context);
                                    });
                                }),
                            SizedBox(
                                width: SizeConfig.blockSizeHorizontal! * 1),
                          ]),
                        ]))),
          ]),
          header
        ]));
  }

  Widget switchViewMode(dividerModel, MyCourse target) {
    if (viewMode == 0) {
      return summaryContent(dividerModel, target);
    } else {
      return syllabusPageViewBuilder(target);
    }
  }

  Widget syllabusPageViewBuilder(MyCourse target){
    return FutureBuilder(
      future: SyllabusRequestQuery.getSingleSyllabusInfo(target.syllabusID!),
      builder: (conetext,snapshot){
        if(snapshot.connectionState == ConnectionState.waiting){
          return const Center(
            child:CircularProgressIndicator(
              color:Colors.blueAccent)
            );
        }else if(snapshot.hasData){
      return Container(
          decoration: BoxDecoration(
            color:FORGROUND_COLOR,
            border: const Border(bottom: BorderSide(color: Colors.grey))
          ),
          height: SizeConfig.blockSizeVertical! * 50,
          width: SizeConfig.blockSizeHorizontal! * 100,
          child: SyllabusDescriptonView(
              showHeader: false,
              syllabusQuery: snapshot.data!));
        }else{
          return const Center(
            child:CircularProgressIndicator(
              color:Colors.blueAccent)
            );
        }
        
      });
  }

  Widget viewModeSwitch() {
    MyCourse target = widget.target;
    if (target.syllabusID != null && target.syllabusID != "") {
      if (viewMode == 0) {
        return buttonModel(() {
          setState(() {
            viewMode = 1;
          });
        }, Colors.blueAccent, " 授業の詳細 ");
      } else {
        return const SizedBox();
      }
    } else {
      return const SizedBox();
    }
  }

  Widget searchModeSwitch() {
    if (!searchMode && viewMode == 0) {
      return buttonModel(() {
        setState(() {
          searchMode = true;
        });
      }, Colors.lightBlueAccent, " シラバス検索 ");
    } else {
      return const SizedBox();
    }
  }

  Widget descriptionModeSwitch() {
    MyCourse target = widget.target;
    if (searchMode) {
      return buttonModel(() {
        setState(() {
          searchMode = false;
        });
      }, Colors.blueAccent, " もどる ");
    } else if (target.syllabusID != null && target.syllabusID != "") {
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

  Widget summaryContent(dividerModel, MyCourse target) {
    int? credit = target.credit;
    String creditString = 
      credit != null ? credit.toString() : "？";
    String criteria = 
      target.criteria ?? "？";

    return Column(children: [
      Row(children: [
        SizedBox(width: MediaQuery.of(context).size.width * 0.01),
        const Icon(Icons.access_time, color: Colors.blue),
        SizedBox(width: MediaQuery.of(context).size.width * 0.03),
        Text(
          "${target.weekday!.text}曜日 ${target.period!.period}限",
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
            child: Text(
          "${target.year} ${target.semester?.fullText ?? Term.fullYear.fullText}",
          style: const TextStyle(fontSize: 15, color: Colors.grey),
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
          int id = target.id!;
          //＠ここに教室のアップデート関数！！！
          await MyCourse.updateMemo(id, value);
          widget.setTimetableState(() {});
        })
      ]),
      dividerModel,
      Row(children: [
        SizedBox(width: MediaQuery.of(context).size.width * 0.01),
        const Text("単位数",style: TextStyle(color:Colors.grey,fontSize: 17),),
        SizedBox(width: MediaQuery.of(context).size.width * 0.03),
        Text(creditString,style:const TextStyle(fontWeight: FontWeight.bold,fontSize:20)),
        SizedBox(width: MediaQuery.of(context).size.width * 0.03),
      //   const Text("評価基準",style: TextStyle(color:Colors.grey,fontSize: 17)),
      //   SizedBox(width: MediaQuery.of(context).size.width * 0.03),
      //   Expanded(
      //     child:Text(criteria,style:const TextStyle(fontSize: 17)))
      ]),
      dividerModel,
      Row(children: [
        SizedBox(width: MediaQuery.of(context).size.width * 0.01),
        const Icon(Icons.class_, color: Colors.blue),
        SizedBox(width: MediaQuery.of(context).size.width * 0.03),
        textFieldModel("科目の分類を入力…", classificationController, FontWeight.normal, 20.0,
            (value) async {
              int id = target.id!;
              MyCourse newMyCourse = widget.target;
              newMyCourse.subjectClassification = classificationController.text;
              await MyCourse.updateMyCourse(id,newMyCourse);
              widget.setTimetableState(() {});
        })
      ]),
      dividerModel,
    ]);
  }

  Widget classRoomSelector(BuildContext context, MyCourse target) {
    List<String> classRooms = target.classRoom.toString().split("\n");
    Map<String, bool> selectedRooms = {};
    int id;
    for (var classroom in classRooms) {
      selectedRooms[classroom] = true;
    }

    if (classRooms.length <= 2) {
      return textFieldModel(
          "教室を入力…", classRoomController, FontWeight.bold, 20.0, (value) async {
        id = target.id!;
        //＠ここに教室のアップデート関数！！！
        await MyCourse.updateClassRoom(id, value);
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
                id = target.id!;
                String selectedRoomValue = selectedRooms.entries
                    .where((entry) => entry.value)
                    .map((entry) => entry.key)
                    .join("\n")
                    .trimRight();

                await MyCourse.updateClassRoom(id, selectedRoomValue);
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
        color: Colors.transparent,
      child: TextField(
          controller: controller,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          decoration: InputDecoration.collapsed(
              fillColor: Colors.transparent,
              filled: true,
              border: InputBorder.none,
              hintText: hintText),
          style: TextStyle(
              fontSize: fontSize, color: Colors.black, fontWeight: weight),
          onChanged: onChanged),
    ));
  }

  Widget relatedTasks() {
    if (widget.taskList.isNotEmpty) {
      return Column(children: [
        space,
        Row(
          children: [
            const SizedBox(width: 5 ),
            Text("課題",
                style: titleStyle),
            const Spacer(),
            lengthBadge(widget.taskList.length, 17.5, false),
            const SizedBox(width: 10),
          ],
        ),
        Container(
            decoration: roundedBoxdecoration(radiusType: 2),
            padding: const EdgeInsets.all(10.0),
            margin: const EdgeInsets.symmetric(horizontal: 5),
            child: Column(children: [
              const SizedBox(height: 2),
              ListView.separated(
                itemBuilder: (context, index) {
                  return taskListChild(widget.taskList.elementAt(index));
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 2);
                },
                itemCount: widget.taskList.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
              )
            ]))
      ]);
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
                  decoration: roundedBoxdecoration(
                      radiusType: 2, backgroundColor: BACKGROUND_COLOR),
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
