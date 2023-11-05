import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/db_manager.dart';

import 'package:flutter/widgets.dart';
import 'dart:async';

import 'package:intl/intl.dart';
import '../../size_config.dart';
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

  @override
  void initState() {
    super.initState();
    if (_existData(urlString) == true) {
      _displayDB();
    } else {
      if (urlString == "") {
        //urlStringがなかった時の処理はこちら
      } else {
        _loadData();
      }
    }
    ;
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

  //データベースが存在するか判定する関数
  Future<bool> _existData(urlString) async {
    if (await resisterTaskToDB(urlString) == false) {
      return false;
    } else {
      return true;
    }
  }

  Widget buildMyFutureBuilder(Future<List<Map<String, dynamic>>> events) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: events,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else if (snapshot.hasData) {
          return buildDataCards(snapshot.data!);
        } else {
          return CircularProgressIndicator();
        }
      },
    );
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
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            } else if (snapshot.hasData) {
              // データが読み込まれた場合、リストを生成
              return buildDataCards(snapshot.data!);
            } else {
              // データがない場合の処理（nullの場合など）
              return const CircularProgressIndicator();
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
