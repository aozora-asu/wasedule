import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_calandar_app/frontend/colors.dart';


class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  String loadingText = 'Loading';

  @override
  void initState() {
    super.initState();

    // インターバルごとにloadingTextを更新
    Timer.periodic(Duration(milliseconds: 200), (timer) {
      setState(() {
        loadingText = (loadingText == 'Loading...') ? 'Loading' : '${loadingText}.';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('lib/assets/eye_catch/eyecatch.png', height: 75, width: 75), 
            SizedBox(height: 20),
            Text(loadingText, 
            style: TextStyle(
             fontSize: 25,
             color:MAIN_COLOR,
             fontWeight:FontWeight.w700
             )
            ),
          ],
        ),
      ),
    );
  }
}