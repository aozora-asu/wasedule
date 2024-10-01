import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  String loadingText = 'Loading';
  Timer? _timer;
  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (mounted) {
        setState(() {
          loadingText =
              (loadingText == 'Loading...') ? 'Loading' : '$loadingText.';
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:BACKGROUND_COLOR,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('lib/assets/eye_catch/eyecatch.png',
                height: 75, width: 75),
            const SizedBox(height: 20),
            Text(loadingText,
                style: const TextStyle(
                    fontSize: 25,
                    color: MAIN_COLOR,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}


class LoadingDialog extends StatefulWidget {
  @override
  _LoadingDialogState createState() => _LoadingDialogState();

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
        builder: (BuildContext context) {

          // NOTE: ↓Flutter v3.16.0~ Deprecated
          // 「Android実機の戻るボタン」を無効にする（NOTE: Flutter v3.16.0以前の実装方法）
          // return WillPopScope(
          //   onWillPop: () async => false,
          //   child: LoadingDialog()
          // );

          // 「Android実機の戻るボタン」を無効にする（NOTE: Flutter v3.16.0~）
          return PopScope(
              canPop: false,
              child: LoadingDialog(),
          );
      }
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}

class _LoadingDialogState extends State<LoadingDialog> {

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 150,
        height: 150,
        child: AlertDialog(
          // backgroundColor: Colors.green, // MEMO: 背景色の指定
          alignment: Alignment.center,
          contentPadding: EdgeInsets.zero,
          insetPadding: EdgeInsets.zero,
          content: _dialogContent(),
        ),
      ),
    );

  }

  // ダイアログ内に表示するWidget
  Widget _dialogContent() {
    return const SizedBox(
      child: Column(
        children: [
          Spacer(),
          CircularProgressIndicator(),
          Spacer(),
          Text('Loading...'),
          // Text('Loading...', style: TextStyle(fontSize: 18,fontWeight: FontWeight.w100),),
          Spacer(),
        ],
      ),
    );
  }
}