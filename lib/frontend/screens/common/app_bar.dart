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

  Color contentColor = Colors.white;
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    Widget appBarContent = const SizedBox();
    if(!backButton){
      appBarContent = dateThumbNail();
    }


    return AppBar(
        backgroundColor:MAIN_COLOR.withOpacity(0.95),
        elevation: 2,
        title: 
        Row(children: <Widget>[
          LogoAndTitle(
            size: 7,
            color:contentColor,
            isLogoWhite: true,
          ),
          const Spacer(),
          appBarContent,
          const Spacer(),
          InkWell(
            child: Icon(Icons.notifications_outlined, color:contentColor),
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage(initIndex:1)),
              );
            },
          ),
          popupMenuButton(contentColor)
        ]),
         leading: switchLeading(context),
          shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(32),
          ),
        ),
    );
  }

  Widget? switchLeading(context){
   if(backButton){
    return BackButton(color:contentColor);
   }else{
    return null;
   }
  }

  Widget dateThumbNail(){
    DateTime now = DateTime.now();
    String todayText = DateFormat("MM/dd").format(now);
    String todayWeekday = DateFormat("EEE.").format(now);
    return Container(
      width:SizeConfig.blockSizeHorizontal! *20,
      height:SizeConfig.blockSizeVertical! *6,
      decoration: BoxDecoration(
        color: BACKGROUND_COLOR,
        borderRadius:const BorderRadius.all(Radius.circular(7.5)),
        border: Border.all(color:PALE_MAIN_COLOR,width: 3.5),
      ),
      child: Column(
       mainAxisAlignment: MainAxisAlignment.center,
       children:[
        Text(todayWeekday,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: SizeConfig.blockSizeHorizontal! *3
            )
        ),
        Text(todayText,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: SizeConfig.blockSizeHorizontal! *5
            )
        )
      ])
    );
  }

}

Widget popupMenuButton(color){
  return PopupMenuButton(

    icon:Icon(Icons.more_vert,color:color),
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
