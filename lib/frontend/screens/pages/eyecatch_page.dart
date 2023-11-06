import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_calandar_app/frontend/colors.dart';
import '../../screen_manager.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FadingImage(),
    );
  }
}

class FadingImage extends StatefulWidget {
  @override
  _FadingImageState createState() => _FadingImageState();
}

class _FadingImageState extends State<FadingImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<Offset> _imageAnimation;
  String loadingText = 'Loading';

  @override
  void initState() {
    super.initState();
    late Timer _timer;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _imageAnimation =
        Tween<Offset>(begin: Offset(0.0, 0.35), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward().whenComplete(() {
      // アニメーション完了後に遷移
      load().then((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FirstPage()),
        );
      });
    });

    // インターバルごとにloadingTextを更新
    _timer = Timer.periodic(Duration(milliseconds: 200), (timer) {
      if (!mounted) {
        // Check if the widget is still part of the tree
        timer
            .cancel(); // Cancel the timer if the widget is no longer in the tree
        return;
      }

      setState(() {
        loadingText =
            (loadingText == 'Loading...') ? 'Loading' : '${loadingText}.';
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> load() async {
    await Future.delayed(Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MAIN_COLOR,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SlideTransition(
              position: _imageAnimation,
              child: FadeTransition(
                opacity: _animation,
                child: Image.asset(
                  'lib/assets/eye_catch/eyecatch_white.png',
                  height: 200,
                  width: 200,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "わせジュール",
              style: TextStyle(
                fontSize: 25,
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 20),
            Text(
              loadingText,
              style: TextStyle(
                fontSize: 25,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
