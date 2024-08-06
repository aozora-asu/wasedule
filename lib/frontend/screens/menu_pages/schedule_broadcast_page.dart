import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_calandar_app/backend/DB/handler/schedule_metaInfo_db_handler.dart';
import 'package:flutter_calandar_app/backend/firebase/firebase_handler.dart';
import 'package:flutter_calandar_app/frontend/assist_files/data_loader.dart';
import 'package:flutter_calandar_app/frontend/assist_files/ui_components.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/add_event_dialog.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/calendar_data_manager.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/tag_and_template_page.dart';
import 'package:flutter_calandar_app/frontend/screens/menu_pages/code_share_page.dart';
import 'package:flutter_calandar_app/frontend/screens/menu_pages/scanner_page.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/task_data_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../assist_files/colors.dart';
import '../../assist_files/size_config.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:ulid/ulid.dart';

class DataUploadPage extends ConsumerStatefulWidget {
  const DataUploadPage({super.key});

  @override
  _DataUploadPageState createState() => _DataUploadPageState();
}

class _DataUploadPageState extends ConsumerState<DataUploadPage> {
  late int currentIndex;
  List<Map<String, dynamic>> shareScheduleList = [];
  late TextEditingController dtEndController;

  @override
  void initState() {
    super.initState();
    currentIndex = 0;
    ref.read(scheduleFormProvider).clearContents();
    dtEndController = TextEditingController(text: "30");
  }

  @override
  Widget build(BuildContext context) {
    generateShereScheduleList(
        ref.watch(scheduleFormProvider).tagController.text);
    SizeConfig().init(context);
    return Scaffold(
        backgroundColor: BACKGROUND_COLOR,
        // appBar: AppBar(
        //   leading: const BackButton(color: WHITE),
        //   backgroundColor: MAIN_COLOR,
        //   elevation: 10,
        //   title: Column(
        //     children: <Widget>[
        //       Row(children: [
        //         const Icon(
        //           Icons.group,
        //           color: WIDGET_COLOR,
        //         ),
        //         SizedBox(
        //           width: SizeConfig.blockSizeHorizontal! * 4,
        //         ),
        //         Text(
        //           '予定の配信/受信',
        //           style: TextStyle(
        //               fontSize: SizeConfig.blockSizeHorizontal! * 5,
        //               fontWeight: FontWeight.w800,
        //               color: WHITE),
        //         ),
        //       ])
        //     ],
        //   ),
        // ),
        body: SingleChildScrollView(
            child: Center(
                child: Column(children: [
          thumbnailImage(),
          Container(
              width: SizeConfig.blockSizeHorizontal! * 100,
              decoration: BoxDecoration(
                  color: FORGROUND_COLOR,
                  borderRadius:const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30))),
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
        'lib/assets/schedule_share/schedule_broadcast_download.png',
        height: SizeConfig.blockSizeHorizontal! * 100,
        width: SizeConfig.blockSizeHorizontal! * 100,
      );
    } else {
      return Image.asset(
        'lib/assets/schedule_share/schedule_broadcast_upload.png',
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
      labels: const ['予定の配信', '予定の受信'],
      onToggle: (index) {
        setState(() {
          currentIndex = index ?? 0;
        });
      },
    );
  }

  Widget pageBody() {
    if (currentIndex == 0) {
      return broadcastUploadPage();
    } else {
      return broadcastDownloadPage();
    }
  }

  Widget broadcastUploadPage() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text(
              "・「スケジュールID」を知っている人に向けて、予定を配信することができます。サークルやゼミなどで、スケジュールの共有にお使いください。",
              style: TextStyle(fontSize: 17)),
          const SizedBox(height: 10),
          const Text("・選択したタグが紐付いている予定のみが共有されます。",
              style: TextStyle(color: Colors.red, fontSize: 17)),
          const SizedBox(height: 10),
          chooseTagButton(),
          const SizedBox(height: 5),
          broadcastUploadButton(),
          const SizedBox(height: 5),
          dtEndField(60),
          tagThumbnail(),
          shereScheduleListView(),
          showUploadDataView(),
        ]));
  }

  Widget chooseTagButton() {
    return buttonModelWithChild(() async {
      await showTagDialogue(ref, context, setState);
      setState(() {});
    },
        PALE_MAIN_COLOR,
        Row(
          children: [
            const SizedBox(width: 20),
            Icon(Icons.more_vert_rounded, color: FORGROUND_COLOR),
            const SizedBox(width: 20),
            Text("タグを選択", style: TextStyle(color: FORGROUND_COLOR)),
          ],
        ),
        verticalpadding: 8);
  }

  Widget dtEndField(int maxDay) {
    if (shareScheduleList.isEmpty) {
      return const SizedBox();
    } else {
      return Row(children: [
        Text("有効期限(~$maxDay日)"),
        const Spacer(),
        SizedBox(
            width: SizeConfig.blockSizeHorizontal! * 20,
            child: CupertinoTextField(
              controller: dtEndController,
              placeholder: "半角数字",
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
            )),
        SizedBox(width: SizeConfig.blockSizeHorizontal! * 1),
        const Text("日"),
        SizedBox(width: SizeConfig.blockSizeHorizontal! * 3),
      ]);
    }
  }

  Widget tagThumbnail() {
    String tagID =
        returnTagId(ref.watch(scheduleFormProvider).tagController.text, ref) ??
            "";
    if (tagID.isEmpty) {
      return const SizedBox();
    } else {
      return Column(children: [
        const SizedBox(height: 30),
        Row(children: [
          const Text("選択中："),
          tagChip(tagID, ref),
          const SizedBox(width: 10),
          Text("${shareScheduleList.length}件",
              style: const TextStyle(color: Colors.grey)),
        ]),
        const SizedBox(height: 5),
      ]);
    }
  }

  Future<void> generateShereScheduleList(String id) async {
    shareScheduleList = [];
    List<Map<String, dynamic>> result = [];
    List calendarList = ref.watch(calendarDataProvider).calendarData;
    if (id.isNotEmpty) {
      for (int i = 0; i < calendarList.length; i++) {
        if (calendarList.elementAt(i)["tagID"] == returnTagId(id, ref)) {
          result.add(calendarList.elementAt(i));
        }
      }
    }
    shareScheduleList = result.reversed.toList();
  }

  Widget shereScheduleListView() {
    return ListView.separated(
      itemBuilder: (context, index) {
        Map targetDayData = shareScheduleList.elementAt(index);
        Text dateTimeData = const Text("");
        if (targetDayData["startTime"].trim() != "" &&
            targetDayData["endTime"].trim() != "") {
          dateTimeData = Text(
            "${" " + targetDayData["startTime"]}～" + targetDayData["endTime"],
            style: const TextStyle(color: Colors.grey),
          );
        } else if (targetDayData["startTime"].trim() != "") {
          dateTimeData = Text(
            " " + targetDayData["startTime"],
            style: const TextStyle(color: Colors.grey),
          );
        } else {
          dateTimeData = const Text(
            " 終日",
            style: TextStyle(color: Colors.grey),
          );
        }

        return Container(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(
              shareScheduleList.elementAt(index)["startDate"],
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(width: 10),
            dateTimeData
          ]),
          Text(shareScheduleList.elementAt(index)["subject"]),
        ]));
      },
      separatorBuilder: (context, index) {
        return const Divider(height: 1);
      },
      itemCount: shareScheduleList.length,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
    );
  }

  Widget broadcastUploadButton() {
    if (shareScheduleList.isNotEmpty) {
      return buttonModelWithChild(() async {
        int dtEnd = int.parse(dtEndController.text);

        if (dtEnd > 60 || 0 >= dtEnd) {
          showBackupFailDialogue("有効期限は1日以上60日以下に設定してください。");
        } else {
          String tagID = returnTagId(
                  ref.watch(scheduleFormProvider).tagController.text, ref) ??
              "";
          String? scheduleID =
              await ScheduleMetaDatabaseHelper().getScheduleIDByTagID(tagID);

          if (scheduleID != null) {
            confirmDataReplaceDialogue(scheduleID, tagID, dtEnd);
          } else {
            inputScheduleIDDialogue(context, tagID, dtEnd, setState);
          }
        }
      },
          MAIN_COLOR,
          Row(children: [
            const SizedBox(width: 20),
            Icon(Icons.backup, color: FORGROUND_COLOR),
            const SizedBox(width: 20),
            Text("予定をアップロード", style: TextStyle(color: FORGROUND_COLOR))
          ]));
    } else {
      return const SizedBox();
    }
  }

  void inputScheduleIDDialogue(
      BuildContext context, String tagID, int dtEnd, StateSetter setosute) {
    bool isIDValid = true;
    Color textColor = Colors.green;
    String validatorText = "このIDは登録可能です";
    TextEditingController scheduleIDController = TextEditingController();
    scheduleIDController.text = insertHyphens(Ulid().toString().toUpperCase());
    bool isSuccessed;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('予定のアップロード'),
              actions: <Widget>[
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("共有する予定のスケジュールIDを設定しましょう。"),
                ),
                const Text(
                    """IDを知っている者は予定をダウンロードできてしまいます。\n・6文字以上\n・推測されにくい文字列\nで設定することを推奨します。""",
                    style: TextStyle(color: Colors.red)),
                const SizedBox(height: 10),
                CupertinoTextField(
                  controller: scheduleIDController,
                  placeholder: 'スケジュールIDを入力',
                  onChanged: (value) async {
                    if (scheduleIDController.text.isEmpty) {
                      isIDValid = false;
                      textColor = Colors.red;
                      validatorText = "1文字以上入力してください。";
                    } else if (!isValidInput(scheduleIDController.text)) {
                      isIDValid = false;
                      textColor = Colors.red;
                      validatorText = "文字数は半角32文字以内にしてください";
                    } else if (await isResisteredScheduleID(
                        scheduleIDController.text)) {
                      isIDValid = false;
                      textColor = Colors.red;
                      validatorText = "このIDはすでに登録されています。";
                    } else {
                      isIDValid = true;
                      textColor = Colors.green;
                      validatorText = "このIDは登録可能です";
                    }
                    setState(() {});
                  },
                ),
                const SizedBox(height: 5),
                Text(validatorText, style: TextStyle(color: textColor)),
                const SizedBox(height: 5),
                ElevatedButton(
                  onPressed: () async {
                    String id = scheduleIDController.text;
                    if (isIDValid && !await isResisteredScheduleID(id)) {
                      isSuccessed = await postScheduleToFB(id, tagID, dtEnd);
                      Navigator.pop(context);
                      if (!isSuccessed) {
                        //処理の失敗時
                        showBackupFailDialogue("アップロードに失敗しました");
                      } else {
                        ref.watch(scheduleFormProvider).clearContents();
                        //処理の成功時
                        //アップロード完了を知らせるダイアログ
                        showUploadDoneDialogue(id);
                      }
                    } else {
                      showBackupFailDialogue("アップロードに失敗しました");
                    }
                    setosute(() {});
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith<Color>(
                      (Set<WidgetState> states) {
                        if (!isIDValid) {
                          return Colors.grey; //無効時の色
                        } else {
                          return MAIN_COLOR; // デフォルトカラー
                        }
                      },
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.upload_file, color: FORGROUND_COLOR),
                      const SizedBox(width: 20),
                      Text("アップロード", style: TextStyle(color: FORGROUND_COLOR)),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void confirmDataReplaceDialogue(
      String scheduleID, String tagID, int dtEnd) async {
    bool isSuccessed;
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('この予定はすでに配信されています'),
            content: const Text('配信中の予定を上書きしますか？'),
            actions: [
              buttonModel(
                () async {
                  isSuccessed =
                      await postScheduleToFB(scheduleID, tagID, dtEnd);
                  Navigator.of(context).pop();
                  if (!isSuccessed) {
                    //処理の失敗時
                    showBackupFailDialogue("アップロードに失敗しました");
                  } else {
                    ref.watch(scheduleFormProvider).clearContents();
                    //処理の成功時
                    //アップロード完了を知らせるダイアログ
                    showUploadDonePlainDialogue(scheduleID);
                    setState(() {});
                  }
                },
                MAIN_COLOR,
                '  はい  ',
              ),
              const SizedBox(height: 5),
              buttonModel(
                () {
                  Navigator.of(context).pop();
                },
                ACCENT_COLOR,
                '  いいえ  ',
              ),
            ],
          );
        });
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

  void showUploadDonePlainDialogue(String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('アップロードデータが更新されました',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          actions: <Widget>[
            const SizedBox(height: 10),
            okButton(context, 500.0)
          ],
        );
      },
    );
  }

  void showUploadDoneDialogue(String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('アップロード完了'),
          actions: <Widget>[
            const Text("他の人に以下のスケジュールIDをシェアして、いま配信した予定を受信してもらいましょう！",
                style: TextStyle(color: Colors.red)),
            const SizedBox(height: 10),
            const Align(
                alignment: Alignment.centerLeft, child: Text("スケジュールID")),
            Text(id,
                style:
                    const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
            okButton(context, 500.0)
          ],
        );
      },
    );
  }

  Widget showUploadDataView() {
    return FutureBuilder(
      future: BroadcastLoader().getUploadDataSource(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(
            color: MAIN_COLOR,
          );
        } else if (snapshot.hasError) {
          return const SizedBox();
          //Text('エラー: ${snapshot.error}');
        } else {
          BroadcastLoader().insertUploadDataToProvider(ref);
          return uploadDataView(snapshot.data);
        }
      },
    );
  }

  Widget uploadDataView(Map<String, dynamic> data) {
    if (data.isEmpty || data.values.elementAt(0).isEmpty) {
      return const SizedBox();
    } else {
      return Column(children: [
        const SizedBox(height: 20),
        Container(
            decoration: roundedBoxdecoration(),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("アップロード中データ:",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Divider(height: 1),
              uploadDataList(data),
              const Divider(height: 1),
              const SizedBox(height: 10),
            ]))
      ]);
    }
  }

  Widget uploadDataList(Map<String, dynamic> data) {
    return ListView.separated(
      itemBuilder: (context, index) {
        String id = data.keys.elementAt(index);
        Map tag = data.values.elementAt(index)["tag"];
        String rawDtEnd = data.values.elementAt(index)["dtEnd"];
        DateTime dtEnd = DateTime.parse(rawDtEnd);
        List scheduleList = data.values.elementAt(index)["schedule"];

        if (dtEnd.isBefore(DateTime.now())) {
          return const SizedBox();
        } else if (scheduleList.isEmpty) {
          return const SizedBox();
        } else {
          Widget listChild = Column(children: [
            const SizedBox(height: 4),
            Row(children: [validTagChip(tag)]),
            Row(children: [
              Text(id),
            ]),
            Row(children: [
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scheduleList.elementAt(0)["subject"] ?? "",
                        style: const TextStyle(color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(children: [
                        InkWell(
                            onTap: () {
                              showSchedulesDialogue(
                                  context, "アップロード中データ", scheduleList);
                            },
                            child: Text(
                              "ほか${scheduleList.length - 1}件",
                              style: const TextStyle(color: Colors.blue),
                              overflow: TextOverflow.ellipsis,
                            )),
                        const Spacer(),
                        Text(
                          "あと${dtEnd.difference(DateTime.now()).inDays}日",
                          style: const TextStyle(color: Colors.redAccent),
                          overflow: TextOverflow.ellipsis,
                        )
                      ])
                    ]),
              ),
              IconButton(
                  onPressed: () async {
                    final data = ClipboardData(text: id);
                    await Clipboard.setData(data);
                  },
                  icon: const Icon(Icons.copy, color: Colors.grey)),
              buttonModelWithChild(() async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CodeSharePage(
                            id: id,
                            tagName: tag["title"],
                            scheduleData: scheduleList,
                          )),
                );
              },
                  MAIN_COLOR,
                  Row(children: [
                    Icon(
                      Icons.qr_code_2_outlined,
                      color: FORGROUND_COLOR,
                    ),
                    const SizedBox(width: 5),
                    Text("共有",
                        style: TextStyle(
                          color: FORGROUND_COLOR,
                          fontWeight: FontWeight.bold,
                        )),
                  ])),
            ])
          ]);

          return listChild;
        }
      },
      separatorBuilder: (context, index) {
        return const Divider(height: 1);
      },
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: data.length,
    );
  }

  TextEditingController idController = TextEditingController();
  Widget broadcastDownloadPage() {
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
    return buttonModelWithChild(() async {
      String id = idController.text;
      if (id.isNotEmpty) {
        bool isScheduleDownloadSuccess = await receiveSchedule(id);
        if (isScheduleDownloadSuccess) {
          showDownloadDoneDialogue("データがダウンロードされました！");
          ref.read(taskDataProvider).isRenewed = true;
          ref.read(calendarDataProvider.notifier).state = CalendarData();
          while (ref.read(taskDataProvider).isRenewed != false) {
            await Future.delayed(const Duration(microseconds: 1));
          }
        } else {
          showDownloadFailDialogue("ダウンロードに失敗しました");
        }
      } else {
        showDownloadFailDialogue("IDを入力してください。");
      }
    },
        PALE_MAIN_COLOR,
        Row(
          children: [
            const SizedBox(width: 20),
            Icon(Icons.install_mobile, color: FORGROUND_COLOR),
            const SizedBox(width: 20),
            Text("予定を受信する", style: TextStyle(color: FORGROUND_COLOR)),
          ],
        ),
        verticalpadding: 8);
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
            okButton(context, 1500.0)
          ],
        );
      },
    );
  }
}

void showSchedulesDialogue(context, String text, List<dynamic> data) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(text),
        actions: <Widget>[
          ListView.separated(
            itemBuilder: (context, index) {
              Map targetDayData = data.elementAt(index);
              Text dateTimeData = const Text("");
              if (targetDayData["startTime"].trim() != "" &&
                  targetDayData["endTime"].trim() != "") {
                dateTimeData = Text(
                  "${" " + targetDayData["startTime"]}～" +
                      targetDayData["endTime"],
                  style: const TextStyle(color: Colors.grey),
                );
              } else if (targetDayData["startTime"].trim() != "") {
                dateTimeData = Text(
                  " " + targetDayData["startTime"],
                  style: const TextStyle(color: Colors.grey),
                );
              } else {
                dateTimeData = const Text(
                  " 終日",
                  style: TextStyle(color: Colors.grey),
                );
              }

              return Container(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Row(children: [
                      Text(
                        data.elementAt(index)["startDate"],
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(width: 10),
                      dateTimeData
                    ]),
                    Text(data.elementAt(index)["subject"]),
                  ]));
            },
            separatorBuilder: (context, index) {
              return const Divider(height: 1);
            },
            itemCount: data.length,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
          ),
          const SizedBox(height: 10),
          okButton(context, 500.0)
        ],
      );
    },
  );
}
