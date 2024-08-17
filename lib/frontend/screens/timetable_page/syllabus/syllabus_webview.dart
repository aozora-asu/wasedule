import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/frontend/screens/moodle_view_page/moodle_view_page.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/services.dart' show rootBundle;

class SyllabusWebView extends StatefulWidget {
  String? pageID;
  SyllabusWebView({super.key, required this.pageID});

  @override
  _SyllabusWebViewState createState() => _SyllabusWebViewState();
}

class _SyllabusWebViewState extends State<SyllabusWebView> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    int height = (SizeConfig.blockSizeVertical! * 100).round();
    String? pageID = widget.pageID;

    if (pageID != null && pageID != "") {
      return Expanded(
        child:
        Container(
            width: SizeConfig.blockSizeHorizontal! * 100,
            height: SizeConfig.blockSizeVertical! * 90,
            decoration: BoxDecoration(border: Border.all()),
              child: SizedBox(
                  width: SizeConfig.blockSizeHorizontal! * 100,
                  height: SizeConfig.blockSizeVertical! * height,
                  child: InAppWebView(
                    key: webMoodleViewKey,
                    onConsoleMessage: (controller, consoleMessage) async {
                      //print(consoleMessage.message);
                    },
                    initialUrlRequest: URLRequest(url: WebUri(pageID)),
                    onWebViewCreated: (controller) async {
                      webMoodleViewController = controller;
                      String javascriptCode = await rootBundle.loadString(
                          'lib/backend/service/js/scroll_controller.js');
                      await webMoodleViewController.evaluateJavascript(
                          source: javascriptCode);
                    },
                    onLoadStop: (a, b) async {
                      String javascriptCode = await rootBundle.loadString(
                          'lib/backend/service/js/scroll_controller.js');
                      await webMoodleViewController.evaluateJavascript(
                          source: javascriptCode);
                      setState(() {});
                    },
                    onContentSizeChanged: (a, b, c) async {
                      setState(() {});
                    },
                  )),
            ),
      );
    } else {
      return const SizedBox();
    }
  }
}
