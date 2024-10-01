import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/handler/calendarpage_config_db_handler.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/assist_files/data_loader.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/calendar_data_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:settings_ui/settings_ui.dart';

class CalendarSettingPage extends ConsumerStatefulWidget{
  Function buildConfig;
  FocusNode nodeText1;
  TextEditingController controller;
  Function updateConfigInfo;

  CalendarSettingPage({super.key, 
    required this.buildConfig ,
    required this.nodeText1,
    required this.controller,
    required this.updateConfigInfo,
  });

  @override
  _CalendarSettingPageState createState()
   => _CalendarSettingPageState();

}

class _CalendarSettingPageState extends ConsumerState<CalendarSettingPage>{

  @override
  Widget build(BuildContext context) {
    Widget borderModel = Column(children: [
      const SizedBox(height: 2.5),
      Divider(height: 2, thickness: 2, color: BACKGROUND_COLOR),
      const SizedBox(height: 2.5),
    ]);

    return SettingsList(
        platform: DevicePlatform.iOS,
        sections: [
          SettingsSection(
            title: Text("カレンダーの設定"),
            tiles: <SettingsTile>[
              SettingsTile(
                title: Text("土日祝日の着色"),
               trailing: configSwitch("holidayPaint"),
              ),
              SettingsTile(
                title: Text("祝日名の表示"),
                trailing: configSwitch("holidayName"),
              ),
            ]),
            SettingsSection(
              title: Text("時間割連携機能"),
              tiles:[
              SettingsTile(
                title: Text("カレンダーに授業を表示"),
                trailing: configSwitch("timetableInCalendarcell"),
              ),
              SettingsTile(
                title: Text("日付ダイアログに授業を表示"),
                trailing: configSwitch("timetableInDailyView"),
                description: Text(
                  "これらは、登録されている時間割をもとに該当月の各曜日に授業データを機械的に表示するものです。ご利用にあたっては大学暦や授業の状況を併せてご確認ください。"),
              ),
            ]),
            SettingsSection(
              title: Text("画面表示のカスタマイズ"),
              tiles: <SettingsTile>[
                SettingsTile(
                  title: Text("アルバイト推計収入額"),
                  trailing: configSwitch("arbeitPreview"),
                ),
            ]),
          ]);

    
  }

  Widget configSwitch(String widgetName) {
    return 
      CupertinoSwitch(
        value: searchConfigData(widgetName),
        activeColor: Colors.blue,
        onChanged: (value) {
          updateConfigData(widgetName, value);
        },
      );
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
}