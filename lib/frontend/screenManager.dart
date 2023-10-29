import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/widgets.dart';

import './size_config.dart';
import './colors.dart';

/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////

//以下はカレンダー関連です。
class FirstPage extends StatefulWidget {
  @override
    _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  int _currentIndex = 0;

    void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
        Widget body;
    if (_currentIndex == 0) {
      body = Calendar();
    } else {
      body = TaskPage();
    }

    return Scaffold(
        appBar: AppBar(
          backgroundColor: MAIN_COLOR,
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Column(children: <Widget>[
                Text(
                  'わせジュール',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '早稲田生のためのスケジュールアプリ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ]),
              const SizedBox(width: 10),
            ],
          ),
        ),
        body: body,
        bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        backgroundColor: MAIN_COLOR,
        selectedItemColor: ACCENT_COLOR,
        unselectedItemColor: Colors.white,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'カレンダー',           
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.splitscreen),
            label: 'タスク',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'フレンド',
          ),
        ],
      ),
    );
  }
}


class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TableCalendar<dynamic>(
        firstDay: DateTime.utc(1882, 10, 21),
        lastDay: DateTime.utc(2100, 10, 21),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        calendarBuilders: CalendarBuilders(
          defaultBuilder:
              (BuildContext context, DateTime day, DateTime focusedDay) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: EdgeInsets.zero,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 1,
                ),
              ),
              alignment: Alignment.topCenter,
              child: Text(
                day.day.toString(),
                style: TextStyle(
                  color: Colors.black87,
                ),
              ),
            );
          },

          /// 有効範囲（firstDay~lastDay）以外の日付部分を生成する
          disabledBuilder:
              (BuildContext context, DateTime day, DateTime focusedDay) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: EdgeInsets.zero,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 0.5,
                ),
              ),
              alignment: Alignment.topCenter,
              child: Text(
                day.day.toString(),
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            );
          },
          selectedBuilder:
              (BuildContext context, DateTime day, DateTime focusedDay) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: EdgeInsets.zero,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.red[800]!,
                  width: 3.0,
                ),
              ),
              alignment: Alignment.topCenter,
              child: Text(
                day.day.toString(),
                style: TextStyle(
                  color: Colors.black87,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////



//以下はタスク管理画面関連の関数です。
class TaskPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListView(
          children: [
            DataCard(
                variable1: "線文字A 入門",
                variable2: "近くの遺跡で石板を見つけ、解読してくる。",
                variable3: DateTime(2023, 10, 25, 23, 59),
                variable4: true),
            DataCard(
                variable1: "ワセメシを探求する",
                variable2: "油そば4店舗をめぐり、感想を各1000字のレポートに書く。",
                variable3: DateTime(2023, 12, 22, 23, 59),
                variable4: false),
            DataCard(
                variable1: "マネーロンダリング論 入門",
                variable2: "違法行為により資金を調達してくる。最低40万円。",
                variable3: DateTime(2023, 12, 19, 23, 59),
                variable4: true),
            DataCard(
                variable1: "エスペラント語 1-1 S",
                variable2: "エスペラント語でのディスカッション資料を準備する。",
                variable3: DateTime(2023, 10, 15, 23, 59),
                variable4: false),
            DataCard(
                variable1: "線文字B 入門",
                variable2: "線文字Bにて詩を書く。最低4つ、400文字",
                variable3: DateTime(2023, 10, 28, 23, 59),
                variable4: true),
          ],
       ),
      ),
        //bottomNavigationBar:MyBottomNavigationBarApp()
    );
  }
}

class DataCard extends StatefulWidget {
  final String variable1; //授業名
  final String variable2; //課題
  final DateTime variable3; //期限
  bool variable4; //課題が終了したか(trueで済)

  DataCard({
    required this.variable1,
    required this.variable2,
    required this.variable3,
    required this.variable4,
  });

  @override
  _DataCardState createState() => _DataCardState();
}

class _DataCardState extends State<DataCard> {
  late TextEditingController _controller1;
  late TextEditingController _controller2;
  late TextEditingController _controller3;
  late TextEditingController _controller4;

  @override
  void initState() {
    super.initState();
    _controller1 = TextEditingController(text: widget.variable1);
    _controller2 = TextEditingController(text: widget.variable2);
    _controller3 = TextEditingController(text: widget.variable3.toString());
    _controller4 = TextEditingController(text: widget.variable4.toString());
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Column(
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(1.0),
          child: Card(
            color: Color.fromARGB(255, 244, 237, 216),
            child: SizedBox(
              height: SizeConfig.blockSizeHorizontal!  *35,
              width: SizeConfig.blockSizeHorizontal! * 98,
              child: Column(
                children: <Widget>[
                  Container(
                   height: SizeConfig.blockSizeHorizontal! * 13,
                   child:Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children:[Row(
                     children: <Widget>[
                      TaskData(),
                      SizedBox(width: SizeConfig.blockSizeHorizontal! * 2,
                               height: SizeConfig.blockSizeHorizontal!  *7),
                      Container(
                        width: SizeConfig.blockSizeHorizontal!  *68,
                        height: SizeConfig.blockSizeHorizontal!  *8,
                        child: TextField(
                          style: TextStyle(
                            fontSize:  SizeConfig.blockSizeHorizontal! * 5,
                            fontWeight: FontWeight.w900,
                          ),
                          controller: _controller1,
                          decoration: InputDecoration(
                            hintText: "授業名",
                            border: InputBorder.none,
                          ),
                          //maxLines: 2, // または1（1の場合は一行で折り返す）),
                        ),
                      ),
                    InkWell(
                      onTap: () {
                        setState(() {
                           String userInput1 = _controller1.text;
                         });
                        },
                      child: Container(
                      width:SizeConfig.blockSizeHorizontal! * 4,
                      height: SizeConfig.blockSizeHorizontal!  *4,
                      decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(10), // ボタンの角を丸くする
                       ),
                     child: Icon(
                       Icons.edit, // アイコンの種類
                       color: Colors.brown, // アイコンの色
                       size: SizeConfig.blockSizeHorizontal!  *4
                       ),
                      ),
                     ),
                    ],
                   ),
                   Divider(
                    color: Colors.yellow,
                    thickness: SizeConfig.blockSizeHorizontal! * 0.8,
                  ),
                 ],
                ),
               ),
                  Container(
                    height:SizeConfig.blockSizeHorizontal! * 4.2,
                    alignment: Alignment.topLeft, // テキストを左上に配置
                    child: Text(
                      '　課題',
                      textAlign: TextAlign.left, // テキスト自体の揃え方も指定
                      style: TextStyle(
                        fontSize: SizeConfig.blockSizeHorizontal! * 3.5,
                        fontWeight: FontWeight.w800,
                        color: const Color.fromARGB(255, 77, 46, 35),
                      ),
                    ),
                  ),
                  Container(
                    width:SizeConfig.blockSizeHorizontal!  *2,
                    height:SizeConfig.blockSizeHorizontal! * 0.6,        
                  ), // 適宜間隔を調整するためにSizedBoxを追加
                  Expanded(
                    child: SizedBox(
                      width: SizeConfig.blockSizeHorizontal!  *96,
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: SizedBox(
                              width: SizeConfig.blockSizeHorizontal!  *83,
                              height: SizeConfig.blockSizeHorizontal! * 3,
                              child: TextField(
                                controller: _controller2,
                                style:TextStyle(fontSize:  SizeConfig.blockSizeHorizontal! * 3,),
                                //onChanged: (newValue) {
                                //String userInput = _controller2.text;// テキストが変更された際の処理
                                //},
                                decoration: const InputDecoration(
                                  hintText: "課題",
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                    InkWell(
                      onTap: () {
                        setState(() {
                           String userInput2 = _controller2.text;
                         });
                        },
                      child: Container(
                      width:SizeConfig.blockSizeHorizontal! * 4.5,
                      height: SizeConfig.blockSizeHorizontal!  *4.5,
                      decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(10), // ボタンの角を丸くする
                       ),
                     child: Icon(
                       Icons.edit, // アイコンの種類
                       color: Colors.brown, // アイコンの色
                       size: SizeConfig.blockSizeHorizontal!  *4.5
                        ),
                       ),
                      ),
                     ],
                    ),
                   ),
                  ),
                  Container(
                    alignment: Alignment.topLeft, // テキストを左上に配置
                    child: Text(
                      '　期限',
                      textAlign: TextAlign.left, // テキスト自体の揃え方も指定
                      style: TextStyle(
                        fontSize: SizeConfig.blockSizeHorizontal! * 3.5,
                        fontWeight: FontWeight.w800,
                        color: const Color.fromARGB(255, 77, 46, 35),
                      ),
                    ),
                  ),
                  SizedBox(
                    width:SizeConfig.blockSizeHorizontal!  *2,
                    height:SizeConfig.blockSizeHorizontal! * 0.6,
                    ),
                  Expanded(
                    child: SizedBox(
                      width: SizeConfig.blockSizeHorizontal!  *96,
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: SizedBox(
                              width: SizeConfig.blockSizeHorizontal!  *35,
                              child: TextField(
                                style:TextStyle(fontSize:  SizeConfig.blockSizeHorizontal! * 3,),
                                controller: _controller3,
                                decoration: InputDecoration(
                                  hintText: "日付 (yyyy-MM-dd HH:mm)",
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                    InkWell(
                      onTap: () {
                        setState(() {
                           String userInput3 = _controller3.text;
                         });
                        },
                      child: Container(
                      width:SizeConfig.blockSizeHorizontal! * 4.5,
                      height: SizeConfig.blockSizeHorizontal!  *4.5,
                      decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(10), // ボタンの角を丸くする
                       ),
                     child: Icon(
                       Icons.edit, // アイコンの種類
                       color: Colors.brown, // アイコンの色
                       size: SizeConfig.blockSizeHorizontal!  *4.5
                       ),
                      ),
                     ),
                          Row(
                            children: <Widget>[
                              SizedBox(
                                width:SizeConfig.blockSizeHorizontal! * 17,
                                height:SizeConfig.blockSizeHorizontal! * 5,
                              ),
                              DaysLeft(),
                              SizedBox(width:SizeConfig.blockSizeHorizontal!  *2),
                              ButtonSwitching(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                  height:SizeConfig.blockSizeHorizontal! * 1,
                 ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 10),//カード間の隙間。固定値で。
      ],
    );
  }

  String initialData() {
    return TaskData();
  }

  String Titlename() {
    return _controller1.text;
  }

  ButtonSwitching() {
   if (widget.variable4 == true){
    if (widget.variable3.isBefore(DateTime.now()) == false) {
      return ElevatedButton(  //課題完了、期限内
        onPressed: () {
          setState(() {
              widget.variable4 = false;
            });
        },
        child: Text('  元に戻す  '),
        style: TextButton.styleFrom(
          backgroundColor: Colors.grey, 
          elevation: 0, // 影を消す
        ),
      );
    }else{
        return ElevatedButton(
          onPressed: () {
          },
          child: Text('スワイプ→'),//完了、期限切れ
          style: TextButton.styleFrom(
            backgroundColor: Colors.grey, // 背景色を透明に設定
            elevation: 0, // 影を消す
          ),
        );
    }
    }else {
      if (widget.variable3.isBefore(DateTime.now()) == false) {
        return ElevatedButton(//未完了、期限内
          onPressed: () {
            setState(() {
              widget.variable4 = true;
            });
          },
          child: Text('終わった！'),
          style: TextButton.styleFrom(
            backgroundColor: Colors.brown, 
            elevation: 0, 
          ),
        );
      } else {
        return ElevatedButton(
          onPressed: () {
          },
          child: Text('スワイプ→'),//未完了、期限切れ
          style: TextButton.styleFrom(
            backgroundColor: Colors.grey, // 背景色を透明に設定
            elevation: 0, // 影を消す
          ),
        );
      }
    }
  }

  DaysLeft() {
    if (widget.variable3.isBefore(DateTime.now()) == false) {
      Duration difference =
          widget.variable3.difference(DateTime.now()); // 日付の差を求める
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
  //

  TaskData() {
    String TodaysTask = _controller2.text;
    DateTime TimeLimit = widget.variable3;
    bool FinishOrNot = widget.variable4;

    String Limit = "\n締切…";
    String Task = "課題…";

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
                fontSize:  SizeConfig.blockSizeHorizontal! *4,
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
                fontSize:  SizeConfig.blockSizeHorizontal! * 4,
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
                fontSize:  SizeConfig.blockSizeHorizontal! * 4,
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
    super.dispose();
  }
}

