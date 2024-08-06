import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_calandar_app/backend/DB/handler/calendarpage_config_db_handler.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/assist_files/data_loader.dart';
import 'package:flutter_calandar_app/frontend/assist_files/ui_components.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/calendar_data_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

class CalendarSettingPage extends ConsumerStatefulWidget{
  Function buildConfig;
  FocusNode nodeText1;
  TextEditingController controller;
  Function updateConfigInfo;

  CalendarSettingPage({
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

    return KeyboardActions(
        config: widget.buildConfig(widget.controller),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text(
            'カレンダー設定…',
            style: TextStyle(
                fontSize:25,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
              decoration: roundedBoxdecoration(),
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      ' 画面表示のカスタマイズ',
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
                    configSwitch("Tipsとお知らせ", "tips"),
                    borderModel,
                    configSwitch("きょうの予定", "todaysSchedule"),
                    configSwitch(
                        "きょうの予定枠内に\n時間割データを表示", "timetableInTodaysSchedule"),
                    borderModel,
                    configSwitch("近日締切のタスク", "taskList"),
                    const SizedBox(height: 5),
                    configTextField("表示日数：", "taskList", widget.controller),
                    borderModel,
                    configSwitch("アルバイト推計収入", "arbeitPreview"),
                    borderModel,
                  ])),
          const SizedBox(height: 10),
          Container(
              decoration: roundedBoxdecoration(),
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      ' カレンダーの設定',
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
        style:const TextStyle(
          fontSize: 16,
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
        style:const TextStyle(
          fontSize: 16,
        ),
      ),
      Expanded(
        child: CupertinoTextField(
            controller: controller,
            focusNode: widget.nodeText1,
            onSubmitted: (value) {
              widget.updateConfigInfo(widgetName, value);
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
}