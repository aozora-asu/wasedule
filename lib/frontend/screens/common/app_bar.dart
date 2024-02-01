import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'burger_menu.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  const CustomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MAIN_COLOR,
        elevation: 3,
        title: const 
        Column(
          children: <Widget>[
            Text(
              'わせジュール',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color:Colors.white
              ),
            ),
            Text(
              '早稲田生のためのスケジュールアプリ',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color:Colors.white
              ),
            ),
          ],
        ),
         leading: IconButton(
          icon: const Icon(Icons.menu,color:Colors.white),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
    );
  }
}
