import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
InAppWebView? webView;

class MyWasedaViewPage extends ConsumerStatefulWidget {
  @override
  _MyWasedaViewPageState createState() => _MyWasedaViewPageState();
}

final GlobalKey webMoodleViewKey = GlobalKey();
late InAppWebViewController webMoodleViewController;

class _MyWasedaViewPageState extends ConsumerState<MyWasedaViewPage> {
  final GlobalKey webViewKey = GlobalKey();
  late InAppWebViewController webViewController;
  double progress = 0;

  static const String moodleUrl = "https://my.waseda.jp/portal/view/portal-top-view";


  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    String javascriptCode;
    Map<String, dynamic> messageData;
    return Scaffold(
        body: Column(children: [
      progress < 1.0
          ? LinearProgressIndicator(value: progress)
          : const SizedBox.shrink(),
      Expanded(
          child: InAppWebView(
        key: webViewKey,
        initialSettings: InAppWebViewSettings(
            thirdPartyCookiesEnabled: true,),
        initialUrlRequest: URLRequest(url: WebUri(moodleUrl)),
        onWebViewCreated: (controller) {
          webViewController = controller;
        },
      )),
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
