import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';

class LogoAndTitle extends StatelessWidget{

  @override
  Widget build(BuildContext context){
    return 
    Padding(
      padding: const EdgeInsets.all(8),
      child:Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children:[
      Image.asset('lib/assets/eye_catch/eyecatch.png',height: 35, width: 35),
      const Column(
        children:[
        Text("早稲田生のためのスケジュールアプリ",
        style:TextStyle(fontSize:8,color:MAIN_COLOR,fontWeight:FontWeight.bold)),
        Text("わせジュール",
        style:TextStyle(fontSize:20,color:Colors.black,fontWeight:FontWeight.w900))
        ])
      ]))
    ;
  }
}