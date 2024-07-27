import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/sharepreference.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/assist_files/ui_components.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TimetableSettingPage extends ConsumerStatefulWidget{

  @override
  _TimetableSettingPageState createState() => _TimetableSettingPageState();
}

class _TimetableSettingPageState extends ConsumerState<TimetableSettingPage>{

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Text(
            '  時間割設定…',
            style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Container(
              decoration: roundedBoxdecorationWithShadow(),
              padding:
                  const EdgeInsets.symmetric(vertical: 7.5, horizontal: 15),
              margin: const EdgeInsets.symmetric(vertical: 7.5, horizontal: 10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '出欠記録の設定',
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
                    attendDialogSettingSwitch(),
                    const SizedBox(height: 2),
                  ])),
        ]);
  }

  Widget attendDialogSettingSwitch() {
    return Row(children: [
      const Text("出欠記録画面の自動表示"),
      const Spacer(),
      CupertinoSwitch(
        activeColor: PALE_MAIN_COLOR,
        value: SharepreferenceHandler()
            .getValue(SharepreferenceKeys.showAttendDialogAutomatically),
        onChanged: (value) async {
          SharepreferenceHandler().setValue(
              SharepreferenceKeys.showAttendDialogAutomatically, value);
          setState(() {});
        },
      )
    ]);
  }

}