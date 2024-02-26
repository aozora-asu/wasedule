import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/screens/menu_pages/arbeit_stats_page.dart';
import '../../assist_files/colors.dart';
import '../../assist_files/size_config.dart';

class HowToUsePage extends StatefulWidget {
  @override
  _HowToUsePageState createState() => _HowToUsePageState();
}

class _HowToUsePageState extends State<HowToUsePage> {

  @override
  Widget build(BuildContext context) {
  SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color:Colors.white),
        backgroundColor: MAIN_COLOR,
        elevation: 10,
        title: Column(
          children:<Widget>[
            Row(children:[
            const Icon(
              Icons.question_mark_rounded,
              color:WIDGET_COLOR,
              ),
              SizedBox(width: SizeConfig.blockSizeHorizontal! *4,),
            Text(
              '使い方ガイド',
              style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal! *5,
                fontWeight: FontWeight.w800,
                color:Colors.white
              ),
            ),
            ]
            )
          ],
        ),
      ),
      body:Padding(
        padding:const EdgeInsets.all(10),
        child:ListView(children:[
        categoryIndex(Icons.school,"アプリについて"),
        howToUsePanel("わせジュールとは?","わせジュールとは、授業管理機能を中心とした早大生向けの学生生活アシストアプリです！"),
        categoryIndex(Icons.calendar_month,"カレンダー"),
        howToUsePanel("カレンダーとは?","大学生向けにカスタムされた便利なカレンダーです。授業課題とも連動し、あなたの学生生活をサポート。\n以下ではその機能をご紹介します"),
        howToUsePanel("カレンダーの予定登録","①カレンダーページの[+]ボタンを押すか、カレンダーの任意の日付を押す。\n②「+ 予定の追加...」を押す。"),
        categoryIndex(Icons.splitscreen,"タスク"),
        categoryIndex(Icons.task_outlined,"ToDo"),
      ])
     )
    );
  }

  Widget howToUsePanel(String title,String caption){
    return
    Column(children:[
     Container(
      decoration: roundedBoxdecorationWithShadow(),
      child:
      Padding(
        padding:const EdgeInsets.all(10),
        child:ExpandablePanel(
        header:Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children:[ 
          const Icon(Icons.question_mark,color:MAIN_COLOR),
          const SizedBox(width:20),
          Text(title,style: const TextStyle(fontWeight:FontWeight.bold,fontSize:25),),
        ]),
        collapsed:const SizedBox(),
        expanded:Text(caption)
        )
       )
      ),
      const SizedBox(height:10)
    ]);
  }

    Widget categoryIndex(IconData icon,String title){
    return Column(children:[
      Padding(
        padding:const EdgeInsets.only(left:10,right:10,top:10),
        child:Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children:[ 
          Icon(icon,color:MAIN_COLOR),
          const SizedBox(width:20),
          Text(title,style: const TextStyle(fontWeight:FontWeight.bold,fontSize:25),),
        ]),
      ),
      const Divider(color:ACCENT_COLOR,thickness: 3,height:10,),
      const SizedBox(height:10)
    ]);
  }
}


