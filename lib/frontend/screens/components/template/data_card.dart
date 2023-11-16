import 'package:flutter/material.dart';
import "package:flutter_calandar_app/backend/DB/database_helper.dart";
import 'package:flutter_calandar_app/frontend/size_config.dart';
import 'package:flutter_calandar_app/frontend/colors.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../pages/task_page.dart';

Map<String, List<Widget>> FoldableMap = {}; //折りたたみ可能ウィジェットの管理用キメラ。
List<String> TitleList = [];
List<String> uniqueTitleList = TitleList.toSet().toList();

class DataCard extends StatefulWidget {
  final String title; // 授業名
  final String description; // 課題
  final DateTime dtEnd; // 期限
  final String summary; //メモ(通知表示用の要約)
  bool isDone; // 課題が終了したか(trueで済)
  final int index;

  DataCard({
    required this.index,
    required this.title,
    required this.description,
    required this.dtEnd,
    required this.summary,
    required this.isDone,
  });

  @override
  DataCardState createState() => DataCardState();
}

Widget buildDataCards(BuildContext context, List<Map<String, dynamic>> data) {
  SizeConfig().init(context);

  return ListView(
    children: <Widget>[
      //１枚目のカードを生成(エラー回避)
      for (int i = 0; i < data.length; i++) ...{
        if (i == 0) ...{
          if (data[i]["isDone"] == 0)
            DataCard(
              index: i + 1,
              title: data[i]["title"],
              description: data[i]["description"],
              dtEnd: DateTime.fromMillisecondsSinceEpoch(data[i]["dtEnd"]),
              summary: data[i]["summary"],
              isDone: false,
            ),
        } else ...{
          //2枚目以降の未完了のカードのうち、
          if (data[i]["isDone"] == 0)
            //前のカードとtitleとdtEndのいずれかが一致していないものは,
            //通常ウィジェットとして生成

            if (data[i]["title"] != data[i - 1]["title"] ||
                data[i]["dtEnd"] != data[i - 1]["dtEnd"]) ...{
              DataCard(
                index: i + 1,
                title: data[i]["title"],
                description: data[i]["description"],
                dtEnd: DateTime.fromMillisecondsSinceEpoch(data[i]["dtEnd"]),
                summary: data[i]["summary"],
                isDone: false,
              )
            } else ...{
              if (i == 1) ...{
                //前のカードとtitle、dtEndの両方が一致しているもので,
                // ２枚目のカードだった場合、親折りたたみウィジェットを生成(エラー回避)

                GroupFoldableCard(
                  isChild: false,
                  FoldableCardSummary: data[i]["summary"],
                  DatacardIndex: i + 1,
                  DataCardTitle: data[i]["title"],
                  DataCardDescription: data[i]["description"],
                  DataCardDtEnd:
                      DateTime.fromMillisecondsSinceEpoch(data[i]["dtEnd"]),
                  DataCardSummary: data[i]["summary"],
                  DataCardIsDone: false,
                )
              } else ...{
                if (data[i]["title"] == data[i - 2]["title"] &&
                    data[i]["dtEnd"] == data[i - 2]["dtEnd"]) ...{
                  //２つ前のカードとTitle,dtEndが一致する場合、
                  //子折りたたみウィジェットを生成

                  GroupFoldableCard(
                    isChild: true,
                    FoldableCardSummary: data[i]["summary"],
                    DatacardIndex: i + 1,
                    DataCardTitle: data[i]["title"],
                    DataCardDescription: data[i]["description"],
                    DataCardDtEnd:
                        DateTime.fromMillisecondsSinceEpoch(data[i]["dtEnd"]),
                    DataCardSummary: data[i]["summary"],
                    DataCardIsDone: false,
                  ),
                } else ...{
                  //そうでない場合、親折りたたみウィジェットを生成。

                  GroupFoldableCard(
                    isChild: false,
                    FoldableCardSummary: data[i]["summary"],
                    DatacardIndex: i + 1,
                    DataCardTitle: data[i]["title"],
                    DataCardDescription: data[i]["description"],
                    DataCardDtEnd:
                        DateTime.fromMillisecondsSinceEpoch(data[i]["dtEnd"]),
                    DataCardSummary: data[i]["summary"],
                    DataCardIsDone: false,
                  ),
                }
              }
            }
        }
      }
    ],
  );
}

class DataCardState extends State<DataCard> with AutomaticKeepAliveClientMixin {
  late TextEditingController _controller1; //categories
  late TextEditingController _controller2; //description
  late String _controller3; //dtEnd
  late TextEditingController _controller4; //isDone
  late TextEditingController _controller5; //memo
  late TextEditingController _index;

  String _userInput1 = '';
  String _userInput5 = '';
  String _userInput2 = '';
  final FocusNode _focusNodeCategories = FocusNode();
  final FocusNode _focusNodeMemo = FocusNode();
  final FocusNode _focusNodeDescription = FocusNode();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    //setState(() {
    _controller1 = TextEditingController(text: widget.title);
    _controller2 = TextEditingController(text: widget.description);
    _controller3 = DateFormat('yyyy年MM月dd日 HH時mm分').format(widget.dtEnd);
    _controller4 = TextEditingController(text: widget.isDone.toString());
    _controller5 = TextEditingController(text: widget.summary);
    _index = TextEditingController(text: widget.index.toString());
    //});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    SizeConfig().init(context);
    int index = int.parse(_index.text);
    TaskDatabaseHelper databaseHelper = TaskDatabaseHelper();
    TitleList.add(widget.title);

//スワイプで削除の処理////////////////////////////////////////////////////////////////////////////
    void _showSnackBar(BuildContext context) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
            SnackBar(
              content: const Text(
                'タスクを削除しました…',
                style: TextStyle(color: Colors.black),
              ),
              action: SnackBarAction(
                label: '元に戻す',
                textColor: Colors.lightBlue,
                onPressed: () {
                  setState(() {});
                },
              ),
              backgroundColor: WIDGET_OUTLINE_COLOR,
              duration:
                  const Duration(seconds: 6), // スナックバーが自動で閉じるまでの時間。デフォルトは4秒
            ),
          )
          .closed
          .then((reason) {
        if (reason == SnackBarClosedReason.action) {
          print("消去取消");
        } else {
          print("消去発動");
          // SnackBar が閉じられたときの処理（非表示になったとき）
          databaseHelper.unDisplay(index);
          _controller4.text = "1";
        }
      });
    }

    return Dismissible(
        key: UniqueKey(),
        direction: DismissDirection.startToEnd,
        onDismissed: (direction) {
          if (!_focusNodeCategories.hasFocus &&
              !_focusNodeMemo.hasFocus &&
              !_focusNodeDescription.hasFocus) {
            _showSnackBar(context);
          }
        },
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 16.0),
          child: const Icon(Icons.delete),
        ),
        child:
//カード本体//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            Column(
          children: <Widget>[
            SizedBox(height: SizeConfig.blockSizeHorizontal! * 4), //カード間の隙間。
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Card(
                margin: EdgeInsets.symmetric(
                    horizontal: SizeConfig.blockSizeHorizontal! * 2),
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
                  height: SizeConfig.blockSizeHorizontal! * 40.25,
                  width: SizeConfig.blockSizeHorizontal! * 95.75,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
//授業名////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                      Container(
                        height: SizeConfig.blockSizeHorizontal! * 9,
                        child: Row(
                          children: <Widget>[
                            SizedBox(
                              width: SizeConfig.blockSizeHorizontal! * 2.5,
                              height: SizeConfig.blockSizeHorizontal! * 9,
                            ),
                            SizedBox(
                              width: SizeConfig.blockSizeHorizontal! * 5,
                              height: SizeConfig.blockSizeHorizontal! * 9,
                              child: buttonSwitching(),
                            ),
                            SizedBox(
                                width: SizeConfig.blockSizeHorizontal! * 2.5,
                                height: SizeConfig.blockSizeHorizontal! * 9),
                            Container(
                              //padding: const EdgeInsets.only(top: 12),

                              width: SizeConfig.blockSizeHorizontal! * 80,
                              height: SizeConfig.blockSizeHorizontal! * 9,
                              child: TextField(
                                focusNode: _focusNodeCategories,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (inputValue) {
                                  _userInput1 = inputValue;
                                  databaseHelper.updateTitle(
                                      index, _userInput1);
                                },
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize:
                                      SizeConfig.blockSizeHorizontal! * 4.5,
                                  fontWeight: FontWeight.w900,
                                ),
                                controller: _controller1,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.only(
                                      bottom: SizeConfig.blockSizeHorizontal! *
                                          2.75),
                                  hintText: "授業名",
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Divider(
                      //   height: SizeConfig.blockSizeHorizontal! *
                      //       0.8, // 高さを指定する場合（省略可）
                      //   color: WIDGET_OUTLINE_COLOR, // 線の色を指定する場合（省略可）
                      //   thickness: 2, // 線の太さを指定する場合（省略可）
                      // ),
//要約(メモ)/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

                      Container(
                        height: SizeConfig.blockSizeHorizontal! * 7,
                        width: SizeConfig.blockSizeHorizontal! * 96,
                        child: Row(
                          children: [
                            // SizedBox(
                            //   height: SizeConfig.blockSizeHorizontal! * 12,
                            //   width: SizeConfig.blockSizeHorizontal! * 11,
                            //   alignment: Alignment.topLeft,
                            //   child: Text(
                            //     '  要約',
                            //     textAlign: TextAlign.left, // テキスト自体の揃え方も指定
                            //     style: TextStyle(
                            //       fontSize: SizeConfig.blockSizeHorizontal! * 3.5,
                            //       fontWeight: FontWeight.w600,
                            //       color: Color.fromARGB(255, 0, 0, 0),
                            //     ),
                            //   ),
                            // ),
                            SizedBox(
                              width: SizeConfig.blockSizeHorizontal! * 2,
                              height: SizeConfig.blockSizeHorizontal! * 7,
                            ),
                            Container(
                              width: SizeConfig.blockSizeHorizontal! * 82,
                              height: SizeConfig.blockSizeHorizontal! * 7,
                              alignment: Alignment.topLeft,
                              child: Row(
                                children: <Widget>[
                                  SizedBox(
                                      width:
                                          SizeConfig.blockSizeHorizontal! * 2),
                                  Container(
                                    constraints: BoxConstraints(
                                        maxWidth:
                                            SizeConfig.blockSizeHorizontal! *
                                                75),
                                    margin: EdgeInsets.only(top: 0),
                                    //width: SizeConfig.blockSizeHorizontal! * 75,
                                    alignment: Alignment.topLeft,
                                    height: SizeConfig.blockSizeHorizontal! * 7,
                                    child: TextField(
                                      focusNode: _focusNodeMemo,
                                      maxLines: 1,
                                      textAlign: TextAlign.start,
                                      controller: _controller5,
                                      style: TextStyle(
                                        fontSize:
                                            SizeConfig.blockSizeHorizontal! * 3,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      textInputAction: TextInputAction.done,
                                      onSubmitted: (inputValue) {
                                        _userInput5 = inputValue;
                                        databaseHelper.updateSummary(
                                            index, _userInput5);
                                      },
                                      decoration: InputDecoration(
                                        hintText: "通知表示用の要約を入力…  (例 レポ課題1500字)",
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.only(
                                            bottom: SizeConfig
                                                    .blockSizeHorizontal! *
                                                3.2),
                                        hintStyle: const TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w500),
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
                      SizedBox(
                        height: SizeConfig.blockSizeHorizontal! * 13,
                        width: SizeConfig.blockSizeHorizontal! * 96,
                        child: Row(
                          children: [
                            // SizedBox(
                            //   height: SizeConfig.blockSizeHorizontal! * 15,
                            //   width: SizeConfig.blockSizeHorizontal! * 11,
                            //   alignment: Alignment.topLeft,
                            //   child: Text(
                            //     '  詳細',
                            //     textAlign: TextAlign.left, // テキスト自体の揃え方も指定
                            //     style: TextStyle(
                            //       fontSize: SizeConfig.blockSizeHorizontal! * 3.5,
                            //       fontWeight: FontWeight.w600,
                            //       color: Color.fromARGB(255, 0, 0, 0),
                            //     ),
                            //   ),
                            // ),
                            SizedBox(
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
                                      width:
                                          SizeConfig.blockSizeHorizontal! * 2),
                                  SingleChildScrollView(
                                    child: Container(
                                      margin: EdgeInsets.only(top: 0),
                                      constraints: BoxConstraints(
                                          maxWidth:
                                              SizeConfig.blockSizeHorizontal! *
                                                  75),
                                      width:
                                          SizeConfig.blockSizeHorizontal! * 75,
                                      alignment: Alignment.topLeft,
                                      height:
                                          SizeConfig.blockSizeHorizontal! * 13,
                                      child: TextField(
                                        focusNode: _focusNodeDescription,
                                        textInputAction: TextInputAction.done,
                                        onSubmitted: (inputValue) {
                                          _userInput2 = inputValue;
                                          databaseHelper.updateDescription(
                                              index, _userInput2);
                                        },
                                        maxLines: 3,
                                        textAlign: TextAlign.start,
                                        controller: _controller2,
                                        style: TextStyle(
                                          fontSize:
                                              SizeConfig.blockSizeHorizontal! *
                                                  3,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        decoration: const InputDecoration(
                                          hintText: "タスクの詳細やメモを入力…",
                                          border: InputBorder.none,
                                          contentPadding:
                                              EdgeInsets.only(top: 0),
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
                      // Divider(
                      //   height: SizeConfig.blockSizeHorizontal! * 0.8,
                      //   color: WIDGET_OUTLINE_COLOR,
                      //   thickness: 2,
                      // ),
                      SizedBox(
                        height: SizeConfig.blockSizeHorizontal! * 2,
                      ),
//期限、残り日数、タスクの状態//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                      Row(children: [
                        SizedBox(
                          width: SizeConfig.blockSizeHorizontal! * 1.2,
                        ),
                        SizedBox(
                          height: SizeConfig.blockSizeHorizontal! * 6,
                          width: SizeConfig.blockSizeHorizontal! * 94,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                SizedBox(
                                  child: Text(
                                    ' 期限',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontSize:
                                          SizeConfig.blockSizeHorizontal! * 3.5,
                                      fontWeight: FontWeight.w600,
                                      color: const Color.fromARGB(255, 0, 0, 0),
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
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Container(
                                          width:
                                              SizeConfig.blockSizeHorizontal! *
                                                  38,
                                          height:
                                              SizeConfig.blockSizeHorizontal! *
                                                  6,
                                          alignment: Alignment.center,
                                          child: Text(
                                            _controller3,
                                            style: TextStyle(
                                              fontSize: SizeConfig
                                                      .blockSizeHorizontal! *
                                                  3,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: <Widget>[
                                          SizedBox(
                                            width: SizeConfig
                                                    .blockSizeHorizontal! *
                                                42,
                                            height: SizeConfig
                                                    .blockSizeHorizontal! *
                                                6.5,
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: taskData(),
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
                      ]),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ));
  }

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  String initialData() {
    return taskData();
  }

  String titlename() {
    return _controller1.text;
  }

  buttonSwitching() {
    return InkWell(
      onTap: () {
        informationAutoDismissiblePopup(context);
      },
      child: SizedBox(
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

  Stream<String> getRemainingTimeStream(DateTime dtEnd) async* {
    while (dtEnd.isAfter(DateTime.now())) {
      Duration remainingTime = dtEnd.difference(DateTime.now());

      int days = remainingTime.inDays;
      int hours = (remainingTime.inHours % 24);
      int minutes = (remainingTime.inMinutes % 60);
      int seconds = (remainingTime.inSeconds % 60);

      yield '  $days日 $hours時間 $minutes分 $seconds秒  ';

      await Future.delayed(Duration(seconds: 1));
    }
  }

  StreamBuilder<String> repeatdaysLeft() {
    return StreamBuilder<String>(
      stream: getRemainingTimeStream(widget.dtEnd),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Text(
            snapshot.data!,
            style: TextStyle(
              fontSize: SizeConfig.blockSizeHorizontal! * 4,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          );
        } else {
          return const SizedBox(); // データがない場合は何も表示しない
        }
      },
    );
  }

  String getRemainingTime(DateTime dtEnd) {
    Duration remainingTime = widget.dtEnd.difference(DateTime.now());

    int days = remainingTime.inDays;
    int hours = (remainingTime.inHours % 24);
    int minutes = (remainingTime.inMinutes % 60);
    int seconds = (remainingTime.inSeconds % 60);

    return '  $days日 $hours時間 $minutes分 $seconds秒  ';
  }

  daysLeft() {
    if (widget.dtEnd.isBefore(DateTime.now()) == false) {
      Duration difference = widget.dtEnd.difference(DateTime.now()); // 日付の差を求める
      if (difference >= const Duration(days: 4)) {
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
          getRemainingTime(widget.dtEnd),
          style: TextStyle(
            fontSize: SizeConfig.blockSizeHorizontal! * 4,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        );
      }
    } else {
      return Text(
        ("  残り 0 日  "),
        style: TextStyle(
          fontSize: SizeConfig.blockSizeHorizontal! * 4,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      );
    }
  }

  taskData() {
    DateTime timeLimit = widget.dtEnd;
    Duration difference = widget.dtEnd.difference(DateTime.now());
    if (timeLimit.isBefore(DateTime.now()) == false) {
      if (difference >= const Duration(days: 4)) {
        return Container(
            decoration: BoxDecoration(
              color: Colors.blueGrey, // 背景色を指定
              borderRadius: BorderRadius.circular(7), // 角丸にする場合は設定
            ),
            child: Text(
              ("  残り${difference.inDays} 日  "),
              style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal! * 4,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            )); // 日数の差を出力
      } else {
        return Container(
            decoration: BoxDecoration(
              color: Colors.red, // 背景色を指定
              borderRadius: BorderRadius.circular(7), // 角丸にする場合は設定
            ),
            child: repeatdaysLeft());
      }
    } else {
      return Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 0, 0, 0), // 背景色を指定
            borderRadius: BorderRadius.circular(7), // 角丸にする場合は設定
          ),
          child: Text(
            ' 期限切れ ',
            style: TextStyle(
              fontSize: SizeConfig.blockSizeHorizontal! * 4,
              fontWeight: FontWeight.w900,
              color: const Color.fromARGB(255, 250, 0, 0),
            ),
          ));
    }
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller4.dispose();
    _controller5.dispose();
    _index.dispose();
    super.dispose();
  }
}

void informationAutoDismissiblePopup(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      Timer(const Duration(seconds: 2), () {
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
      // ウィジェットの祖先への参照を保存する
      BuildContext? parentContext;

      // didChangeDependencies メソッド内で参照を保存
      void saveParentContext(BuildContext newContext) {
        parentContext = newContext;
      }

      return Builder(
        builder: (BuildContext builderContext) {
          // Builder ウィジェットを使用して新しい context を取得
          saveParentContext(builderContext);

          Timer(const Duration(seconds: 2), () {
            // タイマー内で parentContext を使用
            Navigator.of(parentContext!).pop();
          });

          return Align(
            alignment: Alignment.bottomCenter,
            child: AlertDialog(
              title: Text(
                'ダブルタップで内容を展開/折りたたみできます。',
                style: TextStyle(
                  fontSize: SizeConfig.blockSizeHorizontal! * 4,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

//カードそのものの折り畳みに関する記述//////////////////////////////////////////////////////////////////
class FoldableCard extends StatefulWidget {
  final DataCard dataCard; // DataCardのインスタンスを保持するプロパティ
  final String summary; // 追加するString型データ

  const FoldableCard({
    required this.dataCard,
    required this.summary,
  }); // コンストラクタでDataCardのインスタンスとtitleを受け取る

  @override
  _FoldableCardState createState() => _FoldableCardState();
}

class _FoldableCardState extends State<FoldableCard> {
  bool isFolded = true;

  void toggleFold() {
    setState(() {
      isFolded = !isFolded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: SizeConfig.blockSizeHorizontal! * 100,
        color: BACKGROUND_COLOR,
        child: GestureDetector(
          onDoubleTap: toggleFold,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            height: isFolded
                ? SizeConfig.blockSizeHorizontal! * 7
                : SizeConfig.blockSizeHorizontal! * 45, // カードが折りたたまれる高さと元の高さ
            color: WIDGET_COLOR,

            child: isFolded
                ? Center(
                    child: Card(
                        child: Container(
                            color: BACKGROUND_COLOR,
                            width: SizeConfig.blockSizeHorizontal! * 96,
                            child: Row(children: [
                              Container(
                                width: SizeConfig.blockSizeHorizontal! * 2,
                              ),
                              Container(
                                width: SizeConfig.blockSizeHorizontal! * 1.7,
                                height: SizeConfig.blockSizeHorizontal! * 4,
                                color: ACCENT_COLOR,
                              ),
                              Container(
                                width: SizeConfig.blockSizeHorizontal! * 2,
                              ),
                              InkWell(
                                onTap: () {
                                  showAutoDismissiblePopup(context);
                                },
                                child: SizedBox(
                                  width: SizeConfig.blockSizeHorizontal! * 5,
                                  height: SizeConfig.blockSizeHorizontal! * 5,
                                  child: Icon(
                                    Icons.info,
                                    color: Colors.blueGrey,
                                    size: SizeConfig.blockSizeHorizontal! * 5,
                                  ),
                                ),
                              ),
                              Text("     ${widget.summary}",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal! * 3,
                                    fontWeight: FontWeight.w500,
                                  )),
                            ]))))
                : widget.dataCard,
          ),
        ));
  }
}

//グループ化されたカードの折り畳みに関する記述/////////////////////////////////////////////////////////////////
class GroupFoldableCard extends StatefulWidget {
  final bool isChild;

  final String FoldableCardSummary;
  final int DatacardIndex;
  final String DataCardTitle;
  final String DataCardDescription;
  final DateTime DataCardDtEnd;
  final String DataCardSummary;
  final bool DataCardIsDone;

  GroupFoldableCard({
    required this.isChild, // コンストラクタに追加
    required this.FoldableCardSummary,
    required this.DatacardIndex,
    required this.DataCardTitle,
    required this.DataCardDescription,
    required this.DataCardDtEnd,
    required this.DataCardSummary,
    required this.DataCardIsDone,
  });

  @override
  _GroupFoldableCardState createState() => _GroupFoldableCardState();
}

class _GroupFoldableCardState extends State<GroupFoldableCard>
    with AutomaticKeepAliveClientMixin {
  bool isFolded = true;
  late FoldableCard foldableCard;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    foldableCard = FoldableCard(
      dataCard: DataCard(
        index: widget.DatacardIndex,
        title: widget.DataCardTitle,
        description: widget.DataCardDescription,
        dtEnd: widget.DataCardDtEnd,
        summary: widget.DataCardSummary,
        isDone: widget.DataCardIsDone,
      ),
      summary: widget.FoldableCardSummary,
    );
    int? childLength =
        FoldableMap["$widget.DataCardTitle${widget.DataCardDtEnd.toString()}"]
            ?.length;
    AddWidgetToMap();
  }

  void AddWidgetToMap() {
    if (widget.isChild == false) {
      FoldableMap["$widget.DataCardTitle${widget.DataCardDtEnd.toString()}"] = [
        foldableCard
      ];
    } else {
      if (FoldableMap[
              "$widget.DataCardTitle${widget.DataCardDtEnd.toString()}"] ==
          null) {
        FoldableMap["$widget.DataCardTitle${widget.DataCardDtEnd.toString()}"] =
            [];
      }
      FoldableMap["$widget.DataCardTitle${widget.DataCardDtEnd.toString()}"]!
          .add(foldableCard);
    }
  }

  void toggleFold() {
    setState(() {
      isFolded = !isFolded;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return widget.isChild
        ? const SizedBox.shrink()
        : GestureDetector(
            onTap: toggleFold,
            child: Container(
              width: SizeConfig.blockSizeHorizontal! * 95.75,
              child: Card(
                margin: EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: SizeConfig.blockSizeHorizontal! * 2),
                child: Container(
                  child: Column(
                    children: [
                      ListTile(
                        title: Row(children: [
                          //  Container(
                          //   width: SizeConfig.blockSizeHorizontal! * 3,
                          //   height: SizeConfig.blockSizeHorizontal! * 11,
                          //   color: ACCENT_COLOR,
                          //   ),
                          //  Container(
                          //   width: SizeConfig.blockSizeHorizontal! * 6,
                          //   height: SizeConfig.blockSizeHorizontal! * 10,
                          //   ),
                          Icon(
                            Icons.subdirectory_arrow_right,
                            size: 30,
                            color: Colors.blueGrey,
                          ),
                          Text(
                            "そのほかのタスク…",
                            //"ほか${FoldableMap["$widget.DataCardTitle${widget.DataCardDtEnd.toString()}"]?.length ?? 0}件のタスク…",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: SizeConfig.blockSizeHorizontal! * 4,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ]),
                        trailing: Icon(
                          isFolded
                              ? Icons.arrow_drop_down
                              : Icons.arrow_drop_up,
                        ),
                      ),
                      if (!isFolded) ChildrenDataCards(context),
                    ],
                  ),
                ),
              ),
            ));
  }

  Widget ChildrenDataCards(BuildContext context) {
    return Column(
      children: [
        for (var card in FoldableMap[
            "$widget.DataCardTitle${widget.DataCardDtEnd.toString()}"]!)
          card
      ],
    );
  }
}
