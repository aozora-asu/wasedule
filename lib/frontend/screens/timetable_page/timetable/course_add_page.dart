import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/sharepreference.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/frontend/assist_files/ui_components.dart';
import 'package:flutter_calandar_app/backend/DB/handler/my_course_db.dart';
import 'package:flutter_calandar_app/frontend/screens/timetable_page/syllabus/syllabus_search_dialog.dart';
import 'package:flutter_calandar_app/static/constant.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CourseAddPage extends ConsumerStatefulWidget {
  DayOfWeek? weekDay;
  Lesson? period;
  int? year;
  Term? semester;
  late StateSetter setTimetableState;
  CourseAddPage(
      {super.key,
      this.weekDay,
      this.period,
      this.year,
      this.semester,
      required this.setTimetableState});

  @override
  _CourseAddPageState createState() => _CourseAddPageState();
}

class _CourseAddPageState extends ConsumerState<CourseAddPage> {
  TextEditingController memoController = TextEditingController();
  TextEditingController classNameController = TextEditingController();
  TextEditingController classRoomController = TextEditingController();
  TextEditingController creditController = TextEditingController();
  TextEditingController classificationController = TextEditingController();
  TextEditingController criteriaController = TextEditingController();
  DayOfWeek? weekDay;
  Lesson? period;
  late int year;
  late Term semester;
  late int creditNum;
  String errorText = "";

  @override
  void initState() {
    super.initState();
    year = widget.year ?? DateTime.now().year;
    semester = widget.semester ?? Term.fullYear;
    period = widget.period;
    weekDay = widget.weekDay;
    creditNum = 0;
  }

  @override
  Widget build(BuildContext context) {
    final bottomSpace = MediaQuery.of(context).viewInsets.bottom;
    return GestureDetector(onTap: () {
      Navigator.pop(context);
    }, child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
      Department? userDepartment = Department.byValue(SharepreferenceHandler()
          .getValue(SharepreferenceKeys.recentSyllabusQueryDepartmentValue));

      return SingleChildScrollView(
          reverse: true,
          child: Scrollbar(
              interactive: true,
              thickness: 5,
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text("時間割に新規追加...",
                                            style: TextStyle(
                                                fontSize: 25,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold)),
                                        SyllabusSearchDialog(
                                            radiusType: 1,
                                            gakki: widget.semester,
                                            jigen: widget.period,
                                            youbi: widget.weekDay,
                                            gakubu: null,
                                            setTimetableState: widget.setTimetableState
                                            ),
                                        const SizedBox(height: 2),
                                        courseInfo(),
                                      ]))))))));
    }));
  }

  Widget courseInfo() {
    Widget dividerModel = const Divider(
      height: 2,
    );
    String courseTimeText;
    String className;
    String classRoom;
    String memo;

    if (weekDay != null && period != null) {
      courseTimeText =
          "$year年 / ${semester.text} / ${weekDay?.text}曜日 / ${period!.period}限";
    } else {
      courseTimeText = "$year年 / ${semester.text} / オンデマンド / 時限なし";
    }

    return GestureDetector(
        onTap: () {},
        child: Container(
            decoration: roundedBoxdecoration(radiusType: 0),
            width: SizeConfig.blockSizeHorizontal! * 100,
            child: Material(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(2),
                    topRight: Radius.circular(2),
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25)),
                child: Padding(
                    padding: const EdgeInsets.all(12.5),
                    child: ExpandablePanel(
                        header: Row(children: [
                          const SizedBox(
                              width: 100,
                              child: Text(
                                "手動登録",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              )),
                          Text(errorText,
                              style: const TextStyle(color: Colors.red)),
                          const Spacer(),
                          SizedBox(width: SizeConfig.blockSizeHorizontal! * 1),
                        ]),
                        collapsed: const SizedBox(),
                        expanded: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              dividerModel,
                              Row(children: [
                                SizedBox(
                                    width: SizeConfig.blockSizeHorizontal! * 1),
                                const Icon(Icons.school, color: MAIN_COLOR),
                                SizedBox(
                                    width: SizeConfig.blockSizeHorizontal! * 3),
                                textFieldModel("授業名…", classNameController,
                                    FontWeight.normal, (value) {}),
                              ]),
                              const SizedBox(height: 3),
                              dividerModel,
                              Row(children: [
                                SizedBox(
                                    width: SizeConfig.blockSizeHorizontal! * 1),
                                const Icon(Icons.access_time,
                                    color: MAIN_COLOR),
                                SizedBox(
                                    width: SizeConfig.blockSizeHorizontal! * 3),
                                Expanded(
                                    child: GestureDetector(
                                        onTap: () async {
                                          await showWeekdayAndPeriodDialogue();
                                          setState(() {
                                            isValid();
                                          });
                                        },
                                        child: Text(courseTimeText,
                                            style: const TextStyle(
                                                fontSize: 20,
                                                overflow: TextOverflow.clip,
                                                color: Colors.blueAccent)))),
                              ]),
                              dividerModel,
                              Row(children: [
                                SizedBox(
                                    width: SizeConfig.blockSizeHorizontal! * 1),
                                const Icon(Icons.group, color: MAIN_COLOR),
                                SizedBox(
                                    width: SizeConfig.blockSizeHorizontal! * 3),
                                textFieldModel("教室…", classRoomController,
                                    FontWeight.normal, (value) {})
                              ]),
                              dividerModel,
                              Row(children: [
                                SizedBox(
                                    width: SizeConfig.blockSizeHorizontal! * 1),
                                const Icon(Icons.sticky_note_2,
                                    color: MAIN_COLOR),
                                SizedBox(
                                    width: SizeConfig.blockSizeHorizontal! * 3),
                                textFieldModel("授業メモ…", memoController,
                                    FontWeight.normal, (value) {}),
                              ]),
                              dividerModel,
                              Row(children: [
                                SizedBox(
                                    width: SizeConfig.blockSizeHorizontal! * 1),
                                const Icon(Icons.class_, color: MAIN_COLOR),
                                SizedBox(
                                    width: SizeConfig.blockSizeHorizontal! * 3),
                                textFieldModel("科目分類…", classificationController,
                                    FontWeight.normal, (value) {})
                              ]),
                              dividerModel,
                              Row(children: [
                                SizedBox(
                                    width: SizeConfig.blockSizeHorizontal! * 1),
                                const Icon(Icons.reviews, color: MAIN_COLOR),
                                SizedBox(
                                    width: SizeConfig.blockSizeHorizontal! * 3),
                                textFieldModel("評価基準…", criteriaController,
                                    FontWeight.normal, (value) {})
                              ]),
                              dividerModel,
                              Row(children: [
                                SizedBox(
                                    width: SizeConfig.blockSizeHorizontal! * 1),
                                const Text("単位数",style:TextStyle(fontSize: 20,color: Colors.grey)),
                                SizedBox(
                                    width: SizeConfig.blockSizeHorizontal! * 3),
                                const Spacer(),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if(creditNum >= 1){
                                        creditNum -= 1;
                                      }
                                    });
                                  },
                                  child:const Icon(Icons.arrow_back_ios,color: Colors.grey,),
                                ),
                                const Spacer(),
                                Text(creditNum.toString(),
                                  style:const TextStyle(fontSize: 20)),
                                const Spacer(),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      creditNum += 1;
                                    });
                                  },
                                  child:const Icon(Icons.arrow_forward_ios,color: Colors.grey,),
                                ),
                                const Spacer(),
                                SizedBox(
                                    width: SizeConfig.blockSizeHorizontal! * 1),
                              ]),
                              dividerModel,
                              Row(children: [
                                const Spacer(),
                                buttonModel(() async {
                                  className = classNameController.text;
                                  classRoom = classRoomController.text;
                                  memo = memoController.text;
                                  if (isValid()) {
                                    //＠ここに時間割データの追加関数！！！
                                    MyCourse myCourse = MyCourse(
                                        attendCount: null,
                                        classNum: null,
                                        remainAbsent: null,
                                        classRoom: classRoom,
                                        color: "#96C78C",
                                        courseName: className,
                                        pageID: null,
                                        period: period,
                                        semester: semester,
                                        syllabusID: null,
                                        weekday: weekDay,
                                        year: year,
                                        criteria: criteriaController.text,
                                        memo: memo,
                                        subjectClassification: classificationController.text,
                                        credit: creditNum);
                                    await myCourse.resisterDB();
                                    widget.setTimetableState(() {});
                                    Navigator.pop(context);
                                  } else {}
                                }, isValid() ? BLUEGREY : Colors.grey,
                                    "   追加   "),
                              ])
                            ]))))));
  }

  Widget textFieldModel(String hintText, TextEditingController controller,
      FontWeight weight, Function(String) onSubmitted) {
    return Expanded(
        child: Material(
      child: TextField(
          controller: controller,
          maxLines: null,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration.collapsed(
              border: InputBorder.none, hintText: hintText),
          style:
              TextStyle(color: Colors.black, fontWeight: weight, fontSize: 20),
          onSubmitted: onSubmitted),
    ));
  }

  bool isValid() {
    if (weekDay == null && period != null) {
      errorText = "*曜日を設定してください。";
      return false;
    } else if (weekDay != null && period == null) {
      errorText = "*時限を設定してください。";
      return false;
    } else {
      return true;
    }
  }

  Future<void> showWeekdayAndPeriodDialogue() async {
    DayOfWeek? tempweekDay = weekDay;
    Lesson? tempPeriod = period;
    int now = DateTime.now().year;
    int tempYear = DateTime.now().year;
    Term tempSemester = Term.fullYear;
    List<int> yearList = [
      now - 10,
      now - 9,
      now - 8,
      now - 7,
      now - 6,
      now - 5,
      now - 4,
      now - 3,
      now - 2,
      now - 1,
      now,
      now + 1,
      now + 2,
      now + 3,
      now + 4,
      now + 5,
      now + 6,
      now + 7,
      now + 8,
      now + 9,
      now + 10
    ];

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('学期、曜日、時限を選択'),
          actions: <Widget>[
            Column(
              children: [
                DropdownButtonFormField(
                  value: tempYear,
                  items: [
                    for (int year in yearList)
                      DropdownMenuItem(
                        value: year,
                        child: Text("$year年"),
                      ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      tempYear = value!;
                    });
                  },
                ),
                DropdownButtonFormField(
                  value: tempSemester,
                  items: [
                    DropdownMenuItem(
                      value: Term.fullYear,
                      child: const Text("通年"),
                    ),
                    DropdownMenuItem(
                      value: Term.springSemester,
                      child: const Text("春学期"),
                    ),
                    DropdownMenuItem(
                      value: Term.springQuarter,
                      child: const Text("春クォーター"),
                    ),
                    DropdownMenuItem(
                      value: Term.summerQuarter,
                      child: const Text("夏クォーター"),
                    ),
                    DropdownMenuItem(
                      value: Term.fallSemester,
                      child: const Text("秋学期"),
                    ),
                    DropdownMenuItem(
                      value: Term.fallQuarter,
                      child: const Text("秋クォーター"),
                    ),
                    DropdownMenuItem(
                      value: Term.winterQuarter,
                      child: const Text("冬クォーター"),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      tempSemester = value!;
                    });
                  },
                ),
                DropdownButtonFormField(
                  value: tempweekDay,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text("オンデマンド"),
                    ),
                    DropdownMenuItem(
                      value: DayOfWeek.monday,
                      child: const Text("月曜日"),
                    ),
                    DropdownMenuItem(
                      value: DayOfWeek.tuesday,
                      child: const Text("火曜日"),
                    ),
                    DropdownMenuItem(
                      value: DayOfWeek.wednesday,
                      child: const Text("水曜日"),
                    ),
                    DropdownMenuItem(
                      value: DayOfWeek.thursday,
                      child: const Text("木曜日"),
                    ),
                    DropdownMenuItem(
                      value: DayOfWeek.friday,
                      child: const Text("金曜日"),
                    ),
                    DropdownMenuItem(
                      value: DayOfWeek.saturday,
                      child: const Text("土曜日"),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      tempweekDay = value;
                    });
                  },
                ),
                DropdownButtonFormField(
                  value: tempPeriod,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text("なし"),
                    ),
                    DropdownMenuItem(
                      value: Lesson.first,
                      child: const Text("1限"),
                    ),
                    DropdownMenuItem(
                      value: Lesson.second,
                      child: const Text("2限"),
                    ),
                    DropdownMenuItem(
                      value: Lesson.third,
                      child: const Text("3限"),
                    ),
                    DropdownMenuItem(
                      value: Lesson.fourth,
                      child: const Text("4限"),
                    ),
                    DropdownMenuItem(
                      value: Lesson.fifth,
                      child: const Text("5限"),
                    ),
                    DropdownMenuItem(
                      value: Lesson.sixth,
                      child: const Text("6限"),
                    ),
                    DropdownMenuItem(
                      value: Lesson.seventh,
                      child: const Text("7限"),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      tempPeriod = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            buttonModel(
              () {
                setState(() {
                  weekDay = tempweekDay;
                  period = tempPeriod;
                  year = tempYear;
                  semester = tempSemester;
                });
                Navigator.pop(context);
              },
              MAIN_COLOR,
              "   OK   ",
            ),
          ],
        );
      },
    );
  }
}
