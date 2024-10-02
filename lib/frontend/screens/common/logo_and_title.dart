import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';

enum AppLogoType{
  task,
  calendar,
  timetable
}

//基準サイズ ８
class LogoAndTitle extends StatelessWidget{
  late double size;
  late Color? color;
  late bool? isLogoWhite;
  late String? subTitle;
  late AppLogoType logotype;

  LogoAndTitle({super.key, 
    required this.size,
    required this.logotype,
    this.isLogoWhite,
    this.color,
    this.subTitle
  });

  @override
  Widget build(BuildContext context){
    isLogoWhite ??= false;

    Image thumbnail = Image.asset('lib/assets/eye_catch/eyecatch.png',height:size*4, width:size*4);
    if(isLogoWhite!){
      switch(logotype){
        case AppLogoType.calendar:
          thumbnail = Image.asset('lib/assets/eye_catch/eyecatch_calendar_white.png',height:size*4,width:size*4);
        case AppLogoType.task:
          thumbnail = Image.asset('lib/assets/eye_catch/eyecatch_task_white.png',height:size*4,width:size*4);
        case AppLogoType.timetable:
          thumbnail = Image.asset('lib/assets/eye_catch/eyecatch_timetable_white.png',height:size*4,width:size*4);
      }
    }

    return 
    Padding(
      padding: EdgeInsets.all(size),
      child:Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children:[
      thumbnail,
      Column(
        children:[
          //const Spacer(),
          Text(subTitle ?? "早稲田生のための生活アプリ",
          style:TextStyle(fontSize:size,color:color ?? MAIN_COLOR,fontWeight:FontWeight.bold)),
          //const Spacer(),
          Text("わせジュール",
          style:TextStyle(
            fontSize:size*2.2,
            color:color ?? Colors.black,
            fontWeight:FontWeight.bold,
            //fontFamily: "Roboto"
          )),
          //const Spacer()
        ])
      ]))
    ;
  }
}