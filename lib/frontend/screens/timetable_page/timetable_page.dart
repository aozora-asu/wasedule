import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/handler/schedule_db_handler.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/assist_files/ui_components.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/calendar_page.dart';
import 'package:flutter_calandar_app/frontend/screens/common/loading.dart';
import 'package:flutter_calandar_app/frontend/screens/moodle_view_page/my_course_db.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/task_data_manager.dart';
import 'package:flutter_calandar_app/frontend/screens/timetable_page/course_add_page.dart';
import 'package:flutter_calandar_app/frontend/screens/timetable_page/course_preview.dart';
import 'package:flutter_calandar_app/frontend/screens/timetable_page/ondemand_preview.dart';
import 'package:flutter_calandar_app/frontend/screens/timetable_page/timetable_data_manager.dart';
import 'package:flutter_calandar_app/frontend/screens/to_do_page/todo_assist_files/size_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TimeTablePage extends ConsumerStatefulWidget {
  @override
  _TimeTablePageState createState() => _TimeTablePageState();
}

class _TimeTablePageState extends ConsumerState<TimeTablePage> {
  late int thisYear;
  late int semesterNum;
  late String targetSemester;

  @override
  void initState() {
    super.initState();
    initTargetSem();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
            image: tableBackGroundImage(),
            fit: BoxFit.cover,
          )),
          child: Padding(
            padding: EdgeInsets.only(
              left: SizeConfig.blockSizeHorizontal! * 2.5,
              right: SizeConfig.blockSizeHorizontal! * 2.5,
            ), 
            child:ListView(
              shrinkWrap: true,
              children: [
                const SizedBox(height:10),
                timeTable(),
                const SizedBox(height:30),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
          margin: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical! *12),
          child: Row(children:[
            const Spacer(),
            FloatingActionButton(
              onPressed:(){
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CourseAddPage();
                 });
              },
              backgroundColor: ACCENT_COLOR,
              child:const Icon(Icons.add,color:Colors.white)
            ),
            const SizedBox(width: 10),
            //timetableShareButton(context),
          ])
        ),
    );
  }

  void initTargetSem(){
    DateTime now = DateTime.now();  
      thisYear = now.year;
    if(now.month <= 3){
      thisYear -= 1;
    }
      semesterNum = 0;
    if(now.month <= 3){
      semesterNum = 4;
    }else if(now.month <= 5){
      semesterNum = 1;
    }else if(now.month <= 9){
      semesterNum = 2;
    }else if(now.month <= 11){
      semesterNum = 3;
    }else{
      semesterNum = 4;
    }
    targetSemester = thisYear.toString() + "-" + semesterNum.toString();
  }

  

  void increasePgNumber() {
    if(semesterNum == 3 || semesterNum == 4){
      thisYear += 1;  
      semesterNum = 1;
    }else{
      semesterNum = 3;
    }
    setState(() {
      targetSemester = thisYear.toString() + "-" + semesterNum.toString();
    });
  }

  void decreasePgNumber() {
    if(semesterNum == 1 || semesterNum == 2){
      thisYear -= 1;  
      semesterNum = 3;
    }else{
      semesterNum = 1;
    }
    setState(() {
      targetSemester = thisYear.toString() + "-" + semesterNum.toString();
    });
  }

  Widget changeQuaterbutton(int type){
    int buttonSemester = 0;
    if(type == 1){
      buttonSemester = button1Semester();
    }else{
      buttonSemester = button2Semester();
    }

    String quaterName = "";
    switch(buttonSemester){
      case 1:quaterName = "   春   ";
      case 2:quaterName = "   夏   ";
      case 3:quaterName = "   秋   ";
      case 4:quaterName = "   冬   ";
    }

    Color quaterColor = Colors.white;
    switch(buttonSemester){
      case 1:quaterColor = const Color.fromARGB(255, 255, 159, 191);
      case 2:quaterColor = Colors.blueAccent;
      case 3:quaterColor = const Color.fromARGB(255, 231, 85, 0);
      case 4:quaterColor = Colors.cyan;
    }

    return buttonModel(
      (){
        switchSemester();
      },
      buttonColor(buttonSemester,quaterColor),
      quaterName);
  }

  void switchSemester(){
    if(semesterNum == 1){
      setState(() {
        semesterNum = 2;
      });
    }else if(semesterNum == 2){
      setState(() {
        semesterNum = 1;
      });
    } else if(semesterNum == 3){
      setState(() {
        semesterNum = 4;
      });
    }else if(semesterNum == 4){
      setState(() {
        semesterNum = 3;
      });
    }
  }

  int button1Semester(){
    if(semesterNum == 1){
        return 1;
    }else if(semesterNum == 2){
        return 1;
    } else if(semesterNum == 3){
        return 3;
    }else{
       return 3;
    }
  }

  int button2Semester(){
    if(semesterNum == 1){
        return 2;
    }else if(semesterNum == 2){
        return 2;
    } else if(semesterNum == 3){
        return 4;
    }else{
       return 4;
    }
  }

  Color buttonColor(int buttonSemester,Color color){
    if(semesterNum == buttonSemester){
      return color;
    }else{
      return Colors.grey[350]!;
    }
  }

  String semesterText(){
    String result = "年  春学期";
    if(semesterNum == 2){
      result = "年  春学期";
    }else if(semesterNum == 3){
      result = "年  秋学期";
    }else if(semesterNum == 4){
      result = "年  秋学期";
    }
    return thisYear.toString() + result;
  }

  String currentQuaterID(){
    String result = "full_year";
    if(semesterNum == 1){
      result = "spring_quarter";
    }else if(semesterNum == 2){
      result = "summer_quarter";
    }else if(semesterNum == 3){
      result = "fall_quarter";
    }else if(semesterNum == 4){
      result = "winter_quarter";
    }
    return result;
  }

  String currentSemesterID(){
    String result = "full_year";
    if(semesterNum == 1 || semesterNum == 2){
      result = "spring_semester";
    }else if(semesterNum == 3 || semesterNum == 4){
      result = "fall_semester";
    }
    return result;
  }

  Widget timeTable(){
    return Container(
      decoration:BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 3,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child:Column(children:[
        Row(children: [
          IconButton(
              onPressed: () {
                decreasePgNumber();
              },
              icon: const Icon(Icons.arrow_back_ios),
              iconSize: 20),
          Text(
            semesterText(),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          IconButton(
              onPressed: () {
                setState(() {
                  increasePgNumber();
                });
              },
              icon: const Icon(Icons.arrow_forward_ios),
              iconSize: 20),
          const Spacer(),
          changeQuaterbutton(1),
          changeQuaterbutton(2),
          const Spacer(),
          ]),
          FutureBuilder(
            future: MyCourseDatabaseHandler().getMyCourse(),
            builder:((context, snapshot) {
              if(snapshot.connectionState == ConnectionState.waiting){
                return timeTableBody();
              }else if (snapshot.hasError) {
                return const SizedBox();
              } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                ref.read(timeTableProvider).sortDataByWeekDay(snapshot.data!);
                ref.read(timeTableProvider).initUniversityScheduleByDay(thisYear,semesterNum);
                return timeTableBody();
              }else{
                return noDataScreen();
              }
            }
          )
        )
      ])
    );
  }

  Widget noDataScreen(){
    return SizedBox(
      height: SizeConfig.blockSizeVertical! *80,
      width: SizeConfig.blockSizeHorizontal! *85,
      child: Center(child:
        Column(
         mainAxisAlignment: MainAxisAlignment.center,
         children:[
         Image.asset('lib/assets/eye_catch/eyecatch.png',height: 200, width: 200),
         const SizedBox(height:20),
         Text("時間割データはまだありません。",
          style:TextStyle(fontSize: SizeConfig.blockSizeHorizontal! *5,
            fontWeight: FontWeight.bold
          )),
        const SizedBox(height:15),
        const Row(
         mainAxisAlignment: MainAxisAlignment.center,
         crossAxisAlignment: CrossAxisAlignment.start,
         children:[
          Icon(Icons.school,color:MAIN_COLOR),
          Text(" Moodle",
           style:TextStyle(
             color:MAIN_COLOR,
             fontWeight: FontWeight.bold
           )),
           Expanded(child:Text(" ページから、時間割データを自動作成しましょう！",
             overflow: TextOverflow.clip,))
        ]),
        const Icon(
          Icons.keyboard_double_arrow_right,
          color:MAIN_COLOR,
          size: 150,),
      ]))
    );
  }

  Widget loadingScreen(){
    return SizedBox(
      height: SizeConfig.blockSizeVertical! *80,
      width: SizeConfig.blockSizeHorizontal! *95,
      child:const Center(
        child:CircularProgressIndicator()
      )
    );
  }

  Widget timeTableBody(){
    return Column(children:[
          Row(children:[
            Expanded(child:generatePrirodColumn()),
            Column(children:[
              generateWeekThumbnail(),
              SizedBox(
                width: SizeConfig.blockSizeHorizontal! *cellWidth * 6,
                child:Row(children:[
                  timetableSells(1),
                  timetableSells(2),
                  timetableSells(3),
                  timetableSells(4),
                  timetableSells(5),
                  timetableSells(6),
              ])
             )
            ])
          ]),
          SizedBox(height: SizeConfig.blockSizeVertical! *1),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "   ■ オンデマンド・その他",
              style: TextStyle(
                fontSize: 17.5,
                fontWeight: FontWeight.w700,
              ),
            )),
          const Divider(height: 0.5,thickness: 0.5,color:Colors.grey),
          SizedBox(
              height: SizeConfig.blockSizeVertical! *cellHeight,
              child:generateOndemandRow()),
          const Divider(height: 0.5,thickness: 0.5,color:Colors.grey),
          SizedBox(height: SizeConfig.blockSizeVertical! *3,)
    ]);
  }

  double cellWidth = 14.5;
  double cellHeight = 14;

  Widget generateWeekThumbnail() {
    List<String> days = ["月", "火", "水", "木", "金", "土"];
    return SizedBox(
      height: SizeConfig.blockSizeVertical! * 2.5,
      child:ListView.builder(
        itemBuilder: (context, index) {
          Color bgColor = Colors.white;
          Color fontColor = Colors.grey;
          if(index + 1 == DateTime.now().weekday 
            && index != 6){
            bgColor = Colors.blueAccent;
            fontColor = Colors.white;
          }

          return Container(
              width: SizeConfig.blockSizeHorizontal! *cellWidth,
              height: SizeConfig.blockSizeVertical! * 2,
              color:bgColor,
              child: Center(
                  child: Text(
                days.elementAt(index),
                style:TextStyle(color: fontColor),
              )));
        },
        itemCount: 6,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
      )
    );
  }

  Widget generatePrirodColumn(){
    double fontSize = SizeConfig.blockSizeHorizontal! *2;
    Color grey = Colors.grey;
    
    return Column(children:[
      SizedBox(height: SizeConfig.blockSizeVertical! * 2.5,),
      ListView.separated(
        itemBuilder:(context, index) {
          Color bgColor = Colors.white;
          Color fontColor = Colors.grey;            
          DateTime now = DateTime.now();
          if(returnBeginningDateTime(index+1).isBefore(now)
              && returnEndDateTime(index+1).isAfter(now)){
            bgColor = Colors.blueAccent;
            fontColor = Colors.white;
          }

          return Container(
            height: SizeConfig.blockSizeVertical! * cellHeight,
            decoration: BoxDecoration(
              color: bgColor,
              border: Border.all(
                color: Colors.grey,
                width: 0.5,
              ),
            ),
            child: Padding(
              padding:const EdgeInsets.symmetric(horizontal:3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:[
                Text(returnBeginningTime(index+1),style:TextStyle(color:fontColor,fontSize:fontSize),),
                Text((index+1).toString(),style:TextStyle(color:fontColor,fontSize:fontSize*2,fontWeight: FontWeight.bold)),
                Text(returnEndTime(index+1),style:TextStyle(color:fontColor,fontSize:fontSize),),
              ])
            ) 
          );
        },
        separatorBuilder:(context, index) {
          Widget resultinging = const SizedBox();
          DateTime now = DateTime.now(); 
          Color bgColor = Colors.white;
          if(returnEndDateTime(2).isBefore(now)
              && returnBeginningDateTime(3).isAfter(now)){
            bgColor = const Color.fromRGBO(255, 204, 204, 1);
          }
          if(index == 1){
            resultinging = 
              Container(
                height:SizeConfig.blockSizeVertical! *2.5,
                color:bgColor,
                child:const Column(
                  children:[
                    Divider(color:Colors.grey,height:0.5,thickness: 0.5),
                    Spacer(),
                    Divider(color:Colors.grey,height:0.5,thickness: 0.5)
                ])
              );
          }
          return resultinging;
        },
        itemCount: ref.read(timeTableProvider).maxPeriod,
        shrinkWrap: true,
        physics:const NeverScrollableScrollPhysics(),
        )
    ]);
  }

  Color cellBackGroundColor(int length,Color color){
    Color bgColor = Colors.white;
    switch(length){
    case 0:bgColor = increaseRed(color,amount:0);
    case 1:bgColor = increaseRed(color,amount:30);
    case 2:bgColor = increaseRed(color,amount:60);
    case 3:bgColor = increaseRed(color,amount:90);
    case 4:bgColor = increaseRed(color,amount:120);
    case 5:bgColor = increaseRed(color,amount:150);
    case 6:bgColor = increaseRed(color,amount:180);
    case 7:bgColor = increaseRed(color,amount:210);
    case 8:bgColor = increaseRed(color,amount:240);
    case 9:bgColor = increaseRed(color,amount:255);
    default :bgColor = increaseRed(color,amount:255);
    }
    return bgColor;
  }

  Color increaseRed(Color color, {int amount = 10}) {
    int red = color.red;
    int green = color.green;
    int blue = color.blue;

    red = (red + amount).clamp(0, 255); // clampで0～255の範囲に収める

    return Color.fromRGBO(red, green, blue, 1);
  }

  Widget timetableSells(int weekDay){
    final tableData = ref.read(timeTableProvider);
    return SizedBox(
      width: SizeConfig.blockSizeHorizontal! *cellWidth, 
      child:ListView.separated(
      shrinkWrap: true,
      itemCount: ref.read(timeTableProvider).maxPeriod,
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      itemBuilder: (
      (context, index) {
        Color bgColor = Colors.white;
        Widget cellContents = GestureDetector(
          onTap:(){
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return CourseAddPage(
                  year:thisYear,
                  semester:currentSemesterID(),
                  weekDay:weekDay,
                  period:index+1
                );
            });
          }
        );
        int length = random.nextInt(1);

        if(tableData.currentSemesterClasses.containsKey(weekDay)
          && returnExistingPeriod(tableData.currentSemesterClasses[weekDay]).contains(index+1)
          &&tableData.currentSemesterClasses[weekDay]
            .elementAt(returnIndexFromPeriod(
              tableData.currentSemesterClasses[weekDay],index + 1))["year"] 
            == thisYear){
            Color colorning = hexToColor(tableData.currentSemesterClasses[weekDay]
              .elementAt(returnIndexFromPeriod(
                tableData.currentSemesterClasses[weekDay],index + 1))["color"] );
            if(tableData.currentSemesterClasses[weekDay]
              .elementAt(returnIndexFromPeriod(
                tableData.currentSemesterClasses[weekDay],index + 1))["semester"] 
              == currentQuaterID() || 
              tableData.currentSemesterClasses[weekDay]
              .elementAt(returnIndexFromPeriod(
                tableData.currentSemesterClasses[weekDay],index + 1))["semester"] 
              == currentSemesterID()
            ){
              bgColor = cellBackGroundColor(length,colorning);
              cellContents = timeTableSellsChild(
                weekDay,index+1,length);
            }
        }
        
        Color lineColor = const Color.fromARGB(255, 152, 144, 144);
        double lineWidth = 0.5;
        DateTime now = DateTime.now();
        if(returnBeginningDateTime(index+1).isBefore(now)
            && returnEndDateTime(index+1).isAfter(now)
            && now.weekday == weekDay
            && weekDay <= 6){
          lineWidth = 4;
          lineColor = Colors.blueAccent;
        }
        

        return Container(
          width: SizeConfig.blockSizeHorizontal! *cellWidth,
          height: SizeConfig.blockSizeVertical! * cellHeight,
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(
              color: lineColor,
              width: lineWidth,
            ),
          ),
          child: Padding(
            padding:const EdgeInsets.symmetric(horizontal:3),
            child:cellContents) 
        );
      }),

      separatorBuilder: (context, index) {
        Widget resultinging = const SizedBox();
        DateTime now = DateTime.now(); 
        Color bgColor = Colors.white;
        if(returnEndDateTime(2).isBefore(now)
            && returnBeginningDateTime(3).isAfter(now)){
          bgColor = const Color.fromRGBO(255, 204, 204, 1);
        }
        String childText = "";
        if(weekDay == 2){
          childText = "昼";
        }
        if(weekDay == 3){
          childText = "休";
        }
        if(weekDay == 4){
          childText = "み";
        }

        if(index == 1){
          resultinging = 
            Container(
              height:SizeConfig.blockSizeVertical! *2.5,
              color:bgColor,
              child:Column(
                children:[
                  const Divider(color:Colors.grey,height:0.5,thickness: 0.5),
                  const Spacer(),
                  Text(childText, style: TextStyle(color:Colors.grey,fontSize: SizeConfig.blockSizeHorizontal! *3)),
                  const Spacer(),
                  const Divider(color:Colors.grey,height:0.5,thickness: 0.5)
              ])
            );
          }
          return resultinging;
        },
      )
    );
  }
 
  Widget generateOndemandRow(){
    final tableData = ref.read(timeTableProvider);
    int listLength = 0;
    if(tableData.sortedDataByWeekDay.containsKey(7)){
      listLength =tableData.sortedDataByWeekDay[7].length;
    }

    return ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      itemCount: listLength,
      itemBuilder: (context,index){
        Color colorning = hexToColor(tableData.sortedDataByWeekDay[7]
            .elementAt(index)["color"]);
        int length = random.nextInt(1);
        Color bgColor = cellBackGroundColor(length,colorning);
        Widget child = const SizedBox();
        if(tableData.sortedDataByWeekDay[7]
            .elementAt(index)["semester"] 
            == currentQuaterID()
          || tableData.sortedDataByWeekDay[7]
            .elementAt(index)["semester"] 
            == currentSemesterID()
          &&tableData.sortedDataByWeekDay[7]
            .elementAt(index)["year"] 
            == thisYear){
          child =Container(
            height: SizeConfig.blockSizeVertical! * cellHeight,
            width: SizeConfig.blockSizeHorizontal! *cellWidth,
            decoration: BoxDecoration(
              color: bgColor,
              border: Border.all(
                color: Colors.grey,
                width: 0.5,
              ),
            ),
            child:ondemandSellsChild(index,length)
        ); 
        }
        return child;
      });
  }

  List<int> returnExistingPeriod(List<Map>target){
    List<int> result = [];
    for(int i = 0; i < target.length; i++){
      result.add(target.elementAt(i)["period"]);
    }
    return result;
  }

  int returnIndexFromPeriod(List<Map>target,int period){
    int result = 0;
    for(int i = 0; i < target.length; i++){
      if(target.elementAt(i)["period"] == period){
        result = i;
      }
    }
    return result;
  }

  Widget timeTableSellsChild(int weekDay, int period, int taskLength){
    double fontSize = SizeConfig.blockSizeHorizontal! *2.75;
    Color grey = Colors.grey;
    final timeTableData = ref.read(timeTableProvider);
    Map targetData = timeTableData.currentSemesterClasses[weekDay]
        .elementAt(returnIndexFromPeriod(
          timeTableData.currentSemesterClasses[weekDay],period));
    String className = 
      timeTableData.currentSemesterClasses[weekDay]
        .elementAt(returnIndexFromPeriod(
          timeTableData.currentSemesterClasses[weekDay],period))["courseName"];
    String? classRoom = timeTableData.currentSemesterClasses[weekDay]
        .elementAt(returnIndexFromPeriod(
          timeTableData.currentSemesterClasses[weekDay],period))["classRoom"];
    
    Widget classRoomView = const SizedBox();
    if(classRoom != null
      && classRoom != ""
      && classRoom != "-"){
      classRoomView =Container(
        decoration: BoxDecoration(
          color:Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(2)),
          border: Border.all(color:grey,width: 0.5)
      ),
      child:
        Text(classRoom,
          style:TextStyle(fontSize:SizeConfig.blockSizeHorizontal! *2.5,),
          overflow: TextOverflow.visible,
          maxLines: 2,
        ));}


    return Stack(
     children:[
      Align(
        alignment:const Alignment(-1,-1),
        child:lengthBadge(taskLength,fontSize,true)
      ),
      SizedBox(
        width: SizeConfig.blockSizeHorizontal! *cellWidth,
        child: InkWell(
          onTap:(){
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return CoursePreview(target: targetData);
            });
          },
          child:Column(
          mainAxisAlignment:MainAxisAlignment.start,
          children:[
            SizedBox(height:SizeConfig.blockSizeVertical! *2.25),
            const Spacer(),

            Text(className,
              style:TextStyle(fontSize:fontSize,overflow: TextOverflow.ellipsis),
              maxLines: 4,
              ),
            const Spacer(),
            classRoomView,
            const Spacer()

          ])
        )
        
      )
    ]);
  }

  Widget ondemandSellsChild(int index, int taskLength){
    final tableData = ref.read(timeTableProvider);
    Map target = tableData.sortedDataByWeekDay[7].elementAt(index);
    double fontSize = SizeConfig.blockSizeHorizontal! *2.75;
    String className = target["courseName"];
    

    return GestureDetector(
      onTap:() {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return OndemandPreview(target:target);
        });
      },
      child:Stack(
      children:[
        Align(
          alignment:const Alignment(-1,-1),
          child:lengthBadge(taskLength,fontSize,true)
        ),
        SizedBox(
          child:Column(
          mainAxisAlignment:MainAxisAlignment.start,
          children:[
            SizedBox(height:SizeConfig.blockSizeVertical! *2.25),
            const Spacer(),

            Text(className,
              style:TextStyle(fontSize:fontSize,overflow: TextOverflow.ellipsis),
              maxLines: 4,
              ),
            const Spacer(),
          ])
        )
      ])
    );
  }

  AssetImage tableBackGroundImage() {
    if (DateTime.now().hour >= 5 && DateTime.now().hour <= 9) {
      return const AssetImage(
          'lib/assets/calendar_background/ookuma_morning.png');
    } else if (DateTime.now().hour >= 9 && DateTime.now().hour <= 17) {
      return const AssetImage('lib/assets/calendar_background/ookuma_day.png');
    } else {
      return const AssetImage(
          'lib/assets/calendar_background/ookuma_night.png');
    }
  }
  
  String returnBeginningTime(int period){
    switch(period) {
      case 1: return "08:50";
      case 2: return "10:40";
      case 3: return "13:10";
      case 4: return "15:05";
      case 5: return "17:00";
      case 6: return "18:55";
      default : return "20:45";
    }
  }

  DateTime returnBeginningDateTime(int period){
    DateTime now = DateTime.now();
    switch(period) {
      case 1: return DateTime(now.year,now.month,now.day,8,50);
      case 2: return DateTime(now.year,now.month,now.day,10,40);
      case 3: return DateTime(now.year,now.month,now.day,13,10);
      case 4: return DateTime(now.year,now.month,now.day,15,05);
      case 5: return DateTime(now.year,now.month,now.day,17,00);
      case 6: return DateTime(now.year,now.month,now.day,18,55);
      default : return DateTime(now.year,now.month,now.day,20,45);
    }
  }

  String returnEndTime(int period){
    switch(period) {
      case 1: return "10:30";
      case 2: return "12:20";
      case 3: return "14:50";
      case 4: return "16:45";
      case 5: return "18:40";
      case 6: return "20:35";
      default : return "21:35";
    }
  }

  DateTime returnEndDateTime(int period){
    DateTime now = DateTime.now();
    switch(period) {
      case 1: return DateTime(now.year,now.month,now.day,10,30);
      case 2: return DateTime(now.year,now.month,now.day,12,20);
      case 3: return DateTime(now.year,now.month,now.day,14,50);
      case 4: return DateTime(now.year,now.month,now.day,16,45);
      case 5: return DateTime(now.year,now.month,now.day,18,40);
      case 6: return DateTime(now.year,now.month,now.day,20,35);
      default : return DateTime(now.year,now.month,now.day,21,35);
    }
  }

Color hexToColor(String hexColor) {
  // 16進数のカラーコードが#で始まる場合、#を削除する
  if (hexColor.startsWith('#')) {
    hexColor = hexColor.substring(1);
  }
  
  // 16進数のカラーコードをRGBに分解する
  int hexValue = int.parse(hexColor, radix: 16);
  int alpha = (hexValue >> 24) & 0xFF;
  int red = (hexValue >> 16) & 0xFF;
  int green = (hexValue >> 8) & 0xFF;
  int blue = hexValue & 0xFF;
  
  // Colorオブジェクトを作成して返す
  return Color.fromARGB(alpha, red, green, blue);
}

}


  //これはUI表示調整用の仮データです。
  // Future<List<Map<String,dynamic>>> tempData() async{
  //   List<Map<String,dynamic>> tempData = [
  //     {"id":1,
  //     "classID":"",
  //     "courseName":"未来社会を作るセキュリティ最前線",
  //     "weekDay":1,
  //     "period": 4,
  //     "semester" : "summer_quarter",
  //     "classRoom":"3-301",
  //     "memo" : "",
  //     "color" : 22354646,
  //     "groupID" : "d34erws2",
  //     "year" : 2024
  //     },
  //     {"id":5,
  //     "classID":"",
  //     "courseName":"社会科学特講（社会デザインの基礎理論）A",
  //     "weekDay":3,
  //     "period":2,
  //     "semester" : "spring_semester",
  //     "classRoom":"7-209",
  //     "memorandom" : "",
  //     "color" : 22354646,
  //     "groupID" : "d34erws2",
  //     "year" : 2024
  //     },
  //     {"id":6,
  //     "classID":"",
  //     "semester" : "spring_semester",
  //     "courseName":"知識社会学",
  //     "weekDay":3,
  //     "period": 3,
  //     "classRoom":"14-B101",
  //     "memorandom" : "",
  //     "color" : 22354646,
  //     "groupID" : "d34erws2",
  //     "year" : 2024
  //     },
  //     {"id":4,
  //     "classID":"",
  //     "courseName":"人間の安全保障論",
  //     "weekDay":2,
  //     "period": 5,
  //     "semester" : "spring_semester",
  //     "classRoom":"14-502",
  //     "memorandom" : "",
  //     "color" : 22354646,
  //     "groupID" : "d34erws2",
  //     "year" : 2024
  //     },
  //     {"id":0,
  //     "classID":"",
  //     "courseName":"経営学",
  //     "weekDay":1,
  //     "period": 2,
  //     "semester" : "spring_semester",
  //     "classRoom":"14-402",
  //     "memo" : null,
  //     "color" : 22354646,
  //     "groupID" : "d34erws2",
  //     "year" : 2024
  //     },
  //     {"id":15,
  //     "classID":"",
  //     "courseName":"全く同じ授業だよ",
  //     "weekDay":3,
  //     "period":2,
  //     "semester" : "spring_semester",
  //     "classRoom":"7-419",
  //     "memorandom" :"",
  //     "color" : 22354646,
  //     "groupID" : "d34erws2",
  //     "year" : 2024
  //     },
  //     {"id":7,
  //     "classID":"",
  //     "semester" : "spring_semester",
  //     "courseName":"ゼミナールⅡ（国際経済法研究／春学期）",
  //     "weekDay":3,
  //     "period": 5,
  //     "classRoom":"14-516",
  //     "memorandom" : "",
  //     "color" : 22354646,
  //     "groupID" : "d34erws2",
  //     "year" : 2024
  //     },
  //     {"id":11,
  //     "classID":"",
  //     "courseName":"ディスアビリティ・スタディーズ",
  //     "semester" : "spring_semester",
  //     "weekDay": null,
  //     "period": null,
  //     "classRoom": null,
  //     "memorandom" : "",
  //     "color" : 22354646,
  //     "groupID" : "d34erws2",
  //     "year" : 2024
  //     },
  //     {"id":8,
  //     "classID":"",
  //     "courseName":"日本語を教える１",
  //     "semester" : "spring_semester",
  //     "weekDay":4,
  //     "period": 2,
  //     "classRoom":"22-201",
  //     "memorandom" : "",
  //     "color" : 22354646,
  //     "groupID" : "d34erws2",
  //     "year" : 2024
  //     },
  //     {"id":3,
  //     "classID":"",
  //     "courseName":"経営学",
  //     "weekDay":2,
  //     "period": 3,
  //     "semester" : "spring_semester",
  //     "classRoom":"14-402",
  //     "memo" : null,
  //     "color" : 22354646,
  //     "groupID" : "d34erws2",
  //     "year" : 2024
  //     },
  //     {"id":9,
  //     "classID":"",
  //     "courseName":"商業史1",
  //     "semester" : "spring_semester",
  //     "weekDay": 5,
  //     "period": 2,
  //     "classRoom":"",
  //     "memorandom" : "15-102",
  //     "color" : 22354646,
  //     "groupID" : "d34erws2",
  //     "year" : 2024
  //     },
  //     {"id":16,
  //     "classID":"",
  //     "courseName":"全く同じ授業だよ",
  //     "weekDay":3,
  //     "period":2,
  //     "semester" : "spring_semester",
  //     "classRoom":"7-419",
  //     "memorandom" :"",
  //     "color" : 22354646,
  //     "groupID" : "d34erws2",
  //     "year" : 2025
  //     },
  //     {"id":16,
  //     "classID":"",
  //     "courseName":"全く同じ授業だえ～。",
  //     "weekDay":3,
  //     "period":3,
  //     "semester" : "spring_semester",
  //     "classRoom":"7-419",
  //     "memorandom" :"",
  //     "color" : 22354646,
  //     "groupID" : "d34erws2",
  //     "year" : 2025
  //     },
  //     {"id":10,
  //     "classID":"",
  //     "courseName":"現代政治分析(イタリア)",
  //     "semester" : "spring_semester",
  //     "weekDay":5,
  //     "period": 3,
  //     "classRoom":"14-514",
  //     "memorandom" : "",
  //     "color" : 22354646,
  //     "groupID" : "d34erws2",
  //     "year" : 2024
  //     },
  //   ];
  //   return tempData;
  // }