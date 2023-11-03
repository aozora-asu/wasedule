import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/db_Manager.dart';
import 'package:flutter_calandar_app/backend/http_request.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';

import '../../size_config.dart';
import '../../colors.dart';
import "../../../backend/temp_file.dart";

class TaskPage extends StatefulWidget {
  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  Future<List<Map<String, dynamic>>>? events;
  DBManager dbManager = DBManager();

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    final data = await dbManager.taskListforTaskPage();
    setState(() {
      events = Future.value(data);
    });
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
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text("エラー: ${snapshot.error}");
            } else if (snapshot.hasData) {
              return buildDataCards(
                  snapshot.data! as List<Map<String, dynamic>>);
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _initData();
        },
        backgroundColor: MAIN_COLOR,
        child: Icon(Icons.get_app),
      ),
    );
  }
}

class DataCard extends StatefulWidget {
  final String title; // 授業名
  final DateTime dtEnd; // 期限
  final String? summary; //メモ(通知表示用の要約)
  final String? description; // 課題

  bool isDone; // 課題が終了したか(trueで済)

  DataCard({
    required this.title,
    required this.dtEnd,
    this.description,
    this.summary,
    required this.isDone,
  });

  @override
  _DataCardState createState() => _DataCardState();
}

Widget buildDataCards(List<Map<String, dynamic>> data) {
  if (data == null) {
    return CircularProgressIndicator();
  }

  return ListView(
    children: [
      for (int i = 0; i < data.length; i++)
        DataCard(
          title: data[i]["title"],
          description: data[i]["description"],
          dtEnd: DateTime.fromMillisecondsSinceEpoch(data[i]["dtEnd"]),
          summary: data[i]["summary"],
          isDone: false,
        )
    ],
  );
}

//ここにmemo追加しといてー。上のは追加した
class _DataCardState extends State<DataCard> {
  late TextEditingController _controller1; //categories
  late TextEditingController _controller2; //description
  late TextEditingController _controller3; //dtEnd
  late TextEditingController _controller4; //isDone
  late TextEditingController _controller5; //memo

  @override
  void initState() {
    super.initState();
    _controller1 = TextEditingController(text: widget.title);
    _controller2 = TextEditingController(text: widget.description);
    _controller3 = TextEditingController(text: widget.dtEnd.toString());
    _controller4 = TextEditingController(text: widget.isDone.toString());
    _controller5 = TextEditingController(text: widget.summary);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Column(
//カード本体//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(5.0),
          child: Card(
            color: WIDGET_COLOR, //Color.fromARGB(255, 244, 237, 216),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  // 輪郭線のスタイルを設定
                  color: WIDGET_OUTLINE_COLOR, // 輪郭線の色
                  width: 3.5, // 輪郭線の幅
                ),
                borderRadius: BorderRadius.circular(8.0), // カードの角を丸める場合は設定
              ),
              height: SizeConfig.blockSizeHorizontal! * 42,
              width: SizeConfig.blockSizeHorizontal! * 98,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
//タスクの状態・授業名///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                  Container(
                    height: SizeConfig.blockSizeHorizontal! * 12,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            TaskData(),
                            SizedBox(
                                width: SizeConfig.blockSizeHorizontal! * 2,
                                height: SizeConfig.blockSizeHorizontal! * 11),
                            Container(
                              width: SizeConfig.blockSizeHorizontal! * 68,
                              height: SizeConfig.blockSizeHorizontal! * 12,
                              child: TextField(
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  fontSize: SizeConfig.blockSizeHorizontal! * 5,
                                  fontWeight: FontWeight.w900,
                                ),
                                controller: _controller1,
                                decoration: InputDecoration(
                                  hintText: "授業名",
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  String userInput1 = _controller1.text;
                                });
                                showAutoDismissiblePopup(context);
                              },
                              child: Container(
                                width: SizeConfig.blockSizeHorizontal! * 4,
                                height: SizeConfig.blockSizeHorizontal! * 4,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius:
                                      BorderRadius.circular(10), // ボタンの角を丸くする
                                ),
                                child: Icon(Icons.edit, // アイコンの種類
                                    color: Colors.brown, // アイコンの色
                                    size: SizeConfig.blockSizeHorizontal! * 4),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          height: SizeConfig.blockSizeHorizontal! * 0,
                          // child:Divider(
                          //   color: ACCENT_COLOR,
                          //   thickness: SizeConfig.blockSizeHorizontal! * 0.8,
                          // ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height:
                        SizeConfig.blockSizeHorizontal! * 0.8, // 高さを指定する場合（省略可）
                    color: WIDGET_OUTLINE_COLOR, // 線の色を指定する場合（省略可）
                    thickness: 2, // 線の太さを指定する場合（省略可）
                  ),
//要約(メモ)/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                  Container(
                    height: SizeConfig.blockSizeHorizontal! * 6,
                    width: SizeConfig.blockSizeHorizontal! * 96,
                    child: Row(
                      children: [
                        Container(
                          height: SizeConfig.blockSizeHorizontal! * 12,
                          width: SizeConfig.blockSizeHorizontal! * 11,
                          alignment: Alignment.topLeft,
                          child: Text(
                            '  要約',
                            textAlign: TextAlign.left, // テキスト自体の揃え方も指定
                            style: TextStyle(
                              fontSize: SizeConfig.blockSizeHorizontal! * 3.5,
                              fontWeight: FontWeight.w600,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                        ),
                        Container(
                          width: SizeConfig.blockSizeHorizontal! * 2,
                          height: SizeConfig.blockSizeHorizontal! * 6,
                        ),
                        Container(
                          width: SizeConfig.blockSizeHorizontal! * 82,
                          height: SizeConfig.blockSizeHorizontal! * 6,
                          alignment: Alignment.topLeft,
                          child: Row(
                            children: <Widget>[
                              Container(
                                height: SizeConfig.blockSizeHorizontal! * 6,
                                width: SizeConfig.blockSizeHorizontal! * 4.5,
                                alignment: Alignment.topLeft,
                                child: Column(children: [
                                  SizedBox(
                                    height: SizeConfig.blockSizeHorizontal! * 1,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        String userInput5 = _controller5.text;
                                      });
                                      showAutoDismissiblePopup(context);
                                    },
                                    child: Container(
                                      width:
                                          SizeConfig.blockSizeHorizontal! * 4.5,
                                      height:
                                          SizeConfig.blockSizeHorizontal! * 4.5,
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(
                                            10), // ボタンの角を丸くする
                                      ),
                                      child: Icon(Icons.edit, // アイコンの種類
                                          color: Colors.grey, // アイコンの色
                                          size:
                                              SizeConfig.blockSizeHorizontal! *
                                                  4.5),
                                    ),
                                  ),
                                ]),
                              ),
                              SizedBox(
                                  width: SizeConfig.blockSizeHorizontal! * 2),
                              Container(
                                margin: EdgeInsets.only(top: 0),
                                width: SizeConfig.blockSizeHorizontal! * 75,
                                alignment: Alignment.topLeft,
                                height: SizeConfig.blockSizeHorizontal! * 6,
                                child: TextField(
                                  maxLines: 1,
                                  textAlign: TextAlign.start,
                                  controller: _controller5,
                                  style: TextStyle(
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal! * 3,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  //onChanged: (newValue) {
                                  //String userInput = _controller2.text;// テキストが変更された際の処理
                                  //},
                                  decoration: InputDecoration(
                                    hintText: "通知表示用の要約を入力…  (例 レポ課題1500字)",
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.only(
                                        bottom:
                                            SizeConfig.blockSizeHorizontal! *
                                                3.2),
                                    hintStyle: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500),
                                    //alignLabelWithHint: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height:
                        SizeConfig.blockSizeHorizontal! * 0.6, // 高さを指定する場合（省略可）
                    color: WIDGET_OUTLINE_COLOR, // 線の色を指定する場合（省略可）
                    thickness: 2, // 線の太さを指定する場合（省略可）
                  ),
//課題////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                  SizedBox(
                    height: SizeConfig.blockSizeHorizontal! * 1,
                  ),
                  Container(
                    height: SizeConfig.blockSizeHorizontal! * 13,
                    width: SizeConfig.blockSizeHorizontal! * 96,
                    child: Row(
                      children: [
                        Container(
                          height: SizeConfig.blockSizeHorizontal! * 15,
                          width: SizeConfig.blockSizeHorizontal! * 11,
                          alignment: Alignment.topLeft,
                          child: Text(
                            '  課題',
                            textAlign: TextAlign.left, // テキスト自体の揃え方も指定
                            style: TextStyle(
                              fontSize: SizeConfig.blockSizeHorizontal! * 3.5,
                              fontWeight: FontWeight.w600,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                        ),
                        Container(
                          width: SizeConfig.blockSizeHorizontal! * 2,
                          height: SizeConfig.blockSizeHorizontal! * 0.6,
                        ),
                        Container(
                          width: SizeConfig.blockSizeHorizontal! * 82,
                          height: SizeConfig.blockSizeHorizontal! * 15,
                          alignment: Alignment.topLeft,
                          child: Row(
                            children: <Widget>[
                              Container(
                                height: SizeConfig.blockSizeHorizontal! * 15,
                                width: SizeConfig.blockSizeHorizontal! * 4.5,
                                alignment: Alignment.topLeft,
                                child: Column(children: [
                                  SizedBox(
                                    height: SizeConfig.blockSizeHorizontal! * 1,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        String userInput2 = _controller2.text;
                                      });
                                      showAutoDismissiblePopup(context);
                                    },
                                    child: Container(
                                      width:
                                          SizeConfig.blockSizeHorizontal! * 4.5,
                                      height:
                                          SizeConfig.blockSizeHorizontal! * 4.5,
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(
                                            10), // ボタンの角を丸くする
                                      ),
                                      child: Icon(Icons.edit, // アイコンの種類
                                          color: Colors.grey, // アイコンの色
                                          size:
                                              SizeConfig.blockSizeHorizontal! *
                                                  4.5),
                                    ),
                                  ),
                                  SizedBox(
                                    height: SizeConfig.blockSizeHorizontal! * 1,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      _controller2.clear();
                                    },
                                    child: Container(
                                      width:
                                          SizeConfig.blockSizeHorizontal! * 4.5,
                                      height:
                                          SizeConfig.blockSizeHorizontal! * 4.5,
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(Icons.delete,
                                          color: Colors.grey,
                                          size:
                                              SizeConfig.blockSizeHorizontal! *
                                                  4.5),
                                    ),
                                  ),
                                ]),
                              ),
                              SizedBox(
                                  width: SizeConfig.blockSizeHorizontal! * 2),
                              SingleChildScrollView(
                                child: Container(
                                  margin: EdgeInsets.only(top: 0),
                                  width: SizeConfig.blockSizeHorizontal! * 75,
                                  alignment: Alignment.topLeft,
                                  height: SizeConfig.blockSizeHorizontal! * 13,
                                  child: TextField(
                                    maxLines: 3,
                                    textAlign: TextAlign.start,
                                    controller: _controller2,
                                    style: TextStyle(
                                      fontSize:
                                          SizeConfig.blockSizeHorizontal! * 3,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    //onChanged: (newValue) {
                                    //String userInput = _controller2.text;// テキストが変更された際の処理
                                    //},
                                    decoration: const InputDecoration(
                                      hintText: "課題の詳細やメモを入力…",
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.only(top: 0),
                                      hintStyle: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),
                              ),
                              //),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height:
                        SizeConfig.blockSizeHorizontal! * 0.8, // 高さを指定する場合（省略可）
                    color: WIDGET_OUTLINE_COLOR, // 線の色を指定する場合（省略可）
                    thickness: 2, // 線の太さを指定する場合（省略可）
                  ),
//期限、残り日数、完了ボタン//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                  Row(children: [
                    SizedBox(
                      width: SizeConfig.blockSizeHorizontal! * 1.2,
                    ),
                    Container(
                      height: SizeConfig.blockSizeHorizontal! * 6,
                      width: SizeConfig.blockSizeHorizontal! * 71.4,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            child: Text(
                              '期限',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: SizeConfig.blockSizeHorizontal! * 3.5,
                                fontWeight: FontWeight.w600,
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: SizeConfig.blockSizeHorizontal! * 2,
                            height: SizeConfig.blockSizeHorizontal! * 6,
                          ),
                          SizedBox(
                            width: SizeConfig.blockSizeHorizontal! * 61,
                            child: Row(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: Container(
                                    width: SizeConfig.blockSizeHorizontal! * 35,
                                    height: SizeConfig.blockSizeHorizontal! * 6,
                                    alignment: Alignment.center,
                                    child: TextField(
                                      style: TextStyle(
                                        fontSize:
                                            SizeConfig.blockSizeHorizontal! * 3,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      controller: _controller3,
                                      decoration: InputDecoration(
                                        hintText: "日付 (yyyy-MM-dd HH:mm)",
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.only(
                                            bottom: SizeConfig
                                                    .blockSizeHorizontal! *
                                                3.2),
                                      ),
                                    ),
                                  ),
                                ),
                                Row(
                                  children: <Widget>[
                                    SizedBox(
                                      width:
                                          SizeConfig.blockSizeHorizontal! * 5.9,
                                      height:
                                          SizeConfig.blockSizeHorizontal! * 5,
                                    ),
                                    Container(
                                      width:
                                          SizeConfig.blockSizeHorizontal! * 18,
                                      height:
                                          SizeConfig.blockSizeHorizontal! * 5.5,
                                      child: DaysLeft(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: SizeConfig.blockSizeHorizontal! * 1),
                    Container(
                      width: SizeConfig.blockSizeHorizontal! * 20,
                      height: SizeConfig.blockSizeHorizontal! * 5,
                      child: ButtonSwitching(),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: SizeConfig.blockSizeHorizontal! * 0.75), //カード間の隙間。
      ],
    );
  }

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  String initialData() {
    return TaskData();
  }

  String Titlename() {
    return _controller1.text;
  }

  ButtonSwitching() {
    if (widget.isDone == true) {
      if (widget.dtEnd.isBefore(DateTime.now()) == false) {
        //課題完了、期限内
        return ElevatedButton(
          onPressed: () {
            setState(() {
              widget.isDone = false;
            });
          },
          child: Text('元に戻す',
              style: TextStyle(fontSize: SizeConfig.blockSizeHorizontal! * 2)),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.grey), // ボタンの背景色
            elevation: MaterialStateProperty.all(0),
          ),
        );
      } else {
        //完了、期限切れ
        return Text(
          'スワイプ→',
          style: TextStyle(fontSize: SizeConfig.blockSizeHorizontal! * 6),
        );
      }
    } else {
      if (widget.dtEnd.isBefore(DateTime.now()) == false) {
        //未完了、期限内
        return ElevatedButton(
          onPressed: () {
            setState(() {
              widget.isDone = true;
            });
          },
          child: Text('終わった！',
              style: TextStyle(fontSize: SizeConfig.blockSizeHorizontal! * 2)),
          style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all(Colors.blueGrey), // ボタンの背景色
            elevation: MaterialStateProperty.all(0),
          ),
        );
      } else {
        //未完了、期限切れ
        return Text(
          'スワイプで削除',
          style: TextStyle(
              fontSize: SizeConfig.blockSizeHorizontal! * 2.8,
              color: const Color.fromARGB(255, 77, 46, 35),
              fontWeight: FontWeight.w600),
        );
      }
    }
  }

  DaysLeft() {
    if (widget.dtEnd.isBefore(DateTime.now()) == false) {
      Duration difference = widget.dtEnd.difference(DateTime.now()); // 日付の差を求める
      if (difference >= Duration(days: 4)) {
        return Text(
          ("残り${difference.inDays} 日"),
          style: TextStyle(
            fontSize: SizeConfig.blockSizeHorizontal! * 3.5,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ); // 日数の差を出力
      } else {
        return Text(
          ("残り${difference.inDays} 日"),
          style: TextStyle(
            fontSize: SizeConfig.blockSizeHorizontal! * 3.5,
            fontWeight: FontWeight.w600,
            color: const Color.fromARGB(255, 255, 0, 0),
          ),
        ); // 日数の差を出力
      }
    } else {
      return Text(
        ("残り 0 日"),
        style: TextStyle(
          fontSize: SizeConfig.blockSizeHorizontal! * 3.5,
          fontWeight: FontWeight.w600,
          color: const Color.fromARGB(255, 255, 0, 0),
        ),
      );
    }
  }

  TaskData() {
    DateTime TimeLimit = widget.dtEnd;
    bool FinishOrNot = widget.isDone;

    if (TimeLimit.isBefore(DateTime.now()) == false) {
      if (FinishOrNot == false) {
        return Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 255, 119, 119), // 背景色を指定
              borderRadius: BorderRadius.circular(7), // 角丸にする場合は設定
            ),
            child: Text(
              '   未完了   ',
              style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal! * 4,
                fontWeight: FontWeight.w900,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
            ));
      } else {
        return Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 0, 166, 255), // 背景色を指定
              borderRadius: BorderRadius.circular(7), // 角丸にする場合は設定
            ),
            child: Text(
              '   完了！  ',
              style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal! * 4,
                fontWeight: FontWeight.w900,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
            ));
      }
    } else {
      if (FinishOrNot == false) {
        return Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 0, 0, 0), // 背景色を指定
              borderRadius: BorderRadius.circular(7), // 角丸にする場合は設定
            ),
            child: Text(
              ' 期限切れ ',
              style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal! * 4,
                fontWeight: FontWeight.w900,
                color: Color.fromARGB(255, 250, 0, 0),
              ),
            ));
      } else {
        return Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 0, 166, 255), // 背景色を指定
              borderRadius: BorderRadius.circular(7), // 角丸にする場合は設定
            ),
            child: Text(
              '   完了！   ',
              style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal! * 4,
                fontWeight: FontWeight.w900,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
            ));
      }
    }
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    _controller4.dispose();
    _controller5.dispose();
    super.dispose();
  }
}

void showAutoDismissiblePopup(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      Timer(Duration(seconds: 2), () {
        Navigator.of(context).pop();
      });

      return Align(
          alignment: Alignment.bottomCenter,
          child: AlertDialog(
            title: Text(
              '変更が反映されました',
              style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal! * 4,
                fontWeight: FontWeight.w700,
              ),
            ),
          ));
    },
  );
}
