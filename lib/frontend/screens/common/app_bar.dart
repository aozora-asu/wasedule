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
import 'package:flutter_calandar_app/frontend/screens/task_page/task_data_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

 int type = 0;

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget{
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  late bool backButton;

  CustomAppBar({
    required this.backButton,
    Key? key
  }) : super(key: key);

  Color contentColor = Colors.white;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SizeConfig().init(context);
    Widget appBarContent = const SizedBox();
    if(!backButton){
      appBarContent = const AppBarThumbNail();
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
            bottom: Radius.circular(0),
          ),
        ),
        bottom: PreferredSize(
          preferredSize:const Size.fromHeight(5),
          child: Container(
            height: SizeConfig.blockSizeVertical! *0.6,
            color:PALE_MAIN_COLOR
          ),
        )
    );
  }

  Widget? switchLeading(context){
   if(backButton){
    return BackButton(color:contentColor);
   }else{
    return null;
   }
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
            Navigator.pop(context);
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
            Navigator.pop(context);
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
            Navigator.pop(context);
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
            Navigator.pop(context);
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
            Navigator.pop(context);
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

class AppBarThumbNail extends ConsumerStatefulWidget {
  const AppBarThumbNail({Key? key}) : super(key: key);

  @override
  _AppBarThumbNailState createState() => _AppBarThumbNailState();
}

class _AppBarThumbNailState extends ConsumerState<AppBarThumbNail> {
 
  @override
  Widget build(BuildContext context){
  SizeConfig().init(context);
  Widget contents = const SizedBox();
  switch(type){
    case 0: contents = datePreview();
    break; 
    case 1: contents = taskPreview();
    break; 
    case 2: contents = fuck();
    break; 
  }

  return PopupMenuButton(
    itemBuilder:(BuildContext context) => <PopupMenuEntry>[
    PopupMenuItem(
      child: ListTile(
        leading:const Icon(Icons.do_disturb,color:MAIN_COLOR),
        title :const Text('表示なし'),
        onTap:(){
          Navigator.pop(context);
          setState(() {
            type = 100;
          });
        }
      )
    ),
    PopupMenuItem(
      child: ListTile(
        leading:const Icon(Icons.date_range,color:MAIN_COLOR),
        title :const Text('今日の日付'),
        onTap:(){
          Navigator.pop(context);
          setState(() {
            type = 0;
          });
        }
      )
    ),
    PopupMenuItem(
      child: ListTile(
        leading:const Icon(Icons.check,color:MAIN_COLOR),
        title :const Text('課題の残件数'),
        onTap:(){
          Navigator.pop(context);
          setState(() {
            type = 1;
          });
        }
      )
    ),
    PopupMenuItem(
      child: ListTile(
        leading:const Icon(Icons.check,color:MAIN_COLOR),
        title :const Text('次の課題期限'),
        onTap:(){
          Navigator.pop(context);
          setState(() {
            type = 2;
          });
        }
      )
    ),
    PopupMenuItem(
      child: ListTile(
        leading:const Icon(Icons.directions_walk,color:MAIN_COLOR),
        title :const Text('次の教室'),
        onTap:(){
          Navigator.pop(context);

        }
      )
    ),
  ],
    child: frame(contents)
  );
}

  Widget frame(contents){

    if (type < 100) {
      return Container(
        padding: EdgeInsets.symmetric(
          vertical: SizeConfig.blockSizeVertical! * 0.25,
          horizontal: SizeConfig.blockSizeHorizontal! * 3,
        ),
        decoration: BoxDecoration(
          color: BACKGROUND_COLOR,
          borderRadius: const BorderRadius.all(Radius.circular(7.5)),
          border: Border.all(color: PALE_MAIN_COLOR, width: 3),
        ),
        child: contents,
      );
    } else {
      return SizedBox(
        height: SizeConfig.blockSizeVertical! * 4,
        width: SizeConfig.blockSizeHorizontal! * 20,
      );
    }

  }

Widget datePreview(){
  DateTime now = DateTime.now();
  String todayText = DateFormat("MM/dd").format(now);
  String todayWeekday = DateFormat("EEE.").format(now);
  return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children:[
      Text(todayWeekday,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: SizeConfig.blockSizeVertical! *1.5
          )
      ),
      Text(todayText,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: SizeConfig.blockSizeVertical! *2
          )
      )
    ]);
}

Widget taskPreview(){
  final taskData = ref.read(taskDataProvider);
  int taskLength = taskData.taskDataList.length
    - taskData.expiredTaskDataList.length
    - taskData.deletedTaskDataList.length;

  return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children:[
      Text("残り課題",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: SizeConfig.blockSizeVertical! *1.5
          )
      ),
      Text(taskLength.toString() + "件",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: SizeConfig.blockSizeVertical! *2
          )
      )
    ]);
  }

  Widget fuck(){
    if(type == 2 && ref.read(taskDataProvider).sortedDataByDTEnd.isEmpty){
      return SizedBox(
        height: SizeConfig.blockSizeVertical! * 4,
        width: SizeConfig.blockSizeHorizontal! * 20,
        child:Center(
          child:Text("課題なし",
            overflow: TextOverflow.clip,
            style:TextStyle(color:Colors.grey,fontSize:SizeConfig.blockSizeVertical! *1.5))
        )
      );
    }else{
      return earliestTaskPreview();
    }
  }

  Widget earliestTaskPreview(){
  final taskData = ref.read(taskDataProvider);
  DateTime? earliestDtEnd
   = DateTime.fromMillisecondsSinceEpoch(taskData.sortedDataByDTEnd.values.elementAt(0).elementAt(0)["dtEnd"]);
  Duration remainingTime = earliestDtEnd.difference(DateTime.now());
  String hour = remainingTime.inHours.toString();
  String minute = (remainingTime.inMinutes %60).toString();

  return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children:[
      Text("次の期限まで",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: SizeConfig.blockSizeVertical! *1.25
          )
      ),
      Text(hour +"h "+minute +"m",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: SizeConfig.blockSizeVertical! *2
          )
      )
    ]);
  }
}