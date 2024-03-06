import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/handler/task_db_handler.dart';
import 'package:flutter_calandar_app/backend/DB/handler/user_info_db_handler.dart';
import 'package:flutter_calandar_app/frontend/assist_files/none_task_page.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/data_manager.dart';
import 'package:flutter_calandar_app/frontend/screens/to_do_page/todo_assist_files/screen_manager.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import '../common/loading.dart';

class TaskPage extends ConsumerStatefulWidget {
  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends ConsumerState<TaskPage> {
  // Future<List<Map<String, dynamic>>>? events;
  // String? urlString;
  // TaskDatabaseHelper databaseHelper = TaskDatabaseHelper();

  // @override
  // void initState() {
  //   super.initState();
  //   _initializeData();
  // }

  // Future<void> _initializeData() async {
  //   urlString = await UserDatabaseHelper().getUrl();
  //   if (urlString != null) {
  //     await _displayDB();
  //   } else {
  //     NoTaskPage();
  //   }
  // }

  // Future<void> _displayDB() async {
  //   final addData = await databaseHelper.taskListForTaskPage();
  //   if (mounted) {
  //     setState(() {
  //       events = Future.value(addData);
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return ScreenBuilder(
            context: context,
          );
    //FutureBuilder<List<Map<String, dynamic>>>(
    //   future: events,
    //   builder: (context, snapshot) {
    //     if (snapshot.connectionState == ConnectionState.waiting) {
    //       return LoadingScreen();
    //     } else if (snapshot.hasError) {
    //       return Text("Error: ${snapshot.error}");
    //     } else if (snapshot.hasData) {
    //       return ScreenBuilder(
    //         snapshot: snapshot,
    //         context: context,
    //         events: events,
    //       );
    //     } else {
    //       return NoTaskPage();
    //     }
    //   },
    // );
  }
}
