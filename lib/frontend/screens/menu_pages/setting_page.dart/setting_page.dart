import 'package:flutter/material.dart';
import '../../../assist_files/colors.dart';
import '../../../assist_files/size_config.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: AppBar(
        leading: const BackButton(color:Colors.white),
        backgroundColor: MAIN_COLOR,
        elevation: 10,
        title: const Column(
          children:<Widget>[
            Row(children:[
            Icon(
              Icons.settings,
              color:WIDGET_COLOR,
              ),
            Text(
              '  設定',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color:Colors.white
              ),
            ),
            ]
            )
          ],
        ),
      ),
      body:const MyWidget(),
      );
  }
}

//サイドメニュー//////////////////////////////////////////////////////
class MyWidget extends StatefulWidget {

  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            labelType: NavigationRailLabelType.selected,
            selectedIconTheme: const IconThemeData(color: MAIN_COLOR),
            selectedLabelTextStyle: const TextStyle(color: MAIN_COLOR),
            elevation: 20,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.calendar_today),
                label: Text('カレンダー'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.notifications_active),
                label: Text('通知'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people),
                label: Text('フレンド'),
              ),
            ],
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          MainContents(index: _selectedIndex)
        ],
      ),
    );
  }
}

class MainContents extends StatelessWidget {
  const MainContents({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
  SizeConfig().init(context);
//通知の設定画面////////////////////////////////////////////////
    switch (index) {
      case 1:
    return Expanded(
      child: Stack(
          children: [Scaffold(
            backgroundColor: BACKGROUND_COLOR,
      body: Center(
        child: Text('通知の設定…'),
      ),
    ),
            Positioned(
              top: 7,
              left: 10,
              child:  Text('通知設定…',
              style:TextStyle(
        fontSize: SizeConfig.blockSizeHorizontal! *7,
        fontWeight: FontWeight.bold
        ),),
            ),
          ],
        ),
        );
//フレンドの設定画面////////////////////////////////////////////////////
      case 2:
    return Expanded(
      child: Stack(
          children: [Scaffold(
      backgroundColor: BACKGROUND_COLOR,
      body: Center(
        child: Text('フレンドの設定…'),
      ),
    ),
            Positioned(
              top: 7,
              left: 10,
              child:  Text('フレンド設定…',
              style:TextStyle(
        fontSize: SizeConfig.blockSizeHorizontal! *7,
        fontWeight: FontWeight.bold
        ),),
            ),
          ],
        ),
        );
//カレンダーの設定画面////////////////////////////////////////////////
      default:
    return Expanded(
      child: Stack(
          children: [Scaffold(
      backgroundColor: BACKGROUND_COLOR,
      body: Center(
        child: Text('カレンダーの設定…'),
      ),
    ),
            Positioned(
              top: 7,
              left: 10,
              child:  Text('カレンダー設定…',
              style:TextStyle(
        fontSize: SizeConfig.blockSizeHorizontal! *7,
        fontWeight: FontWeight.bold
        ),),
            ),
          ],
        ),
        );
}
}
}