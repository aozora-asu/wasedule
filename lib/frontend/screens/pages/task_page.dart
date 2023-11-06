import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/database_helper.dart';
import 'package:flutter_calandar_app/backend/db_manager.dart';

import 'package:flutter/widgets.dart';
import 'dart:async';

import '../components/template/loading.dart';

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
      _loadData();
    } else {
      if (urlString == "") {
        // urlStringがない場合の処理
      } else {
        noneTaskText();
      }
    }
  }

  Widget noneTaskText() {
    return const Text("現在課題はありません");
  }

  //データベースを更新する関数
  Future<void> _loadData() async {
    final data = await resisterTaskToDB(urlString);
    if (mounted) {
      setState(() {
        events = Future.value(data);
      });
    }
  }

  Future<void> _displayDB() async {
    final addData = await taskListforTaskPage();
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _loadData();
        },
        backgroundColor: MAIN_COLOR, // ボタンの背景色
        child: const Icon(Icons.get_app), // ボタンのアイコン
      ),
    );
  }
}
