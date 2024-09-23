import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/sharepreference.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/assist_files/ui_components.dart';
import 'package:flutter_calandar_app/static/constant.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaskSettingPage extends ConsumerStatefulWidget{
  const TaskSettingPage({super.key});


  @override
  _TaskSettingPageState createState() => _TaskSettingPageState();
}

class _TaskSettingPageState extends ConsumerState<TaskSettingPage>{

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Text(
            '  課題ページ設定…',
            style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 5),
          Container(
              decoration: roundedBoxdecoration(),
              padding:
                  const EdgeInsets.symmetric(vertical: 7.5, horizontal: 15),
              margin: const EdgeInsets.symmetric(vertical: 7.5, horizontal: 10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'タスク表示の設定',
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
                    showDayWithoutTaskSwitch(),
                    const Divider(indent: 5,endIndent: 5,),
                    showCalendarLineSwitch(),
                    const SizedBox(height: 2),
                  ])),
        ]);
  }


  Widget showDayWithoutTaskSwitch() {
    return Row(children: [
      const Text("課題のない日を表示"),
      const Spacer(),
      CupertinoSwitch(
        activeColor: PALE_MAIN_COLOR,
        value: SharepreferenceHandler()
            .getValue(SharepreferenceKeys.isShowDayWithoutTask),
        onChanged: (value) async {
          SharepreferenceHandler().setValue(
              SharepreferenceKeys.isShowDayWithoutTask, value);
          setState(() {});
        },
      )
    ]);
  }

  Widget showCalendarLineSwitch() {
    return Row(children: [
      const Text("カレンダーラインを表示"),
      const Spacer(),
      CupertinoSwitch(
        activeColor: PALE_MAIN_COLOR,
        value: SharepreferenceHandler()
            .getValue(SharepreferenceKeys.isShowTaskCalendarLine),
        onChanged: (value) async {
          SharepreferenceHandler().setValue(
              SharepreferenceKeys.isShowTaskCalendarLine, value);
          setState(() {});
        },
      )
    ]);
  }

}