import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';

//基準サイズ ８
class LogoAndTitle extends StatelessWidget{
  late double size;
  late Color? color;
  late bool? isLogoWhite;

  LogoAndTitle({
    required this.size,
    this.isLogoWhite,
    this.color,
  });

  @override
  Widget build(BuildContext context){
    isLogoWhite ??= false;

    Image thumbnail = Image.asset('lib/assets/eye_catch/eyecatch.png',height:size*4, width:size*4);
    if(isLogoWhite!){
      thumbnail = Image.asset('lib/assets/eye_catch/eyecatch_white.png',height:size*4,width:size*4);
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
        Text("早稲田生のための生活アプリ",
        style:TextStyle(fontSize:size,color:color ?? MAIN_COLOR,fontWeight:FontWeight.bold)),
        Text("わせジュール",
        style:TextStyle(fontSize:size*2 ,color:color ?? Colors.black,fontWeight:FontWeight.w800))
        ])
      ]))
    ;
  }
}