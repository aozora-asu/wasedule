import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';

//基準サイズ ８
class LogoAndTitle extends StatelessWidget{
  late double size;

  LogoAndTitle({
    required this.size
  });

  @override
  Widget build(BuildContext context){
    return 
    Padding(
      padding: EdgeInsets.all(size),
      child:Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children:[
      Image.asset('lib/assets/eye_catch/eyecatch.png',height:size*4, width:size*4),
      Column(
        children:[
        Text("早稲田生のための生活アプリ",
        style:TextStyle(fontSize:size,color:MAIN_COLOR,fontWeight:FontWeight.bold)),
        Text("わせジュール",
        style:TextStyle(fontSize:size*2 ,color:Colors.black,fontWeight:FontWeight.w900))
        ])
      ]))
    ;
  }
}