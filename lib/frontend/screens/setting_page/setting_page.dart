import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_calandar_app/backend/DB/handler/calendarpage_config_db_handler.dart';
import 'package:flutter_calandar_app/backend/DB/sharepreference.dart';
import 'package:flutter_calandar_app/frontend/assist_files/data_loader.dart';
import 'package:flutter_calandar_app/frontend/assist_files/ui_components.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/calendar_data_manager.dart';
import 'package:flutter_calandar_app/frontend/screens/common/plain_appbar.dart';
import 'package:flutter_calandar_app/frontend/screens/setting_page/calendar_setting.dart';
import 'package:flutter_calandar_app/frontend/screens/setting_page/data_backup_page.dart';
import 'package:flutter_calandar_app/frontend/screens/setting_page/notify_setting.dart';
import 'package:flutter_calandar_app/frontend/screens/setting_page/support_page.dart';
import 'package:flutter_calandar_app/frontend/screens/setting_page/theme_setting.dart';
import 'package:flutter_calandar_app/frontend/screens/setting_page/timetable_setting.dart';
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
      appBar = CustomAppBar(backButton: true);
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
            backgroundColor: FORGROUND_COLOR,
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
              NavigationRailDestination(
                icon: Icon(Icons.backup),
                label: Text('バックアップ'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.info),
                label: Text('その他'),
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
      keyboardBarColor: FORGROUND_COLOR,
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
          child: CalendarSettingPage(
            buildConfig: _buildConfig, 
            nodeText1: _nodeText1,
            controller: controller,
            updateConfigInfo: updateConfigInfo
          ),
        ));

      case 1:
        return Expanded(
          child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: NotifySettingPage(
            buildConfig: _buildConfig,
            controller: controller),
        ));

      case 2:
        return Expanded(
            child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
          child: TimetableSettingPage(),
        ));

      case 3:
        return Expanded(
            child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
          child: ThemeSettingPage(),
        ));
      
      case 4:
        return const Expanded(
          child: DataBackupPage()
        );
      
      default:
        return Expanded(
          child: SnsLinkPage(showAppBar: false)
        );
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
}
