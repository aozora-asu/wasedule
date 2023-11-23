import 'package:flutter/material.dart';
import '../../colors.dart';
import '../../size_config.dart';

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
            ), ),

            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // ここで入力されたURLを取得
                String enteredUrl = _urlController.text;
                // TODO: 入力されたURLを使用する処理を追加
                print('Entered URL: $enteredUrl');
              },
            style: ElevatedButton.styleFrom(
              backgroundColor: MAIN_COLOR, // ここで背景色を設定
            ),
              child: const Text('登録'),
            ),
          ],
        ),
      ),
    );
  }
}