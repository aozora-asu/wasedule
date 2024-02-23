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
        const SizedBox(height:10),
        howToUsePanel("わせジュールとは?","わせジュールとは、授業管理機能を中心とした早大生向けの学生生活アシストアプリです！")
      ])
     )
    );
  }

  Widget howToUsePanel(String title,String caption){
    return 
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
    );
  }
}


