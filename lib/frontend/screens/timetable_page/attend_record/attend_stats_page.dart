import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/handler/my_course_db.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/assist_files/ui_components.dart';
import 'package:flutter_calandar_app/frontend/screens/common/attendance_dialog.dart';
import 'package:flutter_calandar_app/frontend/screens/timetable_page/attend_record/attend_menu_panel.dart';
import 'package:flutter_calandar_app/frontend/screens/timetable_page/timetable/timetable_data_manager.dart';
import 'package:flutter_calandar_app/static/constant.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AttendStatsPage extends ConsumerStatefulWidget {
  @override
  _AttendStatsPageState createState() => _AttendStatsPageState();
}

class _AttendStatsPageState extends ConsumerState<AttendStatsPage> {
  late int thisYear;
  late Term currentQuarter;
  late Term currentSemester;
  late DateTime now;
  List<MyCourse> currentCourseDataList = [];

  @override
  void initState() {
    super.initState();
    now = DateTime.now();
    initTargetSem();
  }

  void generateCurrentCourseData() {
    currentCourseDataList = [];
    List<MyCourse> data = ref.read(timeTableProvider).timeTableDataList;
    for (int i = 0; i < data.length; i++) {
      int targetYear = data.elementAt(i).year;
      Term? targetSemester = data.elementAt(i).semester;
      DayOfWeek? targetWeekday = data.elementAt(i).weekday;
      Lesson? targetPeriod = data.elementAt(i).period;

      if (targetPeriod != null && targetWeekday != null) {
        if (currentSemester == Term.springSemester && targetYear == thisYear) {
          if (targetSemester == Term.springSemester ||
              targetSemester == Term.springQuarter ||
              targetSemester == Term.summerQuarter) {
            currentCourseDataList.add(data.elementAt(i));
          }
        } else if (currentSemester == Term.fallSemester &&
            targetYear == thisYear) {
          if (targetSemester == Term.fallSemester ||
              targetSemester == Term.fallQuarter ||
              targetSemester == Term.winterQuarter) {
            currentCourseDataList.add(data.elementAt(i));
          }
        } else {
          if (targetSemester == Term.fullYear) {
            currentCourseDataList.add(data.elementAt(i));
          }
        }
      }
    }
  }

  void initTargetSem() {
    DateTime now = DateTime.now();
    thisYear = Term.whenSchoolYear(now);
    Term? nowQuarter = Term.whenQuarter(now);
    Term? nowSemester = Term.whenSemester(now);

    if (nowQuarter != null) {
      currentQuarter = nowQuarter;
    } else {
      if (now.month <= 3) {
        currentQuarter = Term.winterQuarter;
      } else if (now.month <= 5) {
        currentQuarter = Term.springQuarter;
      } else if (now.month <= 7) {
        currentQuarter = Term.summerQuarter;
      } else if (now.month <= 11) {
        currentQuarter = Term.fallQuarter;
      } else {
        currentQuarter = Term.winterQuarter;
      }
    }
    if (nowSemester != null) {
      currentSemester = nowSemester;
    } else {
      if (now.month <= 3) {
        currentSemester = Term.fallSemester;
      } else if (now.month <= 7) {
        currentSemester = Term.springSemester;
      } else if (now.month <= 11) {
        currentSemester = Term.fallSemester;
      } else {
        currentSemester = Term.fallSemester;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    generateCurrentCourseData();
    return Scaffold(
        backgroundColor: BACKGROUND_COLOR,
        body: Column(children: [
          header(),
          const Divider(height:1,indent: 10,endIndent: 10,),
          if (currentCourseDataList.isEmpty)
            noCourseDataScreen()
          else
            semesterCourseList(),
        ]));
  }

  Widget header() {
    return Padding(
      padding:const EdgeInsets.symmetric(horizontal: 5,vertical: 2),
      child:Row(children: [
        IconButton(
          onPressed: () {
            decreasePgNumber();
          },
          icon: const Icon(Icons.arrow_back_ios_rounded),
          iconSize: 20,
          color: BLUEGREY),
        Text(
          "$thisYear年  ${currentSemester.text}",
          style: const TextStyle(
              fontSize: 17, fontWeight: FontWeight.w700, color: BLUEGREY),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              increasePgNumber();
            });
          },
          icon: const Icon(Icons.arrow_forward_ios_rounded),
          iconSize: 20,
          color: BLUEGREY),
      const Spacer(),
      buttonModel(() async {
        await showAttendanceDialog(context, now, ref, true);
        setState(() {});
      },
      PALE_MAIN_COLOR,
      "今日の出欠",
      verticalpadding: 10,
      horizontalPadding:30,
      ),
      const SizedBox(width: 10)
    ])
    );
  }

  void increasePgNumber() {
    if (currentQuarter == Term.fallQuarter ||
        currentQuarter == Term.winterQuarter) {
      thisYear += 1;
      currentQuarter = Term.springQuarter;
      currentSemester = Term.springSemester;
    } else {
      currentQuarter = Term.fallQuarter;
      currentSemester = Term.fallSemester;
    }
    setState(() {});
  }

  void decreasePgNumber() {
    if (currentQuarter == Term.springQuarter ||
        currentQuarter == Term.summerQuarter) {
      thisYear -= 1;
      currentQuarter = Term.fallQuarter;
      currentSemester = Term.fallSemester;
    } else {
      currentQuarter = Term.springQuarter;
      currentSemester = Term.springSemester;
    }
    setState(() {});
  }

  Widget noCourseDataScreen() {
    return const Expanded(
        child: Center(
            child: Text("この学期の授業データはありません。",
                style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.normal,
                    overflow: TextOverflow.clip,
                    fontSize: 20))));
  }

  Widget semesterCourseList() {
    return Expanded(
      child:Padding(
        padding:const EdgeInsets.symmetric(horizontal: 10),
        child:ListView.separated(
          itemBuilder: (context,index){
            return courseListChild(currentCourseDataList.elementAt(index));
          },
          separatorBuilder: (context,index){
            return const SizedBox(height:15);
          },
          itemCount: currentCourseDataList.length,
          shrinkWrap: true,
          ))
    );
  }

  Widget courseListChild(MyCourse courseData) {
    return GestureDetector(
        onTap: () async {
          int absentNum = await  MyCourse.getAttendStatusCount(courseData.id!, AttendStatus.absent);
          await showAttendMenuPanel(courseData,absentNum);
        },
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: roundedBoxdecoration(
                radiusType: 2, backgroundColor: FORGROUND_COLOR),
            child: Column(children: [
              Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Text(
                    DayOfWeek.weekAt(courseData.weekday!.index).text +
                        "/" +
                        courseData.period!.period.toString() +
                        "限",
                    style: const TextStyle(
                        color: Colors.grey,
                        overflow: TextOverflow.clip,
                        fontSize: 10)),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(courseData.courseName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.clip,
                            fontSize: 17))),
                remainingAbesentViewBuilder(courseData)
              ]),
              attendStatsIndicatorFrame(courseData)
            ])));
  }

  Widget remainingAbesentViewBuilder(MyCourse courseData) {
    int maxAbsentNum = courseData.remainAbsent ?? 0;
    return FutureBuilder(
        future:
            MyCourse.getAttendStatusCount(courseData.id!, AttendStatus.absent),
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
      padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 10),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
          color: BACKGROUND_COLOR, borderRadius: BorderRadius.circular(5)),
      child: Row(children: [
        const Text("残機 ",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const Icon(Icons.favorite, color: Colors.redAccent, size: 16),
        Text("×${absentNum.toString()}",
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
      ]),
    );
  }

  Widget attendStatsIndicatorFrame(MyCourse courseData) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 7),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: BACKGROUND_COLOR,
        ),
        child: FutureBuilder(
            future: MyCourse.getAttendanceRecordFromDB(courseData.id!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return attendStatsIndicator(courseData, snapshot.data!);
              } else {
                return const CircularProgressIndicator(color: Colors.blue);
              }
            }));
  }

  Widget attendStatsIndicator(MyCourse courseData, List attendRecordList) {
    int attendNum = 0;
    int lateNum = 0;
    int absentNum = 0;
    TextStyle bold = const TextStyle(fontWeight: FontWeight.bold);
    TextStyle grey = const TextStyle(color: Colors.grey);
    TextStyle absentTextStyle = grey;

    for (int i = 0; i < attendRecordList.length; i++) {
      String? targetAttendStatus =
          attendRecordList.elementAt(i)["attendStatus"];
      if (targetAttendStatus == AttendStatus.attend.value) {
        attendNum++;
      } else if (targetAttendStatus == AttendStatus.late.value) {
        lateNum = 0;
      } else if (targetAttendStatus == AttendStatus.absent.value) {
        absentNum++;
      }
    }

    if (absentNum > 0) {
      absentTextStyle =
          const TextStyle(fontWeight: FontWeight.bold, color: Colors.red);
    }

    return Column(children: [
      Row(children: [
        Text("授業 ${courseData.classNum.toString()} 回中  "),
        attendStatusIcon(AttendStatus.attend),
        Text("${attendNum.toString()} ", style: attendNum > 0 ? bold : grey),
        attendStatusIcon(AttendStatus.late),
        Text("${lateNum.toString()} ", style: lateNum > 0 ? bold : grey),
        attendStatusIcon(AttendStatus.absent),
        Text("${absentNum.toString()} ", style: absentTextStyle),
      ]),
    ]);
  }

  Widget attendStatusIcon(AttendStatus status) {
    String iconText;
    Color iconColor;
    if (status == AttendStatus.attend) {
      iconText = "出";
      iconColor = Colors.blue;
    } else if (status == AttendStatus.late) {
      iconText = "遅";
      iconColor = Colors.orange;
    } else if (status == AttendStatus.absent) {
      iconText = "欠";
      iconColor = Colors.red;
    } else {
      iconText = "";
      iconColor = Colors.transparent;
    }

    return Container(
      decoration: BoxDecoration(
          color: iconColor, borderRadius: BorderRadius.circular(5)),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: Center(
          child: Text(iconText,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white))),
    );
  }

  Future<void> showAttendMenuPanel(MyCourse courseData, int absentNum) async {
    TextStyle grey = const TextStyle(color: Colors.grey);
    Widget header = Container(
      margin:const EdgeInsets.symmetric(horizontal: 5),
      padding:const EdgeInsets.symmetric(horizontal: 15,vertical: 5),
      decoration: dialogHeader(),
      child: Column(
        children:[
          Row(children:[
            Expanded(
              child:Text(courseData.courseName,
                overflow: TextOverflow.clip,
                style:const TextStyle(fontSize:23,fontWeight: FontWeight.bold,))),
            GestureDetector(
              onTap:()=> Navigator.pop(context),
              child:const Icon(Icons.cancel_rounded,size:20,color:Colors.red,))
          ]),
          //const Divider(height: 10),
          Row(children: [
            Text("残り欠席数(残機) ${(courseData.remainAbsent! - absentNum).toString()}回 / ",
                style: grey),
            Text("欠席可能数 ${courseData.remainAbsent.toString()}回", style: grey),
          ]),
      ])
    );

    await showDialog(
      context: context,
      builder: (context){
        return Container(
          margin:const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              const Spacer(),
              Stack(
                alignment:const  Alignment(0,-0.98),
                children:[
                Column(children:[
                  header,
                  AttendMenuPanel(
                    courseData: courseData,
                    setTimetableState: setState),
                ]),
                header
              ]),
              const Spacer(),
            ]
          )
        );
      });

  }
}
