import 'package:flutter/material.dart';
import "package:flutter_calandar_app/backend/DB/database_helper.dart";
import 'package:flutter_calandar_app/frontend/size_config.dart';
import 'package:flutter_calandar_app/frontend/colors.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../components/organism/float_button.dart';
import 'dart:async';
import '../../pages/task_page.dart';
import 'package:tab_indicator_styler/tab_indicator_styler.dart';


class PriorityTabBar extends StatefulWidget {
  @override
  _PriorityTabBarState createState() => _PriorityTabBarState();
}

class _PriorityTabBarState extends State<PriorityTabBar> with TickerProviderStateMixin {
  late TabController _tabController;
  ValueNotifier<int> _currentIndex1 = ValueNotifier<int>(0);
  double _radius = 30.0;

  @override
  void initState() {
    super.initState();
    // TabControllerの初期化
    _tabController = TabController(length: _items.length, vsync: this);
  }

  final List<Widget> _items = [
    Tab(text: 'なし'),
    Tab(text: '低'),
    Tab(text: '中'),
    Tab(text: '高'),
  ];

  @override
  Widget build(BuildContext context) {

    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: WIDGET_OUTLINE_COLOR,
                borderRadius: BorderRadius.circular(_radius),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black,
                tabs: _items,
                indicator: RectangularIndicator(
                  color: ACCENT_COLOR,
                  topLeftRadius: _radius,
                  topRightRadius: _radius,
                  bottomLeftRadius: _radius,
                  bottomRightRadius: _radius,
                  horizontalPadding: 4,
                  verticalPadding: 4,
                ),
                onTap: (int index) {
                  _currentIndex1.value = index;
                },
              ),
            ),
          ],
        ),
    );
  }
}


class BriefKanBan extends StatefulWidget {
  @override
  _BriefKanBanState createState() => _BriefKanBanState();
}

class _BriefKanBanState extends State<BriefKanBan> {
  @override
  Widget build(BuildContext context) {
    return Column(children:[
        Container(
         width: SizeConfig.blockSizeHorizontal! * 100,
         height: SizeConfig.blockSizeHorizontal! * 5,
         child: Text(" タスクの優先度",
         style:TextStyle(fontSize: SizeConfig.blockSizeHorizontal! * 4,
         fontWeight: FontWeight.w600)
         ),
        ),
                Container(
         width: SizeConfig.blockSizeHorizontal! * 100,
         height: SizeConfig.blockSizeHorizontal! * 1),
       Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            width: SizeConfig.blockSizeHorizontal! * 32,
            height: SizeConfig.blockSizeHorizontal! * 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20),),
                color: WIDGET_OUTLINE_COLOR,
                ),
            child: Center(
              child: Text('高'),
            ),
          ),
          Container(
            width: SizeConfig.blockSizeHorizontal! * 32,
            height: SizeConfig.blockSizeHorizontal! *  32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20),),
                color: WIDGET_OUTLINE_COLOR,
                ),
            child: Center(
              child: Text('中'),
            ),
          ),
          Container(
            width: SizeConfig.blockSizeHorizontal! * 32,
            height: SizeConfig.blockSizeHorizontal! *  32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20),),
                color: WIDGET_OUTLINE_COLOR,
                ),
            child: Center(
              child: Text('低'),
            ),
          ),
        ],
      ), 
        Container(
         width: SizeConfig.blockSizeHorizontal! * 100,
         height: SizeConfig.blockSizeHorizontal! *1),
      ]
      );

  }
}