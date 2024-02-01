import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/handler/schedule_db_handler.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/schedule_data_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'brief_task_text.dart';
import '../../assist_files/size_config.dart';
import 'add_event_button.dart';
import 'event.dart';
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

  bool setIsAllDay(Map<String, dynamic> schedule) {
    //startTimeとendTimeのどちらも空だった場合にtrueを返す
    if (schedule['startTime'] == null && schedule['endTime'] == null) {
      return true;
    } else {
      return false;
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

  List<DateTime>generateWeek(DateTime firstDayOfDay){
   List<DateTime> result = [
    firstDayOfDay,
    firstDayOfDay.add(const Duration(days:7)),
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
        return Container(
          width: SizeConfig.blockSizeHorizontal! *14.285,
          height: SizeConfig.blockSizeVertical! *12,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey,
              width: 0.5,
            ),
          ),
          child:Column(
           mainAxisAlignment: MainAxisAlignment.start,
           children:[
            Align(
              alignment: Alignment.centerLeft,
              child:Text(target.day.toString())
            ),
            calendarCellsChild(target)
          ])
        );
      }, 
      itemCount:generateCalendarData()[dayOfWeek]!.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      ));
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
            if (targetDayData.elementAt(index)["startTime"] != null){
              dateTimeData =
                  Text(
                    targetDayData.elementAt(index)["startTime"].hours.toString() + ":" + targetDayData.elementAt(index)["startTime"].minutes.toString(),
                    style: const TextStyle(color: Colors.grey,fontSize: 8),
                  );
                }
            return Container(
              child:Column(children:[
                dateTimeData,
                Text(
                  targetDayData.elementAt(index)["subject"],
                  style: const TextStyle(color: Colors.black,fontSize: 8),
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
