import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/frontend/screens/menu_pages/url_register_page.dart';

class NoTaskPage extends StatefulWidget {
  @override
  _NoTaskPageState createState() => _NoTaskPageState();
}

class _NoTaskPageState extends State<NoTaskPage> {
  @override
  Widget build(BuildContext context) {
  SizeConfig().init(context);
    return Scaffold(
        body:Padding(
          padding:const EdgeInsets.all(20),
          child:Column(children:[
          const Spacer(),
          Image.asset('lib/assets/eye_catch/eyecatch.png',height: 200, width: 200),
          const Spacer(),
          const Text("現在課題はありません",style:TextStyle(fontWeight: FontWeight.bold,fontSize: 30),),
          const SizedBox(height:20),
          const Text("● [+]ボタンから新しいタスクを追加してみましょう！\n● Waseda MoodleのURLを登録して、自動で課題を取得できるようにしましょう！"),
          const SizedBox(height:15),
          urlPageButton(),
          const Spacer(),
          ])
        )
        
    );
  }

  Widget urlPageButton(){
    return ElevatedButton(
      style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(MAIN_COLOR)),
      onPressed:(){
          Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UrlRegisterPage()),
        );
      },
      child:const Row(children:[
        Icon(Icons.add_link_rounded,color: Colors.white),
        SizedBox(width:20),
        Text("Moodle URL登録",style:TextStyle(color:Colors.white,fontWeight:FontWeight.bold))
      ])
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