import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/frontend/assist_files/ui_components.dart';
import 'package:flutter_calandar_app/frontend/screens/common/logo_and_title.dart';
import 'package:flutter_calandar_app/frontend/screens/menu_pages/setting_page.dart';
import 'package:flutter_calandar_app/frontend/screens/menu_pages/support_page.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/task_data_manager.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/task_view_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

 int type = 0;

class MenuAppBar extends ConsumerWidget implements PreferredSizeWidget{
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  late int currentIndex;
  late ValueChanged<int> onItemTapped;
  late int currentSubIndex;
  late ValueChanged<int> onTabTapped;
  late bool isChildmenuExpand;
  late Function changeChildmenuState; 
  late StateSetter setosute;

  MenuAppBar({
    required this.currentIndex,
    required this.onItemTapped,
    required this.currentSubIndex,
    required this.onTabTapped,
    required this.setosute,
    required this.isChildmenuExpand,
    required this.changeChildmenuState,
    super.key
  });


    Color contentColor = FORGROUND_COLOR;
    Color backgroundColor = Colors.transparent;
    bool isLogoWhite =true;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int pageNum = currentIndex;
    
    if(pageNum == 0 ||
       pageNum == 3 ||
       pageNum == 4){
        contentColor = BLACK;
        backgroundColor = Colors.transparent;
        isLogoWhite = false;
    }
      SizeConfig().init(context);
    Color itemColor = Colors.white;

    return AppBar(
        backgroundColor: MAIN_COLOR.withOpacity(0.95),
        elevation: 2,
        surfaceTintColor: Colors.transparent,
        title: SizedBox(
          height:45,
          child:Row(children: <Widget>[
            GestureDetector(
              onTap:(){
                if(Platform.isIOS){
                  showFeedBackDialog(context);
                }
              },
              child:LogoAndTitle(
                size: 7,
                color:itemColor ,
                isLogoWhite:true,
                subTitle: "早稲田から、落単をなくしたい。",
              )
            ),
            const Spacer(),
            InkWell(
              child: const Icon(Icons.notifications_outlined, color:Colors.white),
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage(initIndex:1)),
                );
              },
            ),
            popupMenuButton(Colors.white)
           ])
          ),
          shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(0),
          ),
        ),
        bottom: PreferredSize(
          preferredSize:const Size.fromHeight(5),
          child: SizedBox(
            height: 35,
            child: subMenuList(ref),
          ),
        )
    );
  }

  Widget subMenuList(ref){
    Widget space = 
      SizedBox(width: SizeConfig.blockSizeHorizontal! *0);

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      shrinkWrap: false,
      itemBuilder: (context, index) {
        return returnSubPage(ref)[currentIndex]!.elementAt(index);
      },
      itemCount: returnSubPage(ref)[currentIndex]!.length,
    );
  }

  Widget subMenuPanel(
    WidgetRef ref,
    {Color color1 = PALE_MAIN_COLOR,
     Color color2 = PALE_MAIN_COLOR,
     IconData icon = Icons.abc,
     int subIndex = 0,
     String title = "",
     bool showExpiredTasks = false,
     }
  ){
    BoxDecoration? decoration;
    Color iconColor = Colors.grey;
    double iconSize = 20;
    Color underBarColor = PALE_MAIN_COLOR;


    if(subIndex == currentSubIndex){
      underBarColor = brighten(PALE_MAIN_COLOR, 0.6);
      iconColor = brighten(PALE_MAIN_COLOR, 0.7);
    }

    Widget headerIcon = 
      Icon(
        icon,
        color: iconColor,
        size: iconSize 
      );

    if(showExpiredTasks){
      headerIcon =  listLengthView(
        ref.watch(taskDataProvider)
           .expiredTaskDataList
           .length,
        10,
      );
    }
    

    return GestureDetector(
      onTap: (){
        onTabTapped(subIndex);
      },
      child:Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children:[
        Container(height: 0,),
        Container(
          width: SizeConfig.blockSizeHorizontal! *20,
          height: 30,
          decoration: decoration,
          child:Row(children:[
            const Spacer(),
            headerIcon,
            SizedBox(width:SizeConfig.blockSizeHorizontal! *1),
            Text(title,
              style:TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: iconColor
              ),  
            ),
            const Spacer(),
          ])
        ),
        Container(
          width: SizeConfig.blockSizeHorizontal! *20,
          height: 5,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(0),
            color: underBarColor
          ),
        ),
        
      ])
    );
  }

  Widget space(double width){
    Color underBarColor = PALE_MAIN_COLOR;
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children:[
        SizedBox(
          width: SizeConfig.blockSizeHorizontal! *width,
          height: 30,
        ),
        Container(
          width: SizeConfig.blockSizeHorizontal! *width,
          height: 5,
          color:underBarColor
        ),
      ]);
  }

  Map<int,List<Widget>> returnSubPage(ref){

    Map<int,List<Widget>> subPageTabs = {
      0 : [
          space(0),
          subMenuPanel(
            ref,
            icon:Icons.location_on,
            subIndex:0,
            title: "わせまっぷ"
          ),
          space(79.0),
          ],
      1 : [
          space(0),
          subMenuPanel(
            ref,
            icon:Icons.grid_on,
            subIndex:0,
            title: "時間割"
          ),
          space(79.0),
      ],
      2 : [
          space(0),
          subMenuPanel(
            ref,
            icon:Icons.calendar_month,
            subIndex:0,
            title: "予定"
          ),
          space(0),
          subMenuPanel(
            ref,
            icon:Icons.groups,
            subIndex:1,
            title: "シェア"
          ),
          space(0),
          subMenuPanel(
            ref,
            icon:Icons.currency_yen,
            subIndex:2,
            title: "バイト"
          ),

          space(0),
          subMenuPanel(
            ref,
            icon:Icons.school,
            subIndex:3,
            title: "大学暦"
          ),
          space(0),
          subMenuPanel(
            ref,
            icon:Icons.settings,
            subIndex:4,
            title: "設定"
          ),
          space(0),
          subMenuPanel(
            ref,
            icon:Icons.backup,
            subIndex:5,
            title: "バックアップ"
          ),
          space(0),
        ],
        3 : [
          space(0),
          subMenuPanel(
            ref,
            icon:Icons.check,
            subIndex:0,
            title: "課題"
          ),
          space(0),
          subMenuPanel(
            ref,
            icon:Icons.close,
            subIndex:1,
            title: "期限切れ",
            showExpiredTasks: true
          ),
          space(0),
          subMenuPanel(
            ref,
            icon:Icons.delete,
            subIndex:2,
            title: "削除済み"
          ),
          space(0),
          subMenuPanel(
            ref,
            icon:Icons.edit,
            subIndex:4,
            title: "学習記録"
          ),
          space(20.00),
        ],
        4 : [
          space(1.0),
          subMenuPanel(
            ref,
            icon:Icons.school,
            subIndex:0,
            title: "Moodle"
          ),
          space(1.0),
          subMenuPanel(
            ref,
            icon:Icons.school,
            subIndex:1,
            title: "WyWaseda"
          ),
          space(68.0),
        ],
      };
    return subPageTabs;
  }



}

  void showFeedBackDialog(BuildContext context) {
    final urlLaunchWithStringButton = UrlLaunchWithStringButton();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:const Text("アプリをご利用いただきありがとうございます！"),
          content: const Text("感想や評価など、ぜひアプリストアまでお寄せください！"),
          backgroundColor: FORGROUND_COLOR,
          actions: <Widget>[
            buttonModel(
              (){
                  urlLaunchWithStringButton.launchUriWithString(
                  context,
                  "https://apps.apple.com/jp/app/%E3%82%8F%E3%81%9B%E3%82%B8%E3%83%A5%E3%83%BC%E3%83%AB/id6479050214",
                );
              },
              MAIN_COLOR,
              " ストアへ "
              )
          ],
        );
      },
    );
  }

Widget popupMenuButton(color){
  return PopupMenuButton(
    color: FORGROUND_COLOR,
    icon:Icon(Icons.more_vert,color:color),
    itemBuilder: (BuildContext context) => <PopupMenuEntry>[
      PopupMenuItem(
        child: ListTile(
          tileColor: FORGROUND_COLOR,
          leading:const Icon(Icons.info_rounded,color:MAIN_COLOR),
          title :const Text('サポート'),
          onTap:(){
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SnsLinkPage()));
          }
        )
      ),
      const PopupMenuDivider(),
      PopupMenuItem(
        child: ListTile(
          tileColor: FORGROUND_COLOR,
          leading:const Icon(Icons.settings,color:MAIN_COLOR),
          title :const Text('設定'),
          onTap:(){
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsPage()));
          }
        )
      ),
    ],
  );
}

