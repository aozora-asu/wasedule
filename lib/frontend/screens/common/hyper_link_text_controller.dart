import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

//TextField内のテキストで、urlにマッチする部分をハイパーリンクにするtextEditingControllerの拡張機能
class LinkedTextEditingController extends TextEditingController {
  final RegExp linkRegexp;

  static final RegExp _defaultRegExp = RegExp(
    r'https?://([\w-]+\.)+[\w-]+(/[\w-./?%&=#]*)?',
    caseSensitive: false,
    dotAll: true,
  );

  LinkedTextEditingController({
    String? text,
    RegExp? regexp,
  })  : linkRegexp = regexp ?? _defaultRegExp,
        super(text: text);

  @override
  TextSpan buildTextSpan(
      {BuildContext? context, TextStyle? style, bool? withComposing}) {
    List<TextSpan> children = [];
    text.splitMapJoin(
      linkRegexp,
      onMatch: (Match match) {
        final String matchText = match[0]!;
        children.add(
          TextSpan(
            text: "$matchText\n",
            style: TextStyle(
                color: Colors.blue, // 文字を青に設定
                decoration: TextDecoration.underline, // 下線をつける
                decorationColor: Colors.blue, // 下線の色を青に設定
                decorationThickness: 1.5, // 下線の太さを指定
                height: style?.height, // テキストの高さを調整
                fontSize: style?.fontSize,
                fontFamily: "Web-font"),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                showLinkActionSheet(context!, matchText);
              },
          ),
        );
        return "";
      },
      onNonMatch: (String span) {
        children.add(TextSpan(text: span, style: style));
        return "";
      },
    );
    return TextSpan(style: style, children: children);
  }
}

// タップ時のアクションを定義
void showLinkActionSheet(BuildContext context, String url) {
  showCupertinoModalPopup(
    context: context,
    builder: (BuildContext context) => CupertinoActionSheet(
      title: Text('Choose an action'),
      message: Text("selected url : $url"),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('Open Link'),
              SizedBox(width: 30),
              Icon(CupertinoIcons.compass, size: 30),
            ],
          ),
          onPressed: () async {
            final Uri uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
            Navigator.pop(context);
          },
        ),
        CupertinoActionSheetAction(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('Copy Link'),
              SizedBox(width: 30),
              Icon(CupertinoIcons.link, size: 30),
            ],
          ),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: url));
            Navigator.pop(context);
          },
        ),
        CupertinoActionSheetAction(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('Share...'),
              SizedBox(width: 40),
              Icon(CupertinoIcons.share, size: 30)
            ],
          ),
          onPressed: () {
            Share.share(url);
            Navigator.pop(context);
          },
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text('Cancel'),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    ),
  );
}
