import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/screens/menu_pages/arbeit_stats_page.dart';
import 'package:flutter_calandar_app/frontend/screens/menu_pages/how_to_use_page.dart';
import 'package:flutter_calandar_app/frontend/screens/menu_pages/sns_contents_page/sns_contents_page.dart';
import 'package:flutter_calandar_app/frontend/screens/menu_pages/sns_link_page.dart';
import 'package:intl/intl.dart';
import 'app_bar.dart';
import '../../assist_files/size_config.dart';
import '../menu_pages/setting_page.dart';
import '../menu_pages/url_register_page.dart';

class burgerMenu extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            height: SizeConfig.blockSizeHorizontal! *30, // 高さを設定
            decoration:const BoxDecoration(
              color: ACCENT_COLOR,
            ),
            child: const Column(
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

          menuPanel(
            Icons.settings,
            "設定",
            MaterialPageRoute(builder: (context) => SettingsPage()),
            context
          ),

          menuPanel(
            Icons.school,
            "使い方ガイド",
            MaterialPageRoute(builder: (context) => HowToUsePage()),
            context
          ),

          menuPanel(
            Icons.add_link,
            "Moodle URLの登録",
            MaterialPageRoute(builder: (context) => UrlRegisterPage()),
            context
          ),

          menuPanel(
            Icons.currency_yen_rounded,
            "アルバイト",
            MaterialPageRoute(builder: (context) => ArbeitStatsPage(targetMonth:DateFormat('yyyy/MM').format(DateTime.now()))),
            context
          ),

          menuPanel(
            Icons.ios_share,
            "SNS共有コンテンツ",
            MaterialPageRoute(builder: (context) => SnsContentsPage()),
            context
          ),

          menuPanel(
            Icons.info_rounded,
            "サポート",
            MaterialPageRoute(builder: (context) => SnsLinkPage()),
            context
          ),

        ],
      ),
    );
  }

  Widget menuPanel(IconData icon, String title, MaterialPageRoute ontap, BuildContext context){
    return ListTile(
            leading: Icon(icon, color: MAIN_COLOR,),
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 22.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            onTap: () {
              Navigator.pop(context); 
              Navigator.push(
                context,ontap
              );
            },
          );
  }
}

