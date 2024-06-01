import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/ui_components.dart';
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
        leading: const BackButton(color:WHITE),
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
                color:WHITE
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
       padding: EdgeInsets.symmetric(horizontal:SizeConfig.blockSizeHorizontal! *5,),
       child:SingleChildScrollView(
        child:Column(children:[
         const SizedBox(height:50),
         Image.asset('lib/assets/eye_catch/eyecatch.png',height: 200, width: 200),
         const SizedBox(height:50),
         const Text("使い方ガイドやお問い合わせはこちら"),
         HomePageUrlLauncher(),
         const SizedBox(height:5),
         PrivacyPolicyLauncher(),
         const SizedBox(height:5),
         ErrorReportButton(),
         const SizedBox(height:20),
         const Text("運営からの新着情報をチェック！"),
         InstaUrlLauncher(),
         const SizedBox(height:5),
         XUrlLauncher(),
         const SizedBox(height:30)
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
  ErrorReportButton({Key? key}) : super(key: key);

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
  InstaUrlLauncher({Key? key}) : super(key: key);

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
  XUrlLauncher({Key? key}) : super(key: key);

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
    Key? key,
    }) : super(key: key);

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
          ACCENT_COLOR,
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