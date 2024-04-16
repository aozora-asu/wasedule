import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/handler/user_info_db_handler.dart';
import 'package:flutter_calandar_app/frontend/screens/common/tutorials.dart';
import 'package:flutter_calandar_app/frontend/screens/menu_pages/sns_link_page.dart';
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(color:Colors.white),
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
      SingleChildScrollView(
       child:Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [SizedBox(
            height:SizeConfig.blockSizeVertical! *5,
            child:CupertinoTextField(
              controller: _urlController,
              padding:const EdgeInsets.all(2),
              
             ), 
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async{

                // ここで入力されたURLを取得
                String enteredUrl = _urlController.text;
                if(await UserDatabaseHelper().resisterUserInfo(enteredUrl)){
                  succeedRegisterDialogue(context);
                }else{
                  failRegisterDialogue(context);
                }
                
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
              child:Text('①WasedaMoodle右端のアカウントアイコンからメニューを開き、「カレンダー」を選択',
               style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal! *4,
              ),),),
              const SizedBox(height: 16.0),
              Align(alignment:Alignment.centerLeft,
              child:Text('②カレンダーの下にある「カレンダーをインポートまたはエクスポートする」を押す。',
               style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal! *4,
              ),),),
              const SizedBox(height: 16.0),
              Align(alignment:Alignment.centerLeft,
              child:Text('③「カレンダーをエクスポートする」ボタンを押す。',
               style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal! *4,
              ),),),
              const SizedBox(height: 16.0),
              Align(alignment:Alignment.centerLeft,
              child:Text('④エクスポートしたいデータの種類と期間を選択。\n（推奨設定…「コースに関連したイベント」&「最近及び次の60日間」）',
               style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal! *4,
              ),),),
              const SizedBox(height: 16.0),
              Align(alignment:Alignment.centerLeft,
              child:Text('⑤「カレンダーURLを取得する」ボタンを押し、出現したURLを「URLをコピーする」ボタンでコピーする。',
               style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal! *4,
              ),),),
              const SizedBox(height: 16.0),
              Align(alignment:Alignment.centerLeft,
              child:Text('⑥アプリに戻り、上の入力フォームにURLをペーストして「登録」を押す',
               style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal! *4,
              ),),),
              const SizedBox(height: 8.0),
              MoodleUrlLauncher(width:100),
              const SizedBox(height: 16.0),
              const Divider(color: ACCENT_COLOR,thickness: 2,),
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
      ),) 
    );
  }

  void failRegisterDialogue(BuildContext context){
   showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
      title: const Text('登録失敗'),
      content: const Text('無効なURLです。'),
      actions: <Widget>[
        okButton(context, 500.0)
      ],
     );
    }
   );
  }

  void succeedRegisterDialogue(BuildContext context){
   showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
      title: const Text('登録成功'),
      content: const Text('以後、このアプリにあなたのMoodleから自動で課題が取得されるようになりました!'),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          style: const ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(MAIN_COLOR),
            visualDensity: VisualDensity.standard
            ),
          child:const Text('OK',style:TextStyle(color: Colors.white),),
        ),
      ],
     );
    }
   );
  }

 }
