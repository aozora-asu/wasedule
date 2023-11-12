import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/database_helper.dart';
import '../components/organism/float_button.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';

import 'package:flutter_calandar_app/frontend/size_config.dart';
import '../components/template/loading.dart';
import '../components/template/add_data_card_button.dart';

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
    return Scaffold(
        backgroundColor: BACKGROUND_COLOR,
        body: Center(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: events,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return LoadingScreen();
              } else if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}");
              } else if (snapshot.hasData) {
                // データが読み込まれた場合、リストを生成

                return buildDataCards(context, snapshot.data!);
              } else {
                // データがない場合の処理（nullの場合など）

                return noneTaskText();
              }
            },
          ),
        ),
        floatingActionButton:
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          addDataCardButton(),
          Container(
              width: SizeConfig.blockSizeHorizontal! * 2,
              height: SizeConfig.blockSizeHorizontal! * 5),
          FloatingActionButton(
            onPressed: () {
              _loadData();
            },
            backgroundColor: MAIN_COLOR, // ボタンの背景色
            child: const Icon(Icons.get_app), // ボタンのアイコン
          ),
        ]));
  }
}
