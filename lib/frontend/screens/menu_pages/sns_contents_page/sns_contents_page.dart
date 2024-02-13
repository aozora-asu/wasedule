import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/handler/todo_db_handler.dart';
import 'package:flutter_calandar_app/backend/DB/handler/user_info_db_handler.dart';
import '../../../assist_files/colors.dart';
import '../../../assist_files/size_config.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SnsContentsPage extends StatefulWidget {
  @override
  _SnsContentsPageState createState() => _SnsContentsPageState();
}

class _SnsContentsPageState extends State<SnsContentsPage> {
  TextEditingController _urlController = TextEditingController();
  @override
  Widget build(BuildContext context) {
  SizeConfig().init(context);
    return Scaffold(appBar: AppBar(
        leading: const BackButton(color:Colors.white),
        backgroundColor: MAIN_COLOR,
        elevation: 10,
        title: Column(
          children:<Widget>[
            Row(children:[
            const Icon(
              Icons.ios_share_rounded,
              color:WIDGET_COLOR,
              ),
              SizedBox(width: SizeConfig.blockSizeHorizontal! *4,),
            Text(
              'SNS共有コンテンツ',
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
      body: Center(child:
       Padding(padding:EdgeInsets.all(10),
               child:Column(children:[
                const Text("SNSコンテンツにようこそ！友達などに共有してお楽しみください♬",
                style: TextStyle(fontSize:20,fontWeight: FontWeight.bold),),
                SizedBox(height:SizeConfig.blockSizeVertical!*3),
                linkPanel(Icons.sunny,"#私の月間忙しさ予報", () { }, Colors.orange,"いつ課題で余裕がないのか知らせておこう！"),
                SizedBox(height:SizeConfig.blockSizeVertical!*2),
                linkPanel(Icons.calendar_month_rounded,"#この日は一日空いてます", () { }, Colors.red,"なにも予定がない日を画像でシェア。"),
                SizedBox(height:SizeConfig.blockSizeVertical!*2),
                linkPanel(Icons.mood_bad_rounded,"オレ的忙しい授業ランキング", () { }, Colors.purple,"今学期最も課題が出された授業とは!?"),
                SizedBox(height:SizeConfig.blockSizeVertical!*2),
                linkPanel(Icons.access_time_filled_sharp,"バイト王は 俺だ！", () { }, Colors.yellowAccent,"今月何時間働いた?皆で共有してみよう"),
        ]))

        )
    );
  }

  Widget linkPanel(IconData icon, String text, void Function() ontap, Color iconColor, String description){
     return InkWell(
      onTap:ontap,
      child:Container(
       width: SizeConfig.blockSizeHorizontal! *95,
       height: SizeConfig.blockSizeVertical! *10,
      decoration: BoxDecoration(
        color:Colors.white,
        borderRadius: BorderRadius.circular(15.0), // 角丸の半径を指定
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.7), // 影の色と透明度
            spreadRadius: 2, // 影の広がり
            blurRadius: 3, // ぼかしの強さ
            offset: const Offset(0, 3), // 影の方向（横、縦）
          ),
        ],
      ),
      child: Center(
        child: Row(
         crossAxisAlignment: CrossAxisAlignment.center,
         children:[
          const Spacer(),
          Icon(icon,color:iconColor,size:30),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
            const Spacer(),
            Text(text,style:const TextStyle(fontSize:22)),
            Text(description,style:const TextStyle(fontSize:13,color:Colors.grey)),
            const Spacer(),
          ]),
          
          const Spacer(),
       ])
      ),
    ),
  );
 }
}
