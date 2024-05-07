import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;

CookieManager cookieManager = CookieManager.instance();
List<Cookie> cookieList = [];

Future<List<Cookie>> getCookies(WebUri url, CookieManager cookieManager) async {
  List<Cookie> cookies = await cookieManager.getCookies(url: url);
  return cookies;
}

Future<URLRequest> loginRequest(
    String loginPageUrl, String afterLoginPageUrl) async {
  // Cookieを文字列に変換
  String cookieString =
      cookieList.map((cookie) => '${cookie.name}=${cookie.value}').join('; ');
  // HTTPリクエストにCookieを含める
  Map<String, String> headers = {'Cookie': cookieString};
  final response = await http.get(Uri.parse(loginPageUrl), headers: headers);
  if (response.statusCode == 200) {
    print("cookieでログインします");

    return URLRequest(url: WebUri(afterLoginPageUrl), headers: headers);
  } else {
    print("ログインしてください");
    return URLRequest(url: WebUri(loginPageUrl));
  }
}
