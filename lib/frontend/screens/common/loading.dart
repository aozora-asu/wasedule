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
