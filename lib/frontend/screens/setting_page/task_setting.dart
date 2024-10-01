import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/sharepreference.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/assist_files/ui_components.dart';
import 'package:flutter_calandar_app/frontend/screens/setting_page/setting_page.dart';
import 'package:flutter_calandar_app/static/constant.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:settings_ui/settings_ui.dart';

class TaskSettingPage extends ConsumerStatefulWidget{
  const TaskSettingPage({super.key});


  @override
  _TaskSettingPageState createState() => _TaskSettingPageState();
}

class _TaskSettingPageState extends ConsumerState<TaskSettingPage>{

  @override
  Widget build(BuildContext context) {

    return SettingsList(
        platform: DevicePlatform.iOS,
        sections: [
          SettingsSection(
            title: Text("課題ページ設定"),
            tiles: <SettingsTile>[
              SettingsTile(
                title: Text("課題のない日を表示"),
                trailing: showDayWithoutTaskSwitch(),
              ),
              SettingsTile(
                title: Text("カレンダータイムラインを表示"),
                trailing: showCalendarLineSwitch(),
              ),
            ]),
          SettingsSection(
            title:Text("課題の自動取得設定"),
            tiles:[
              SettingsTile.navigation(
                leading:
                    const Icon(CupertinoIcons.link),
                title: Text("moodle連携"),
                trailing: NavIcon(),
                onPressed:  (context) {
                  movePage(SettingPages.moodleLink);
                })
              ]
            )
        ]);
  }

  void movePage(SettingPages targetPage){
      Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MainContents(settingPages: targetPage,)),
    );
  }

  Widget showDayWithoutTaskSwitch() {
    return 
      CupertinoSwitch(
        activeColor: Colors.blue,
        value: SharepreferenceHandler()
            .getValue(SharepreferenceKeys.isShowDayWithoutTask),
        onChanged: (value) async {
          SharepreferenceHandler().setValue(
              SharepreferenceKeys.isShowDayWithoutTask, value);
          setState(() {});
        },
      );
  }

  Widget showCalendarLineSwitch() {
    return 
      CupertinoSwitch(
        activeColor: Colors.blue,
        value: SharepreferenceHandler()
            .getValue(SharepreferenceKeys.isShowTaskCalendarLine),
        onChanged: (value) async {
          SharepreferenceHandler().setValue(
              SharepreferenceKeys.isShowTaskCalendarLine, value);
          setState(() {});
        },
    );
  }

}