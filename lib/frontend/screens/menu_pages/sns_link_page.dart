import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/task_view_page.dart';
import '../../assist_files/colors.dart';
import '../../assist_files/size_config.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SnsLinkPage extends StatefulWidget {
  @override
  _SnsLinkPageState createState() => _SnsLinkPageState();
}

class _SnsLinkPageState extends State<SnsLinkPage> {
  @override
  Widget build(BuildContext context) {
  SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color:Colors.white),
        backgroundColor: MAIN_COLOR,
        elevation: 10,
        title: Column(
          children:<Widget>[
            Row(children:[
            const Icon(
              Icons.question_mark_rounded,
              color:WIDGET_COLOR,
              ),
              SizedBox(width: SizeConfig.blockSizeHorizontal! *4,),
            Text(
              'サポート',
              style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal! *5,
                fontWeight: FontWeight.w800,
                color:Colors.white
              ),
            ),
            ]
            )
          ],
        ),
      ),
      body:
      Container(
       width: SizeConfig.blockSizeHorizontal! *100,
       child:SingleChildScrollView(
        child:Column(children:[
         const SizedBox(height:50),
         Image.asset('lib/assets/eye_catch/eyecatch.png',height: 200, width: 200),
         const SizedBox(height:50),
         const Text("使い方ガイドやお問い合わせはこちら"),
         HomePageUrlLauncher(),
         PrivacyPolicyLauncher(),
         ErrorReportButton(),
         const SizedBox(height:20),
         const Text("運営からの新着情報をチェック！"),
         InstaUrlLauncher(),
         XUrlLauncher(),
         const SizedBox(height:20),
         const Text("Waseda Moodleへのアクセスはこちらから！"),
         MoodleUrlLauncher(width:80),
         const SizedBox(height:3)
        ])
      ))
      
    );
  }
}

class HomePageUrlLauncher extends StatelessWidget {
  HomePageUrlLauncher({Key? key}) : super(key: key);

  final _urlLaunchWithStringButton = UrlLaunchWithStringButton();

  @override
  Widget build(BuildContext context) {
    return  ElevatedButton(
          style:  ButtonStyle(
            backgroundColor: const MaterialStatePropertyAll(MAIN_COLOR),
            fixedSize: MaterialStatePropertyAll(Size(SizeConfig.blockSizeHorizontal! *80,25))
            ),
          child: const Text('わせジュール 公式サイト',style:TextStyle(color:Colors.white)),
          onPressed: () {
            _urlLaunchWithStringButton.launchUriWithString(
              context,
              "https://wasedule.com/",
            );
          }
        );
  }
}


class ErrorReportButton extends StatelessWidget {
  ErrorReportButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  ElevatedButton(
          style:  ButtonStyle(
            backgroundColor: const MaterialStatePropertyAll(Colors.red),
            fixedSize: MaterialStatePropertyAll(Size(SizeConfig.blockSizeHorizontal! *80,25))
            ),
          child: const Text('お問い合わせ',style:TextStyle(color:Colors.white)),
          onPressed: () {
            showErrorReportDialogue(context);
          }
        );
  }
}
class InstaUrlLauncher extends StatelessWidget {
  InstaUrlLauncher({Key? key}) : super(key: key);

  final _urlLaunchWithStringButton = UrlLaunchWithStringButton();

  @override
  Widget build(BuildContext context) {
    return  ElevatedButton(
          style:  ButtonStyle(
            backgroundColor: const MaterialStatePropertyAll(Colors.pinkAccent),
            fixedSize: MaterialStatePropertyAll(Size(SizeConfig.blockSizeHorizontal! *80,25))
            ),
          child: const Text('Instagram',style:TextStyle(color:Colors.white)),
          onPressed: () {
            _urlLaunchWithStringButton.launchUriWithString(
              context,
              "https://www.instagram.com/wasedule/",
            );
          }
        );
  }
}

class XUrlLauncher extends StatelessWidget {
  XUrlLauncher({Key? key}) : super(key: key);

  final _urlLaunchWithStringButton = UrlLaunchWithStringButton();

  @override
  Widget build(BuildContext context) {
    return  ElevatedButton(
          style:  ButtonStyle(
            backgroundColor: const MaterialStatePropertyAll(Colors.lightBlue),
            fixedSize: MaterialStatePropertyAll(Size(SizeConfig.blockSizeHorizontal! *80,25))
            ),
          child: const Text('Twitter(現X)',style:TextStyle(color:Colors.white)),
          onPressed: () {
            _urlLaunchWithStringButton.launchUriWithString(
              context,
              "https://twitter.com/wasedule",
            );
          }
        );
  }
}

class MoodleUrlLauncher extends StatelessWidget {
  int width;
  MoodleUrlLauncher({
    Key? key,
    required this.width
    }) : super(key: key);

  final _urlLaunchWithStringButton = UrlLaunchWithStringButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
          style:  ButtonStyle(
            backgroundColor: const MaterialStatePropertyAll(Colors.orange),
            fixedSize: MaterialStatePropertyAll(Size(SizeConfig.blockSizeHorizontal!*width,25))
            ),
          child: const Text('Waseda Moodle リンク',style:TextStyle(color:Colors.white)),
          onPressed: () {
            _urlLaunchWithStringButton.launchUriWithString(
              context,
              "https://wsdmoodle.waseda.jp/",
            );
          }
        );
  }
}

class PrivacyPolicyLauncher extends StatelessWidget {
  PrivacyPolicyLauncher({
    Key? key,
    }) : super(key: key);

  final _urlLaunchWithStringButton = UrlLaunchWithStringButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
          style:  ButtonStyle(
            backgroundColor: const MaterialStatePropertyAll(ACCENT_COLOR),
            fixedSize: MaterialStatePropertyAll(Size(SizeConfig.blockSizeHorizontal! *80,25))
            ),
          child: const Text('プライバシーポリシー',style:TextStyle(color:Colors.white)),
          onPressed: () {
            _urlLaunchWithStringButton.launchUriWithString(
              context,
              "https://wasedule.com/privacy",
            );
          }
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