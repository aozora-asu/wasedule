import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/colors.dart';

class CustomBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemTapped;
  const CustomBottomBar(
      {Key? key, required this.currentIndex, required this.onItemTapped})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onItemTapped,
      backgroundColor: MAIN_COLOR,
      selectedItemColor: ACCENT_COLOR,
      unselectedItemColor: Colors.white,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'カレンダー',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.splitscreen),
          label: 'タスク',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group),
          label: 'フレンド',
        ),
      ],
    );
  }
}