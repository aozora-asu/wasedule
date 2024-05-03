import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../common/loading.dart';

InAppWebView? webView; // InAppWebViewを保持する変数


class MoodleViewPage extends ConsumerStatefulWidget {
  @override
  _MoodleViewPageState createState() => _MoodleViewPageState();
}

final GlobalKey webMoodleViewKey = GlobalKey();
late InAppWebViewController webMoodleViewController;

class _MoodleViewPageState extends ConsumerState<MoodleViewPage> {
  final GlobalKey webViewKey = GlobalKey();
  late InAppWebViewController webViewController;
  double progress = 0;
  CookieManager cookieManager = CookieManager.instance();
  List<Cookie> cookieList = [];
  static const String moodleUrl = "https://wsdmoodle.waseda.jp/my/";
  static const String moodleLoginUrl =
      "https://wsdmoodle.waseda.jp/login/index.php";
  Future<List<Cookie>> getCookies(
      WebUri url, CookieManager cookieManager) async {
    List<Cookie> cookies = await cookieManager.getCookies(url: url);
    return cookies;
  }

  Future<URLRequest> loginRequest() async {
    // Cookieを文字列に変換
    String cookieString =
        cookieList.map((cookie) => '${cookie.name}=${cookie.value}').join('; ');
    // HTTPリクエストにCookieを含める
    Map<String, String> headers = {'Cookie': cookieString};
    final response =
        await http.post(Uri.parse(moodleLoginUrl), headers: headers);
    if (response.statusCode == 200) {
      print("cookieでログインします");
      print(response.body);
      return URLRequest(url: WebUri(moodleUrl), headers: headers);
    } else {
      print("ログインしてください");
      return URLRequest(url: WebUri(moodleLoginUrl));
    }
  }

  late Future<URLRequest>? _initialUrlRequest;

  @override
  void initState() {
    super.initState();
    _initialUrlRequest = loginRequest();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    // Cookieを文字列に変換
    String cookieString =
        cookieList.map((cookie) => '${cookie.name}=${cookie.value}').join('; ');
    // HTTPリクエストにCookieを含める
    Map<String, String> headers = {'Cookie': cookieString};
    return Scaffold(
        body: Column(children: [
      progress < 1.0
          ? LinearProgressIndicator(value: progress)
          : const SizedBox.shrink(),
      Expanded(
          child: FutureBuilder<URLRequest?>(
        future: _initialUrlRequest,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingScreen(); // もしくはローディング用のウィジェット
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData) {
            return InAppWebView(
              key: webViewKey,
              initialSettings: InAppWebViewSettings(
                thirdPartyCookiesEnabled: true,
                sharedCookiesEnabled: true,
              ),
              onConsoleMessage: (controller, consoleMessage) {
                // print(consoleMessage);
                try {
                  Map<String, dynamic> messageData =
                      jsonDecode(consoleMessage.message);

                  switch (messageData.keys.first) {
                    case "isAllowAutoLogin":
                      print(messageData["isAllowAutoLogin"]);
                  }
                } catch (e) {}
              },
              initialUrlRequest: snapshot.data,
              onWebViewCreated: (controller) {
                webViewController = controller;
                webViewController.loadUrl(
                  urlRequest:
                      URLRequest(url: WebUri(moodleUrl), headers: headers),
                );
              },
              onLoadStop: (controller, currentUrl) async {
                // JavaScriptファイルの内容を読み込んで実行
                print("現在のページのURL:$currentUrl");
                if (currentUrl.toString() ==
                    "https://iaidp.ia.waseda.jp/idp/profile/Authn/SAML2/POST/SSO") {
                  webViewController.loadUrl(
                    urlRequest: URLRequest(
                        url: WebUri("https://my.waseda.jp/login/login")),
                  );
                }
                if (currentUrl.toString() == moodleLoginUrl) {
                  String javascriptCode = await rootBundle.loadString(
                      'lib/frontend/screens/moodle_view_page/auto_login_checkbox.js');
                  await webViewController.evaluateJavascript(
                      source: javascriptCode);
                }
                if (currentUrl.toString() ==
                    "https://login.microsoftonline.com/b3865172-9887-4b3a-89ff-95a35b92f4c3/saml2?SAMLRequest=hVJdb5wwEPwryO9gMAcH1nHRNaeqJ6XNKZA%2B9KVauCXnytjUa5L235fcR5W%2BpK%2F27MzOzK5ufg06eEZHypqKJVHMAjSdPSjzVLHH5mNYsJv1imDQYpSbyR%2FNA%2F6ckHwwDxqS55%2BKTc5IC6RIGhiQpO9kvfl8J0UUy9FZbzurWbAhQudnqVtraBrQ1eieVYePD3cVO3o%2FkuRcgTqMkYLoBQgPEP0Y%2BfzAZ5ZeaeSnJfgrueD7%2B7rhdX3Pgu28kjLgTzauTNo%2BKRMNqnOWbO%2Bt0cpg1NmBt2mRZ8lShGVRLMNFm0JYlH0flhmkWVuKftGl%2FOSNBbttxb6LZQJ9mS%2FaJEvEIRVpBiAgzxGhLESLM4xowp0hD8ZXTMRiEcZZGIsmiWWWyCyPyrz4xoL9JY0PypxTfi%2B69gwi%2Balp9uGrXRZ8vbY1A9ilG3lSd29LeZ8Yrk2w9X9yp6NqW6vRH1f8rdbfq%2Fgyk%2B%2B2e6tV9zvYaG1fbh2Cx4p5NyHj68vcv%2Fez%2FgM%3D&RelayState=e2s1") {
                  String javascriptCode = await rootBundle.loadString(
                      'lib/frontend/screens/moodle_view_page/auto_login_checkbox.js');
                  await webViewController.evaluateJavascript(
                      source: javascriptCode);
                }

                if (currentUrl.toString() == moodleUrl) {
                  cookieList = await getCookies(
                    currentUrl!,
                    cookieManager,
                  );

                  //print(cookies);
                }
              },
            );
          } else {
            return const Text('No data available'); // データがない場合の表示
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
          final url = URLRequest(
              url: WebUri(
                  "https://coursereg.waseda.jp/portal/simpleportal.php?HID_P14=JA"));
          webViewController.loadUrl(urlRequest: url);
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
