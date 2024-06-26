import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../task_page/task_data_manager.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import '../../assist_files/screen_manager.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: "Noto_Sans_JP",
        canvasColor: WHITE,
      ),
      debugShowCheckedModeBanner: false,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1)),
          child: child!,
        );
      },
      // localizationsDelegates: [
      //   GlobalMaterialLocalizations.delegate,
      //   GlobalWidgetsLocalizations.delegate,],
      // supportedLocales: [const Locale('en'),],
      // locale: const Locale('en'),
      home: const FadingImage());
  }
}

class FadingImage extends ConsumerStatefulWidget {
  const FadingImage({super.key});

  @override
  _FadingImageState createState() => _FadingImageState();
}

class _FadingImageState extends ConsumerState<FadingImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<Offset> _imageAnimation;
  String loadingText = 'Loading';

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 10),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _imageAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.35), end: Offset.zero).animate(
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
          MaterialPageRoute(builder: (context) => AppPage()),
        );
      });
    });

    // インターバルごとにloadingTextを更新

    Timer.periodic(const Duration(milliseconds: 5), (timer) {
      if (!mounted) {
        // Check if the widget is still part of the tree
        timer
            .cancel(); // Cancel the timer if the widget is no longer in the tree
        return;
      }

      setState(() {
        loadingText =
            (loadingText == 'Loading...') ? 'Loading' : '$loadingText.';
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> load() async {
    await Future.delayed(const Duration(seconds: 0));
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(taskDataProvider.notifier);
    ref.watch(taskDataProvider);
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
            const SizedBox(height: 30),
            SizedBox(
              width: 200,
              height: 5,
              child: LinearProgressIndicator(
                color: PALE_MAIN_COLOR,
                backgroundColor: Colors.pink[50],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              loadingText,
              style: const TextStyle(
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
