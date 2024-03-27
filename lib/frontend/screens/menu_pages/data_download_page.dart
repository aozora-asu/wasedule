import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_calandar_app/backend/firebase_handler.dart';
import 'package:flutter_calandar_app/frontend/assist_files/data_loader.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/add_event_button.dart';
import 'package:flutter_calandar_app/frontend/screens/common/tutorials.dart';
import 'package:flutter_calandar_app/frontend/screens/menu_pages/arbeit_stats_page.dart';
import 'package:flutter_calandar_app/frontend/screens/menu_pages/data_upload_page.dart';
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
          const Text("・ほかの人が配信した予定データを、共有ＩＤを入力して受信登録することができます！",
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
          showDownloadDataView(),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget scheduleReceiveButton(TextEditingController idController) {
    return ElevatedButton(
      onPressed: () {
        String id = idController.text;
        if (id.isNotEmpty) {
          receiveSchedule(id);

          Navigator.pop(context);
          showDownloadDoneDialogue();
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
          Text("予定を受信登録する", style: TextStyle(color: Colors.white)),
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
                child: Text("ダウンロードを行うと今端末内にあるデータが全て削除され、バックアップしたデータが復元されます。",
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
                onPressed: () {
                  String id = idController.text;
                  if (id.isNotEmpty) {
                    //ここにバックアップの実行処理を書き込む（ダウンロード）

                    Navigator.pop(context);
                    showDownloadDoneDialogue();
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

  void showDownloadDoneDialogue() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ダウンロード完了'),
          actions: <Widget>[
            const Align(
                alignment: Alignment.centerLeft, child: Text("データが復元されました！")),
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

  Widget showDownloadDataView() {
    return FutureBuilder(
      future: BroadcastLoader().getDownloadDataSource(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(
            color: MAIN_COLOR,
          );
        } else if (snapshot.hasError) {
          return Text('エラー: ${snapshot.error}');
        } else {
          BroadcastLoader().insertUploadDataToProvider(ref);
          return donwloadDataView(snapshot.data);
        }
      },
    );
  }

  Widget donwloadDataView(Map<String, dynamic> data) {
    if (data.isEmpty) {
      return const SizedBox();
    } else {
      return Column(children: [
        const SizedBox(height: 20),
        Container(
            decoration: roundedBoxdecorationWithShadow(),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("ダウンロード登録中のデータ:",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Divider(height: 1),
              downloadDataList(data),
              const Divider(height: 1),
              const SizedBox(height: 10),
            ]))
      ]);
    }
  }

  Widget downloadDataList(Map<String, dynamic> data) {
    return ListView.separated(
      itemBuilder: (context, index) {
        String id = data.keys.elementAt(index);
        return Column(children: [
          Text(id),
          Row(children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.values.elementAt(index).elementAt(0)["subject"],
                      style: const TextStyle(color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                    InkWell(
                    onTap:() {
                      showSchedulesDialogue(context,"ダウンロード登録中のデータ",
                        data.values.elementAt(index));
                    },
                    child:Text(
                      "ほか" +
                          (data.values.elementAt(index).length - 1).toString() +
                          "件",
                      style: const TextStyle(color: Colors.blueAccent),
                      overflow: TextOverflow.ellipsis,
                      )
                    )
                  ]),
            ),
            IconButton(
                onPressed: () async {
                  final data = ClipboardData(text: id);
                  await Clipboard.setData(data);
                },
                icon: const Icon(Icons.copy, color: Colors.grey)),
          ])
        ]);
      },
      separatorBuilder: (context, index) {
        return const Divider(height: 1);
      },
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: data.length,
    );
  }
}
