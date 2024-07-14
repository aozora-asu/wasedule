import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/constant.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/frontend/assist_files/ui_components.dart';
import 'package:flutter_calandar_app/backend/DB/handler/my_course_db.dart';
import 'package:flutter_calandar_app/frontend/screens/common/attendance_dialog.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/task_modal_sheet.dart';
import 'package:flutter_calandar_app/frontend/screens/timetable_page/syllabus_webview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class CoursePreview extends ConsumerStatefulWidget {
  late Map target;
  late StateSetter setTimetableState;
  late List<Map<String, dynamic>> taskList;
  CoursePreview(
      {super.key, required this.target,
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
                                    attendMenuPanel(),
                                    const SizedBox(height: 15),
                                    relatedTasks(),
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

    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: roundedBoxdecorationWithShadow(),
        width: SizeConfig.blockSizeHorizontal! * 100,
        child: Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                textFieldModel("授業名を入力…", classNameController,
                    FontWeight.bold, 22.5, (value) async {
                  int id = target["id"];
                  //＠ここに授業名変更関数を登録！！！
                  await MyCourseDatabaseHandler()
                      .updateCourseName(id, value);
                  widget.setTimetableState((){});
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
                    int id = target["id"];
                    //＠ここに削除実行関数！！！
                    await MyCourseDatabaseHandler()
                        .deleteMyCourse(id);
                    widget.setTimetableState(() {});
                    Navigator.pop(context);
                  }),
              SizedBox(width: SizeConfig.blockSizeHorizontal! * 1),
            ]),
          ])
        )
      )
    );
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
    if(target["syllabusID"] != null &&
    target["syllabusID"] != ""){
      if(viewMode == 0){
        return buttonModel(
          (){
            setState(() {
              viewMode = 1;
            });
          },
          Colors.blueAccent,
          " シラバス詳細 ");
      }else{
        return const SizedBox();
      }   
    }else{
      return const SizedBox();
    }
  }

  Widget descriptionModeSwitch(){
    Map target = widget.target;
    if(target["syllabusID"] != null &&
    target["syllabusID"] != ""){
      if(viewMode == 0){
        return const SizedBox();
      }else{
        return buttonModel(
          (){
            setState(() {
              viewMode = 0;
            });
          },
          Colors.blueAccent,
          " もどる ");
      }   
    }else{

      return const SizedBox();
    }
  }

  Widget summaryContent(dividerModel, target) {
    return Column(children: [
      dividerModel,
      Row(children: [
        SizedBox(width: SizeConfig.blockSizeHorizontal! * 1),
        const Icon(Icons.access_time, color: MAIN_COLOR),
        SizedBox(width: SizeConfig.blockSizeHorizontal! * 3),
        Text(
            "${getJapaneseWeekday(target["weekday"])} ${target["period"]}限",
            style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal! * 5,
                fontWeight: FontWeight.normal)),
        SizedBox(width: SizeConfig.blockSizeHorizontal! * 3),
        Text(
            "${target["year"]} ${targetSemester(target["semester"])}",
            style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal! * 4,
                color: Colors.grey)),
        const Spacer(),
      ]),
      dividerModel,
      Row(children: [
        SizedBox(width: SizeConfig.blockSizeHorizontal! * 1),
        const Icon(Icons.group, color: MAIN_COLOR),
        SizedBox(width: SizeConfig.blockSizeHorizontal! * 3),
        textFieldModel("教室を入力…", classRoomController, FontWeight.normal, 20.0,
            (value) async {
          int id = target["id"];
          //＠ここに教室のアップデート関数！！！
          await MyCourseDatabaseHandler().updateClassRoom(id, value);
          widget.setTimetableState(() {});
        })
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
          await MyCourseDatabaseHandler().updateMemo(id, value);
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
              fillColor: WHITE,
              filled: true,
              border: InputBorder.none, hintText: hintText),
          style: TextStyle(
              fontSize: fontSize, color: Colors.black, fontWeight: weight),
          onSubmitted: onSubmitted),
    ));
  }

  String getJapaneseWeekday(int weekday) {
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
        return '無効な曜日';
    }
  }

  String targetSemester(String semesterID) {
    String result = "通年科目";
    if (semesterID == "spring_quarter") {
      result = "春学期 -春クォーター";
    } else if (semesterID == "summer_quarter") {
      result = "春学期 -夏クォーター";
    } else if (semesterID == "spring_semester") {
      result = "春学期";
    } else if (semesterID == "fall_quarter") {
      result = "秋学期 -秋クォーター";
    } else if (semesterID == "winter_quarter") {
      result = "秋学期 -冬クォーター";
    } else if (semesterID == "fall_semester") {
      result = "秋学期";
    }
    return result;
  }

  int maxAbsentNum = 0;
  int totalClassNum = 0;
  bool isClassNumSettingInit = true;

  void initClassNumSetting(){
    Map myCourseData = widget.target;
    if(isClassNumSettingInit){
     maxAbsentNum = myCourseData["remainAbsent"];
     totalClassNum = myCourseData["classNum"] ?? 0;
     isClassNumSettingInit = false;
    }
  }

  Widget attendMenuPanel(){
    initClassNumSetting();
    return GestureDetector(
      onTap:(){},
      child: Container(
          decoration: roundedBoxdecorationWithShadow(),
          padding: const EdgeInsets.symmetric(vertical:10.0,horizontal:20),
          width: SizeConfig.blockSizeHorizontal! * 95,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children:[
                const Text("出席管理",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22.5)),
                const Spacer(),
                remainingAbesentViewBuilder()
              ]),
              const SizedBox(height:5),
              attendRecordView(),
              const Divider(),
              attendSettingsPanel(),
          ])
       )
      );
  }

  Widget attendSettingsPanel(){
    return Material(
      child:ExpandablePanel(
        controller: ExpandableController(initialExpanded: false),
        header: const Text("設定",
          style: TextStyle(
            fontSize: 20,
            color:Colors.grey)),
        collapsed: const SizedBox(),
        expanded:remainingAbsentSetting()));
  }


  Widget remainingAbesentViewBuilder(){
    return FutureBuilder(
      future: MyCourseDatabaseHandler().getAttendStatusCount(widget.target["id"],AttendStatus.absent),
      builder: (context,snapShot){
        if(snapShot.connectionState == ConnectionState.done){
          if(snapShot.data == null){
            return remainingAbesentView(maxAbsentNum);
          }else{
            int  remainingLife = maxAbsentNum - snapShot.data!;
            if(remainingLife <= 0){
              remainingLife = 0;
            }
            return remainingAbesentView(remainingLife);
          }
        }else{
          return remainingAbesentView(maxAbsentNum);
        }
      });
  }

  Widget remainingAbesentView(int absentNum){
    return Container(
      padding:const EdgeInsets.symmetric(
        vertical: 3,horizontal: 10), 
      margin:const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color:BACKGROUND_COLOR,
        borderRadius: BorderRadius.circular(5)),
      child: Row(children:[
        const Text("残機 ",
          style:TextStyle(fontWeight:FontWeight.bold,fontSize: 20)),
        const Icon(Icons.favorite,color:Colors.redAccent,size:20),
        Text(" × " + absentNum.toString(),
          style:const TextStyle(fontWeight:FontWeight.bold,fontSize: 20,color:Colors.grey)),
      ]),
    );
  }

  Widget remainingAbsentSetting(){

    EdgeInsets containerPadding = const EdgeInsets.all(10);
    BoxDecoration containerDecoration = BoxDecoration(
      color:BACKGROUND_COLOR,
      border: Border.all(color:Colors.grey),
      borderRadius: BorderRadius.circular(15),
    );

    return Row(children:[
      const Spacer(),
      Column (children:[
        Container(
          padding: containerPadding,
          decoration: containerDecoration,
          child: Row(children:[
              changeNumButton("remainAbsent","decrease"),
              Text(maxAbsentNum.toString(),
                style:const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20)),
              changeNumButton("remainAbsent","increase")
          ]),
        ),
        const Text("最大欠席可能数",
        style: TextStyle(
          fontSize: 15,
          color:Colors.grey)),
      ]),
      const Spacer(),
      const Column(children:[
        Text(" / ",
          style: TextStyle(
            fontSize: 40,
            color:Colors.grey)),
        Text("  ",
          style: TextStyle(
            fontSize: 15)),
      ]),
      const Spacer(),
      Column (children:[
        Container(
          padding: containerPadding,
          decoration: containerDecoration,
          child: Row(children:[
              changeNumButton("classNum","decrease"),
              Text(totalClassNum.toString(),
                style:const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20)),
              changeNumButton("classNum","increase")
          ]),
        ),
        const Text("授業数",
        style: TextStyle(
          fontSize: 15,
          color:Colors.grey)),
      ]),
      const Spacer(),
    ]);
  }

  Widget changeNumButton(String numType,String buttonType){
    IconData buttonIcon = Icons.arrow_forward_ios;
    if(buttonType == "decrease"){
      buttonIcon = Icons.arrow_back_ios;
    }

    return GestureDetector(
      child:Icon(buttonIcon,color:Colors.grey,size: 17,),
      onTap: ()async{
        if(numType == "classNum"){
          if(buttonType == "increase"){
            totalClassNum += 1;
          }else{
            totalClassNum -= 1;
          }
          if(totalClassNum <= 0){
            totalClassNum = 0;
          }
          if(totalClassNum <= maxAbsentNum){
            totalClassNum = maxAbsentNum;
          }
          await MyCourseDatabaseHandler().updateClassNum(
            widget.target["id"],totalClassNum);
          setState((){});
          widget.setTimetableState((){});
          
        }else{
          if(buttonType == "increase"){
            maxAbsentNum += 1;
          }else{
            maxAbsentNum -= 1;
          }
          if(maxAbsentNum <= 0){
            maxAbsentNum = 0;
          }
          if(maxAbsentNum >= totalClassNum ){
            maxAbsentNum = totalClassNum;
          }
          await MyCourseDatabaseHandler().updateRemainAbsent(
            widget.target["id"], maxAbsentNum);
          setState((){});
          widget.setTimetableState((){});
        }

      }
    );
  }

  Widget attendRecordView(){
    return Material(
      child:ExpandablePanel(
        controller: ExpandableController(initialExpanded: true),
        header: const Text("出欠記録",
          style: TextStyle(
            fontSize: 20,
            color:Colors.grey)),
        collapsed: const SizedBox(),
        expanded:Column(children:[
          attendRecordListBuilder(),
          addRecordButton()
        ]) ));
  }

  Widget attendRecordListBuilder(){
    return FutureBuilder(
      future:MyCourseDatabaseHandler().getAttendanceRecordFromDB(widget.target["id"]),
      builder: (context,snapshot){
        if(snapshot.connectionState == ConnectionState.done){
          if(snapshot.data == null || snapshot.data!.isEmpty){
            return const SizedBox();
            const Center(
              child:Text("データはありません。",
                style: TextStyle(color:Colors.grey,fontSize: 20)));
          }else{
            return attendRecordList(snapshot.data!);
          }
        }else{
          return const Center(
              child:CircularProgressIndicator(color:PALE_MAIN_COLOR));
        }
      });
  }

  
  Widget attendRecordList(List attendRecordList){
    return ListView.builder(
      itemCount: attendRecordList.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context,index){
         return attendRecordListPanel(attendRecordList.elementAt(index));
      });
  }

  Widget attendRecordListPanel(Map attendRecord){
    String attendStatusText = "";
    Color attendStatusColor = Colors.white;
    if(attendRecord["attendStatus"] == "attend"){
      attendStatusText = "出席";
      attendStatusColor = Colors.blue;
    }else if(attendRecord["attendStatus"] =="late"){
      attendStatusText = "遅刻";
      attendStatusColor = const Color.fromARGB(255, 223, 200, 0);
    }else{
      attendStatusText = "欠席";
      attendStatusColor = Colors.redAccent;
    }

    return GestureDetector(
      onTap:()async{
        showIndividualCourseEditDialog(
          context,widget.target,
          initData: attendRecord,
          (){
            setState(() {});
            widget.setTimetableState((){});
          });
      },
    child:Container(
      padding:const EdgeInsets.symmetric(
        vertical: 5,horizontal: 15),
      margin:const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color:BACKGROUND_COLOR,
        borderRadius: BorderRadius.circular(10)
      ),
      child: Row(children:[
        Text(attendRecord["attendDate"],
          style:const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20)),
        const Spacer(),
        Container(
          padding:const EdgeInsets.symmetric(
            vertical: 5,horizontal: 15),
          margin:const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color:attendStatusColor,
            borderRadius: BorderRadius.circular(10)
          ),
          child: Text(attendStatusText,
            style:const TextStyle(
              fontWeight:FontWeight.bold,
              fontSize: 15,
              color: Colors.white),),
        )
      ])
    )
    );
  }
  
  Widget addRecordButton(){
     return GestureDetector(
      onTap:()async{
        showIndividualCourseEditDialog(
          context,widget.target,
          (){
            setState(() {});
            widget.setTimetableState((){});
          });
      },
      child:Container(
      padding:const EdgeInsets.symmetric(
        vertical: 5,horizontal: 15),
      margin:const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color:BACKGROUND_COLOR,
        borderRadius: BorderRadius.circular(10)
      ),
      child:const Center(child:
      Icon(Icons.add,color: Colors.grey,size:30))
     ));
  }

  Widget relatedTasks() {
    if (widget.taskList.isNotEmpty) {
      return Container(
          decoration: roundedBoxdecorationWithShadow(),
          padding: const EdgeInsets.all(10.0),
          width: SizeConfig.blockSizeHorizontal! * 95,
          child: Column(children: [

            Row(children: [
              const SizedBox(width:10),
              const Text("関連する課題",
                  style: TextStyle(fontSize: 22.5, fontWeight: FontWeight.bold)),
              const Spacer(),
              lengthBadge(widget.taskList.length,17.5,false),
              const SizedBox(width:10),
            ],),

            const SizedBox(height:5),
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
        onTap: () async{
          await bottomSheet(context,target, widget.setTimetableState);
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
                      color: WHITE,
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
