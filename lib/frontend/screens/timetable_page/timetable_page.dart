import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/ui_components.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/calendar_page.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/task_data_manager.dart';
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
      )
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
    if(semesterNum == 4){
      thisYear += 1;  
      semesterNum = 1;
    }else{
      semesterNum += 1;
    }
    setState(() {
      targetSemester = thisYear.toString() + "-" + semesterNum.toString();
    });
  }

  void decreasePgNumber() {
    if(semesterNum == 1){
      thisYear -= 1;  
      semesterNum = 4;
    }else{
      semesterNum -= 1;
    }
    setState(() {
      targetSemester = thisYear.toString() + "-" + semesterNum.toString();
    });
  }

  String semesterText(){
    String result = "年  春学期  春セメスター";
    if(semesterNum == 2){
      result = "年  春学期  夏セメスター";
    }else if(semesterNum == 3){
      result = "年  秋学期  秋セメスター";
    }else if(semesterNum == 4){
      result = "年  秋学期  冬セメスター";
    }
    return thisYear.toString() + result;
  }

  String currentQuaterID(){
    String result = "full_year";
    if(semesterNum == 1){
      result = "spring_quater";
    }else if(semesterNum == 2){
      result = "summer_quater";
    }else if(semesterNum == 3){
      result = "fall_quater";
    }else if(semesterNum == 4){
      result = "winter_quater";
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
          const Spacer(),
          Text(
            semesterText(),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          IconButton(
              onPressed: () {
                setState(() {
                  increasePgNumber();
                });
              },
              icon: const Icon(Icons.arrow_forward_ios),
              iconSize: 20),
          ]),
          Row(children:[
            // SizedBox(
            //   width: SizeConfig.blockSizeHorizontal! *5,
            //   child:Text("")),
            Column(children:[
              generateWeekThumbnail(),
              SizedBox(
                width: SizeConfig.blockSizeHorizontal! *cellWidth * 7,
                child:Row(children:[
                  timetableSells(1),
                  timetableSells(2),
                  timetableSells(3),
                  timetableSells(4),
                  timetableSells(5),
                  timetableSells(6),
                  timetableSells(7),
              ])
             )
            ])
          ]),
        SizedBox(height: SizeConfig.blockSizeVertical! *2,)
      ])
    );
  }

  double cellWidth = 13.571;

  Widget generateWeekThumbnail() {
    List<String> days = ["月", "火", "水", "木", "金", "土", "ｵﾝﾃﾞﾏ"];
    return SizedBox(
      height: SizeConfig.blockSizeVertical! * 2.5,
      child:ListView.builder(
        itemBuilder: (context, index) {
          Color bgColor = Colors.white;
          if(index + 1 == DateTime.now().weekday 
            && index != 6){
            bgColor = const Color.fromRGBO(255, 204, 204, 1);
          }

          return Container(
              width: SizeConfig.blockSizeHorizontal! *cellWidth,
              height: SizeConfig.blockSizeVertical! * 2,
              color:bgColor,
              child: Center(
                  child: Text(
                days.elementAt(index),
                style: const TextStyle(color: Colors.grey),
              )));
        },
        itemCount: 7,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
      )
    );
  }

  Widget timetableSells(int weekDay){
    return SizedBox(
        width: SizeConfig.blockSizeHorizontal! *cellWidth, 
        child:ListView.separated(
        shrinkWrap: true,
        itemCount: 7,
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        itemBuilder: (
        (context, index) {
          Color bgColor = Colors.white;
          Widget cellContents = const SizedBox();
          int length = random.nextInt(11);

          if(random.nextInt(100).isEven){
            switch(length){
               case 0:bgColor = Color.fromRGBO(255, 255, 255, 0.6);
               case 1:bgColor = Color.fromRGBO(254, 255, 232, 0.6);
               case 2:bgColor = Color.fromRGBO(253, 255, 187, 0.6);
               case 3:bgColor = Color.fromRGBO(255, 243, 150, 0.6);
               case 4:bgColor = Color.fromRGBO(255, 231, 125, 0.6);
               case 5:bgColor = Color.fromRGBO(255, 203, 138, 0.6);
               case 6:bgColor = Color.fromRGBO(255, 184, 117, 0.6);
               case 7:bgColor = Color.fromRGBO(255, 125, 142, 0.6);
               case 8:bgColor = Color.fromRGBO(255, 128, 128, 0.6);
               case 9:bgColor = Color.fromRGBO(255, 139, 170, 0.6);
               default :bgColor = Color.fromRGBO(255, 102, 161, 0.6);
            }
              
            cellContents = timeTableSellsChild(
              weekDay,index+1,length);
          }
          
          DateTime now = DateTime.now();
          if(returnBeginningDateTime(index+1).isBefore(now)
              && returnEndDateTime(index+1).isAfter(now)
              && now.weekday == weekDay
              && weekDay <= 6){
            bgColor = Color.fromRGBO(255, 166, 166, 1);
          }
          

          return Container(
            width: SizeConfig.blockSizeHorizontal! *cellWidth,
            height: SizeConfig.blockSizeVertical! * 16,
            decoration: BoxDecoration(
              color: bgColor,
              border: Border.all(
                color: Colors.grey,
                width: 0.5,
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
          if(returnBeginningDateTime(2).isAfter(now)
              && returnEndDateTime(3).isBefore(now)){
            bgColor = const Color.fromRGBO(255, 204, 204, 1);
          }
          String childText = "";
          if(weekDay == 3){
            childText = "昼";
          }
          if(weekDay == 4){
            childText = "休";
          }
          if(weekDay == 5){
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
 

  Widget timeTableSellsChild(int weekDay, int period, int taskLength){
    double fontSize = SizeConfig.blockSizeHorizontal! *2.75;
    Color grey = Colors.grey;
    String className = "社会科学特講（社会デザインの基礎理論）A";
    String classRoom = "100-S102";
    

    return Stack(
     children:[
      Align(
        alignment:const Alignment(-1,-0.9),
        child:lengthBadge(taskLength,fontSize,true)
      ),
      SizedBox(
        child:Column(
        mainAxisAlignment:MainAxisAlignment.spaceBetween,
        children:[
          Text(returnBeginningTime(period),style:TextStyle(color:grey,fontSize:fontSize),),
          Text(className,
            style:TextStyle(fontSize:fontSize,overflow: TextOverflow.ellipsis),
            maxLines: 4,
            ),
          Container(
            decoration: BoxDecoration(
              color:Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(2)),
              border: Border.all(color:grey,width: 0.5)
          ),
          child:Column(children:[
            Text(classRoom,
              style:TextStyle(fontSize:SizeConfig.blockSizeHorizontal! *2.5,),
              overflow: TextOverflow.visible,
              maxLines: 2,
            ),
          ]),
        ),       
        Text(returnEndTime(period),style:TextStyle(color:grey,fontSize:fontSize),),
        ])
      )
    ])
    ;
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



  //これはUI表示調整用の仮データです。
  //データ構造これから大幅に変えちゃってもいいです。
  List<Map<String,dynamic>> tempData = [
    {"id":0,
     "classID":"",
     "category":"経営学",
     "weekDay":1,
     "period": 2,
     "semester" : "spring_semester",
     "classRoom":"14-402",
     "memo" : null,
     "color" : 22354646,
     "groupID" : "d34erws2"
    },
    {"id":1,
     "classID":"",
     "className":"未来社会を作るセキュリティ最前線",
     "weekDay":1,
     "period": 4,
     "semester" : "spring_semester",
     "classRoom":"3-301",
     "memo" : "",
     "color" : 22354646,
     "groupID" : "d34erws2"
    },
    {"id":3,
     "classID":"",
     "className":"経営学",
     "weekDay":2,
     "period": 3,
     "classRoom":"14-402",
     "memorandom" : "",
     "color" : 22354646,
     "groupID" : "d34erws2"
    },
    {"id":4,
     "classID":"",
     "className":"人間の安全保障論",
     "weekDay":2,
     "period": 5,
     "classRoom":"14-502",
     "memorandom" : "",
     "color" : 22354646,
     "groupID" : "d34erws2"
    },
    {"id":5,
     "classID":"",
     "className":"社会科学特講（社会デザインの基礎理論）A",
     "weekDay":3,
     "period":2,
     "classRoom":"7-419",
     "memorandom" :"",
     "color" : 22354646,
     "groupID" : "d34erws2"
    },
    {"id":6,
     "classID":"",
     "className":"知識社会学",
     "weekDay":3,
     "period": 3,
     "classRoom":"14-B101",
     "memorandom" : "",
     "color" : 22354646,
     "groupID" : "d34erws2"
    },
    {"id":7,
     "classID":"",
     "className":"ゼミナールⅡ（国際経済法研究／春学期）",
     "weekDay":3,
     "period": 5,
     "classRoom":"14-516",
     "memorandom" : "",
     "color" : 22354646,
     "groupID" : "d34erws2"
    },
    {"id":8,
     "classID":"",
     "className":"日本語を教える１",
     "weekDay":4,
     "period": 2,
     "classRoom":"22-201",
     "memorandom" : "",
     "color" : 22354646,
     "groupID" : "d34erws2"
    },
    {"id":9,
     "classID":"",
     "className":"商業史1",
     "weekDay": 4,
     "period": 2,
     "classRoom":"",
     "memorandom" : "15-102",
     "color" : 22354646,
     "groupID" : "d34erws2"
    },
    {"id":10,
     "classID":"",
     "className":"現代政治分析(イタリア)",
     "weekDay":4,
     "period": 3,
     "classRoom":"14-514",
     "memorandom" : "",
     "color" : 22354646,
     "groupID" : "d34erws2"
    },
    {"id":11,
     "classID":"",
     "className":"ディスアビリティ・スタディーズ",
     "weekDay": 7,
     "period": null,
     "classRoom": null,
     "memorandom" : "",
     "color" : 22354646,
     "groupID" : "d34erws2"
    },
  ];

}
