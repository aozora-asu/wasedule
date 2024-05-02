import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/tag_and_template_page.dart';
import 'package:flutter_calandar_app/frontend/screens/common/logo_and_title.dart';
import 'package:flutter_calandar_app/frontend/screens/menu_pages/arbeit_stats_page.dart';
import 'package:flutter_calandar_app/frontend/screens/menu_pages/how_to_use_page.dart';
import 'package:flutter_calandar_app/frontend/screens/menu_pages/setting_page.dart';
import 'package:flutter_calandar_app/frontend/screens/menu_pages/sns_link_page.dart';
import 'package:flutter_calandar_app/frontend/screens/menu_pages/url_register_page.dart';
import 'package:intl/intl.dart';


class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  late bool backButton;

  CustomAppBar({
    required this.backButton,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MAIN_COLOR,
        elevation: 3,
        title: 
        Row(children: <Widget>[
          LogoAndTitle(
            size: 7,
            color:Colors.white,
            isLogoWhite: true,
          ),
          const Spacer(),
          InkWell(
            child: const Icon(Icons.notifications_outlined,color:Colors.white),
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage(initIndex:1)),
              );
            },
          ),
          popupMenuButton()
        ]),
         leading: switchLeading(context)
      ),
    );
  }

  Widget? switchLeading(context){
   if(backButton){
    return const BackButton(color:Colors.white);
   }else{
    return null;
   }
  }
}

Widget popupMenuButton(){
  return PopupMenuButton(

    icon:const Icon(Icons.more_vert,color:Colors.white),
    itemBuilder: (BuildContext context) => <PopupMenuEntry>[
      PopupMenuItem(
        child: ListTile(
          leading:const Icon(Icons.add_link,color:MAIN_COLOR),
          title :const Text('Moodle URLの登録'),
          onTap:(){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UrlRegisterPage())
            );
          }
        )
      ),
      PopupMenuItem(
        child: ListTile(
          leading:const Icon(Icons.school,color:MAIN_COLOR),
          title :const Text('使い方ガイド'),
          onTap:(){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HowToUsePage()));
          }
        )
      ),
      PopupMenuItem(
        child: ListTile(
          leading:const Icon(Icons.tag,color:MAIN_COLOR),
          title :const Text('タグとテンプレート'),
          onTap:(){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TagAndTemplatePage()));
          }
        )
      ),
      PopupMenuItem(
        child: ListTile(
          leading:const Icon(Icons.currency_yen_rounded,color:MAIN_COLOR),
          title :const Text('アルバイト'),
          onTap:(){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ArbeitStatsPage(targetMonth:DateFormat('yyyy/MM').format(DateTime.now()))));
          }
        )
      ),
      PopupMenuItem(
        child: ListTile(
          leading:const Icon(Icons.info_rounded,color:MAIN_COLOR),
          title :const Text('サポート'),
          onTap:(){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SnsLinkPage()));
          }
        )
      ),
      const PopupMenuDivider(),
      PopupMenuItem(
        child: ListTile(
          leading:const Icon(Icons.settings,color:MAIN_COLOR),
          title :const Text('設定'),
          onTap:(){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsPage()));
          }
        )
      ),
    ],
  );
}
