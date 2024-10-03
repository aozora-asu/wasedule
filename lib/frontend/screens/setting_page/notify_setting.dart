import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/sharepreference.dart';
import 'package:flutter_calandar_app/backend/notify/notify_content.dart';
import 'package:flutter_calandar_app/backend/notify/notify_db.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/screens/common/ui_components.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_actions/keyboard_actions.dart';


class NotifySettingPage extends ConsumerStatefulWidget{
  Function buildConfig;
  TextEditingController controller;

  NotifySettingPage({super.key, 
    required this.buildConfig ,
    required this.controller,
  });
  @override
  _NotifySettingPageState createState() => _NotifySettingPageState();
}

class _NotifySettingPageState extends ConsumerState<NotifySettingPage>{

  @override
  Widget build(BuildContext context) {
    return KeyboardActions(
        config: widget.buildConfig(widget.controller),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text(
        '通知設定…',
        style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 5),
      Container(
          decoration: roundedBoxdecoration(),
          padding: const EdgeInsets.all(7.5),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text(
              ' 通知の設定',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: BLUEGREY),
            ),
            const Divider(
              height: 2,
              thickness: 2,
              color: BLUEGREY,
            ),
            const SizedBox(height: 2),
            notificationFrequencySetting(),
            const SizedBox(height: 1),
            notificationTypeSetting(),
            const Divider(height: 1),
            const SizedBox(height: 1),
            const Text(
              " ■ 設定済み通知",
              style: TextStyle(color: Colors.grey),
            ),
            buildNotificationSettingList()
          ])),
      const SizedBox(height: 10),
      Container(
          decoration: roundedBoxdecoration(),
          padding: const EdgeInsets.all(7.5),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text(
              ' 通知フォーマットの設定',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: BLUEGREY),
            ),
            const Divider(
              height: 2,
              thickness: 2,
              color: BLUEGREY,
            ),
            const SizedBox(height: 2),
            notificarionFormatSetting(),
          ])),
      const SizedBox(height: 20)
    ]));
  }

  Widget buildNotificationSettingList() {
    return FutureBuilder(
        future: NotifyDatabaseHandler().getNotifyConfigList(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return loadingSettingWidget();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return showNotificationList(snapshot.data);
          }
        });
  }

  late String notifyType;
  int? weekday;
  String timeFrequency = "8:00";
  DateTime datetimeFrequency = DateFormat("H:mm").parse("8:00");
  int days = 1;
  String timeBeforeDtEnd = "8:00";
  String timeBeforeDtEndForPreview = "8時間00分";
  DateTime datetimeBeforeDtEnd = DateFormat("H:mm").parse("8:00");

  Widget notificationFrequencySetting() {
    Widget borderModel = const Column(children: [
      SizedBox(height: 2.5),
      Divider(height: 1),
      SizedBox(height: 2.5),
    ]);

    return Column(children: [
      IntrinsicHeight(
        child: Row(children: [
          SizedBox(
            width: 125,
            child: DropdownButtonFormField(
              decoration: const InputDecoration.collapsed(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "通知する日",
                  border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: null, child: Text(" 毎日")),
                DropdownMenuItem(value: 1, child: Text(" 毎週月曜日")),
                DropdownMenuItem(value: 2, child: Text(" 毎週火曜日")),
                DropdownMenuItem(value: 3, child: Text(" 毎週水曜日")),
                DropdownMenuItem(value: 4, child: Text(" 毎週木曜日")),
                DropdownMenuItem(value: 5, child: Text(" 毎週金曜日")),
                DropdownMenuItem(value: 6, child: Text(" 毎週土曜日")),
                DropdownMenuItem(value: 7, child: Text(" 毎週日曜日")),
              ],
              onChanged: (value) {
                setState(() {
                  weekday = value;
                });
              },
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () async {
              DateTime now = DateTime.now();
              await DatePicker.showTimePicker(context,
                  showTitleActions: true,
                  showSecondsColumn: false, onConfirm: (date) {
                setState(() {
                  timeFrequency = DateFormat("H:mm").format(date);
                  datetimeFrequency = date;
                });
              },
                  currentTime: DateTime(
                      now.year,
                      now.month,
                      now.day,
                      int.parse(DateFormat("HH").format(datetimeFrequency)),
                      int.parse(DateFormat("mm").format(datetimeFrequency))),
                  locale: LocaleType.jp);
            },
            child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 2.5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                      color: const Color.fromARGB(255, 100, 100, 100),
                      width: 1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(children: [
                  Text(timeFrequency,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Icon(Icons.arrow_drop_down,
                      color: Color.fromARGB(255, 100, 100, 100))
                ])),
          ),
          const Text(" に"),
        ]),
      ),
      IntrinsicHeight(
        child: Row(children: [
          SizedBox(
            width:50,
            child: DropdownButtonFormField(
              value: days,
              isDense: true,
              padding: EdgeInsets.zero,
              decoration:const  InputDecoration.collapsed(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "",
                  border: OutlineInputBorder(),
                  hintStyle: TextStyle(
                    fontSize: 16,
                  )),
              items: const [
                DropdownMenuItem(value: 1, child: Text(" 1")),
                DropdownMenuItem(value: 2, child: Text(" 2")),
                DropdownMenuItem(value: 3, child: Text(" 3")),
                DropdownMenuItem(value: 4, child: Text(" 4")),
                DropdownMenuItem(value: 5, child: Text(" 5")),
                DropdownMenuItem(value: 6, child: Text(" 6")),
                DropdownMenuItem(value: 7, child: Text(" 7")),
                DropdownMenuItem(value: 8, child: Text(" 8")),
              ],
              onChanged: (value) {
                setState(() {
                  days = value!;
                });
              },
            ),
          ),
          const Text(" 日分を通知"),
          const Spacer(),
          GestureDetector(
            onTap: () async {
              if (weekday == null) {
                notifyType = "daily";
              } else {
                notifyType = "weekly";
              }
              setState(() {});
              //＠ここで毎日or毎週通知をDB登録！！
              NotifyConfig notifyConfig = NotifyConfig(
                  notifyType: notifyType,
                  time: timeFrequency,
                  isValidNotify: 1,
                  days: days,
                  weekday: weekday);
              await NotifyDatabaseHandler().setNotifyConfig(notifyConfig);
            },
            child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: BLUEGREY,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(children: [
                  Text("   追加   ", style: TextStyle(color: FORGROUND_COLOR)),
                ])),
          ),
          const SizedBox(width: 5)
        ]),
      ),
      borderModel,
      const SizedBox(height: 7),
      IntrinsicHeight(
        child: Row(children: [
          const Text("期限/予定の  "),
          GestureDetector(
            onTap: () async {
              DateTime now = DateTime.now();
              await DatePicker.showTimePicker(context,
                  showTitleActions: true,
                  showSecondsColumn: false, onConfirm: (date) {
                setState(() {
                  timeBeforeDtEndForPreview = DateFormat("H時間m分").format(date);
                  timeBeforeDtEnd = DateFormat("H:mm").format(date);
                  datetimeBeforeDtEnd = date;
                });
              },
                  currentTime: DateTime(
                      now.year,
                      now.month,
                      now.day,
                      int.parse(DateFormat("HH").format(datetimeBeforeDtEnd)),
                      int.parse(DateFormat("mm").format(datetimeBeforeDtEnd))),
                  locale: LocaleType.jp);
            },
            child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 2.5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                      color: const Color.fromARGB(255, 100, 100, 100),
                      width: 1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(children: [
                  Text(timeBeforeDtEndForPreview,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Icon(Icons.arrow_drop_down,
                      color: Color.fromARGB(255, 100, 100, 100))
                ])),
          ),
          const Text(" 前"),
        ]),
      ),
      const SizedBox(height: 14),
      IntrinsicHeight(
        child: Row(children: [
          const Text("に通知"),
          const Spacer(),
          buttonModel(() async {
            notifyType = "beforeHour";
            setState(() {});
            //＠ここで締め切り前通知をDB登録！！
            NotifyConfig notifyConfig = NotifyConfig(
                notifyType: notifyType,
                time: timeBeforeDtEnd,
                isValidNotify: 1,
                days: days,
                weekday: weekday);
            await NotifyDatabaseHandler().setNotifyConfig(notifyConfig);
          }, BLUEGREY, "   追加   "),
          const SizedBox(width: 5)
        ]),
      ),
      const SizedBox(height: 7),
      borderModel
    ]);
  }

  Widget notificationTypeSetting() {
    SharepreferenceHandler sharepreferenceHandler = SharepreferenceHandler();
    return Column(children: [
      Row(children: [
        const Text("予定の通知"),
        const Spacer(),
        CupertinoSwitch(
          activeColor: PALE_MAIN_COLOR,
          value: sharepreferenceHandler
              .getValue(SharepreferenceKeys.isCalendarNotify),
          onChanged: (value) async {
            SharepreferenceHandler()
                .setValue(SharepreferenceKeys.isCalendarNotify, value);
            await NotifyContent().setAllNotify();
            setState(() {});
          },
        )
      ]),
      Row(children: [
        const Text("課題の通知"),
        const Spacer(),
        CupertinoSwitch(
          activeColor: PALE_MAIN_COLOR,
          value:
              sharepreferenceHandler.getValue(SharepreferenceKeys.isTaskNotify),
          onChanged: (value) async {
            SharepreferenceHandler()
                .setValue(SharepreferenceKeys.isTaskNotify, value);
            await NotifyContent().setAllNotify();
            setState(() {});
          },
        )
      ]),
      Row(children: [
        const Text("教室・出席管理の通知"),
        const Spacer(),
        CupertinoSwitch(
          activeColor: PALE_MAIN_COLOR,
          value: sharepreferenceHandler
              .getValue(SharepreferenceKeys.isClassNotify),
          onChanged: (value) async {
            SharepreferenceHandler()
                .setValue(SharepreferenceKeys.isClassNotify, value);
            await NotifyContent().setAllNotify();
            setState(() {});
          },
        )
      ]),
    ]);
  }

  Widget showNotificationList(List<Map>? map) {
    if (map == null) {
      return noneSettingWidget();
    } else {
      return notificationSettingList(map);
    }
  }

  Widget notificationSettingList(List<Map> map) {
    return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: ((context, index) {
          Map target = map.elementAt(index);
          int id = target["id"];
          String notifyType = target["notifyType"];
          int? weekday = target["weekday"];
          DateTime time = DateFormat("H:mm").parse(target["time"]);
          int? days = target["days"];
          int isValidNotify = target["isValidNotify"];
          Color buttonColor;
          String buttonText;

          if (isValidNotify == 1) {
            buttonColor = Colors.blue;
            buttonText = "通知ON";
          } else {
            buttonColor = Colors.grey;
            buttonText = "通知OFF";
          }

          Widget notificationDescription = const SizedBox();
          if (notifyType == "beforeHour") {
            notificationDescription = Column(children: [
              const Text(" 締切・予定の ", style: TextStyle(color: Colors.grey)),
              Row(children: [Text(DateFormat("H時間m分前").format(time))]),
            ]);
          } else {
            notificationDescription = Column(children: [
              Row(children: [
                const Text(" "),
                Text(getDayOfWeek(weekday)),
                const Text(" "),
                Text(DateFormat("H:mm").format(time))
              ]),
              Row(children: [
                const Text(" "),
                Text("$days 日分", style: const TextStyle(color: Colors.grey)),
              ]),
            ]);
          }

          return Card(
              color: BACKGROUND_COLOR,
              elevation: 1.5,
              child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Row(children: [
                    InkWell(
                        onTap: () async {
                          //＠ここに通知設定削除の処理

                          await NotifyDatabaseHandler().disableNotify(id);
                          await NotifyDatabaseHandler().deleteNotifyConfig(id);
                          await NotifyContent().setAllNotify();
                          setState(() {});
                        },
                        child: const Icon(Icons.delete)),
                    const Spacer(),
                    notificationDescription,
                    const Spacer(),
                    buttonModel(() async {
                      //＠通知のON OFFの切り替え処理をここでしますよ.
                      //isValidNotify 0<->1の切り替えです
                      isValidNotify = 1 - isValidNotify;
                      if (isValidNotify == 1) {
                        await NotifyDatabaseHandler().activateNotify(id);
                      } else {
                        await NotifyDatabaseHandler().disableNotify(id);
                      }

                      await NotifyContent().setAllNotify();
                      setState(() {});
                    }, buttonColor, buttonText),
                  ])));
        }),
        separatorBuilder: ((context, index) {
          return const SizedBox(height: 2);
        }),
        itemCount: map.length);
  }

  Widget noneSettingWidget() {
    return const SizedBox(
      height: 75,
      child: Center(
          child:
              Text("登録されている通知はありません。", style: TextStyle(color: Colors.grey))),
    );
  }

  Widget loadingSettingWidget() {
    return const SizedBox(
      height: 75,
      child: Center(child: CircularProgressIndicator(color: ACCENT_COLOR)),
    );
  }

  String? notifyFormat;
  bool isContainWeekday = true;
  Widget notificarionFormatSetting() {
    String weekdayText = "";
    if (isContainWeekday && notifyFormat != null) {
      weekdayText = DateFormat("(E)", "ja_JP").format(DateTime.now());
    }

    String thumbnailText = "";
    if (notifyFormat != null) {
      thumbnailText = DateFormat(notifyFormat).format(DateTime.now());
    } else {
      thumbnailText = "今日    明日";
    }

    return Column(children: [
      IntrinsicHeight(
        child: Row(children: [
          const Text("日付の形式：  "),
          SizedBox(
            width: 150,
            child: DropdownButtonFormField(
              decoration: const InputDecoration.collapsed(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "日付の形式",
                  border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: "M月d日", child: Text(" M月d日")),
                DropdownMenuItem(value: "M/d", child: Text(" M/d")),
                DropdownMenuItem(value: "d/M", child: Text(" d/M")),
                DropdownMenuItem(value: null, child: Text(" 相対")),
              ],
              onChanged: (value) {
                setState(() {
                  notifyFormat = value;
                });
              },
            ),
          ),
        ]),
      ),
      IntrinsicHeight(
        child: Row(children: [
          const Text("曜日を含む："),
          CupertinoCheckbox(
              activeColor: BLUEGREY,
              value: isContainWeekday,
              onChanged: (value) {
                setState(() {
                  isContainWeekday = value!;
                });
              }),
          const Spacer(),
          buttonModel(() async {
            setState(() {});
            //＠ここで通知フォーマットをDB登録！！
            await NotifyDatabaseHandler().setNotifyFormat(NotifyFormat(
                isContainWeekday: isContainWeekday ? 1 : 0,
                notifyFormat: notifyFormat));
            await NotifyContent().setAllNotify();
          }, BLUEGREY, "   変更   "),
          const SizedBox(width: 5)
        ]),
      ),
      const Divider(height: 1),
      const SizedBox(height: 5),
      Row(children: [
        const SizedBox(width: 10),
        Text(thumbnailText + weekdayText,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        const Spacer(),
        buttonModel(() async {
          await NotifyContent().sampleNotify();
        }, BLUEGREY, "サンプル通知"),
      ])
    ]);
  }

  String getDayOfWeek(int? dayIndex) {
    switch (dayIndex) {
      case DateTime.monday:
        return "毎週月曜日";
      case DateTime.tuesday:
        return "毎週火曜日";
      case DateTime.wednesday:
        return "毎週水曜日";
      case DateTime.thursday:
        return "毎週木曜日";
      case DateTime.friday:
        return "毎週金曜日";
      case DateTime.saturday:
        return "毎週土曜日";
      case DateTime.sunday:
        return "毎週日曜日";
      default:
        return "毎日";
    }
  }


}