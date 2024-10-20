import 'package:flutter_calandar_app/backend/DB/handler/task_db_handler.dart';
import 'package:flutter_calandar_app/backend/DB/handler/my_course_db.dart';

import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'dart:convert';
import '../../../backend/service/home_widget.dart';
import "../../../backend/service/request_calendar_url.dart";
import "../../../backend/DB/handler/user_info_db_handler.dart";
import "../../../backend/service/syllabus_query_result.dart";

void printWrapped(String text) {
  final pattern = RegExp('.{1,500}'); // 800 is the size of each chunk
  pattern.allMatches(text).forEach((match) => print(match.group(0)));
}

InAppWebView? webView; // InAppWebViewを保持する変数

class MoodleViewPage extends ConsumerStatefulWidget {
  const MoodleViewPage({super.key});

  @override
  _MoodleViewPageState createState() => _MoodleViewPageState();
}

final GlobalKey webMoodleViewKey = GlobalKey();
late InAppWebViewController webMoodleViewController;

class _MoodleViewPageState extends ConsumerState<MoodleViewPage> {
  final GlobalKey webViewKey = GlobalKey();
  late InAppWebViewController webViewController;
  double progress = 0;

  static const String moodleUrl = "https://wsdmoodle.waseda.jp/my/courses.php";
  static const String moodleLoginUrl =
      "https://wsdmoodle.waseda.jp/login/index.php";
  // static const String courseRegistrationUrl =
  //     "https://wcrs.waseda.jp/kyomu/epb1110.htm";
  static const String mywasedaUrl = "https://my.waseda.jp/login/login";
  // static const String mywasedaPortalUrl =
  //     "https://coursereg.waseda.jp/portal/simpleportal.php?HID_P14=JA";
  static const String mywasedaErrorUrl =
      "https://iaidp.ia.waseda.jp/idp/profile/Authn/SAML2/POST/SSO";
  // static const String microsoftLoginUrl =
  //     "https://login.microsoftonline.com/b3865172-9887-4b3a-89ff-95a35b92f4c3/saml2?SAMLRequest=hVJdb5wwEPwryO9gMAcH1nHRNaeqJ6XNKZA%2B9KVauCXnytjUa5L235fcR5W%2BpK%2F27MzOzK5ufg06eEZHypqKJVHMAjSdPSjzVLHH5mNYsJv1imDQYpSbyR%2FNA%2F6ckHwwDxqS55%2BKTc5IC6RIGhiQpO9kvfl8J0UUy9FZbzurWbAhQudnqVtraBrQ1eieVYePD3cVO3o%2FkuRcgTqMkYLoBQgPEP0Y%2BfzAZ5ZeaeSnJfgrueD7%2B7rhdX3Pgu28kjLgTzauTNo%2BKRMNqnOWbO%2Bt0cpg1NmBt2mRZ8lShGVRLMNFm0JYlH0flhmkWVuKftGl%2FOSNBbttxb6LZQJ9mS%2FaJEvEIRVpBiAgzxGhLESLM4xowp0hD8ZXTMRiEcZZGIsmiWWWyCyPyrz4xoL9JY0PypxTfi%2B69gwi%2Balp9uGrXRZ8vbY1A9ilG3lSd29LeZ8Yrk2w9X9yp6NqW6vRH1f8rdbfq%2Fgyk%2B%2B2e6tV9zvYaG1fbh2Cx4p5NyHj68vcv%2Fez%2FgM%3D&RelayState=e2s1";
  String initUrl = moodleUrl;
  String cookies = "";
  String sessionKey = "";
  bool isAllowAutoLogin = true;
  late Future<Map<String, dynamic>> autoLoginInfo;

  @override
  void initState() {
    super.initState();
    autoLoginInfo = checkSession();
  }

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
            thirdPartyCookiesEnabled: true,
            sharedCookiesEnabled: true,
            useShouldOverrideUrlLoading: true),
        onConsoleMessage: (controller, consoleMessage) async {
          try {
            messageData = jsonDecode(consoleMessage.message);
            switch (messageData.keys.first) {
              case "completedTask":
              case "isAllowAutoLogin":
                isAllowAutoLogin = messageData["isAllowAutoLogin"];
                await acceptAutoLogin(isAllowAutoLogin);
              case "myCourseData":
                for (var myCourseData in messageData["myCourseData"] as List) {
                  List<MyCourse>? myCourseList = await getMyCourse(MoodleCourse(
                      color: myCourseData["color"],
                      courseName: myCourseData["courseName"],
                      pageID: myCourseData["pageID"],
                      department: myCourseData["department"]));

                  if (myCourseList != null) {
                    for (var myCourse in myCourseList) {
                      await myCourse.resisterDB();
                    }

                    await TaskDatabaseHelper().setpageID();
                    // await NextCourseHomeWidget().updateNextCourse();
                  }
                }
                javascriptCode = await rootBundle.loadString(
                    'lib/backend/service/js/hide_loading_screen.js');
                await webViewController.evaluateJavascript(
                    source: javascriptCode);
              case "calendarUrl":
                await UserDatabaseHelper()
                    .resisterUserInfo(messageData["calendarUrl"]);
            }
          } catch (e) {
            print(e);
            //printWrapped(consoleMessage.message);
          }
        },
        initialUrlRequest: URLRequest(url: WebUri(initUrl)),
        onWebViewCreated: (controller) {
          webViewController = controller;
        },
        shouldOverrideUrlLoading: (controller, action) async {
          return NavigationActionPolicy.ALLOW;
        },
        onLoadStop: (controller, currentUrl) async {
          switch (currentUrl.toString()) {
            case moodleUrl:
              javascriptCode = await rootBundle
                  .loadString('lib/backend/service/js/get_course_button.js');
              await webViewController.evaluateJavascript(
                  source: javascriptCode);
            // case moodleLoginUrl:
            //   javascriptCode = await rootBundle.loadString(
            //       'lib/frontend/screens/moodle_view_page/auto_login_checkbox.js');
            //   await webViewController.evaluateJavascript(
            //       source: javascriptCode);

            case mywasedaErrorUrl:
              webViewController.loadUrl(
                urlRequest: URLRequest(url: WebUri(mywasedaUrl)),
              );
          }
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
