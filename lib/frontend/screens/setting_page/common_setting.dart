import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/sharepreference.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/assist_files/ui_components.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CommonSettingPage extends ConsumerStatefulWidget{
  const CommonSettingPage({super.key});


  @override
  _CommonSettingPageState createState() => _CommonSettingPageState();
}

class _CommonSettingPageState extends ConsumerState<CommonSettingPage>{
  String bgColorTheme = "";
  int initScreenIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Text(
            '  テーマ設定…',
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
          Container(
              decoration: roundedBoxdecoration(),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                   const Text(
                      '背景カラーテーマの設定',
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
                    buildThemeSettingList(),
                    const SizedBox(height: 2),
                    const Text(
                      "設定は次回起動時から適用されます。",
                      style: TextStyle(color: Colors.grey),
                    )
                  ])),
           ])
          )
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
      width: 150,
      child: DropdownButtonFormField(
        value: bgColorTheme,
        decoration: const InputDecoration.collapsed(
            filled: true,
            fillColor: Colors.white,
            hintText: "背景テーマ色",
            border: OutlineInputBorder()),
        items: const [
          DropdownMenuItem(value: "white", child: Text(" ホワイト")),
          DropdownMenuItem(value: "grey", child: Text(" グレー")),
          DropdownMenuItem(value: "yellow", child: Text(" イエロー")),
          DropdownMenuItem(value: "blue", child: Text(" ブルー")),
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

  Widget initScreenSettings() {
    initScreenIndex = SharepreferenceHandler().getValue(SharepreferenceKeys.initScreenIndex);
    return SizedBox(
      width: 150,
      child: DropdownButtonFormField(
        value: initScreenIndex,
        decoration: const InputDecoration.collapsed(
            filled: true,
            fillColor: Colors.white,
            hintText: "",
            border: OutlineInputBorder()),
        items: const [
          DropdownMenuItem(value: 3, child: Text(" 課題画面")),
          DropdownMenuItem(value: 1, child: Text(" 時間割画面")),
          DropdownMenuItem(value: 2, child: Text(" カレンダー画面")),
          DropdownMenuItem(value: 0, child: Text(" マップ画面")),
          DropdownMenuItem(value: 4, child: Text(" ブラウザ画面")),
        ],
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