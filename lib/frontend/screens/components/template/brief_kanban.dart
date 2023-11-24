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


class BoxContainer extends StatefulWidget {
  @override
  _BoxContainerState createState() => _BoxContainerState();
}

class _BoxContainerState extends State<BoxContainer> {
  List<BoxData> boxes = [
    BoxData(color: Colors.red, text: '高'),
    BoxData(color: Colors.green, text: '中'),
    BoxData(color: Colors.blue, text: '低'),
  ];

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: boxes
          .map((box) => DraggableBox(
                data: box,
              ))
          .toList(),
    );
  }
}

class DraggableBox extends StatelessWidget {
  final BoxData data;

  DraggableBox({required this.data});

  @override
  Widget build(BuildContext context) {
    return Draggable(
      data: data,
      child: BoxWidget(
        color: data.color,
        text: data.text,
      ),
      feedback: BoxWidget(
        color: data.color.withOpacity(0.7),
        text: data.text,
      ),
      childWhenDragging: Container(),
    );
  }
}

class BoxWidget extends StatelessWidget {
  final Color color;
  final String text;

  BoxWidget({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      width:SizeConfig.blockSizeHorizontal! *25,
      height:SizeConfig.blockSizeHorizontal! *20,
      color: color,
      child: Center(
        child: Text(
          text,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class BoxData {
  final Color color;
  final String text;

  BoxData({required this.color, required this.text});
}