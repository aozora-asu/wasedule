import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/ui_components.dart';
import 'package:flutter_calandar_app/frontend/screens/common/plain_appbar.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/task_view_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
      body: 
      Container(
       width: SizeConfig.blockSizeHorizontal! *100,
       padding: EdgeInsets.symmetric(horizontal:SizeConfig.blockSizeHorizontal! *5,),
       child:SingleChildScrollView(
        child:Column(children:[
         const SizedBox(height:50),
         Image.asset('lib/assets/eye_catch/eyecatch.png',height: 200, width: 200),
         const SizedBox(height:50),
         const Text("不具合報告はこちらからお願いします。",
          overflow: TextOverflow.clip,
          style: TextStyle(color:Colors.red,fontSize:18),),
         const SizedBox(height:5),
         const ErrorReportButton(),
         const SizedBox(height:10),
         const Divider(),
         const SizedBox(height:5),
         const Text("公式サイト"),
         HomePageUrlLauncher(),
         const SizedBox(height:5),
         PrivacyPolicyLauncher(),
         const SizedBox(height:20),
         const Text("運営からの新着情報をチェック！"),
         InstaUrlLauncher(),
         const SizedBox(height:5),
         XUrlLauncher(),
         const SizedBox(height:15),
         const Divider(),
         const SizedBox(height:5),
         const Text("SPECIAL THANKS",
           style:TextStyle(fontSize:20,fontWeight: FontWeight.bold)),
         const SizedBox(height:5),
         specialThanks(),
         const SizedBox(height:5),
         const Divider(),
         const SizedBox(height:5),
         const Text("©2024 Aozora.Studio",
          textAlign: TextAlign.end,
          style:TextStyle(color:Colors.grey)),
         const SizedBox(height:30),
        ])
      ))
      
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
          const SizedBox(height:10),
          const Text("上記のテスター参加者 総勢21名には、わせジュール Android版アプリのリリース要件達成にあたり、本アプリの試用にご協力いただきました。この場を借りて心からの感謝を申し上げます。",
            overflow: TextOverflow.clip,
            style:TextStyle(color:Colors.grey)),
      ]
    );
  }
}

class HomePageUrlLauncher extends StatelessWidget {
  HomePageUrlLauncher({super.key});

  final _urlLaunchWithStringButton = UrlLaunchWithStringButton();

  @override
  Widget build(BuildContext context) {
    return buttonModel(
          () {
            _urlLaunchWithStringButton.launchUriWithString(
              context,
              "https://wasedule.com/",
            );
          },
          MAIN_COLOR,
          "   わせジュール 公式サイト   "
        );
  }
}


class ErrorReportButton extends StatelessWidget {
  const ErrorReportButton({super.key});

  @override
  Widget build(BuildContext context) {
    return buttonModel(
      () {
        showErrorReportDialogue(context);
      },
      Colors.redAccent,
      "   お問い合わせ   "
    );
  }
}
class InstaUrlLauncher extends StatelessWidget {
  InstaUrlLauncher({super.key});

  final _urlLaunchWithStringButton = UrlLaunchWithStringButton();

  @override
  Widget build(BuildContext context) {
    return buttonModel(
          () {
            _urlLaunchWithStringButton.launchUriWithString(
              context,
              "https://www.instagram.com/wasedule/",
            );
          },
          Colors.pinkAccent,
          "   Instagram   "
        );
  }
}

class XUrlLauncher extends StatelessWidget {
  XUrlLauncher({super.key});

  final _urlLaunchWithStringButton = UrlLaunchWithStringButton();

  @override
  Widget build(BuildContext context) {
    return  buttonModel(
          () {
            _urlLaunchWithStringButton.launchUriWithString(
              context,
              "https://twitter.com/wasedule",
            );
          },
          Colors.lightBlue,
          "   Twitter (現 X)   "
        );
  }
}


class PrivacyPolicyLauncher extends StatelessWidget {
  PrivacyPolicyLauncher({
    super.key,
    });

  final _urlLaunchWithStringButton = UrlLaunchWithStringButton();

  @override
  Widget build(BuildContext context) {
    return buttonModel(
          () {
            _urlLaunchWithStringButton.launchUriWithString(
              context,
              "https://wasedule.com/privacy",
            );
          },
          PALE_MAIN_COLOR,
          "   プライバシーポリシー   "
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