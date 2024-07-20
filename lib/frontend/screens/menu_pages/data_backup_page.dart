import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_calandar_app/backend/firebase/firebase_handler.dart';
import 'package:flutter_calandar_app/frontend/assist_files/data_loader.dart';
import 'package:flutter_calandar_app/frontend/assist_files/ui_components.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/add_event_button.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/calendar_data_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../assist_files/colors.dart';
import '../../assist_files/size_config.dart';
import 'package:toggle_switch/toggle_switch.dart';

class DataDownloadPage extends ConsumerStatefulWidget {
  const DataDownloadPage({super.key});

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
        // appBar: AppBar(
        //   leading: const BackButton(color: WHITE),
        //   backgroundColor: MAIN_COLOR,
        //   elevation: 10,
        //   title: Column(
        //     children: <Widget>[
        //       Row(children: [
        //         const Icon(
        //           Icons.backup,
        //           color: WIDGET_COLOR,
        //         ),
        //         SizedBox(
        //           width: SizeConfig.blockSizeHorizontal! * 4,
        //         ),
        //         Text(
        //           'データバックアップ',
        //           style: TextStyle(
        //               fontSize: SizeConfig.blockSizeHorizontal! * 5,
        //               fontWeight: FontWeight.w800,
        //               color: WHITE),
        //         ),
        //       ])
        //     ],
        backgroundColor: FORGROUND_COLOR,
        //   ),
        // ),
        body: SingleChildScrollView(
            child: Center(
                child: Column(children: [
          thumbnailImage(),
          Container(
              width: SizeConfig.blockSizeHorizontal! * 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: BACKGROUND_COLOR,
              ),
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
        'lib/assets/schedule_share/schedule_backup_upload.png',
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
      labels: const ['バックアップ', 'バックアップの復元'],
      onToggle: (index) {
        setState(() {
          currentIndex = index ?? 0;
        });
      },
    );
  }

  Widget pageBody() {
    if (currentIndex == 0) {
      return backupDownloadPage();
    } else {
      return backupUploadPage();
    }
  }

  Widget backupDownloadPage() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text(
              "・今お使いの端末からサーバー上にすべてのデータをバックアップします。のちにこの端末や他の端末に復元していただけます。",
              style: TextStyle(fontSize: 17)),
          const SizedBox(height: 10),
          const Text("・バックアップに際して、発行されるIDが必要です。スクリーンショットなどで保管しておいてください。",
              style: TextStyle(color: Colors.red, fontSize: 17)),
          const SizedBox(height: 10),
          const Text("・バックアップは復元後、もしくはアップロードから一定期間後にサーバー上から自動削除されます。",
              style: TextStyle(color: Colors.red, fontSize: 17)),
          const SizedBox(height: 15),
          backUpUploadButton(),
          showIDView(),
        ]));
  }

  Widget backUpUploadButton() {
    return buttonModelWithChild(() async {
      String? id = await backup();

      if (id == null) {
        showBackupFailDialogue("バックアップが失敗しました。");
      } else {
        showBackUpDoneDialogue(id);
      }

      setState(() {});
    },
        MAIN_COLOR,
        Row(children: [
          const SizedBox(width: 20),
          Icon(Icons.backup, color: FORGROUND_COLOR),
          const SizedBox(width: 20),
          Text("データをバックアップ", style: TextStyle(color: FORGROUND_COLOR))
        ]));
  }

  void showBackUpDoneDialogue(String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('バックアップ完了'),
          actions: <Widget>[
            const Text("バックアップの復元に際して、こちらのIDが必要です。スクリーンショットなどで保管しておいてください。",
                style: TextStyle(color: Colors.red)),
            const SizedBox(height: 10),
            const Align(alignment: Alignment.centerLeft, child: Text("ID:")),
            Text(id,
                style:
                    const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
            okButton(context, 500.0)
          ],
        );
      },
    );
  }

  void showBackupFailDialogue(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('アップロード失敗'),
          actions: <Widget>[
            Align(alignment: Alignment.centerLeft, child: Text(errorMessage)),
            const SizedBox(height: 10),
            okButton(context, 500.0)
          ],
        );
      },
    );
  }

  Widget showIDView() {
    return FutureBuilder(
      future: UserInfoLoader().getUserIDSource(ref),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(
            color: MAIN_COLOR,
          );
        } else if (snapshot.hasError) {
          return const SizedBox();
        } else {
          UserInfoLoader().insertDataToProvider(ref);
          return iDView(snapshot.data);
        }
      },
    );
  }

  Widget iDView(String? id) {
    DateTime dtEnd = ref.watch(calendarDataProvider).backUpDtEnd;
    if (id == null || id.isEmpty || dtEnd.isBefore(DateTime.now())) {
      return const SizedBox();
    } else {
      return Column(children: [
        const SizedBox(height: 20),
        Container(
            decoration: roundedBoxdecorationWithShadow(),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Text("あなたのバックアップID:", style: TextStyle(fontSize: 15)),
                IconButton(
                    onPressed: () async {
                      final data = ClipboardData(text: id);
                      await Clipboard.setData(data);
                    },
                    icon: const Icon(Icons.copy, color: Colors.grey))
              ]),
              Text(id,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 25)),
              Text(
                "あと${dtEnd.difference(DateTime.now()).inDays}日",
                style: const TextStyle(color: Colors.redAccent),
                overflow: TextOverflow.ellipsis,
              )
            ]))
      ]);
    }
  }

  Widget backupUploadPage() {
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
    return buttonModelWithChild(() {
      showDownloadConfirmDialogue();
    },
        ACCENT_COLOR,
        Row(children: [
          const SizedBox(width: 20),
          Icon(Icons.downloading_outlined, color: FORGROUND_COLOR),
          const SizedBox(width: 20),
          Text("バックアップを復元", style: TextStyle(color: FORGROUND_COLOR))
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
            buttonModelWithChild(() async {
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
                MAIN_COLOR,
                Row(children: [
                  const SizedBox(width: 20),
                  Icon(Icons.downloading_outlined, color: FORGROUND_COLOR),
                  const SizedBox(width: 20),
                  Text("ダウンロード実行", style: TextStyle(color: FORGROUND_COLOR))
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
