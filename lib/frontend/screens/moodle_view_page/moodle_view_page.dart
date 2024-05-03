import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/services.dart' show rootBundle;

class MoodleViewPage extends ConsumerStatefulWidget {
  @override
  _MoodleViewPageState createState() => _MoodleViewPageState();
}

final GlobalKey webMoodleViewKey = GlobalKey();
InAppWebViewController? webMoodleViewController;

class _MoodleViewPageState extends ConsumerState<MoodleViewPage> {

  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;
  double progress = 0;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    String initURL = "https://wsdmoodle.waseda.jp/login/index.php";
    return Scaffold(
        body:Stack(
          alignment: Alignment(0,0.75),
          children:[
          Column(children: [
          progress < 1.0
              ? LinearProgressIndicator(value: progress)
              : const SizedBox.shrink(),
          
          Expanded(
              child: InAppWebView(
            key: webViewKey,
            onConsoleMessage: (controller, consoleMessage) {
              print("Value from JavaScript:$consoleMessage");
            },
            initialUrlRequest: URLRequest(url: WebUri(initURL)),
            onWebViewCreated: (controller) {
              webViewController = controller;
            },
            onLoadStop: (controller, url) async {
              print("Current URL: $url");
              // JavaScriptファイルの内容を読み込んで実行
              String javascriptCode = await rootBundle.loadString(
                  'lib/frontend/screens/moodle_view_page/get_course_info.js');
              await webViewController?.evaluateJavascript(source: javascriptCode);
            },
          )),
        ]),
        Container(
          margin: EdgeInsets.symmetric(
            horizontal: SizeConfig.blockSizeHorizontal! *3,
            vertical: SizeConfig.blockSizeVertical! *1
          ),
          decoration: BoxDecoration(
            color:Colors.white,
            border: Border.all(color:Colors.grey,width: 0.5),
            borderRadius:const BorderRadius.all(Radius.circular(15)),
            boxShadow:const [BoxShadow(blurRadius:0.5,)]
          ),
          height: SizeConfig.blockSizeVertical! * 4.5,
          child: menuBar()),
        ]) 
      );
  }

  Widget menuBar() {
    return Row(children: [
      IconButton(
        onPressed: () {
          webViewController?.goBack();
        },
        icon: Icon(
          Icons.arrow_back_ios,
          size: SizeConfig.blockSizeVertical! * 2.5,
        ),
      ),
      const Spacer(),
      IconButton(
        onPressed: () {
          final url = URLRequest(
              url: WebUri(
                  "https://coursereg.waseda.jp/portal/simpleportal.php?HID_P14=JA"));
          webViewController?.loadUrl(urlRequest: url);
        },
        icon: Icon(
          Icons.home,
          size: SizeConfig.blockSizeVertical! * 3,
        ),
      ),
      const Spacer(),
      IconButton(
        onPressed: () {
          webViewController?.goForward();
        },
        icon: Icon(
          Icons.arrow_forward_ios,
          size: SizeConfig.blockSizeVertical! * 2.5,
        ),
      ),

    ]);
  }
}
