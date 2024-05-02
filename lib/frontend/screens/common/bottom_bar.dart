import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';


  Widget customBottomBar(
      BuildContext context,
      int currentIndex,
      ValueChanged<int> onItemTapped,
      StateSetter setosute
    ) {
    Color unSelectedColor = MAIN_COLOR;
    Color selectedColor = Colors.blueAccent;
    SizeConfig().init(context);

    return Container(
      padding: const EdgeInsets.all(0),
      margin: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal! *3,
        vertical: SizeConfig.blockSizeVertical! *1.5
        ),
      decoration:const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(25)),
        boxShadow:[BoxShadow(blurRadius:2,)]
        ),
      child:BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onItemTapped,
        backgroundColor:Colors.transparent,
        elevation: 0,
        selectedItemColor: selectedColor,
        unselectedItemColor: unSelectedColor,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_on),
            label: '授業',
            backgroundColor:Colors.transparent
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'カレンダー',
            backgroundColor:Colors.transparent
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check),
            label: '課題',
            backgroundColor:Colors.transparent
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Moodle',
            backgroundColor:Colors.transparent
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: '学習管理',
            backgroundColor:Colors.transparent
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.group),
          //   label: 'フレンド',
          //   backgroundColor: MAIN_COLOR
          // ),
        ],
        selectedFontSize: 17.0, 
        unselectedFontSize: 12.0,
      )
    );
  }

