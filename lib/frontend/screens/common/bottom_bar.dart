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
        //border:const Border(top:BorderSide(color:PALE_MAIN_COLOR,width: 4.5)),
        color: FORGROUND_COLOR,
        borderRadius:const BorderRadius.all(Radius.circular(0)),
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
            icon: Icon(Icons.language),
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
    );
  }

