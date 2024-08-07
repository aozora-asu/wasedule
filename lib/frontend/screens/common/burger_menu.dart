import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/calendar_page.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/tag_and_template_page.dart';
import 'package:flutter_calandar_app/frontend/screens/menu_pages/arbeit_stats_page.dart';
import 'package:flutter_calandar_app/frontend/screens/menu_pages/how_to_use_page.dart';
import 'package:flutter_calandar_app/frontend/screens/setting_page/support_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../assist_files/size_config.dart';
import '../setting_page/setting_page.dart';


class DrawerMenu extends ConsumerWidget {
  Function(int) changeParentIndex;
  Function(int) changeChildIndex;

  DrawerMenu({
    required this.changeChildIndex,
    required this.changeParentIndex,
    super.key});


  @override
  Widget build(BuildContext context,WidgetRef ref) {
    return Drawer(
      width:SizeConfig.blockSizeHorizontal! *70,
      backgroundColor: BACKGROUND_COLOR,
      child: ListView(
        padding:EdgeInsets.zero,
        children: <Widget>[
          Container(
            height: SizeConfig.blockSizeVertical! *15,
            decoration:const BoxDecoration(
              color: MAIN_COLOR,
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
          Container(
            height: SizeConfig.blockSizeVertical! *1,
            decoration:const BoxDecoration(
              color: PALE_MAIN_COLOR,
          )),


        Padding(
          padding:const EdgeInsets.symmetric(horizontal:10),
        child: Column(children:[

            index("カレンダー"),

            Row(children:[
              const Spacer(),
              menuPanel(
                Icons.calendar_month,
                "予定",
                2,0,context
              ),
              const Spacer(),
              menuPanel(
                Icons.group,
                "シェア",
                2,1,context
              ),
              const Spacer(),
              menuPanel(
                Icons.school,
                "大学暦",
                2,2,context
              ),
              const Spacer(),
              menuPanel(
                Icons.currency_yen_rounded,
                "バイト",
                2,3,context
              ),
              const Spacer(),
            ]),

            index("課題"),


            Row(children:[
              const Spacer(),
              menuPanel(
                Icons.done,
                "課題",
                3,0,context
              ),
              const Spacer(),
              menuPanel(
                Icons.close,
                "期限切れ",
                3,1,context
              ),
              const Spacer(),
              menuPanel(
                Icons.delete,
                "削除済み",
                3,2,context
              ),
              const Spacer(),
              menuPanel(
                Icons.edit,
                "学習記録",
                3,3,context
              ),
              const Spacer(),
            ]),

            index("時間割"),

            Row(children:[
              const Spacer(),
              menuPanel(
                Icons.grid_on_rounded,
                "時間割",
                1,0,context
              ),
              const Spacer(),
              menuPanel(
                Icons.search_rounded,
                "シラバス",
                1,1,context
              ),
              const Spacer(),
              menuPanel(
                Icons.abc_rounded,
                "単位",
                1,2,context
              ),
              const Spacer(),
              menuPanel(
                Icons.cut_rounded,
                "出欠",
                1,3,context
              ),
              const Spacer(),
            ]),

            index("わせまっぷ"),

            menuPanel(
              Icons.location_pin,
              "わせまっぷ",
              0,0,context
            ),

            index("Webページ"),

            Row(children:[
              const Spacer(),
              menuPanel(
                Icons.school,
                "Moodle",
                4,0,context
              ),
              const Spacer(),
              menuPanel(
                Icons.school,
                "MyWaseda",
                4,1,context
              ),
              const Spacer(),
              menuPanel(
                Icons.abc_rounded,
                "成績照会",
                4,2,context
              ),
            ]),

            index("その他"),
            
            Row(children:[
              const Spacer(),
              navigatorMenuPanel(
                Icons.settings,
                "設定",
                SettingsPage(isAppBar: true,),
                context
              ),
              const Spacer(),
              navigatorMenuPanel(
                Icons.info,
                "サポート",
                SnsLinkPage(showAppBar: true),
                context
              ),
              const Spacer(),
            ])
          ])
        )
        ],
      ),
    );
  }

  Widget menuPanel(
    IconData icon,
    String title,
    int parentIndex,
    int childIndex,
    BuildContext context){
    return GestureDetector(
        onTap: () {
          Navigator.pop(context); 
          changeParentIndex(parentIndex);
          changeChildIndex(childIndex);
        },
        child: Row(children: [
            Column(
              children:[
                Icon(icon, color: MAIN_COLOR,size: 40),
                  Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ]
            ),
          ])
      );
  }

  Widget navigatorMenuPanel(
    IconData icon,
    String title,
    Widget page,
    BuildContext context){
    return GestureDetector(
        onTap: () {
          Navigator.pop(context); 
          Navigator.push(context,
            MaterialPageRoute(
              builder: (context) => page
            )
          );
        },
        child: Row(children: [
            Column(
              children:[
                Icon(icon, color: MAIN_COLOR,size: 40),
                  Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ]
            ),
          ])
      );
  }

  Widget index(String text){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:[
        const SizedBox(height:7),
        Text(" " + text,style:TextStyle(color:Colors.grey,fontSize:20)),
        const Divider(color:Colors.grey,height: 2,),
        const SizedBox(height:5),
    ]);
  }
}

