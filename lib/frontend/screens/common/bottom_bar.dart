import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';

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
      backgroundColor:MAIN_COLOR,
      selectedItemColor: WIDGET_COLOR,
      unselectedItemColor:WIDGET_COLOR,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'カレンダー',
          backgroundColor: MAIN_COLOR
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.splitscreen),
          label: 'タスク',
          backgroundColor: MAIN_COLOR
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.task_outlined),
          label: '学習管理',
          backgroundColor: MAIN_COLOR
        ),
        // BottomNavigationBarItem(
        //   icon: Icon(Icons.group),
        //   label: 'フレンド',
        //   backgroundColor: MAIN_COLOR
        // ),
      ],
        selectedFontSize: 17.0, // 選択されたアイテムのテキストサイズ
  unselectedFontSize: 12.0, // 選択されていないアイテムのテキストサイズ
    );
  }
}
