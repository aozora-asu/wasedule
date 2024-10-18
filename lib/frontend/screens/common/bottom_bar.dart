import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';


  Widget customBottomBar(
      BuildContext context,
      int currentIndex,
      ValueChanged<int> onItemTapped,
      StateSetter setosute,
      [Color unSelectedColor = Colors.grey]
    ) {
    Color selectedColor = BLUEGREY;
    SizeConfig().init(context);

    return Container(
      padding: const EdgeInsets.all(0),
      margin: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal! *0,
        vertical: SizeConfig.blockSizeVertical! *0
        ),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 2,
            spreadRadius: 2,
            offset: const Offset(0, -1)
          )
        ],
        border:const Border(top:BorderSide(color:Colors.white,width: 0.75)),
        color: FORGROUND_COLOR,
        borderRadius:const BorderRadius.all(Radius.circular(0)),
      ),
      child:Theme(
        data: ThemeData(
          splashColor: Colors.transparent,
        ),
      child:BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onItemTapped,
        backgroundColor:Colors.transparent,
        elevation: 0,
        showUnselectedLabels: true,
        showSelectedLabels: true,
        selectedItemColor: selectedColor,
        unselectedItemColor: unSelectedColor,
        selectedLabelStyle: TextStyle(color: selectedColor,fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(color: unSelectedColor),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.map_pin),
            label: 'わせまっぷ',
            backgroundColor:Colors.transparent
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.rectangle_grid_3x2),
            label: '授業',
            backgroundColor:Colors.transparent
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.calendar),
            label: 'カレンダー',
            backgroundColor:Colors.transparent
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.check_mark),
            label: '課題',
            backgroundColor:Colors.transparent
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.globe),
            label: 'Web',
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
     )
    );
  }

