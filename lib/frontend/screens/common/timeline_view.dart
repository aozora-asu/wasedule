import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/handler/my_course_db.dart';
import 'package:flutter_calandar_app/backend/DB/handler/task_db_handler.dart';
import 'package:flutter_calandar_app/backend/DB/sharepreference.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/assist_files/data_loader.dart';
import 'package:flutter_calandar_app/frontend/assist_files/ui_components.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/calendar_data_manager.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/tag_and_template_page.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/task_data_manager.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/task_progress_indicator.dart';
import 'package:flutter_calandar_app/frontend/screens/timetable_page/timetable_data_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../assist_files/size_config.dart';

class TimelineDrawer extends ConsumerWidget {
  double drawerWidth = SizeConfig.blockSizeHorizontal! *80;
  TimelineDrawer({super.key});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    return Drawer(
      width:drawerWidth,
      backgroundColor: BACKGROUND_COLOR,
      child: Column(children:[
          Container(
            width: drawerWidth,
            height: SizeConfig.blockSizeVertical! *15,
            decoration:const BoxDecoration(
              color: MAIN_COLOR,
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(children:[
                  Spacer(),
                  Text(
                    'TIMELINE  ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ])
              ],
            ),
          ),
          Container(
            height: SizeConfig.blockSizeVertical! *1,
            decoration:const BoxDecoration(
              color: MAIN_COLOR,
          )),
        Timeline()
      ])
    );
  }

}



class Timeline extends ConsumerStatefulWidget{
  @override 
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends ConsumerState<Timeline>{
  late bool isShowSchedule;
  late bool isShowTask;
  late bool isShowCourse;

  @override 
  void initState(){
    super.initState();
    isShowSchedule = SharepreferenceHandler().getValue(SharepreferenceKeys.isShowTimelineSchedule);
    isShowTask = SharepreferenceHandler().getValue(SharepreferenceKeys.isShowTimelineTask);
    isShowCourse = SharepreferenceHandler().getValue(SharepreferenceKeys.isShowTimelineCourse);
  }

  Future<List<Map<String, dynamic>>> loadDataBases() async {
    List<Map<String,dynamic>> taskData = 
      await TaskDatabaseHelper().getTaskFromDB();
    await ref
        .read(calendarDataProvider)
        .getTagData(TagDataLoader().getTagDataSource());
    ref
    .read(taskDataProvider)
    .getData(taskData);
    await ref
        .read(timeTableProvider)
        .getData(TimeTableDataLoader().getTimeTableDataSource());
    List<Map<String, dynamic>> result =
        await CalendarDataLoader().getDataSource();
    return result;
  }

  @override 
  Widget build(BuildContext context){
    return Expanded(child:
      Stack(children:[
        ListView(
          padding:const EdgeInsets.symmetric(horizontal: 5,vertical: 0),
          children:[
            timelineBuilder(),
        ]),
        checkBoxRow(),
      ])
    );
  }

  Widget checkBoxRow() {
    return Container(
      color: PALE_MAIN_COLOR,
      padding:const EdgeInsets.symmetric(horizontal: 10),
      child:Row(children: [
        checkBox(isShowSchedule, "予定", (newValue) {
          SharepreferenceHandler()
            .setValue(SharepreferenceKeys.isShowTimelineSchedule,newValue);
          setState(() {
            isShowSchedule = newValue;
          });
        }),
        const Spacer(),
        checkBox(isShowTask, "課題", (newValue) {
          SharepreferenceHandler()
            .setValue(SharepreferenceKeys.isShowTimelineTask,newValue);
          setState(() {
            isShowTask = newValue;
          });
        }),
        const Spacer(),
        checkBox(isShowCourse, "授業", (newValue) {
          SharepreferenceHandler()
            .setValue(SharepreferenceKeys.isShowTimelineCourse,newValue);
          setState(() {
            isShowCourse = newValue;
          });
        }),
      ])
    );
  }

  Widget checkBox(bool value, String text, Function(bool) onChanged) {
    return Row(children: [
      Text(text, style: const TextStyle(color: Colors.white, fontSize: 15)),
      CupertinoCheckbox(
          value: value,
          onChanged: (newValue) {
            onChanged(newValue!);
          }),
    ]);
  }

  Widget timelineBuilder(){
    return FutureBuilder(
      future:loadDataBases(),
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting){
          return const SizedBox();
        }else if(snapshot.hasData){
          ref.read(calendarDataProvider).getData(snapshot.data!);
          ref.read(calendarDataProvider).sortDataByDay();
          return ListView.builder(
            itemBuilder: (context, index) {
              final DateTime now = DateTime.now();
              // 今日の日付からインデックス分の差を計算
              final date = DateTime(now.year,now.month,now.day).add(Duration(days: index));
              return dayObject(date);
            },
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount:180
          );
        }else{
          return const  CircularProgressIndicator(color:PALE_MAIN_COLOR);
        }
    },);
  }

  DaylyData getDaylyData(DateTime targetDay){
    final calendar = ref.read(calendarDataProvider);
    final task = ref.read(taskDataProvider);
    final timetable = ref.read(timeTableProvider);
    DaylyData result = DaylyData();
    String targetDayString = DateFormat("yyyy-MM-dd").format(targetDay);

    if(calendar.sortedDataByDay[targetDayString] != null
      && isShowSchedule){
      result.calendar = calendar.sortedDataByDay[targetDayString];
    }

    if(task.sortedDataByDTEnd[targetDay] != null
      && isShowTask){
      result.task = task.sortedDataByDTEnd[targetDay];
    }

    if(timetable.targetDateClasses(targetDay).isNotEmpty
      && isShowCourse){
      result.timeTable = timetable.targetDateClasses(targetDay);
    }

    return result;
  }

  Widget dayObject(DateTime targetDay){
    final formattedDate = DateFormat('M月d日(E)', 'ja_JP').format(targetDay);
    int fromToday = targetDay.difference(now).inDays;
    DaylyData targetDayData = getDaylyData(targetDay);
    bool hasData = targetDayData.hasData();

    return hasData ?
    Column(children: [
      Row(
       crossAxisAlignment: CrossAxisAlignment.end,
       children:[
          const SizedBox(width: 5),
          Text(formattedDate,
            style:const TextStyle(fontWeight: FontWeight.bold,fontSize:20,color:BLUEGREY)),
          const Spacer(),
          Text("  $fromToday 日後",
            style: const TextStyle(fontSize:13,color:Colors.grey,fontWeight:FontWeight.bold)),
          const SizedBox(width: 5),
        ]),
        ListView.builder(
          itemBuilder:(context,index){
            return targetDayData.integratedData(ref).elementAt(index).values.first;
          },
          itemCount: targetDayData.integratedData(ref).length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),),
        const SizedBox(height:15),
    ])
    : const SizedBox();
  }

}




class DaylyData{
  List<dynamic>? calendar;
  List<MyCourse?>? timeTable;
  List<Map<String,dynamic>?>? task;

  DaylyData({
    this.calendar,
    this.timeTable,
    this.task});

  bool hasData(){
    if((calendar == null || calendar!.isEmpty) &&
      (timeTable == null || timeTable!.isEmpty) &&
      (task == null || task!.isEmpty)){
      return false;
    } else {
      return true;
    }
  }

  List<Map<DateTime,Widget>> integratedData(ref){
    List<Map<DateTime,Widget>> result = [];
    DateTime now = DateTime.now();

    if(calendar != null && calendar!.isNotEmpty){
      for(int i = 0; i < calendar!.length; i++){
        dynamic target = calendar!.elementAt(i);
        DateTime startDate = now;
        DateTime startTime = DateFormat("HH:mm").tryParse(target["startTime"]) ?? DateFormat("HH:mm").parse("23:59");
        DateTime? endTime = DateFormat("HH:mm").tryParse(target["endTime"]);
        bool allDay = false;

        if(DateFormat("HH:mm").tryParse(target["startTime"]) == null){
          startDate = now.subtract(const Duration(days:1));
          allDay = true;
        }
       
        DateTime startDateTime = 
          DateTime(startDate.year,startDate.month,startDate.day,
                   startTime.hour,startTime.minute,startTime.second);

        Widget tag = Row(children: [
          tagThumbnail(target["tagID"],ref),
          Text(
              " ${returnTagTitle(target["tagID"] ?? "", ref)}",
              overflow: TextOverflow.clip,
              style: const TextStyle(
                  color: Colors.grey, fontSize: 10),
            )
        ]);
        
        result.add({startDateTime:
        calendarListChild(
          startDateTime,
          target,
          allDay:allDay,
          endTime: endTime,
          tag: tag)});
      }
    }
 
    if(task != null && task!.isNotEmpty){
      for(int i = 0; i < task!.length; i++){
        Map<String,dynamic>? target = task!.elementAt(i);
        DateTime dateTimeEnd = DateTime.fromMillisecondsSinceEpoch(target!["dtEnd"]);
        DateTime timeEnd = DateTime(now.year,now.month,now.day,
          dateTimeEnd.hour,dateTimeEnd.month,dateTimeEnd.second);

        result.add({timeEnd:taskListChild(timeEnd,target)});
      }
    }

    if(timeTable != null && timeTable!.isNotEmpty){
      for(int i = 0; i < timeTable!.length; i++){
        MyCourse? target = timeTable!.elementAt(i);
        DateTime timeStart = target!.period!.start;
        DateTime dateTimeStart = DateTime(now.year,now.month,now.day,
          timeStart.hour,timeStart.minute,timeStart.second);

        result.add({dateTimeStart:timetableListChild(dateTimeStart,target)});
      }
    }

    result.sort((a, b) {
      DateTime dateA = a.keys.first;
      DateTime dateB = b.keys.first;
      return dateA.compareTo(dateB);
    });

    return result;

  }


  TextStyle smallChar =const TextStyle(fontSize:10,color:Colors.grey);
  TextStyle largeChar =const TextStyle(fontSize:15,fontWeight:FontWeight.bold);
  Icon listIcon(IconData icon,Color color){return Icon(icon,color:color,size: 14);}

  Widget calendarListChild(
    DateTime time,dynamic calendarData,{bool allDay = false, DateTime? endTime,Widget? tag}){

    return listChildFrame(time,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Row(children: [
          listIcon(Icons.calendar_month,PALE_MAIN_COLOR),
          Text(" 予定",style:smallChar),
          const Spacer(),
          tag ?? const SizedBox()
        ]),
        Text(calendarData["subject"],style:largeChar)
      ]),  
      allDay:allDay,endTime:endTime);
  }

  Widget tagThumbnail(String? id,ref) {
    if (id == null) {
      return Container();
    } else {
      if (returnTagColor(id, ref) == null) {
        return Container();
      } else {
        return Row(children: [
          const SizedBox(width: 1),
          Container(
              width: 5,
              height: 12,
              color: returnTagColor(id, ref))
        ]);
      }
    }
  }

  Widget taskListChild(DateTime time,Map<String,dynamic> taskData){
    return listChildFrame(time,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Row(children: [
          listIcon(Icons.task,Colors.blueAccent),
          Text(" 課題",style:smallChar),
          const Spacer()
        ]),
        Text(taskData["summary"],style:largeChar)
      ]));
  }

  Widget timetableListChild(DateTime time,MyCourse courseData){
    return listChildFrame(time,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Row(children: [
          listIcon(Icons.school,MAIN_COLOR),
          Text(" 授業",style:smallChar),
          const Spacer()
        ]),
        Text(courseData.courseName,style:largeChar)
      ]));
  }

  Widget listChildFrame(DateTime time,Widget child,{bool allDay = false, DateTime? endTime}){
    String endTimeString = endTime == null ? "" :  "\n" + DateFormat("HH:mm").format(endTime);
    String timeString = DateFormat("HH:mm").format(time) + endTimeString;
    return Row(
     children:[
      Container(
        alignment: Alignment.center,
        width: 30,
        child: Text(allDay ? "終日" : timeString,
          style:const TextStyle(fontSize: 10,fontWeight: FontWeight.bold,),)),
      Expanded(child:Container(
        decoration: roundedBoxdecoration(radiusType: 2),
        padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 15),
        margin: const EdgeInsets.symmetric(vertical: 1,horizontal: 3),
        child: child,
      ))
    ]);
  }



}