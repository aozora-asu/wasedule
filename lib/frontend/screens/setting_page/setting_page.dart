import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/handler/calendarpage_config_db_handler.dart';
import 'package:flutter_calandar_app/frontend/assist_files/data_loader.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/calendar_data_manager.dart';
import 'package:flutter_calandar_app/frontend/screens/common/plain_appbar.dart';
import 'package:flutter_calandar_app/frontend/screens/setting_page/app_start_settings.dart';
import 'package:flutter_calandar_app/frontend/screens/setting_page/calendar_setting.dart';
import 'package:flutter_calandar_app/frontend/screens/setting_page/data_backup_page.dart';
import 'package:flutter_calandar_app/frontend/screens/setting_page/notify_setting.dart';
import 'package:flutter_calandar_app/frontend/screens/setting_page/support_page.dart';
import 'package:flutter_calandar_app/frontend/screens/setting_page/task_setting.dart';
import 'package:flutter_calandar_app/frontend/screens/setting_page/common_setting.dart';
import 'package:flutter_calandar_app/frontend/screens/setting_page/timetable_setting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:flutter/cupertino.dart';

import '../../assist_files/colors.dart';
import '../../assist_files/size_config.dart';

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

    return  Scaffold(
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
  PackageInfo? _packageInfo;

  void init() async {
    _packageInfo = await PackageInfo.fromPlatform();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    init();
    _selectedIndex = widget.initIndex;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return SettingsList(
      platform: DevicePlatform.iOS,
      sections: [
        SettingsSection(
          title: const Text("アプリケーション設定"),
          tiles: <SettingsTile>[
            SettingsTile.navigation(
                leading: const Icon(Icons.color_lens_sharp),
                title: const Text("カラーテーマ"),
                trailing: NavIcon(),
                onPressed: (context) {
                  movePage(SettingPages.colortheme);
                }),
            SettingsTile.navigation(
                leading: const Icon(Icons.notifications),
                title: Text("通知設定"),
                trailing: NavIcon(),
                onPressed: (context) {
                  movePage(SettingPages.notification);
                }),
            SettingsTile.navigation(
                leading: const Icon(Icons.smartphone),
                title: Text("アプリ起動設定"),
                trailing: NavIcon(),
                onPressed: (context) {
                  movePage(SettingPages.initPage);
                }),
          ],
        ),
        SettingsSection(
          title: const Text("ページ設定"),
          tiles: <SettingsTile>[
            SettingsTile.navigation(
                leading: const Icon(Icons.check),
                title: Text("課題"),
                trailing: NavIcon(),
                onPressed: (context) {
                  movePage(SettingPages.task);
            }),
            SettingsTile.navigation(
                leading: const Icon(Icons.grid_on),
                title: const Text("時間割"),
                trailing: NavIcon(),
                onPressed: (context) {
                  movePage(SettingPages.timetable);
                }),
            SettingsTile.navigation(
                leading: const Icon(Icons.calendar_month),
                title: Text("カレンダー"),
                trailing: NavIcon(),
                onPressed: (context) {
                  movePage(SettingPages.calendar);
                }),
          ],
        ),
        SettingsSection(
          title: Text("アカウント設定"),
          tiles: <SettingsTile>[
            SettingsTile.navigation(
                leading:
                    const Icon(Icons.backup),
                title: Text("バックアップ"),
                trailing: NavIcon(),
                onPressed:  (context) {
                  movePage(SettingPages.backUp);
                }),
          ],
        ),

        SettingsSection(
          title: Text("その他"),
          tiles: <SettingsTile>[
            SettingsTile.navigation(
                leading: const Icon(Icons.mail),
                title: Text("お問い合わせ / その他"),
                trailing: NavIcon(),
                onPressed:  (context) {
                  movePage(SettingPages.others);
                }),
            SettingsTile(
                leading: const Icon(Icons.info),
                title: Text("バージョン名"),
                value: Text(_packageInfo?.version ?? "",
                    style: Theme.of(context).textTheme.bodyLarge))
          ],
        )
      ],
    );
  }

  void movePage(SettingPages targetPage){
      Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MainContents(settingPages: targetPage,)),
    );
  }
}

enum SettingPages{
  colortheme,
  notification,
  initPage,
  task,
  timetable,
  calendar,
  backUp,
  others,
}

class MainContents extends ConsumerStatefulWidget {
  final SettingPages settingPages;
  const MainContents({super.key, required this.settingPages});
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
    PreferredSizeWidget appBar = CustomAppBar(backButton: true);

    switch (widget.settingPages) {

      case SettingPages.calendar:
        return Scaffold(
          appBar: appBar, 
          body: CalendarSettingPage(
            buildConfig: _buildConfig, 
            nodeText1: _nodeText1,
            controller: controller,
            updateConfigInfo: updateConfigInfo
          ));

      case SettingPages.notification:
        return Scaffold(
          appBar: appBar, 
            body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: NotifySettingPage(
            buildConfig: _buildConfig,
            controller: controller),
        ));

      case SettingPages.timetable:
        return Scaffold(
          appBar: appBar, 
            body:const TimetableSettingPage(),
        );

      case SettingPages.task:
        return Scaffold(
          appBar: appBar, 
            body:const TaskSettingPage());

      case SettingPages.colortheme:
        return Scaffold(
          appBar: appBar, 
            body:const CommonSettingPage());

      case SettingPages.initPage:
        return Scaffold(
          appBar: appBar, 
            body:const AppStartSettingPage());

      case SettingPages.backUp:
        return Scaffold(
          appBar: appBar, 
            body:const DataBackupPage()
        );
      
      default:
        return Scaffold(
          appBar: appBar, 
            body: SnsLinkPage(showAppBar: false)
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

class NavIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Icon(
      CupertinoIcons.forward,
      color: CupertinoColors.systemGrey,
      size: 20,
    );
  }
}
