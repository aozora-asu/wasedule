import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_calandar_app/backend/firebase_handler.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/add_event_button.dart';
import 'package:flutter_calandar_app/frontend/screens/common/tutorials.dart';
import 'package:flutter_calandar_app/frontend/screens/menu_pages/arbeit_stats_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../assist_files/colors.dart';
import '../../assist_files/size_config.dart';

class UnivSchedulePage extends ConsumerStatefulWidget {
  @override
  _UnivSchedulePageState createState() => _UnivSchedulePageState();
}

class _UnivSchedulePageState extends ConsumerState<UnivSchedulePage> {
  late int currentIndex;
  List<Map<String, dynamic>> shareScheduleList = [];

  @override
  void initState() {
    super.initState();
    currentIndex = 0;
    ref.read(scheduleFormProvider).clearContents();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        appBar: AppBar(
          leading: const BackButton(color: Colors.white),
          backgroundColor: MAIN_COLOR,
          elevation: 10,
          title: Column(
            children: <Widget>[
              Row(children: [
                const Icon(
                  Icons.school,
                  color: WIDGET_COLOR,
                ),
                SizedBox(
                  width: SizeConfig.blockSizeHorizontal! * 4,
                ),
                Text(
                  '年間行事予定',
                  style: TextStyle(
                      fontSize: SizeConfig.blockSizeHorizontal! * 5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white),
                ),
              ])
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
           child: Column(children: [
            SizedBox(height:SizeConfig.blockSizeHorizontal! * 80,
              child:thumbnailImage(),
            ),
            Container(
                width: SizeConfig.blockSizeHorizontal! * 100,
                decoration: roundedBoxdecorationWithShadow(),
                child: Column(children: [
                  pageBody()
                ]))
          ])
        )
      )
    );
  }

  Image thumbnailImage() {
      return Image.asset(
        'lib/assets/eye_catch/eyecatch.png',
        height: SizeConfig.blockSizeHorizontal! * 60,
        width: SizeConfig.blockSizeHorizontal! * 60,
      );
  }


  Widget pageBody() {
      return scheduleBroadcastPage();
  }

  TextEditingController idController = TextEditingController();
  Widget scheduleBroadcastPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("・早稲田大学の年間行事予定をダウンロードし、カレンダーに追加できます。",
              style: TextStyle(fontSize: 17)),
          const SizedBox(height: 10),
        ],
      ),
    );
  }


  void showDownloadConfirmDialogue() {
    TextEditingController idController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('の年間行事予定をカレンダーに追加しますか？'),
          actions: <Widget>[
            const Align(
                alignment: Alignment.centerLeft,
                child: Text("ダウンロードを行うと、端末内にあるデータにバックアップしたデータが全て追加されます。",
                    style: TextStyle(color: Colors.red))),
            const SizedBox(height: 10),
            CupertinoTextField(
              controller: idController,
              placeholder: 'IDを入力',
              onChanged: (value) {
                setState(() {});
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
                onPressed: () async {
                  String id = idController.text;
                  if (id.isNotEmpty) {
                    //ここにバックアップの実行処理を書き込む（ダウンロード）
                    bool isBackupSuccess = await recoveryBackup(id);
                    Navigator.pop(context);
                    if (isBackupSuccess) {
                      showDownloadDoneDialogue("データが復元されました！");
                    } else {
                      showDownloadFailDialogue("データの復元に失敗しました");
                    }
                  } else {
                    showDownloadFailDialogue("IDを入力してください。");
                  }
                },
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color?>(MAIN_COLOR)),
                child: const Row(children: [
                  Icon(Icons.downloading_outlined, color: Colors.white),
                  SizedBox(width: 20),
                  Text("ダウンロード実行", style: TextStyle(color: Colors.white))
                ]))
          ],
        );
      },
    );
  }

  void showDownloadDoneDialogue(String text) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ダウンロード完了'),
          actions: <Widget>[
            Align(alignment: Alignment.centerLeft, child: Text(text)),
            const SizedBox(height: 10),
            okButton(context, 500.0)
          ],
        );
      },
    );
  }

  void showDownloadFailDialogue(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ダウンロード失敗'),
          actions: <Widget>[
            Align(alignment: Alignment.centerLeft, child: Text(errorMessage)),
            const SizedBox(height: 10),
            okButton(context, 500.0)
          ],
        );
      },
    );
  }
}
