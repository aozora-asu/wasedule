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
        howToUsePanel("カレンダーとは?","大学生向けにカスタムされた便利なカレンダーです。授業課題とも連動し、あなたの学生生活をサポート。\n以下ではその機能をご紹介します。"),
        howToUsePanel("予定の登録","①カレンダーページの[+]ボタンを押すか、カレンダーの任意の日付を押す。\n\n②「+ 予定の追加...」を押す。\n\n③各ボタンを押し、情報を入力。\n・予定名(必須)\n  カレンダーに表示される予定の名前です。\n・日付(必須)\n  予定を登録する日付です。複数の日付を選択し、一括で入力することができます。\n・開始、終了時刻\n  予定の開始時刻、終了時刻を登録します。入力しなければ「終日」になります。\n・タグ\n  予定にタグ付けできます。表示時に色分けできるほか、アルバイト登録もできます。\n・共有時表示\n  「表示しない」にすると、「カレンダースクリーンショットの共有」時、その予定はスクリーンショットに含まれなくなります。\n・テンプレート\n  登録しておいた「テンプレート」を使用して、楽々入力できます。\n\n④入力可能であれば追加ボタンの色が変わるので、押して登録します。\n"),
        howToUsePanel("予定の編集","①編集したい予定があるカレンダーの日付を押す。\n\n②編集したい予定を押すと編集ダイアログが出てくるので、そこから編集を行う。"),
        howToUsePanel("テンプレート","よく使う予定をあらかじめテンプレートとして登録しておくことで、楽に入力できます！\n\n①登録時\nカレンダー上にある「#タグとテンプレート」を押し、「テンプレートの追加」から登録できます。\n\n②使用時\nカレンダー予定の登録時、「テンプレート」ボタンを押すことでテンプレートを使用できます。\n"),
        howToUsePanel("タグ","タグは、予定に紐づけることができます。\n紐づけることで予定をカテゴリ分け/色分けできたり、アルバイト時給を自動算出できたりします。\n\n①登録時\nカレンダー上にある「#タグとテンプレート」を押し、「タグの追加」から登録できます。この際「アルバイト」ボタンを押して時給と交通費を入力すると、「アルバイトタグ」として登録できます。\n\n②使用時\nカレンダー予定の登録時に、「タグ」ボタンを押すと使用することができます。\n※アルバイトタグを予定につける際は、「開始時刻」「終了時刻」の双方を登録してください。\n"),
        howToUsePanel("アルバイト","「アルバイトタグ」を登録して予定に紐づけると、タグに登録されている「時給」 × 予定に登録されている「終了時刻」-「開始時刻」で見込みの給料が自動計算されます。「年収の壁」管理や家計管理にお役立てください。\n\n①登録方法\nまず「アルバイトタグ」を登録します(※上記の「タグ」参照)。そしてアルバイトの予定をカレンダーに登録する際にそのタグを紐づけます。\n\n②閲覧時\n「カレンダー」ページの下部「￥アルバイト」から、年収・月収等のデータを閲覧できます。\n\n③修正記入\n見込み月収と実際の振込金額がずれた場合に、正しい振込金額を記入していただくことでより正確な年収記録をお求めいただけます。\n\n\n※時給や交通費が変わった場合は、新たなタグを作ることで対応いただけます。"),
        howToUsePanel("カレンダーの共有","カレンダーを画像として保存、印刷、SNS等にて共有していただくことができます！\n\n共有方法\nカレンダーページの[+]ボタンの左隣、共有ボタンを押すと、共有ポップアップが出現するのでそこから共有を行う。"),
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


