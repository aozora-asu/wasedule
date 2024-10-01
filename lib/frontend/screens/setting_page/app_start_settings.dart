import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/sharepreference.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/assist_files/ui_components.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:settings_ui/settings_ui.dart';

class AppStartSettingPage extends ConsumerStatefulWidget{
  const AppStartSettingPage({super.key});

  @override
  _AppStartSettingPageState createState() => _AppStartSettingPageState();
}

class _AppStartSettingPageState extends ConsumerState<AppStartSettingPage>{
  String bgColorTheme = "";
  int initScreenIndex = 0;

  @override
  Widget build(BuildContext context) {

    return SettingsList(
        platform: DevicePlatform.iOS,
        sections: [
          SettingsSection(
            title:Text("起動後表示画面"),
              tiles: <SettingsTile>[
                SettingsTile.navigation(
                  title: initScreenSettings(),
                  description: Text("アプリを起動して最初に表示される画面を設定します。"),
                ),
              ]),
            ]);
  }


  Widget initScreenSettings() {
    initScreenIndex = SharepreferenceHandler().getValue(SharepreferenceKeys.initScreenIndex);
    return SizedBox(
      width: 150,
      child: DropdownButtonFormField(
        value: initScreenIndex,
        icon:const SizedBox(),
        decoration: const InputDecoration.collapsed(
          hintText: "",
          border: InputBorder.none,
        ),
        items: const [
          DropdownMenuItem(value: 3, child: Text(" 課題画面")),
          DropdownMenuItem(value: 1, child: Text(" 時間割画面")),
          DropdownMenuItem(value: 2, child: Text(" カレンダー画面")),
          DropdownMenuItem(value: 0, child: Text(" マップ画面")),
          DropdownMenuItem(value: 4, child: Text(" ブラウザ画面")),
        ],
        style: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 18,
          color: Colors.blue
        ),
        onChanged: (value) async {
          SharepreferenceHandler()
              .setValue(SharepreferenceKeys.initScreenIndex, value!);
          setState(() {
            initScreenIndex = value;
          });
        },
      ),
    );
  }

}