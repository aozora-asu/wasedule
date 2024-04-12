import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_calandar_app/backend/firebase_handler.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/add_event_button.dart';
import 'package:flutter_calandar_app/frontend/screens/common/tutorials.dart';
import 'package:flutter_calandar_app/frontend/screens/menu_pages/arbeit_stats_page.dart';
import 'package:flutter_calandar_app/frontend/screens/menu_pages/scanner_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../assist_files/colors.dart';
import '../../assist_files/size_config.dart';
import 'package:toggle_switch/toggle_switch.dart';

class DataDownloadPage extends ConsumerStatefulWidget {
  @override
  _DataDownloadPageState createState() => _DataDownloadPageState();
}

class _DataDownloadPageState extends ConsumerState<DataDownloadPage> {
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
                  Icons.install_mobile,
                  color: WIDGET_COLOR,
                ),
                SizedBox(
                  width: SizeConfig.blockSizeHorizontal! * 4,
                ),
                Text(
                  '予定のダウンロード',
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
          thumbnailImage(),
          Container(
              width: SizeConfig.blockSizeHorizontal! * 100,
              decoration: roundedBoxdecorationWithShadow(),
              child: Column(children: [
                const SizedBox(height: 15),
                toggleSwitch(),
                pageBody()
              ]))
        ]))));
  }

  Image thumbnailImage() {
    if (currentIndex == 1) {
      return Image.asset(
        'lib/assets/schedule_share/schedule_backup_download.png',
        height: SizeConfig.blockSizeHorizontal! * 100,
        width: SizeConfig.blockSizeHorizontal! * 100,
      );
    } else {
      return Image.asset(
        'lib/assets/schedule_share/schedule_broadcast_download.png',
        height: SizeConfig.blockSizeHorizontal! * 100,
        width: SizeConfig.blockSizeHorizontal! * 100,
      );
    }
  }

  Widget toggleSwitch() {
    return ToggleSwitch(
      initialLabelIndex: currentIndex,
      totalSwitches: 2,
      activeBgColor: const [MAIN_COLOR],
      minWidth: SizeConfig.blockSizeHorizontal! * 45,
      labels: const ['予定の受信', 'バックアップ復元'],
      onToggle: (index) {
        setState(() {
          currentIndex = index ?? 0;
        });
      },
    );
  }

  Widget pageBody() {
    if (currentIndex == 0) {
      return scheduleBroadcastPage();
    } else {
      return dataBackupPage();
    }
  }

  TextEditingController idController = TextEditingController();
  Widget scheduleBroadcastPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("・ほかの人が配信した予定データを、スケジュールＩＤを入力して受信することができます！",
              style: TextStyle(fontSize: 17)),
          const SizedBox(height: 10),
          CupertinoTextField(
            controller: idController,
            placeholder: 'IDを入力',
          ),
          Row(children: [
            const Text("もしくは"),
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ScannerWidget(
                    idController: idController,
                  ),
                ));
              },
              icon: const Icon(Icons.qr_code_2, color: Colors.blue),
              label: const Text("QRを読み込み",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.blue)),
            )
          ]),
          const SizedBox(height: 20),
          scheduleReceiveButton(idController),
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  Widget scheduleReceiveButton(TextEditingController idController) {
    return ElevatedButton(
      onPressed: () async {
        String id = idController.text;
        if (id.isNotEmpty) {
          Navigator.pop(context);
          bool isScheduleDownloadSuccess = await receiveSchedule(id);
          if (isScheduleDownloadSuccess) {
            showDownloadDoneDialogue("データがダウンロードされました！");
          } else {
            showDownloadFailDialogue("ダウンロードに失敗しました");
          }
        } else {
          showDownloadFailDialogue("IDを入力してください。");
        }
      },
      style: const ButtonStyle(
        backgroundColor: MaterialStatePropertyAll(ACCENT_COLOR),
      ),
      child: const Row(
        children: [
          Icon(Icons.install_mobile, color: Colors.white),
          SizedBox(width: 20),
          Text("予定を受信する", style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget dataBackupPage() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("・バックアップしたデータの復元を行います。", style: TextStyle(fontSize: 17)),
          const SizedBox(height: 10),
          const Text("・復元に際して、バックアップ時に発行されたIDが必要です。保管したIDを入力できるようにしておいてください。",
              style: TextStyle(color: Colors.red, fontSize: 17)),
          const SizedBox(height: 15),
          backUpDownloadButton(),
          const SizedBox(height: 15),
        ]));
  }

  Widget backUpDownloadButton() {
    return ElevatedButton(
        onPressed: () {
          showDownloadConfirmDialogue();
        },
        style: const ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(ACCENT_COLOR),
        ),
        child: const Row(children: [
          Icon(Icons.downloading_outlined, color: Colors.white),
          SizedBox(width: 20),
          Text("バックアップを復元", style: TextStyle(color: Colors.white))
        ]));
  }

  void showDownloadConfirmDialogue() {
    TextEditingController idController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('バックアップを復元しますか？'),
          actions: <Widget>[
            const Align(
                alignment: Alignment.centerLeft,
                child: Text("ダウンロードを行うと、端末内にあるデータにバックアップしたデータが全て追加されます。",
                    style: TextStyle(color: Colors.red))),
            const Text(
                """\n以下の点をご留意ください\n・この操作は取り消しできません\n・1つのIDに対してダウンロードは一回のみ有効です\n・一度復元するとサーバー上から削除され二度と復元できません""",
                style: TextStyle(color: Colors.red)),
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
