import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/assist_files/ui_components.dart';
import 'package:flutter_calandar_app/frontend/screens/setting_page/support_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../assist_files/size_config.dart';
import '../setting_page/setting_page.dart';


class DrawerMenu extends ConsumerWidget {
  int currentParentIndex;
  int currentChildIndex;
  Function(int) changeParentIndex;
  Function(int) changeChildIndex;
  double drawerWidth = SizeConfig.blockSizeHorizontal! *75;

  DrawerMenu({
    required this.currentParentIndex,
    required this.currentChildIndex,
    required this.changeChildIndex,
    required this.changeParentIndex,
    super.key});


  @override
  Widget build(BuildContext context,WidgetRef ref) {
    return Drawer(
      width:drawerWidth,
      backgroundColor: BACKGROUND_COLOR,
      child: Column(children:[
          Container(
            width: drawerWidth,
            height: SizeConfig.blockSizeVertical! *15,
            decoration:const BoxDecoration(
              color: MAIN_COLOR,
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(children:[
                  Text(
                    '  MENU',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ])
              ],
            ),
          ),
          Container(
            height: SizeConfig.blockSizeVertical! *1,
            decoration:const BoxDecoration(
              color: PALE_MAIN_COLOR,
          )),
          Expanded(child:
        ListView(
          padding:EdgeInsets.zero,
          children: <Widget>[

          Padding(
            padding:const EdgeInsets.symmetric(horizontal:10),
          child: Column(children:[
              
              const SizedBox(height:20),

              index("カレンダー"),

              menuBackground(
                2,
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
                ])
              ),

              index("課題"),

              menuBackground(
                3,
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
                ])
              ),

              index("時間割"),

              menuBackground(
                1,
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
                ])
              ),

              index("Webページ"),

              menuBackground(
                4,
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
                  const Spacer(),
                  menuPanel(
                    null,
                    "",
                    4,10,context
                  ),
                  const Spacer(),
                ])
              ),

              index("わせまっぷ"),

              menuBackground(
                0,
                Row(children:[
                  const Spacer(),
                  menuPanel(
                    Icons.location_pin,
                    "わせまっぷ",
                    0,0,context
                  ),
                  const Spacer(),
                  menuPanel(
                    null,
                    "",
                    0,10,context
                  ),
                  const Spacer(),
                  menuPanel(
                    null,
                    "",
                    0,10,context
                  ),
                  const Spacer(),
                  menuPanel(
                    null,
                    "",
                    0,10,context
                  ),
                  const Spacer(),
                ])
              ),


              index("その他"),
              menuBackground(
                10,
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
              )
            ])
          )
          ],
        ),
       )
      ])
    );
  }

  Widget menuBackground(int parentindex,Widget child){
    return Container(
      decoration: roundedBoxdecoration(
        radiusType: 0,
        //backgroundColor: currentParentIndex == parentindex ? lighten(PALE_MAIN_COLOR,0.2) : null
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 3),
      margin: const EdgeInsets.symmetric(horizontal: 0,vertical: 2),
      child:child
    );
  }

  Widget menuPanel(
    IconData? icon,
    String title,
    int parentIndex,
    int childIndex,
    BuildContext context,
    ){
      bool isItemSelected = currentParentIndex == parentIndex && currentChildIndex == childIndex;
      bool isPageSelected = currentParentIndex == parentIndex;
      
      Color itemColor = MAIN_COLOR;
      if(isItemSelected){
        itemColor = Colors.white;
      }else if(isPageSelected){
        itemColor = MAIN_COLOR;
      }

    return GestureDetector(
        onTap: () {
          if(icon != null){
            Navigator.pop(context); 
            changeParentIndex(parentIndex);
            changeChildIndex(childIndex);
          }
        },
        child: Container(
          padding:const EdgeInsets.symmetric(horizontal:2,vertical:2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            color: isItemSelected ? lighten(PALE_MAIN_COLOR,0.2) : null,
            boxShadow: [
              isItemSelected ? 
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 1, 
                  blurRadius: 1,
                  offset:const  Offset(0, 2),
                )
              :
               const BoxShadow(color: Colors.transparent)
            ],
          ),
          child:Row(children: [
            Column(
              children:[
                Icon(
                  icon,
                  color: itemColor,
                  size: 30),
                Container(
                  constraints:const BoxConstraints(minWidth: 50),
                  child:Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: itemColor,
                    ),
                  )
                ),
              ]
            ),
          ])
        )
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
                Icon(
                  icon,
                  color: MAIN_COLOR,
                  size: 30),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.normal,
                    color:MAIN_COLOR
                  ),
                ),
              ]
            ),
          ])
      );
  }

  Widget index(String text){
    return Align(
      alignment: Alignment.centerLeft,
      child:Column(
        children:[
          const SizedBox(height:5),
          Row(children: [
            Image.asset("lib/assets/eye_catch/eyecatch.png",
              width: 20,height: 20,),
            const SizedBox(width: 5),
            Text(text,style:const TextStyle(color:Colors.grey,fontSize:15)),
          ])
      ])
    );
  }
}

