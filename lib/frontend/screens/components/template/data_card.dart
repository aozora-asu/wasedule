import 'package:flutter/material.dart';
import "package:flutter_calandar_app/backend/DB/database_helper.dart";
import 'package:flutter_calandar_app/frontend/size_config.dart';
import 'package:flutter_calandar_app/frontend/colors.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class DataCard extends StatefulWidget {
  final String title; // 授業名
  final String? description; // 課題
  final DateTime dtEnd; // 期限
  final String? summary; //メモ(通知表示用の要約)
  bool isDone; // 課題が終了したか(trueで済)
  final int index;

  DataCard({
    required this.index,
    required this.title,
    this.description,
    required this.dtEnd,
    required this.summary,
    required this.isDone,
  });

  @override
  _DataCardState createState() => _DataCardState();
}

Widget buildDataCards(List<Map<String, dynamic>> data) {
  return ListView(
    children: [
      for (int i = 0; i < data.length; i++)
        if (data[i]["isDone"] != 1)
          DataCard(
            index: i + 1,
            title: data[i]["title"],
            description: data[i]["description"],
            dtEnd: DateTime.fromMillisecondsSinceEpoch(data[i]["dtEnd"]),
            summary: data[i]["summary"],
            isDone: false,
          )
    ],
  );
}

class _DataCardState extends State<DataCard> {
  late TextEditingController _controller1; //categories
  late TextEditingController _controller2; //description
  late TextEditingController _controller3; //dtEnd
  late TextEditingController _controller4; //isDone
  late TextEditingController _controller5; //memo
  late TextEditingController _index;

  @override
  void initState() {
    super.initState();
    _controller1 = TextEditingController(text: widget.title);
    _controller2 = TextEditingController(text: widget.description);
    _controller3 = TextEditingController(
        text: DateFormat('yyyy年MM月dd日 HH時mm分').format(widget.dtEnd));
    _controller4 = TextEditingController(text: widget.isDone.toString());
    _controller5 = TextEditingController(text: widget.summary);
    _index = TextEditingController(text: widget.index.toString());
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    int index = int.parse(_index.text);
    TaskDatabaseHelper databaseHelper = TaskDatabaseHelper();

    return Column(
//カード本体//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Card(
            color: WIDGET_COLOR,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  // 輪郭線のスタイルを設定
                  color: WIDGET_OUTLINE_COLOR, // 輪郭線の色
                  width: 1, // 輪郭線の幅
                ),
                borderRadius: BorderRadius.circular(5.0), // カードの角を丸める場合は設定
              ),
              height: SizeConfig.blockSizeHorizontal! * 42,
              width: SizeConfig.blockSizeHorizontal! * 96.8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
//タスクの状態・授業名・チェクボ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                  Container(
                    height: SizeConfig.blockSizeHorizontal! * 12,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: SizeConfig.blockSizeHorizontal! * 2.5,
                              height: SizeConfig.blockSizeHorizontal! * 5,
                            ),
                            Container(
                              width: SizeConfig.blockSizeHorizontal! * 5,
                              height: SizeConfig.blockSizeHorizontal! * 5,
                              child: ButtonSwitching(),
                            ),
                            SizedBox(
                                width: SizeConfig.blockSizeHorizontal! * 2.5,
                                height: SizeConfig.blockSizeHorizontal! * 5),
                            Container(
                              width: SizeConfig.blockSizeHorizontal! * 80,
                              height: SizeConfig.blockSizeHorizontal! * 12,
                              child: TextField(
                                onChanged: (newValue) {
                                  setState(() {
                                    String userInput1 = newValue;
                                    databaseHelper.updateTitle(
                                        index, userInput1);
                                  });
                                },
                                textAlign: TextAlign.start,
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
                          ],
                        ),
                        Container(
                          height: SizeConfig.blockSizeHorizontal! * 0,
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
                                  onChanged: (newValue) {
                                    setState(() {
                                      String userInput5 = newValue;
                                      databaseHelper.updateSummary(
                                          index, userInput5);
                                    });
                                  },
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
                    height: SizeConfig.blockSizeHorizontal! * 0.6,
                    color: WIDGET_OUTLINE_COLOR,
                    thickness: 2,
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
                              SizedBox(
                                  width: SizeConfig.blockSizeHorizontal! * 2),
                              SingleChildScrollView(
                                child: Container(
                                  margin: EdgeInsets.only(top: 0),
                                  width: SizeConfig.blockSizeHorizontal! * 75,
                                  alignment: Alignment.topLeft,
                                  height: SizeConfig.blockSizeHorizontal! * 13,
                                  child: TextField(
                                    onChanged: (newValue) {
                                      setState(() {
                                        String userInput2 = newValue;
                                        databaseHelper.updateDescription(
                                            index, userInput2);
                                      });
                                    },
                                    maxLines: 3,
                                    textAlign: TextAlign.start,
                                    controller: _controller2,
                                    style: TextStyle(
                                      fontSize:
                                          SizeConfig.blockSizeHorizontal! * 3,
                                      fontWeight: FontWeight.w500,
                                    ),
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
                    height: SizeConfig.blockSizeHorizontal! * 0.8,
                    color: WIDGET_OUTLINE_COLOR,
                    thickness: 2,
                  ),
//期限、残り日数、タスクの状態//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                  Row(children: [
                    SizedBox(
                      width: SizeConfig.blockSizeHorizontal! * 1.2,
                    ),
                    Container(
                      height: SizeConfig.blockSizeHorizontal! * 6,
                      width: SizeConfig.blockSizeHorizontal! * 94,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Container(
                              child: Text(
                                ' 期限',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize:
                                      SizeConfig.blockSizeHorizontal! * 3.5,
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
                              width: SizeConfig.blockSizeHorizontal! * 83.1,
                              child: Row(
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(left: 8.0),
                                    child: Container(
                                      width:
                                          SizeConfig.blockSizeHorizontal! * 38,
                                      height:
                                          SizeConfig.blockSizeHorizontal! * 6,
                                      alignment: Alignment.center,
                                      child: TextField(
                                        style: TextStyle(
                                          fontSize:
                                              SizeConfig.blockSizeHorizontal! *
                                                  3,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        controller: _controller3,
                                        decoration: InputDecoration(
                                          hintText: "日付 (yyyy年mm月dd日 hh時mm分)",
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
                                        width: SizeConfig.blockSizeHorizontal! *
                                            20,
                                        height:
                                            SizeConfig.blockSizeHorizontal! * 5,
                                      ),
                                      Container(
                                        width: SizeConfig.blockSizeHorizontal! *
                                            22,
                                        height:
                                            SizeConfig.blockSizeHorizontal! *
                                                6.5,
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: TaskData(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: SizeConfig.blockSizeHorizontal! * 1),
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
    return InkWell(
      onTap: () {
        InformationAutoDismissiblePopup(context);
      },
      child: Container(
        width: SizeConfig.blockSizeHorizontal! * 5,
        height: SizeConfig.blockSizeHorizontal! * 5,
        child: Icon(
          Icons.info,
          color: Colors.blueGrey,
          size: SizeConfig.blockSizeHorizontal! * 5,
        ),
      ),
    );
  }

  DaysLeft() {
    if (widget.dtEnd.isBefore(DateTime.now()) == false) {
      Duration difference = widget.dtEnd.difference(DateTime.now()); // 日付の差を求める
      if (difference >= Duration(days: 4)) {
        return Text(
          ("  残り${difference.inDays} 日  "),
          style: TextStyle(
            fontSize: SizeConfig.blockSizeHorizontal! * 4,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ); // 日数の差を出力
      } else {
        return Text(
          ("  残り${difference.inDays} 日  "),
          style: TextStyle(
            fontSize: SizeConfig.blockSizeHorizontal! * 4,
            fontWeight: FontWeight.w900,
            color: Colors.yellow,
          ),
        ); // 日数の差を出力
      }
    } else {
      return Text(
        ("  残り 0 日  "),
        style: TextStyle(
          fontSize: SizeConfig.blockSizeHorizontal! * 4,
          fontWeight: FontWeight.w900,
          color: Colors.yellow,
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
            child: DaysLeft());
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
    _index.dispose();
    super.dispose();
  }
}

void InformationAutoDismissiblePopup(BuildContext context) {
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
              'カードはスワイプで削除できます。',
              style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal! * 4,
                fontWeight: FontWeight.w700,
              ),
            ),
          ));
    },
  );
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
