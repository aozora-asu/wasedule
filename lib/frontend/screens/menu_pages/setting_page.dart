import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_calandar_app/backend/DB/handler/calendarpage_config_db_handler.dart';
import 'package:flutter_calandar_app/frontend/assist_files/data_loader.dart';
import 'package:flutter_calandar_app/frontend/screens/common/tutorials.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/schedule_data_manager.dart';
import 'package:flutter_calandar_app/frontend/screens/menu_pages/arbeit_stats_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import '../../assist_files/colors.dart';
import '../../assist_files/size_config.dart';

class SettingsPage extends StatelessWidget {
  int? initIndex;
  SettingsPage({
    this.initIndex
  });
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        backgroundColor: MAIN_COLOR,
        elevation: 10,
        title: const Column(
          children: <Widget>[
            Row(children: [
              Icon(
                Icons.settings,
                color: WIDGET_COLOR,
              ),
              Text(
                '  設定',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white),
              ),
            ])
          ],
        ),
      ),
      body: MyWidget(initIndex: initIndex ?? 0),
    );
  }
}

//サイドメニュー//////////////////////////////////////////////////////
class MyWidget extends ConsumerStatefulWidget {
  int initIndex = 0;
  
  MyWidget({
    required this.initIndex,
    super.key});

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
      body: Row(
        children: [
          NavigationRail(
            labelType: NavigationRailLabelType.selected,
            selectedIconTheme: const IconThemeData(color: MAIN_COLOR),
            selectedLabelTextStyle: const TextStyle(color: MAIN_COLOR),
            elevation: 20,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.calendar_today),
                label: Text('カレンダー'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.notifications_active),
                label: Text('通知'),
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
      keyboardBarColor: Colors.white,
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

       default:
        return Expanded(
            child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: notificationBody(),
        ));


    }
  }

  Widget calendarBody() {
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
              padding: const EdgeInsets.all(7.5),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '画面表示のカスタマイズ',
                      style: TextStyle(
                          fontSize: SizeConfig.blockSizeHorizontal! * 5,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    configSwitch("Tipsとお知らせ", "tips"),
                    const SizedBox(height: 5),
                    configSwitch("きょうの予定", "todaysSchedule"),
                    const SizedBox(height: 5),
                    configSwitch("近日締切のタスク", "taskList"),
                    const SizedBox(height: 5),
                    configTextField("表示日数：", "taskList", controller),
                    const SizedBox(height: 5),
                    configSwitch("Waseda Moodle リンク", "moodleLink"),
                    const SizedBox(height: 5),
                  ])),
                
                const SizedBox(height:10),

          Container(
              decoration: roundedBoxdecorationWithShadow(),
              padding: const EdgeInsets.all(7.5),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'カレンダーの設定',
                      style: TextStyle(
                          fontSize: SizeConfig.blockSizeHorizontal! * 5,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    configSwitch("土日祝日の着色", "holidayPaint"),
                    const SizedBox(height: 5),
                    configSwitch("祝日名の表示", "holidayName"),
                    const SizedBox(height: 5),
                  ]))

        ]));
  }

  Widget notificationBody() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        '通知設定…',
        style: TextStyle(
            fontSize: SizeConfig.blockSizeHorizontal! * 7,
            fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 10),
      Container(
          decoration: roundedBoxdecorationWithShadow(),
          padding: const EdgeInsets.all(7.5),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Text(
            //   '通知のON/OFF',
            //   style: TextStyle(
            //       fontSize: SizeConfig.blockSizeHorizontal! * 4,
            //       fontWeight: FontWeight.bold),
            // ),
            // const SizedBox(height: 5),
            // configSwitch("課題の通知(毎朝8時)", "tips"),
            // const SizedBox(height: 5),
            // configSwitch("予定の通知(毎朝8時)", "tips"),
          ]))
    ]);
  }


  Widget configSwitch(String configText, String widgetName) {
    return Row(children: [
      CupertinoSwitch(
          value: searchConfigData(widgetName),
          activeColor: ACCENT_COLOR,
          onChanged: (value) {
            updateConfigData(widgetName, value);
          }),
      Text(
        configText,
        style: TextStyle(
          fontSize: SizeConfig.blockSizeHorizontal! * 4,
        ),
      ),
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
        ref.read(calendarDataProvider).getTagData(TagDataLoader().getTagDataSource());
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
        ref.read(calendarDataProvider).getTagData(TagDataLoader().getTagDataSource());
        await ConfigDataLoader().initConfig(ref);
        await CalendarDataLoader().insertDataToProvider(ref);

        setState(() {});
      }
    }
  }

}
