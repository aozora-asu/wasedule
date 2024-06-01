import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';


  Widget customBottomBar(
      BuildContext context,
      int currentIndex,
      ValueChanged<int> onItemTapped,
      StateSetter setosute
    ) {
    Color unSelectedColor = Colors.grey;
    Color selectedColor = Colors.white;
    SizeConfig().init(context);

    return Container(
      padding: const EdgeInsets.all(0),
      margin: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal! *0,
        vertical: SizeConfig.blockSizeVertical! *0
        ),
      decoration: BoxDecoration(
        border:const Border(top:BorderSide(color:PALE_MAIN_COLOR,width: 4.5)),
        color: MAIN_COLOR.withOpacity(0.95),
        borderRadius:const BorderRadius.all(Radius.circular(0)),
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
            icon: Icon(Icons.location_on),
            label: 'わせまっぷ',
            backgroundColor:Colors.transparent
          ),
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
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.group),
          //   label: 'フレンド',
          //   backgroundColor: MAIN_COLOR
          // ),
        ],
        selectedFontSize: 9, 
        unselectedFontSize:0,
      )
    );
  }

