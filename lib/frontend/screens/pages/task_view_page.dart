import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/database_helper.dart';
import '../components/organism/float_button.dart';
import '../components/template/tasklist_sort_date.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';
import '../../data_manager.dart';

import 'package:flutter_calandar_app/frontend/size_config.dart';
import '../components/template/loading.dart';
import '../components/template/add_data_card_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../colors.dart';
import '../../../backend/temp_file.dart';

class TaskViewPage extends ConsumerStatefulWidget {
  @override
  TaskViewPageState createState() => TaskViewPageState();
}

class TaskViewPageState extends ConsumerState<TaskViewPage> {
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
      await displayDB();
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
  Future<void> loadData() async {
    await databaseHelper.resisterTaskToDB(urlString);

    await displayDB();
  }

  Future<void> displayDB() async {
    final addData = await databaseHelper.taskListForTaskPage();
    if (mounted) {
      setState(() {
        events = Future.value(addData);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskData =ref.watch(taskDataProvider);
     
    return 
       Scaffold(
        backgroundColor:Colors.white, // BACKGROUND_COLOR,
        body: //こっちにタスク進捗リスト
          FutureBuilder<List<Map<String, dynamic>>>(
            future: events,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
              
               if(ref.read(taskDataProvider).isInit){
                return LoadingScreen();
               }else{
                return TaskListByDtEnd(sortedData:taskData.sortDataByDtEnd(taskData.taskDataList));
               }

              } else if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}");
              } else if (snapshot.hasData) {

                if(ref.watch(taskDataProvider).isInit){
                  
                  ref.read(taskDataProvider).isInit = false;
                }
                taskData.getData(snapshot.data!);

                if(ref.read(taskDataProvider).isRenewed){
                  displayDB();
                  ref.read(taskDataProvider).isRenewed = false;
                }

                taskData.sortDataByDtEnd(taskData.taskDataList);

                return TaskListByDtEnd(sortedData:taskData.sortDataByDtEnd(taskData.taskDataList));
              } else {
                return noneTaskText();
              }
            },
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
              loadData();
            },
            backgroundColor: MAIN_COLOR,
            child: const Icon(Icons.get_app,color:Colors.white),
          ),
        ],
      )
     );
  }
}