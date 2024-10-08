import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/handler/my_course_db.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/screens/common/ui_components.dart';
import 'package:flutter_calandar_app/frontend/screens/common/attendance_dialog.dart';
import 'package:flutter_calandar_app/frontend/screens/timetable_page/attend_record/attend_stats_page.dart';
import 'package:flutter_calandar_app/frontend/screens/to_do_page/todo_assist_files/size_config.dart';
import 'package:flutter_calandar_app/static/constant.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AttendMenuPanel extends ConsumerStatefulWidget {
  MyCourse courseData;
  StateSetter setTimetableState;
  Color? backgroundColor = FORGROUND_COLOR;

  AttendMenuPanel({super.key, 
    required this.courseData,
    required this.setTimetableState,
    this.backgroundColor
  });

  @override
  _AttendMenuPanelState createState() => _AttendMenuPanelState();
}

class _AttendMenuPanelState extends ConsumerState<AttendMenuPanel> {
  int maxAbsentNum = 0;
  int totalClassNum = 0;
  bool isClassNumSettingInit = true;
  bool isExpandSettingPanel = false;

  @override
  void initState() {
    super.initState();
    MyCourse myCourseData = widget.courseData;
    if (isClassNumSettingInit) {
      maxAbsentNum = myCourseData.remainAbsent!;
      totalClassNum = myCourseData.classNum ?? 0;
      isClassNumSettingInit = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {},
        child: Container(
            decoration: roundedBoxdecoration(radiusType: 2,backgroundColor: widget.backgroundColor),
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
            margin: const EdgeInsets.symmetric(horizontal:5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                const SizedBox(height: 3),
                attendRecordView(),
                isExpandSettingPanel ? attendSettingsPanel() : const SizedBox(),
            ])
          )
        );
  }

  Widget attendSettingsPanel() {
    return Column(children:[
      const Text("設定",
              style: TextStyle(fontSize: 20, color: Colors.grey)),
      remainingAbsentSetting(),
    ]);
  }

  Widget remainingAbesentViewBuilder() {
    return FutureBuilder(
        future: MyCourse.getAttendStatusCount(
            widget.courseData.id!, AttendStatus.absent),
        builder: (context, snapShot) {
          if (snapShot.connectionState == ConnectionState.done) {
            if (snapShot.data == null) {
              return remainingAbesentView(maxAbsentNum,maxAbsentNum);
            } else {
              int remainingLife = maxAbsentNum - snapShot.data!;
              if (remainingLife <= 0) {
                remainingLife = 0;
              }
              return remainingAbesentView(remainingLife,maxAbsentNum);
            }
          } else {
            return remainingAbesentView(maxAbsentNum,maxAbsentNum);
          }
        });
  }

  Widget remainingAbesentView(int absentNum,int maxAbsentNum) {
    return SizedBox(
      height:20,
      child:ListView.builder(
            itemBuilder:(context,index){
              if(index+1 <= absentNum){
                return const Icon(Icons.favorite, color: Colors.redAccent, size: 22);
              }else{
                return Icon(Icons.favorite, color: Colors.grey.withOpacity(0.5), size: 22);
              }

            },
          itemCount: maxAbsentNum,
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          )
        
      );
  }

  Widget remainingAbsentSetting() {
    EdgeInsets containerPadding = const EdgeInsets.all(10);
    BoxDecoration containerDecoration = BoxDecoration(
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
          await MyCourse.updateClassNum(widget.courseData.id!, totalClassNum);
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
          await MyCourse.updateClassNum(widget.courseData.id!, totalClassNum);
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
          await MyCourse.updateRemainAbsent(
              widget.courseData.id!, maxAbsentNum);
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
          await MyCourse.updateRemainAbsent(
              widget.courseData.id!, maxAbsentNum);
          setState(() {});
          widget.setTimetableState(() {});
        });
  }

  Widget attendRecordView() {
    return Material(
        color: Colors.transparent,
        child: ExpandablePanel(
            controller: ExpandableController(initialExpanded: true),
            header: Column(children: [
              Row(children: [
                remainingAbesentViewBuilder(),
                const Spacer(),
                addRecordButton(),
                const SizedBox(width:5),
              ]),
            ]),
            collapsed: const SizedBox(),
            expanded: Column(
              children: [
                attendRecordListBuilder(),
              ])
          ));
  }

  Widget attendRecordListBuilder() {
    return FutureBuilder(
        future: MyCourse.getAttendanceRecordFromDB(widget.courseData.id!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data == null || snapshot.data!.isEmpty) {
              return attendRecordList([]);
            } else {
              return attendRecordList(snapshot.data!);
            }
          } else {
            return const Center();
          }
        });
  }

  Widget attendRecordList(List attendRecordList) {
    return 
    Column(children:[

      Container(
        decoration: roundedBoxdecoration(radiusType: 2,backgroundColor: FORGROUND_COLOR),
        padding:const EdgeInsets.symmetric(horizontal: 5,vertical: 6),
        child:Row(children:[
          attendStatsIndicator(widget.courseData, attendRecordList),
          const Spacer(),
          GestureDetector(
            onTap: (){
              setState(() {
                if(isExpandSettingPanel){
                  isExpandSettingPanel = false;
                }else{
                  isExpandSettingPanel = true;
                }
              });
            },
            child:Icon(
              isExpandSettingPanel ? Icons.close :  Icons.settings,
              size:20,color:Colors.grey)
          )
        ])
      ),

      if(!isExpandSettingPanel)
        ListView.separated(
          itemCount: attendRecordList.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return attendRecordListPanel(attendRecordList.elementAt(index));
          },
          separatorBuilder: (context, index) {
            return const Divider(height: 1);
          },
        )
    ]);
  }

  Widget attendRecordListPanel(Map attendRecord) {
    String attendStatusText =
        AttendStatus.values[attendRecord["attendStatus"]]!.text;
    Color attendStatusColor =
        AttendStatus.values[attendRecord["attendStatus"]]!.color;

    return GestureDetector(
        onTap: () async {
          showIndividualCourseEditDialog(context, widget.courseData,
              initData: attendRecord, () {
            setState(() {});
            widget.setTimetableState(() {});
          });
        },
        child: Container(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
            margin: const EdgeInsets.symmetric(vertical: 1),
            decoration: roundedBoxdecoration(
                radiusType: 2, backgroundColor: Colors.transparent),
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
                    await MyCourse.deleteAttendRecord(attendRecord["id"]);
                    widget.setTimetableState(() {});
                    setState(() {});
                  },
                  child: const Icon(Icons.delete, color: BLUEGREY)),
            ])));
  }

  Widget addRecordButton() {
    return buttonModel(
        () async {
          showIndividualCourseEditDialog(context, widget.courseData, () {
            setState(() {});
            widget.setTimetableState(() {});
          });
        },
        Colors.blueAccent,
        "+ 記録",
        horizontalPadding: 15,
        verticalpadding: 7
      );

  }
}
