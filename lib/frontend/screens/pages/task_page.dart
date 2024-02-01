import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/database_helper.dart';
import '../components/organism/float_button.dart';
import '../components/template/task_progress_indicator.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';

import 'package:flutter_calandar_app/frontend/size_config.dart';
import '../components/template/loading.dart';
import '../components/template/add_data_card_button.dart';
import '../components/template/brief_kanban.dart';

import '../../colors.dart';
import '../../../backend/temp_file.dart';
import '../components/template/data_card.dart';

class TaskPage extends StatefulWidget {
  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  Future<List<Map<String, dynamic>>>? events;
  String urlString = url_t;
  TaskDatabaseHelper databaseHelper = TaskDatabaseHelper();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    if (await databaseHelper.hasData() == true) {
      await _displayDB();
    } else {
      if (urlString == "") {
        // urlStringがない場合の処理
      } else {
        noneTaskText();
      }
    }
  }

  Widget noneTaskText() {
    return const Text("現在課題はありません。");
  }

  //データベースを更新する関数。主にボタンを押された時のみ
  Future<void> _loadData() async {
    await databaseHelper.resisterTaskToDB(urlString);

    await _displayDB();
  }

  Future<void> _displayDB() async {
    final addData = await databaseHelper.taskListForTaskPage();
    if (mounted) {
      setState(() {
        events = Future.value(addData);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
  onWillPop: () async {
    // 画面が閉じられる直前の処理
    if(isSnackBar){
      canSnackBarClose = false;
    }
    return true; // trueを返すと閉じる、falseを返すと閉じない
  },
      child: Scaffold(
        backgroundColor:Colors.white, // BACKGROUND_COLOR,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              elevation: 0,
              leading: null, // 戻るアイコンを非表示
              automaticallyImplyLeading: false, // 戻るアイコンを非表示
              expandedHeight: SizeConfig.blockSizeHorizontal! * 89,
              collapsedHeight: SizeConfig.blockSizeHorizontal! * 25,
              floating: false,
              pinned: true,
              backgroundColor: WIDGET_COLOR,
              flexibleSpace: FlexibleSpaceBar(
               background: //こっちにタスク進捗リスト
                FutureBuilder<List<Map<String, dynamic>>>(
                future: events,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return LoadingScreen();
                  } else if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  } else if (snapshot.hasData) {
                    return buildTaskProgressIndicator(context, snapshot.data!);
                  } else {
                    return noneTaskText();
                  }
                 },
               ),
              ),
                bottom: PreferredSize(
                preferredSize: Size.fromHeight(SizeConfig.blockSizeHorizontal! * 25), // ウィジェットの高さ
                child: BriefKanBan(), // 折り畳み後の領域に表示するウィジェット
              ),
            ),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: events,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverFillRemaining(
                  child: LoadingScreen(),
                );
              } else if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Text("Error: ${snapshot.error}"),
                );
              } else if (snapshot.hasData) {
                return 
                 buildDataCards(context, snapshot.data!);
              } else {
                return SliverFillRemaining(
                  child: noneTaskText(),
                );
              }
            },
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AddDataCardButton(),
          Container(
            width: SizeConfig.blockSizeHorizontal! * 2,
            height: SizeConfig.blockSizeHorizontal! * 5,
          ),
          FloatingActionButton(
            onPressed: () {
              _loadData();
            },
            backgroundColor: MAIN_COLOR,
            child: const Icon(Icons.get_app,color:Colors.white),
          ),
        ],
      )
     )
    );
  }
}
