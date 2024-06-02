import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/frontend/assist_files/ui_components.dart';

class NoTaskPage extends StatefulWidget {
  @override
  _NoTaskPageState createState() => _NoTaskPageState();
}

class _NoTaskPageState extends State<NoTaskPage> {
  @override
  Widget build(BuildContext context) {
  SizeConfig().init(context);
    return Scaffold(
      backgroundColor: WHITE,
      body:Padding(
        padding:const EdgeInsets.all(20),
        child:Column(
          children:[
        const Spacer(),
        Image.asset('lib/assets/eye_catch/eyecatch.png',height: 200, width: 200),
        const Spacer(),
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
        const Icon(
          Icons.keyboard_double_arrow_right,
          color: MAIN_COLOR,
          size: 150,
        ),
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
        title: Text('Confirmation'),
        content: Text('Are you sure you want to delete?'),
        actions: [
          // キャンセルボタン
          TextButton(
            onPressed: () {
              // ダイアログを閉じる
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
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
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      );
    },
  );
}