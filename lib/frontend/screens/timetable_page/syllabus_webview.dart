import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/frontend/screens/moodle_view_page/moodle_view_page.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/services.dart' show rootBundle;

class SyllabusWebView extends StatefulWidget {
  String? pageID;
  SyllabusWebView({required this.pageID});

  @override
  _SyllabusWebViewState createState() => _SyllabusWebViewState();
}

class _SyllabusWebViewState extends State<SyllabusWebView> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    int _height = (SizeConfig.blockSizeVertical! * 100).round();
    String? pageID = widget.pageID;

    if (pageID != null && pageID != "") {
      return Column(children: [
        Container(
            width: SizeConfig.blockSizeHorizontal! * 100,
            height: SizeConfig.blockSizeVertical! * 75,
            decoration: BoxDecoration(border: Border.all()),
            child: SingleChildScrollView(
              child: Container(
                  width: SizeConfig.blockSizeHorizontal! * 100,
                  height: SizeConfig.blockSizeVertical! * _height,
                  child: InAppWebView(
                    key: webMoodleViewKey,
                    initialUrlRequest: URLRequest(
                        url: WebUri(
                            "https://www.wsl.waseda.jp/syllabus/JAA104.php?pKey=" +
                                pageID)),
                    onWebViewCreated: (controller) {
                      webMoodleViewController = controller;
                    },
                    onLoadStop: (a, b) async {
                      String javascriptCode = await rootBundle.loadString(
                          'lib/frontend/assist_files/scroll_controller.js');
                      await webMoodleViewController.evaluateJavascript(
                          source: javascriptCode);
                      _height =
                          await webMoodleViewController?.getContentHeight() ??
                              100;
                      setState(() {});
                    },
                    onContentSizeChanged: (a, b, c) async {
                      _height =
                          await webMoodleViewController?.getContentHeight() ??
                              100;
                      setState(() {});
                    },
                  )),
            )),
      ]);
    } else {
      return const SizedBox();
    }
  }
}
