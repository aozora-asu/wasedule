import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/ui_components.dart';
import 'package:flutter_calandar_app/frontend/screens/common/plain_appbar.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/task_view_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:settings_ui/settings_ui.dart';
import '../../assist_files/colors.dart';
import '../../assist_files/size_config.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SnsLinkPage extends StatefulWidget {
  bool showAppBar;
  SnsLinkPage({
    required this.showAppBar,
    super.key});

  @override
  _SnsLinkPageState createState() => _SnsLinkPageState();
}

class _SnsLinkPageState extends State<SnsLinkPage> {

  @override
  Widget build(BuildContext context) {
  SizeConfig().init(context);
  PreferredSizeWidget? appBar = CustomAppBar(backButton: true);
  
  if(!widget.showAppBar){
    appBar = null; 
  }

    return Scaffold(
      backgroundColor: BACKGROUND_COLOR,
      appBar: appBar,
      body: SettingsList(
            platform: DevicePlatform.iOS,
            sections: [
              SettingsSection(
                  title: Text("不具合報告はこちらからお願いします。"),
                  tiles: <SettingsTile>[
                    SettingsTile.navigation(
                      title: Text("お問い合わせ",style: TextStyle(color: Colors.red)),
                      onPressed: (context){
                        showErrorReportDialogue(context);
                      },
                    ),
                  ]
                ),
              SettingsSection(
                  title: Text("公式サイト"),
                  tiles: <SettingsTile>[
                    SettingsTile.navigation(
                      title: Text("わせジュール 公式サイト",style: TextStyle(color: Colors.blue)),
                      onPressed: (context){
                        final urlLaunchWithStringButton = UrlLaunchWithStringButton();
                        urlLaunchWithStringButton.launchUriWithString(
                          context,
                          "https://wasedule.com/",
                        );
                      },
                    ),
                    SettingsTile.navigation(
                      title: Text("プライバシーポリシー",style: TextStyle(color: Colors.blue)),
                      onPressed: (context){
                          final urlLaunchWithStringButton = UrlLaunchWithStringButton();
                          urlLaunchWithStringButton.launchUriWithString(
                          context,
                          "https://wasedule.com/privacy",
                        );
                      },
                    ),
                  ]
                ),
              SettingsSection(
                  title: Text("運営からの新着情報"),
                  tiles: <SettingsTile>[
                    SettingsTile.navigation(
                      title: Text("Instagram",style: TextStyle(color: Colors.blue)),
                      onPressed: (context){
                          final urlLaunchWithStringButton = UrlLaunchWithStringButton();
                          urlLaunchWithStringButton.launchUriWithString(
                          context,
                          "https://www.instagram.com/wasedule/",
                        );
                      },
                    ),
                    SettingsTile.navigation(
                      title: Text("Twitter(現 X)",style: TextStyle(color: Colors.blue)),
                      onPressed: (context){
                        final urlLaunchWithStringButton = UrlLaunchWithStringButton();
                        urlLaunchWithStringButton.launchUriWithString(
                          context,
                          "https://twitter.com/wasedule",
                        );
                      },
                    ),
                  ]
                ),
              SettingsSection(
                  title: Text("SPETIAL THANKS"),
                  tiles: <SettingsTile>[
                    SettingsTile(
                      title: specialThanks(),
                      description: const Text("上記のテスター参加者 総勢21名には、わせジュール Android版アプリのリリース要件達成にあたり、本アプリの試用にご協力いただきました。この場を借りて心からの感謝を申し上げます。",
                        overflow: TextOverflow.clip),
                    ),
                  ],
                ),
              ]),
    );
  }

  Widget specialThanks(){
    String name1 =dotenv.get('TESTER_NAME_1');
    String name2 =dotenv.get('TESTER_NAME_2');
    String name3 =dotenv.get('TESTER_NAME_3');
    String name4 =dotenv.get('TESTER_NAME_4');
    String name5 =dotenv.get('TESTER_NAME_5');
    String suffix = "  様";

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:[
         const Text("Android版 テスター参加者",
          style:TextStyle(fontSize:15,color:Colors.grey)),
         const SizedBox(height:5),
          Text(name1+suffix),
          Text(name2+suffix),
          Text(name3+suffix),
          Text(name4+suffix),
          Text(name5+suffix),
          const SizedBox(height:5),
          const Align(
            alignment: Alignment.centerRight,
            child:Text("他 16名")),
      ]
    );
  }
}

class UrlLaunchWithStringButton {
  final alertSnackBar = SnackBar(
    content: const Text('このURLは開けませんでした'),
    action: SnackBarAction(
      label: '閉じる',
      onPressed: () {},
    ),
  );

  Future launchUriWithString(BuildContext context, String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      alertSnackBar;
      ScaffoldMessenger.of(context).showSnackBar(alertSnackBar);
    }
  }
}