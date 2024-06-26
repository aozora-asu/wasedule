import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/frontend/assist_files/ui_components.dart';
import 'package:flutter_calandar_app/backend/DB/handler/my_course_db.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CourseAddPage extends ConsumerStatefulWidget {
  int? weekDay;
  int? period;
  int? year;
  String? semester;
  late StateSetter setTimetableState;
  CourseAddPage(
      {super.key, this.weekDay,
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
  int? weekDay;
  int? period;
  int? year;
  String? semester;
  String errorText = "";

  @override
  void initState() {
    super.initState();
    year = DateTime.now().year;
    semester = "full_year";
    if (widget.year != null) {
      year = widget.year;
    }
    if (widget.semester != null) {
      semester = widget.semester;
    }
    if (widget.period != null) {
      period = widget.period;
    }
    if (widget.weekDay != null) {
      weekDay = widget.weekDay;
    }
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("時間割に新規追加：",
                                        style: TextStyle(
                                            fontSize: SizeConfig
                                                    .blockSizeHorizontal! *
                                                7,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold)),
                                    courseInfo(),
                                  ])))))));
    }));
  }

  Widget courseInfo() {
    Widget dividerModel = const Divider(
      height: 2,
    );

    String courseTimeText = "$year年, ${targetSemester(semester!)}, ${getJapaneseWeekday(weekDay)}, ${getPeriodString(period)}";

    return GestureDetector(
        onTap: () {},
        child: Container(
            decoration: roundedBoxdecorationWithShadow(),
            width: SizeConfig.blockSizeHorizontal! * 100,
            child: Padding(
                padding: const EdgeInsets.all(12.5),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        textFieldModel("授業名…", classNameController,
                            FontWeight.normal, (value) {}),
                      ]),
                      const SizedBox(height: 3),
                      dividerModel,
                      Row(children: [
                        SizedBox(width: SizeConfig.blockSizeHorizontal! * 1),
                        const Icon(Icons.access_time, color: MAIN_COLOR),
                        SizedBox(width: SizeConfig.blockSizeHorizontal! * 3),
                        GestureDetector(
                            onTap: () async {
                              await showWeekdayAndPeriodDialogue();
                              setState(() {
                                isValid();
                              });
                            },
                            child: Text(courseTimeText,
                                style: TextStyle(
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal! * 4,
                                    color: Colors.blueAccent))),
                        const Spacer(),
                      ]),
                      dividerModel,
                      Row(children: [
                        SizedBox(width: SizeConfig.blockSizeHorizontal! * 1),
                        const Icon(Icons.group, color: MAIN_COLOR),
                        SizedBox(width: SizeConfig.blockSizeHorizontal! * 3),
                        textFieldModel("教室…", classRoomController,
                            FontWeight.normal, (value) {})
                      ]),
                      dividerModel,
                      Row(children: [
                        SizedBox(width: SizeConfig.blockSizeHorizontal! * 1),
                        const Icon(Icons.sticky_note_2, color: MAIN_COLOR),
                        SizedBox(width: SizeConfig.blockSizeHorizontal! * 3),
                        textFieldModel("授業メモ…", memoController,
                            FontWeight.normal, (value) {}),
                      ]),
                      dividerModel,
                      const SizedBox(height: 2),
                      Row(children: [
                        const SizedBox(width: 5),
                        Text(errorText,
                            style: const TextStyle(color: Colors.red)),
                        const Spacer(),
                        buttonModel(() {
                          year;
                          semester;
                          weekDay;
                          period;
                          String className = classNameController.text;
                          String classRoom = classRoomController.text;
                          String memo = memoController.text;
                          if (isValid()) {
                            //＠ここに時間割データの追加関数！！！
                            MyCourseDatabaseHandler()
                                .resisterMyCourseFromMoodle(MyCourse(
                                    classRoom: classRoom,
                                    color: "#96C78C",
                                    courseName: className,
                                    pageID: null,
                                    period: period,
                                    semester: semester,
                                    syllabusID: null,
                                    weekday: weekDay,
                                    year: year!,
                                    criteria: null));
                            widget.setTimetableState(() {});
                            Navigator.pop(context);
                          } else {}
                        }, isValid() ? ACCENT_COLOR : Colors.grey, "   追加   "),
                        SizedBox(width: SizeConfig.blockSizeHorizontal! * 1),
                      ])
                    ]))));
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
          style: TextStyle(
              color: Colors.black,
              fontWeight: weight,
              fontSize: SizeConfig.blockSizeHorizontal! * 6),
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
      errorText = "";
      return true;
    }
  }

  Future<String> showWeekdayAndPeriodDialogue() async {
    int? tempweekDay = weekDay;
    int? tempPeriod = period;
    int now = DateTime.now().year;
    int tempYear = DateTime.now().year;
    String tempSemester = "full_year";
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
                  items: const [
                    DropdownMenuItem(
                      value: "full_year",
                      child: Text("通年"),
                    ),
                    DropdownMenuItem(
                      value: "spring_semester",
                      child: Text("春学期"),
                    ),
                    DropdownMenuItem(
                      value: "spring_quarter",
                      child: Text("春クォーター"),
                    ),
                    DropdownMenuItem(
                      value: "summer_quarter",
                      child: Text("夏クォーター"),
                    ),
                    DropdownMenuItem(
                      value: "fall_semester",
                      child: Text("秋学期"),
                    ),
                    DropdownMenuItem(
                      value: "full_quarter",
                      child: Text("秋クォーター"),
                    ),
                    DropdownMenuItem(
                      value: "winter_quarter",
                      child: Text("冬クォーター"),
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
                  items: const [
                    DropdownMenuItem(
                      value: null,
                      child: Text("オンデマンド"),
                    ),
                    DropdownMenuItem(
                      value: 1,
                      child: Text("月曜日"),
                    ),
                    DropdownMenuItem(
                      value: 2,
                      child: Text("火曜日"),
                    ),
                    DropdownMenuItem(
                      value: 3,
                      child: Text("水曜日"),
                    ),
                    DropdownMenuItem(
                      value: 4,
                      child: Text("木曜日"),
                    ),
                    DropdownMenuItem(
                      value: 5,
                      child: Text("金曜日"),
                    ),
                    DropdownMenuItem(
                      value: 6,
                      child: Text("土曜日"),
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
                  items: const [
                    DropdownMenuItem(
                      value: null,
                      child: Text("なし"),
                    ),
                    DropdownMenuItem(
                      value: 1,
                      child: Text("1限"),
                    ),
                    DropdownMenuItem(
                      value: 2,
                      child: Text("2限"),
                    ),
                    DropdownMenuItem(
                      value: 3,
                      child: Text("3限"),
                    ),
                    DropdownMenuItem(
                      value: 4,
                      child: Text("4限"),
                    ),
                    DropdownMenuItem(
                      value: 5,
                      child: Text("5限"),
                    ),
                    DropdownMenuItem(
                      value: 6,
                      child: Text("6限"),
                    ),
                    DropdownMenuItem(
                      value: 7,
                      child: Text("7限"),
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
    return "a";
  }

  String getJapaneseWeekday(int? weekday) {
    switch (weekday) {
      case 1:
        return '月曜日';
      case 2:
        return '火曜日';
      case 3:
        return '水曜日';
      case 4:
        return '木曜日';
      case 5:
        return '金曜日';
      case 6:
        return '土曜日';
      case 7:
        return '日曜日';
      default:
        return 'オンデマンド';
    }
  }

  String getPeriodString(int? period) {
    switch (period) {
      case 1:
        return '１限';
      case 2:
        return '２限';
      case 3:
        return '３限';
      case 4:
        return '４限';
      case 5:
        return '５限';
      case 6:
        return '６限';
      case 7:
        return '７限';
      default:
        return '時限なし';
    }
  }

  String targetSemester(String semesterID) {
    String result = "通年";
    if (semesterID == "spring_quarter") {
      result = "春クォーター";
    } else if (semesterID == "summer_quarter") {
      result = "夏クォーター";
    } else if (semesterID == "spring_semester") {
      result = "春学期";
    } else if (semesterID == "fall_quarter") {
      result = "秋クォーター";
    } else if (semesterID == "winter_quarter") {
      result = "冬クォーター";
    } else if (semesterID == "fall_semester") {
      result = "秋学期";
    }
    return result;
  }
}
