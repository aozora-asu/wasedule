import 'package:flutter/material.dart';
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
      body: Center(child:
        Column(children:[
         const Spacer(),
         Image.asset('lib/assets/eye_catch/eyecatch.png',height: 200, width: 200),
         const Spacer(),
         const Text("使い方ガイドやお問い合わせはこちら"),
         HomePageUrlLauncher(),
         const SizedBox(height:20),
         const Text("運営からの新着情報をチェック！"),
         InstaUrlLauncher(),
         XUrlLauncher(),
         const SizedBox(height:20),
         const Text("Waseda Moodleへのアクセスはこちらから！"),
         MoodleUrlLauncher(),
         const Spacer(),
         const Padding(
          padding: EdgeInsets.all(10),
          child:Row(children:[Spacer(),Text("Version: Beta 15.10.14"),SizedBox(width:7)]),
          ),
         const SizedBox(height:3)
        ])
        )
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
          child: const Text('Instagram   ...coming soon!',style:TextStyle(color:Colors.white)),
          onPressed: () {
            // _urlLaunchWithStringButton.launchUriWithString(
            //   context,
            //   "https://main--silver-alpaca-276a52.netlify.app/",
            // );
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
          child: const Text('X(旧Twitter)   ...coming soon!',style:TextStyle(color:Colors.white)),
          onPressed: () {
            // _urlLaunchWithStringButton.launchUriWithString(
            //   context,
            //   "https://main--silver-alpaca-276a52.netlify.app/",
            // );
          }
        );
  }
}

class MoodleUrlLauncher extends StatelessWidget {
  MoodleUrlLauncher({Key? key}) : super(key: key);

  final _urlLaunchWithStringButton = UrlLaunchWithStringButton();

  @override
  Widget build(BuildContext context) {
    return  ElevatedButton(
          style:  ButtonStyle(
            backgroundColor: const MaterialStatePropertyAll(Colors.orange),
            fixedSize: MaterialStatePropertyAll(Size(SizeConfig.blockSizeHorizontal! *80,25))
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

class UrlLaunchWithStringButton {
  final alertSnackBar = SnackBar(
    content: const Text('このURLは開けませんでした'),
    action: SnackBarAction(
      label: '戻る',
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