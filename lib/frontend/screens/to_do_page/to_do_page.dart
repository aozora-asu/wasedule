import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/handler/task_db_handler.dart';
import 'package:flutter_calandar_app/frontend/screens/to_do_page/todo_assist_files/screen_manager.dart';
import '../common/float_button.dart';
import 'task_progress_indicator.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';

import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import '../common/loading.dart';
import '../task_page/add_data_card_button.dart';

import '../../assist_files/colors.dart';
import '../../../backend/temp_file.dart';

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
            backgroundColor: Colors.white,
            body: Column(children:[
                SizedBox(
                  height:SizeConfig.blockSizeVertical! * 80,
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: events,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return LoadingScreen();
                        } else if (snapshot.hasError) {
                          return Text("Error: ${snapshot.error}");
                        } else if (snapshot.hasData) {
                          return ScreenBuilder(
                            snapshot: snapshot,
                            context: context,
                            events: events,
                            );
                        } else {
                          return noneTaskText();
                        }
                      },
                    ),
                  ),
                ])
              );
 }
}