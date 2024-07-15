import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_calandar_app/backend/DB/handler/calendarpage_config_db_handler.dart';
import 'package:flutter_calandar_app/backend/sharepreference.dart';
import 'package:flutter_calandar_app/frontend/assist_files/data_loader.dart';
import 'package:flutter_calandar_app/frontend/assist_files/ui_components.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/calendar_data_manager.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/task_progress_indicator.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

import '../../assist_files/colors.dart';
import '../../assist_files/size_config.dart';
import "../../../backend/notify/notify_db.dart";
import "../../../backend/notify/notify_content.dart";

class SettingsPage extends StatelessWidget {
  int? initIndex;
  bool? isAppBar;
  SettingsPage({super.key, this.initIndex, this.isAppBar});

  @override
  Widget build(BuildContext context) {
    bool showAppBar = isAppBar ?? true;
    PreferredSizeWidget? appBar;
    if (showAppBar) {
      appBar = AppBar(
        leading: BackButton(color: WHITE),
        backgroundColor: MAIN_COLOR,
        elevation: 10,
        title: Column(
          children: <Widget>[
            Row(children: [
              const Icon(
                Icons.settings,
                color: WIDGET_COLOR,
              ),
              Text(
                '  設定',
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.w800, color: WHITE),
              ),
            ])
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: BACKGROUND_COLOR,
      appBar: appBar,
      body: MyWidget(initIndex: initIndex ?? 0),
    );
  }
}

//サイドメニュー//////////////////////////////////////////////////////
class MyWidget extends ConsumerStatefulWidget {
  int initIndex = 0;

  MyWidget({required this.initIndex, super.key});

  @override
  ConsumerState<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends ConsumerState<MyWidget> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initIndex;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: BACKGROUND_COLOR,
      body: Row(
        children: [
          NavigationRail(
            backgroundColor: WHITE,
            labelType: NavigationRailLabelType.selected,
            selectedIconTheme: const IconThemeData(color: MAIN_COLOR),
            selectedLabelTextStyle: const TextStyle(color: MAIN_COLOR),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.calendar_today),
                label: Text('カレンダー'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.notifications_active),
                label: Text('通知'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.grid_on),
                label: Text('時間割'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.color_lens),
                label: Text('テーマ'),
              ),
            ],
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          MainContents(index: _selectedIndex)
        ],
      ),
    );
  }
}

class MainContents extends ConsumerStatefulWidget {
  final int index;
  const MainContents({super.key, required this.index});
  @override
  ConsumerState<MainContents> createState() => _MainContentsState();
}

class _MainContentsState extends ConsumerState<MainContents> {
  final FocusNode _nodeText1 = FocusNode();
  TextEditingController controller = TextEditingController();

  KeyboardActionsConfig _buildConfig(TextEditingController controller) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor: WHITE,
      nextFocus: false,
      actions: [
        KeyboardActionsItem(
          focusNode: _nodeText1,
          toolbarAlignment: MainAxisAlignment.start,
          displayArrows: false,
          toolbarButtons: [
            (node) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Stack(
                  children: [
                    Container(
                        margin: const EdgeInsets.only(left: 0),
                        child: Row(children: [
                          SizedBox(width: SizeConfig.blockSizeHorizontal! * 80),
                          GestureDetector(
                            onTap: () {
                              updateConfigInfo("taskList", controller.text);
                              node.unfocus();
                            },
                            child: const Text(
                              "完了",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ])),
                  ],
                ),
              );
            }
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    switch (widget.index) {
      case 0:
        return Expanded(
            child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: calendarBody(),
        ));

      case 1:
        return Expanded(
            child: SingleChildScrollView(
                child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: notificationBody(),
        )));

      case 2: return Expanded(child:
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
          child: timetableSettingsBody(),
        ));

      default:
        return Expanded(child:
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
            child: themeSettingsBody(),
        ));
    }
  }

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  Widget calendarBody() {
    Widget borderModel = Column(children: [
      const SizedBox(height: 2.5),
      Divider(height: 2, thickness: 2, color: BACKGROUND_COLOR),
      const SizedBox(height: 2.5),
    ]);

    return KeyboardActions(
        config: _buildConfig(controller),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            'カレンダー設定…',
            style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal! * 7,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
              decoration: roundedBoxdecorationWithShadow(),
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '画面表示のカスタマイズ',
                      style: TextStyle(
                          fontSize: SizeConfig.blockSizeHorizontal! * 5,
                          fontWeight: FontWeight.bold,
                          color: BLUEGREY),
                    ),
                    const Divider(
                      height: 2,
                      thickness: 2,
                      color: BLUEGREY,
                    ),
                    const SizedBox(height: 2),
                    configSwitch("Tipsとお知らせ", "tips"),
                    borderModel,
                    configSwitch("きょうの予定", "todaysSchedule"),
                    configSwitch(
                        "きょうの予定枠内に\n時間割データを表示", "timetableInTodaysSchedule"),
                    borderModel,
                    configSwitch("近日締切のタスク", "taskList"),
                    const SizedBox(height: 5),
                    configTextField("表示日数：", "taskList", controller),
                    borderModel,
                    configSwitch("アルバイト推計収入", "arbeitPreview"),
                    borderModel,
                  ])),
          const SizedBox(height: 10),
          Container(
              decoration: roundedBoxdecorationWithShadow(),
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'カレンダーの設定',
                      style: TextStyle(
                          fontSize: SizeConfig.blockSizeHorizontal! * 5,
                          fontWeight: FontWeight.bold,
                          color: BLUEGREY),
                    ),
                    const Divider(
                      height: 2,
                      thickness: 2,
                      color: BLUEGREY,
                    ),
                    const SizedBox(height: 2),
                    configSwitch("土日祝日の着色", "holidayPaint"),
                    configSwitch("祝日名の表示", "holidayName"),
                    borderModel,
                    configSwitch("カレンダーの大学授業表示", "timetableInCalendarcell"),
                    configSwitch("日付画面の大学授業表示", "timetableInDailyView"),
                    const Padding(
                        padding: EdgeInsets.all(7.5),
                        child: Text(
                            "※これらは、登録されている時間割をもとに該当月の各曜日に授業データを機械的に表示するものです。ご利用にあたっては大学暦や授業の状況を併せてご確認ください。",
                            style: TextStyle(color: Colors.red))),
                    borderModel,
                  ]))
        ]));
  }

  Widget configSwitch(String configText, String widgetName) {
    return Row(children: [
      const SizedBox(width: 5),
      Text(
        configText,
        style: TextStyle(
          fontSize: SizeConfig.blockSizeHorizontal! * 4,
        ),
      ),
      const Spacer(),
      CupertinoSwitch(
          value: searchConfigData(widgetName),
          activeColor: PALE_MAIN_COLOR,
          onChanged: (value) {
            updateConfigData(widgetName, value);
          }),
    ]);
  }

  Widget configTextField(
      String configText, String widgetName, TextEditingController controller) {
    controller.selection = TextSelection.fromPosition(
      //入力文字のカーソルの位置を管理
      TextPosition(offset: controller.text.length),
    ); //入力されている文字数を取得し、その位置にカーソルを移動することで末尾にカーソルを当てる
    controller.text = searchConfigInfo(widgetName);
    return Row(children: [
      const Spacer(),
      Text(
        configText,
        style: TextStyle(
          fontSize: SizeConfig.blockSizeHorizontal! * 4,
        ),
      ),
      Expanded(
        child: CupertinoTextField(
            controller: controller,
            focusNode: _nodeText1,
            onSubmitted: (value) {
              updateConfigInfo(widgetName, value);
            },
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
            ]),
      )
    ]);
  }

  bool searchConfigData(String widgetName) {
    final calendarData = ref.watch(calendarDataProvider);
    int result = 0;
    for (var data in calendarData.configData) {
      String targetWidgetName = data["widgetName"];

      if (targetWidgetName == widgetName) {
        result = data["isVisible"];
      }
    }

    if (result == 1) {
      return true;
    } else {
      return false;
    }
  }

  String searchConfigInfo(String widgetName) {
    final calendarData = ref.watch(calendarDataProvider);
    String result = "";
    for (var data in calendarData.configData) {
      String targetWidgetName = data["widgetName"];
      if (targetWidgetName == widgetName) {
        result = data["info"];
      }
    }

    return result;
  }

  Future<void> updateConfigData(String widgetName, bool value) async {
    final calendarData = ref.watch(calendarDataProvider);
    int result = 0;

    if (value) {
      result = 1;
    }

    for (var data in calendarData.configData) {
      String targetWidgetName = data["widgetName"];

      if (targetWidgetName == widgetName) {
        await CalendarConfigDatabaseHelper().updateCalendarConfig({
          "id": data["id"],
          "widgetName": data["widgetName"],
          "isVisible": result,
          "info": "0"
        });
        ref.read(calendarDataProvider.notifier).state = CalendarData();
        ref
            .read(calendarDataProvider)
            .getTagData(TagDataLoader().getTagDataSource());
        await ConfigDataLoader().initConfig(ref);
        await CalendarDataLoader().insertDataToProvider(ref);

        setState(() {});
      }
    }
  }

  Future<void> updateConfigInfo(String widgetName, String info) async {
    final calendarData = ref.watch(calendarDataProvider);
    if (info == "") {
      info = "0";
    }
    if (int.parse(info) > 100) {
      info = "100";
    }
    for (var data in calendarData.configData) {
      String targetWidgetName = data["widgetName"];

      if (targetWidgetName == widgetName) {
        await CalendarConfigDatabaseHelper().updateCalendarConfig({
          "id": data["id"],
          "widgetName": data["widgetName"],
          "isVisible": data["isVisible"],
          "info": info
        });
        ref.read(calendarDataProvider.notifier).state = CalendarData();
        ref
            .read(calendarDataProvider)
            .getTagData(TagDataLoader().getTagDataSource());
        await ConfigDataLoader().initConfig(ref);
        await CalendarDataLoader().insertDataToProvider(ref);

        setState(() {});
      }
    }
  }

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  Widget notificationBody() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        '通知設定…',
        style: TextStyle(
            fontSize: SizeConfig.blockSizeHorizontal! * 7,
            fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 5),
      Container(
          decoration: roundedBoxdecorationWithShadow(),
          padding: const EdgeInsets.all(7.5),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              '通知の設定',
              style: TextStyle(
                  fontSize: SizeConfig.blockSizeHorizontal! * 5,
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
          decoration: roundedBoxdecorationWithShadow(),
          padding: const EdgeInsets.all(7.5),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              '通知フォーマットの設定',
              style: TextStyle(
                  fontSize: SizeConfig.blockSizeHorizontal! * 5,
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
    ]);
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
            width: SizeConfig.blockSizeHorizontal! * 32,
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
          SizedBox(width: SizeConfig.blockSizeHorizontal! * 2),
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
            width: SizeConfig.blockSizeHorizontal! * 15,
            child: DropdownButtonFormField(
              value: days,
              isDense: true,
              padding: EdgeInsets.zero,
              decoration: InputDecoration.collapsed(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "",
                  border: const OutlineInputBorder(),
                  hintStyle: TextStyle(
                    fontSize: SizeConfig.blockSizeHorizontal! * 4,
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
                  Text("   追加   ", style: TextStyle(color: WHITE)),
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
    return SizedBox(
      height: SizeConfig.blockSizeVertical! * 10,
      child: const Center(
          child:
              Text("登録されている通知はありません。", style: TextStyle(color: Colors.grey))),
    );
  }

  Widget loadingSettingWidget() {
    return SizedBox(
      height: SizeConfig.blockSizeVertical! * 10,
      child:
          const Center(child: CircularProgressIndicator(color: ACCENT_COLOR)),
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
          const Text("日付の形式  "),
          SizedBox(
            width: SizeConfig.blockSizeHorizontal! * 45,
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
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 Widget timetableSettingsBody() {
    return 
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
     children: [
      Text(
        '  時間割設定…',
        style: TextStyle(
            fontSize: SizeConfig.blockSizeHorizontal! * 7,
            fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 5),
      Container(
          decoration: roundedBoxdecorationWithShadow(),
          padding: const EdgeInsets.symmetric(vertical: 7.5, horizontal: 15),
          margin: const EdgeInsets.symmetric(vertical: 7.5, horizontal: 10),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              '出欠記録の設定',
              style: TextStyle(
                  fontSize: SizeConfig.blockSizeHorizontal! * 5,
                  fontWeight: FontWeight.bold,
                  color: BLUEGREY),
            ),
            const Divider(
              height: 2,
              thickness: 2,
              color: BLUEGREY,
            ),
            const SizedBox(height: 2),
            attendDialogSettingSwitch(),
            const SizedBox(height: 2),
          ])),
    ]);
  }

  Widget attendDialogSettingSwitch(){
      return Row(children: [
        const Text("出欠記録画面の自動表示"),
        const Spacer(),
        CupertinoSwitch(
          activeColor: PALE_MAIN_COLOR,
          value: SharepreferenceHandler()
              .getValue(SharepreferenceKeys.showAttendDialogAutomatically),
          onChanged: (value) async {
            SharepreferenceHandler()
                .setValue(SharepreferenceKeys.showAttendDialogAutomatically, value);
            setState(() {});
          },
        )
      ]);
  }


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  String bgColorTheme = "";

  Widget themeSettingsBody() {
    return 
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
     children: [
      Text(
        '  テーマ設定…',
        style: TextStyle(
            fontSize: SizeConfig.blockSizeHorizontal! * 7,
            fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 5),
      Container(
          decoration: roundedBoxdecorationWithShadow(),
          padding: const EdgeInsets.symmetric(vertical: 7.5, horizontal: 15),
          margin: const EdgeInsets.symmetric(vertical: 7.5, horizontal: 10),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              '背景カラーテーマの設定',
              style: TextStyle(
                  fontSize: SizeConfig.blockSizeHorizontal! * 5,
                  fontWeight: FontWeight.bold,
                  color: BLUEGREY),
            ),
            const Divider(
              height: 2,
              thickness: 2,
              color: BLUEGREY,
            ),
            const SizedBox(height: 2),
            buildThemeSettingList(),
            const SizedBox(height: 2),
            const Text(
              "設定は次回起動時から適用されます。",
              style: TextStyle(color: Colors.grey),
            )
          ])),
    ]);
  }

  Widget buildThemeSettingList() {
    String bgColorTheme = SharepreferenceHandler()
        .getValue(SharepreferenceKeys.bgColorTheme) as String;
    return backgroundThemeSettings(bgColorTheme);
    // return FutureBuilder(
    //     future: initThemeSettingsData(),
    //     builder: (BuildContext context, AsyncSnapshot snapshot) {
    //       if (snapshot.connectionState == ConnectionState.waiting) {
    //         return loadingSettingWidget();
    //       } else if (snapshot.hasError) {
    //         return Text('Error: ${snapshot.error}');
    //       } else {
    //         return backgroundThemeSettings(snapshot.data);
    //       }
    //     });
  }

  Widget backgroundThemeSettings(String data) {
    bgColorTheme = data;
    return SizedBox(
      width: SizeConfig.blockSizeHorizontal! * 32,
      child: DropdownButtonFormField(
        value: bgColorTheme,
        decoration: const InputDecoration.collapsed(
            filled: true,
            fillColor: Colors.white,
            hintText: "背景テーマ色",
            border: OutlineInputBorder()),
        items: const [
          DropdownMenuItem(value: "white", child: Text("ホワイト")),
          DropdownMenuItem(value: "grey", child: Text("グレー")),
          DropdownMenuItem(value: "yellow", child: Text("イエロー")),
          DropdownMenuItem(value: "blue", child: Text("ブルー")),
        ],
        onChanged: (value) async {
          SharepreferenceHandler()
              .setValue(SharepreferenceKeys.bgColorTheme, value!);
          switchThemeColor(data);
          setState(() {
            bgColorTheme = value;
          });
        },
      ),
    );
  }
}
