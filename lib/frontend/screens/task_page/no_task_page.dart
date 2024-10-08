import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/frontend/screens/common/ui_components.dart';
import 'package:flutter_calandar_app/frontend/screens/common/tutorials.dart';

class NoTaskPage extends StatefulWidget {
  void Function(int) moveToMoodlePage;
  NoTaskPage({
    required this.moveToMoodlePage,
    super.key});

  @override
  _NoTaskPageState createState() => _NoTaskPageState();
}

class _NoTaskPageState extends State<NoTaskPage> {
  @override
  Widget build(BuildContext context) {
  SizeConfig().init(context);
    return Scaffold(
      backgroundColor: BACKGROUND_COLOR,
      body:Padding(
        padding:const EdgeInsets.all(20),
        child:Column(
          children:[
        SizedBox(height: SizeConfig.blockSizeVertical! *10),
        Image.asset('lib/assets/eye_catch/eyecatch.png',height: 200, width: 200),
        const SizedBox(height:30),
        Text("現在課題はありません。",style:TextStyle(fontWeight: FontWeight.bold,fontSize: SizeConfig.blockSizeHorizontal! * 5,),),
        const SizedBox(height:20),
        const Align(
          alignment: Alignment.centerLeft,
          child:Text("■  [+]ボタンから新しいタスクを追加してみましょう！")),
        const SizedBox(height:5),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text("■  MoodleページからWaseda MoodleのURLを取得して、自動で課題を取得できるようにしましょう！"),
          ),
          const SizedBox(height:30),
          buttonModel(
            ()async{
              await showMoodleRegisterGuide(context,false,MoodleRegisterGuideType.task);
              widget.moveToMoodlePage(4);
              },
            PALE_MAIN_COLOR,"登録画面へ",
            verticalpadding: 10),
        const Spacer(),
      ])
      )
    );
  }


}

void noUrlDialogue(BuildContext context){
    showDialog(
    context: context,
    builder: (BuildContext context) {
      // ダイアログの内容を定義
      return AlertDialog(
        title: const Text('Confirmation'),
        content: const Text('Are you sure you want to delete?'),
        actions: [
          // キャンセルボタン
          TextButton(
            onPressed: () {
              // ダイアログを閉じる
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          // 削除ボタン
          TextButton(
            onPressed: () {
              // 削除処理を実行
              // ここに削除処理のコードを追加
              // 例：deleteItem();
              // ダイアログを閉じる
              Navigator.of(context).pop();
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      );
    },
  );
}