import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/colors.dart';
import 'app_bar.dart';
import "../../../size_config.dart";
import '../../pages/setting_page.dart';

class burgerMenu extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            height: SizeConfig.blockSizeHorizontal! *30, // 高さを設定
            decoration: BoxDecoration(
              color: ACCENT_COLOR,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'MENU',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.settings,
              color: MAIN_COLOR,
            ),
            title: Text(
              "設定",
              style: TextStyle(
                fontSize: 22.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            onTap: () {
              Navigator.pop(context); 
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.school,
              color: MAIN_COLOR,
            ),
            title: Text(
              "使い方ガイド",
              style: TextStyle(
                fontSize: 22.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

