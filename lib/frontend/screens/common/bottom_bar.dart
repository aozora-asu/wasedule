import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';


  Widget customBottomBar(
      int currentIndex,
      ValueChanged<int> onItemTapped,
      StateSetter setosute
    ) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onItemTapped,
      backgroundColor:MAIN_COLOR,
      selectedItemColor: WIDGET_COLOR,
      unselectedItemColor:WIDGET_COLOR,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.grid_on),
          label: '授業',
          backgroundColor: MAIN_COLOR
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'カレンダー',
          backgroundColor: MAIN_COLOR
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.check),
          label: '課題',
          backgroundColor: MAIN_COLOR
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.school),
          label: 'Moodle',
          backgroundColor: MAIN_COLOR
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.edit),
          label: '学習管理',
          backgroundColor: MAIN_COLOR
        ),
        // BottomNavigationBarItem(
        //   icon: Icon(Icons.group),
        //   label: 'フレンド',
        //   backgroundColor: MAIN_COLOR
        // ),
      ],
      selectedFontSize: 17.0, 
      unselectedFontSize: 12.0,
    );
  }

