import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/handler/todo_db_handler.dart';
import 'package:flutter_calandar_app/backend/DB/handler/user_info_db_handler.dart';
import '../../assist_files/colors.dart';
import '../../assist_files/size_config.dart';

class UrlRegisterPage extends StatefulWidget {
  @override
  _UrlRegisterPageState createState() => _UrlRegisterPageState();
}

class _UrlRegisterPageState extends State<UrlRegisterPage> {
  TextEditingController _urlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
  SizeConfig().init(context);
    return Scaffold(appBar: AppBar(
        backgroundColor: MAIN_COLOR,
        elevation: 10,
        title: Column(
          children:<Widget>[
            Row(children:[
            const Icon(
              Icons.add_link,
              color:WIDGET_COLOR,
              ),
              SizedBox(width: SizeConfig.blockSizeHorizontal! *4,),
            Text(
              'URLの登録/変更',
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
      body: 
      Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Container(
            height:SizeConfig.blockSizeHorizontal! *10,
            child:TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Moodle URL',
              ),
             ), 
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // ここで入力されたURLを取得
                String enteredUrl = _urlController.text;
                UserDatabaseHelper().resisterUserInfo(enteredUrl);
                Navigator.pop(context);
              },
            style: ElevatedButton.styleFrom(
              backgroundColor: MAIN_COLOR,
            ),
              child: const Text('登録',style:TextStyle(color:Colors.white)),
            ),
            const Divider(color: ACCENT_COLOR,thickness: 2,),
              Align(alignment:Alignment.centerLeft,
              child:Text('登録方法',
               style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal! *5,
                fontWeight: FontWeight.w800,
              ),),),
              const SizedBox(height: 4.0),
              Align(alignment:Alignment.centerLeft,
              child:Text('①WasedaMoodle「ダッシュボード」ページの一番下「カレンダーをインポートまたはエクスポートする」ボタンを押す。',
               style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal! *4,
              ),),),
              const SizedBox(height: 16.0),
              Align(alignment:Alignment.centerLeft,
              child:Text('②「カレンダーをエクスポートする」ボタンを押す。',
               style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal! *4,
              ),),),
              const SizedBox(height: 16.0),
              Align(alignment:Alignment.centerLeft,
              child:Text('③エクスポートしたいデータの種類と期間を選択。\n（推奨設定…「コースに関連したイベント」&「最近及び次の60日間」）',
               style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal! *4,
              ),),),
              const SizedBox(height: 16.0),
              Align(alignment:Alignment.centerLeft,
              child:Text('④「カレンダーURLを取得する」ボタンを押し、出現したURLを「URLをコピーする」ボタンでコピーする。',
               style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal! *4,
              ),),),
              const SizedBox(height: 16.0),
              Align(alignment:Alignment.centerLeft,
              child:Text('⑤アプリに戻り、上の入力フォームにURLをペーストして「登録」を押す',
               style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal! *4,
              ),),),
              const SizedBox(height: 16.0),
              Divider(color: ACCENT_COLOR,thickness: 2,),
              Align(alignment:Alignment.centerLeft,
              child:Text('登録完了！',
               style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal! *5,
                fontWeight: FontWeight.w800,
              ),),),
              const SizedBox(height: 4.0),
              Align(alignment:Alignment.centerLeft,
              child:Text('以後、このアプリにあなたのMoodleから課題が自動で取得されます!',
               style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal! *4,
              ),),),
          ],),
      ),
    );
  }
}