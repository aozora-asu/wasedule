import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/handler/my_grade_db.dart';
import 'package:flutter_calandar_app/backend/service/share_from_web.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/services.dart' show rootBundle;

InAppWebView? webView;

class MyGradeViewPage extends ConsumerStatefulWidget {
  const MyGradeViewPage({super.key});

  @override
  _MyWasedaViewPageState createState() => _MyWasedaViewPageState();
}

final GlobalKey webMoodleViewKey = GlobalKey();
late InAppWebViewController webMoodleViewController;

class _MyWasedaViewPageState extends ConsumerState<MyGradeViewPage> {
  final GlobalKey webViewKey = GlobalKey();
  late InAppWebViewController webViewController;
  double progress = 0;

  static const String moodleUrl =
      "https://my.waseda.jp/portal/view/portal-top-view?communityId=1&communityPageId=9";
  static const String myGradeUrl =
      "https://gradereport-ty.waseda.jp/kyomu/epb2051.htm";
  static const String myCreditUrl =
      "https://gradereport-ty.waseda.jp/kyomu/epb2052.htm";

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    String javascriptCode;
    List<MajorClass> majorClassList = [];

    return Scaffold(
        body: Column(children: [
      progress < 1.0
          ? LinearProgressIndicator(value: progress)
          : const SizedBox.shrink(),
      Expanded(
          child: InAppWebView(
              key: webViewKey,
              initialSettings: InAppWebViewSettings(
                  thirdPartyCookiesEnabled: true,
                  javaScriptCanOpenWindowsAutomatically: true,
                  javaScriptEnabled: true,
                  supportMultipleWindows: true),
              initialUrlRequest: URLRequest(url: WebUri(moodleUrl)),
              onWebViewCreated: (controller) {
                webViewController = controller;
              },
              onLoadStop: (controller, currentUrl) async {
                switch (currentUrl.toString()) {
                  case moodleUrl:
                    javascriptCode = await rootBundle.loadString(
                        'lib/backend/service/js/go_to_myGradePage.js');
                    await webViewController.evaluateJavascript(
                        source: javascriptCode);
                  case myGradeUrl:
                    javascriptCode = await rootBundle
                        .loadString('lib/backend/service/js/get_myGrade.js');
                    await webViewController.evaluateJavascript(
                        source: javascriptCode);

                    getMyGrade(
                        await controller.getHtml() ?? "", majorClassList);
                  case myCreditUrl:
                    majorClassList =
                        getMyCredit(await controller.getHtml() ?? "");
                    webViewController.goBack();

                  // case moodleLoginUrl:
                  //   javascriptCode = await rootBundle.loadString(
                  //       'lib/frontend/screens/moodle_view_page/auto_login_checkbox.js');
                  //   await webViewController.evaluateJavascript(
                  //       source: javascriptCode)
                }
              },
              onConsoleMessage: (controller, consoleMessage) async {
                if (consoleMessage.message != "") {}
              })),
      const Divider(height: 0.5, thickness: 0.5, color: Colors.grey),
      Container(
          color: Colors.white,
          height: SizeConfig.blockSizeVertical! * 4.5,
          child: menuBar()),
    ]));
  }

  Widget menuBar() {
    return Row(children: [
      IconButton(
        onPressed: () {
          webViewController.goBack();
        },
        icon: Icon(
          Icons.arrow_back_ios,
          size: SizeConfig.blockSizeVertical! * 2.5,
        ),
      ),
      const Spacer(),
      IconButton(
        onPressed: () {
          webViewController.loadUrl(
              urlRequest: URLRequest(url: WebUri(moodleUrl)));
        },
        icon: Icon(
          Icons.home,
          size: SizeConfig.blockSizeVertical! * 3,
        ),
      ),
      const Spacer(),
      IconButton(
        onPressed: () {
          webViewController.goForward();
        },
        icon: Icon(
          Icons.arrow_forward_ios,
          size: SizeConfig.blockSizeVertical! * 2.5,
        ),
      ),
    ]);
  }
}
