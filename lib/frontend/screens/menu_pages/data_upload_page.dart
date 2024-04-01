import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_calandar_app/backend/firebase_handler.dart';
import 'package:flutter_calandar_app/frontend/assist_files/data_loader.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/add_event_button.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/schedule_data_manager.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/tag_and_template_page.dart';
import 'package:flutter_calandar_app/frontend/screens/common/tutorials.dart';
import 'package:flutter_calandar_app/frontend/screens/menu_pages/arbeit_stats_page.dart';
import 'package:flutter_calandar_app/frontend/screens/menu_pages/code_share_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../assist_files/colors.dart';
import '../../assist_files/size_config.dart';
import 'package:toggle_switch/toggle_switch.dart';

class DataUploadPage extends ConsumerStatefulWidget {
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
        appBar: AppBar(
          leading: const BackButton(color: Colors.white),
          backgroundColor: MAIN_COLOR,
          elevation: 10,
          title: Column(
            children: <Widget>[
              Row(children: [
                const Icon(
                  Icons.send_to_mobile_rounded,
                  color: WIDGET_COLOR,
                ),
                SizedBox(
                  width: SizeConfig.blockSizeHorizontal! * 4,
                ),
                Text(
                  '予定のアップロード',
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
        'lib/assets/schedule_share/schedule_backup_upload.png',
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
      labels: const ['予定の配信', 'データバックアップ'],
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

  Widget scheduleBroadcastPage() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text(
              "・共有コードを知っている人に向けて、予定を配信することができます。サークルやゼミなどで、スケジュールの共有にお使いください。",
              style: TextStyle(fontSize: 17)),
          const SizedBox(height: 10),
          const Text("・選択したタグが紐付いている予定のみが共有されます。",
              style: TextStyle(color: Colors.red, fontSize: 17)),
          const SizedBox(height: 10),
          chooseTagButton(),
          broadcastUploadButton(),
          const SizedBox(height: 5),
          dtEndField(60),
          tagThumbnail(),
          shereScheduleListView(),
          showUploadDataView(),
        ]));
  }

  Widget chooseTagButton() {
    return ElevatedButton(
      onPressed: () async {
        await showTagDialogue(ref, context, setState);
        setState(() {});
      },
      style: const ButtonStyle(
        backgroundColor: MaterialStatePropertyAll(ACCENT_COLOR),
      ),
      child: const Row(
        children: [
          Icon(Icons.more_vert_rounded, color: Colors.white),
          SizedBox(width: 20),
          Text("タグを選択", style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget dtEndField(int maxDay) {
    if (shareScheduleList.isEmpty) {
      return const SizedBox();
    } else {
      return Row(children: [
        Text("有効期限(~" + maxDay.toString() + "日)"),
        const Spacer(),
        SizedBox(
            width: SizeConfig.blockSizeHorizontal! * 20,
            child: CupertinoTextField(
              controller: dtEndController,
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
    String tagID = ref.watch(scheduleFormProvider).tagController.text;
    if (tagID.isEmpty) {
      return const SizedBox();
    } else {
      return Column(children: [
        const SizedBox(height: 30),
        Row(children: [
          const Text("選択中："),
          tagChip(tagID, ref),
          const SizedBox(width: 10),
          Text(shareScheduleList.length.toString() + "件",
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
        if (calendarList.elementAt(i)["tag"] == id) {
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
            " " + targetDayData["startTime"] + "～" + targetDayData["endTime"],
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
      return ElevatedButton(
          onPressed: () async {
            int dtEnd = int.parse(dtEndController.text);

            if (dtEnd > 60 || 0 >= dtEnd) {
              showBackupFailDialogue("有効期限は1日以上60日以下に設定してください。");
            } else {
              //★この "tagID" 変数をバックエンド（postScheduleToFB）に受け渡します!
              String tagID = returnTagId(
                      ref.watch(scheduleFormProvider).tagController.text,
                      ref) ??
                  "";
              Map<String, List<Map<String, dynamic>>> result =
                  await postScheduleToFB(int.parse(
                      ref.watch(scheduleFormProvider).tagController.text));

              //処理の失敗時
              //showBackupFailDialogue("エラーメッセージ");

              //アップロード処理成功時
              String id = result.keys.last;
              showUploadDoneDialogue(id);

              setState(() {});
            }
          },
          style: const ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(MAIN_COLOR),
          ),
          child: const Row(children: [
            Icon(Icons.backup, color: Colors.white),
            SizedBox(width: 20),
            Text("予定をアップロード", style: TextStyle(color: Colors.white))
          ]));
    } else {
      return const SizedBox();
    }
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
          return Text('エラー: ${snapshot.error}');
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
            decoration: roundedBoxdecorationWithShadow(),
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

        Widget listChild = Column(children: [
          const SizedBox(height: 4),
          Row(children: [validTagChip(tag)]),
          Text(id),
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
                            "ほか" + (scheduleList.length - 1).toString() + "件",
                            style: const TextStyle(color: Colors.blue),
                            overflow: TextOverflow.ellipsis,
                          )),
                      const Spacer(),
                      Text(
                        "あと" +
                            dtEnd.difference(DateTime.now()).inDays.toString() +
                            "日",
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
            ElevatedButton(
                onPressed: () async {
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
                style: const ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(MAIN_COLOR)),
                child: const Row(children: [
                  Icon(
                    Icons.qr_code_2_outlined,
                    color: Colors.white,
                  ),
                  SizedBox(width: 5),
                  Text("共有",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      )),
                ])),
          ])
        ]);

        if (dtEnd.isBefore(DateTime.now())) {
          return const SizedBox();
        } else {
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

  Widget dataBackupPage() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text(
              "・今お使いの端末からサーバー上に「カレンダー」のすべてのデータをバックアップします。のちにこの端末や他の端末に復元していただけます。",
              style: TextStyle(fontSize: 17)),
          const SizedBox(height: 10),
          const Text("・バックアップに際して、発行されるIDが必要です。スクリーンショットなどで保管しておいてください。",
              style: TextStyle(color: Colors.red, fontSize: 17)),
          const SizedBox(height: 10),
          backUpUploadButton(),
          showIDView(),
        ]));
  }

  Widget backUpUploadButton() {
    return ElevatedButton(
        onPressed: () {
          //DBから呼び出されたID。まだデータがなければ空文字が入る予定。
          String id = ref.watch(calendarDataProvider).userID;
          //今は仮で入れてます、仮IDはdata_loader.dart内に記述

          //ここにバックアップの実行処理を書き込む（アップロード処理）

          //showBackupFailDialogue("エラーメッセージ"); //←処理の失敗時にお使いください。

          //バックアップ成功！ダイアログを表示
          //(初回バックアップ時)ここで発行されたバックアップIDをＤＢに追加する処理。
          showBackUpDoneDialogue(id);
          setState(() {});
        },
        style: const ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(MAIN_COLOR),
        ),
        child: const Row(children: [
          Icon(Icons.backup, color: Colors.white),
          SizedBox(width: 20),
          Text("データをバックアップ", style: TextStyle(color: Colors.white))
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
      future: UserInfoLoader().getUserIDSource(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(
            color: MAIN_COLOR,
          );
        } else if (snapshot.hasError) {
          return Text('エラー: ${snapshot.error}');
        } else {
          UserInfoLoader().insertDataToProvider(ref);
          return iDView(snapshot.data);
        }
      },
    );
  }

  Widget iDView(String id) {
    if (id.isEmpty) {
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
            ]))
      ]);
    }
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
                  " " +
                      targetDayData["startTime"] +
                      "～" +
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
