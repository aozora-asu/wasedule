import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/screens/timetable_page/timetable_data_manager.dart';
import 'package:flutter_calandar_app/static/constant.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AttendStatsPage extends ConsumerStatefulWidget{
  @override
  _AttendStatsPageState createState() => _AttendStatsPageState();
}

class _AttendStatsPageState extends ConsumerState<AttendStatsPage>{
  late int thisYear;
  late Term currentQuarter;
  late Term currentSemester;
  late DateTime now;
  List currentCourseDataList = [];

  @override
  void initState(){
    super.initState();
    now = DateTime.now();
    initTargetSem();
  }

  void generateCurrentCourseData(){
    currentCourseDataList = [];
    List data = ref.read(timeTableProvider).timeTableDataList;
    for(int i = 0; i < data.length; i++){
      int targetYear = data.elementAt(i)["year"];
      String targetSemester = data.elementAt(i)["semester"];
      if(currentSemester == Term.springSemester &&
       targetYear == thisYear){

        if(targetSemester == Term.springSemester.value
         || targetSemester == Term.springQuarter.value
         || targetSemester == Term.summerQuarter.value){
          currentCourseDataList.add(data.elementAt(i));
        }

      }else if(currentSemester == Term.fallSemester &&
       targetYear == thisYear){

        if(targetSemester == Term.fallSemester.value
         || targetSemester == Term.fallQuarter.value
         || targetSemester == Term.winterQuarter.value){
          currentCourseDataList.add(data.elementAt(i));
        }

      }else{

        if(targetSemester == Term.fullYear.value){
          currentCourseDataList.add(data.elementAt(i));
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
  Widget build(BuildContext context){
    generateCurrentCourseData();
    return Scaffold(
      backgroundColor: BACKGROUND_COLOR,
      body: Column(children:[
        header(),
        semesterCourseList(),
      ])
    );
  }

  Widget header(){
    return Row(children: [
      IconButton(
          onPressed: () {
            decreasePgNumber();
          },
          icon: const Icon(Icons.arrow_back_ios),
          iconSize: 20,
          color: BLUEGREY),
      Text(
        "$thisYear年  ${currentSemester.text}",
        style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: BLUEGREY),
      ),
      IconButton(
          onPressed: () {
            setState(() {
              increasePgNumber();
            });
          },
          icon: const Icon(Icons.arrow_forward_ios),
          iconSize: 20,
          color: BLUEGREY),
      const Spacer(),
      const SizedBox(width: 40),
    ]);
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

  Widget semesterCourseList(){
    return Expanded(
      child:Padding(
        padding:const EdgeInsets.symmetric(horizontal: 10),
        child:ListView.separated(
          itemBuilder: (context,index){
            return Text(currentCourseDataList.elementAt(index)["courseName"]);
          },
          separatorBuilder: (context,index){
            return const SizedBox(height:5);
          },
          itemCount: currentCourseDataList.length,
          shrinkWrap: true,
          ))
    );
  }
}