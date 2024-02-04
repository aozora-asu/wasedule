import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/handler/schedule_db_handler.dart';
import 'package:flutter_calandar_app/backend/DB/handler/task_db_handler.dart';
import 'package:flutter_calandar_app/backend/temp_file.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/data_manager.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/daily_view_page.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/schedule_data_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'brief_task_text.dart';
import '../../assist_files/size_config.dart';
import 'add_event_button.dart';
import '../common/loading.dart';

import 'dart:async';
import 'dart:io';
// ignore: unnecessary_import

import 'package:flutter/cupertino.dart';

import '../../../backend/notify/notify_setting.dart';
import '../../../backend/DB/models/notify_content.dart';
import '../../../backend/notify/notify.dart';

class Calendar extends ConsumerStatefulWidget {
  const Calendar({
    Key? key,
  }) : super(key: key);
  // final NotificationAppLaunchDetails? notificationAppLaunchDetails;
  // bool get didNotificationLaunchApp =>
  //     notificationAppLaunchDetails?.didNotificationLaunchApp ?? false;
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends ConsumerState<Calendar> {
  bool _notificationsEnabled = false;
  final StreamController<ScheduleNotification>
      didScheduleLocalNotificationStream =
      StreamController<ScheduleNotification>.broadcast();
 
  late String targetMonth = "";
  String thisMonth = DateTime.now().year.toString() + "/" + DateTime.now().month.toString().padLeft(2, '0');
  String today = DateTime.now().year.toString() + "/" + DateTime.now().month.toString().padLeft(2, '0') + "/" + DateTime.now().day.toString().padLeft(2, '0');

 
  @override
  void initState() {
    super.initState();
    _isAndroidPermissionGranted();
    _requestPermissions();
    _configureDidReceiveLocalNotificationSubject();
    _configureSelectNotificationSubject();
    testNotify();
    targetMonth = thisMonth;
    generateCalendarData();
    _initializeData();
  }

  testNotify() async {
    //await Notify().repeatNotification();
    await Notify().scheduleDailyEightAMNotification();
  }

  Future<void> _isAndroidPermissionGranted() async {
    final bool granted = await isAndroidPermissionGranted();
    setState(() {
      _notificationsEnabled = granted;
    });
  }

  Future<void> _requestPermissions() async {
    final bool? grantedNotificationPermission = await requestPermissions();
    setState(() {
      _notificationsEnabled = grantedNotificationPermission ?? false;
    });
  }

  void _configureDidReceiveLocalNotificationSubject() {
    didScheduleLocalNotificationStream.stream
        .listen((ScheduleNotification receivedNotification) async {
      await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: receivedNotification.title != null
              ? Text(receivedNotification.title!)
              : null,
          content: receivedNotification.body != null
              ? Text(receivedNotification.body!)
              : null,
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();
                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => const Calendar(),
                  ),
                );
              },
              child: const Text('Ok'),
            )
          ],
        ),
      );
    });
  }

  //通知からアプリを開いた時の処理
  void _configureSelectNotificationSubject() {
    selectNotificationStream.stream.listen((String? payload) async {
      await Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (BuildContext context) => const Calendar(),
      ));
    });
  }

  @override
  void dispose() {
    didScheduleLocalNotificationStream.close();
    selectNotificationStream.close();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _getDataSource() async {
    List<Map<String, dynamic>> scheduleList =
        await ScheduleDatabaseHelper().getScheduleFromDB();
    return scheduleList;
  }



  TaskDatabaseHelper databaseHelper = TaskDatabaseHelper();
  String urlString = url_t;
  Future<List<Map<String, dynamic>>>? events;

  bool setIsAllDay(Map<String, dynamic> schedule) {
    //startTimeとendTimeのどちらも空だった場合にtrueを返す
    if (schedule['startTime'] == null && schedule['endTime'] == null) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> _initializeData() async {
    if (await databaseHelper.hasData() == true) {
      await displayDB();
    } else {
      if (urlString == "") {
        // urlStringがない場合の処理
      } else {
        noneTaskText();
      }
    }
  }

  Widget noneTaskText() {
    return const Text("現在課題はありません。");
  }

  //データベースを更新する関数。主にボタンを押された時のみ
  Future<void> loadData() async {
    await databaseHelper.resisterTaskToDB(urlString);

    await displayDB();
  }

  List<Map<String, dynamic>> taskData = [];
  
  Future<void> displayDB() async {
    final addData = await databaseHelper.taskListForTaskPage();
    if (mounted) {
      setState(() {
        events = Future.value(addData);
      });
      taskData.addAll(addData);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(calendarDataProvider);
    SizeConfig().init(context);
    return Scaffold(
      body: ListView(
          children: [
            SizedBox(
              height: SizeConfig.blockSizeHorizontal! * 200,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _getDataSource(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // データが取得される間、ローディングインディケータを表示できます。
                    return calendarBody();
                  } else if (snapshot.hasError) {
                    // エラーがある場合、エラーメッセージを表示します。
                    return Text('エラーだよい: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    // データがないか、データが空の場合、空っぽのカレンダーを表示。
                    return calendarBody();
                  } else {
                    // データが利用可能な場合、取得したデータを使用してカレンダーを構築します。
                     print(snapshot.data);
                     ref.read(calendarDataProvider).getData(snapshot.data!);
                     ref.read(calendarDataProvider).sortDataByDay();
                     ref.read(taskDataProvider).getData(taskData);
                    return calendarBody();
                  }
                },
              ),
            ),
            BriefTaskList(),
          ],
        ),
      floatingActionButton: AddEventButton(),
    );
  }
  
  Widget calendarBody(){
    return Column(children:[
        SizedBox(
        child:Row(children:[
        IconButton(
          onPressed:(){
            decreasePgNumber();
          }, 
          icon: Icon(Icons.arrow_back_ios),iconSize:20),
         Text(targetMonth,
          style: TextStyle(fontSize:25,fontWeight:FontWeight.w700,),  
         ),
        IconButton(
          onPressed:(){
            setState((){increasePgNumber();});
          }, 
          icon: Icon(Icons.arrow_forward_ios),iconSize:20)
       ]),
       ),
       SizedBox(
        width: SizeConfig.blockSizeHorizontal! *100,
        height: SizeConfig.blockSizeVertical! *4,
        child:generateWeekThumbnail (),),
       SizedBox(
        width: SizeConfig.blockSizeHorizontal! *100,
        child:Row(children:[
          generateCalendarCells("sunday"),
          generateCalendarCells("monday"),
          generateCalendarCells("tuesday"),
          generateCalendarCells("wednesday"),
          generateCalendarCells("thursday"),
          generateCalendarCells("friday"),
          generateCalendarCells("saturday")
       ])
      )
       
    ]);
  }

 void increasePgNumber(){
   String increasedMonth = "";
    
    if(targetMonth.substring(5,7) == "12"){
    int year = int.parse(targetMonth.substring(0,4));
    year += 1;
      setState((){increasedMonth =  year.toString() + "/" + "01";});
    }else{
     int month = int.parse(targetMonth.substring(5,7));
     month += 1;
     setState((){increasedMonth = targetMonth.substring(0,5) + month.toString().padLeft(2, '0');});
    }

    targetMonth = increasedMonth;
    generateCalendarData();
  }

 void decreasePgNumber(){
   String decreasedMonth = "";
    
    if(targetMonth.substring(5,7) == "01"){
    int year = int.parse(targetMonth.substring(0,4));
    year -= 1;
      setState((){decreasedMonth =  year.toString() + "/" + "12";});
    }else{
     int month = int.parse(targetMonth.substring(5,7));
     month -= 1;
     setState((){decreasedMonth = targetMonth.substring(0,5) + month.toString().padLeft(2, '0');});
    }

    targetMonth = decreasedMonth;
    generateCalendarData();
  }

  Map<String,List<DateTime>> generateCalendarData(){
   DateTime firstDay = DateTime(int.parse(targetMonth.substring(0,4)),int.parse(targetMonth.substring(5,7)));
   List<DateTime> firstWeek = [];

   List<DateTime> sunDay = [];
   List<DateTime> monDay = [];
   List<DateTime> tuesDay = [];
   List<DateTime> wednesDay = [];
   List<DateTime> thursDay = [];
   List<DateTime> friDay = [];
   List<DateTime> saturDay = [];
   
   switch (firstDay.weekday){
    case 1: firstWeek = [
      firstDay.subtract(const Duration(days: 1)),
      firstDay,
      firstDay.add(const Duration(days: 1)),
      firstDay.add(const Duration(days: 2)),
      firstDay.add(const Duration(days: 3)),
      firstDay.add(const Duration(days: 4)),
      firstDay.add(const Duration(days: 5)),
      ];
    case 2: firstWeek = [
      firstDay.subtract(const Duration(days: 2)),
      firstDay.subtract(const Duration(days: 1)),
      firstDay,
      firstDay.add(const Duration(days: 1)),
      firstDay.add(const Duration(days: 2)),
      firstDay.add(const Duration(days: 3)),
      firstDay.add(const Duration(days: 4)),
      ];
    case 3: firstWeek = [
      firstDay.subtract(const Duration(days: 3)),
      firstDay.subtract(const Duration(days: 2)),
      firstDay.subtract(const Duration(days: 1)),
      firstDay,
      firstDay.add(const Duration(days: 1)),
      firstDay.add(const Duration(days: 2)),
      firstDay.add(const Duration(days: 3)),
      ];
    case 4: firstWeek = [
      firstDay.subtract(const Duration(days: 4)),
      firstDay.subtract(const Duration(days: 3)),
      firstDay.subtract(const Duration(days: 2)),
      firstDay.subtract(const Duration(days: 1)),
      firstDay,
      firstDay.add(const Duration(days: 1)),
      firstDay.add(const Duration(days: 2)),
      ];
    case 5: firstWeek = [
      firstDay.subtract(const Duration(days: 5)),
      firstDay.subtract(const Duration(days: 4)),
      firstDay.subtract(const Duration(days: 3)),
      firstDay.subtract(const Duration(days: 2)),
      firstDay.subtract(const Duration(days: 1)),
      firstDay,
      firstDay.add(const Duration(days: 1)),
      ];
    case 6: firstWeek = [
      firstDay.subtract(const Duration(days: 6)),
      firstDay.subtract(const Duration(days: 5)),
      firstDay.subtract(const Duration(days: 4)),
      firstDay.subtract(const Duration(days: 3)),
      firstDay.subtract(const Duration(days: 2)),
      firstDay.subtract(const Duration(days: 1)),
      firstDay,
      ];
    case 7: firstWeek = [
      firstDay,
      firstDay.add(const Duration(days: 1)),
      firstDay.add(const Duration(days: 2)),
      firstDay.add(const Duration(days: 3)),
      firstDay.add(const Duration(days: 4)),
      firstDay.add(const Duration(days: 5)),
      firstDay.add(const Duration(days: 6)),
      ];
    default : firstWeek = [
      firstDay,
      firstDay.add(const Duration(days: 1)),
      firstDay.add(const Duration(days: 2)),
      firstDay.add(const Duration(days: 3)),
      firstDay.add(const Duration(days: 4)),
      firstDay.add(const Duration(days: 5)),
      firstDay.add(const Duration(days: 6)),
      ];
   }
    sunDay = generateWeek(firstWeek.elementAt(0));
    monDay = generateWeek(firstWeek.elementAt(1));
    tuesDay = generateWeek(firstWeek.elementAt(2));
    wednesDay = generateWeek(firstWeek.elementAt(3));
    thursDay = generateWeek(firstWeek.elementAt(4));
    friDay = generateWeek(firstWeek.elementAt(5));
    saturDay = generateWeek(firstWeek.elementAt(6));

    Map<String,List<DateTime>> result = {
      "sunday" : sunDay,
      "monday" : monDay,
      "tuesday" : tuesDay,
      "wednesday" : wednesDay,
      "thursday" : thursDay,
      "friday" : friDay,
      "saturday" : saturDay
    };

    return result;
  }

  Widget generateWeekThumbnail (){
    List<String> days = ["日","月","火","水","木","金","土"];
    return ListView.builder(
      itemBuilder: (context,index){
       return Container(
          width: SizeConfig.blockSizeHorizontal! *14.285,
          height: SizeConfig.blockSizeVertical! *4,
          child: Center(
            child:Text(
              days.elementAt(index),
              style:const TextStyle(
                color: Colors.grey),
              )
            )
       );
      },
      itemCount:7,
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
    );
  }

  List<DateTime>generateWeek(DateTime firstDayOfDay){
   List<DateTime> result = [
    firstDayOfDay,
    firstDayOfDay.add(const Duration(days:7 )),
    firstDayOfDay.add(const Duration(days:14)),
    firstDayOfDay.add(const Duration(days:21)),
    firstDayOfDay.add(const Duration(days:28)),
    firstDayOfDay.add(const Duration(days:35))
   ];
   return result;
  }

  Widget generateCalendarCells(String dayOfWeek){
    return 
    Container(
      width: SizeConfig.blockSizeHorizontal! *14.285,
      child:ListView.builder(
      itemBuilder: (context,index){
        DateTime target = generateCalendarData()[dayOfWeek]!.elementAt(index);
       return InkWell(
    child:Container(
          width: SizeConfig.blockSizeHorizontal! *14.285,
          height: SizeConfig.blockSizeVertical! *12,
          
          decoration: BoxDecoration(
            color: cellColour(target),
            border: Border.all(
              color: Colors.grey,
              width: 0.5,
            ),
          ),
          child:Column(
           mainAxisAlignment: MainAxisAlignment.start,
           children:[
           Row(children:[
            Align(
              alignment: Alignment.centerLeft,
              child:Text(target.day.toString())
            ),
            const Spacer(),
            taskListLength(target,9.0),
            const SizedBox(width:3)
           ]),
           const Divider(height:0.7,indent:2,endIndent:2,thickness: 0.7,),
           Expanded(child: calendarCellsChild(target))
           
          ])
        ),
          onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DailyViewPage(target: target)),
          );
        },
        );
      }, 
      itemCount:generateCalendarData()[dayOfWeek]!.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      )
    );
  }

  Color cellColour(DateTime target){
    DateTime targetmonthDT = DateTime(int.parse(targetMonth.substring(0,4)),int.parse(targetMonth.substring(5,7))); 
    if(target.year == DateTime.now().year && target.month == DateTime.now().month && target.day == DateTime.now().day){
     return const Color.fromARGB(255, 255, 207, 207);
    }else if(target.month != targetmonthDT.month){
     return const Color.fromARGB(255, 242, 242, 242);
    }else if(target.weekday == 6){
     return Colors.white;//Color.fromARGB(255, 227, 238, 255);
    }else if(target.weekday == 7){
     return Colors.white;//Color.fromARGB(255, 255, 239, 239);
    }else{
     return Colors.white;
    }
  }

  Widget taskListLength(target,fontSize){
    final taskData = ref.watch(taskDataProvider);
    Map<DateTime, List<Map<String, dynamic>>> sortedData = 
    taskData.sortDataByDtEnd(taskData.taskDataList);

    if(sortedData[target] == null){
      return const SizedBox();
    }else{
    return Container(
      decoration: const BoxDecoration(
        color: Colors.redAccent,
        shape: BoxShape.circle,
      ),
      padding: EdgeInsets.all(fontSize / 3),
      child:Text(
        (sortedData[target]?.length ?? 0).toString(),
        style:  TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize:fontSize
          ),
        )
      );}
  }

  Widget calendarCellsChild(DateTime target){
    Widget dateTimeData = Container();
    final data = ref.watch(calendarDataProvider);
    String targetKey =  target.year.toString()+ "-" + target.month.toString().padLeft(2,"0") + "-" + target.day.toString().padLeft(2,"0");
    if(data.sortedDataByDay.keys.contains(targetKey)){
      List<dynamic> targetDayData = data.sortedDataByDay[targetKey];
      return SizedBox(
        child:ListView.separated(
          itemBuilder: (context,index){
            if (targetDayData.elementAt(index)["startTime"].trim() != "" && targetDayData.elementAt(index)["endTime"].trim() != ""){
              dateTimeData =
                  Text(
                    " " + targetDayData.elementAt(index)["startTime"] + "～" + targetDayData.elementAt(index)["endTime"],
                    style: const TextStyle(color: Colors.grey,fontSize: 7),
                  );
            } else if (targetDayData.elementAt(index)["startTime"].trim() != ""){
              dateTimeData =
                  Text(
                    " " + targetDayData.elementAt(index)["startTime"],
                    style: const TextStyle(color: Colors.grey,fontSize: 7),
                  );
            } else {
              dateTimeData =  const Text(
                    " 終日",
                    style: TextStyle(color: Colors.grey,fontSize: 7),
                  );
            }
            return Container(
              
              child:Column(
               crossAxisAlignment:CrossAxisAlignment.start,
               children:[
                Align(
                  alignment: Alignment.centerLeft,
                  child:dateTimeData),
                Text(
                  " " + targetDayData.elementAt(index)["subject"],
                  style: const TextStyle(color: Colors.black,fontSize: 8),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  ),
              ])
            );
          },
          separatorBuilder: (context,index){
            return const Divider(height:0.7,indent:2,endIndent:2,thickness: 0.7,);
          },
          itemCount: targetDayData.length,
          shrinkWrap: true,
          )
       );
    }else{
      return const Center();
    }
  }

}
