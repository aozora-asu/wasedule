import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/db_Manager.dart';
import 'package:flutter_calandar_app/backend/http_request.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/widgets.dart';

import '../../size_config.dart';
import '../../colors.dart';

class TaskPage extends StatefulWidget {
  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  Future<Map<String, dynamic>>? events;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await resisterTaskToDB(urlString);
    setState(() {
      events = Future.value(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder<Map<String, dynamic>>(
          future: events,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            } else if (snapshot.hasData) {
              // データが読み込まれた場合、リストを生成
              return buildDataCards(
                  snapshot.data!["events"] as List<Map<String, dynamic>>);
            } else {
              // データがない場合の処理（nullの場合など）
              return CircularProgressIndicator();
            }
          },
        floatingActionButton: FloatingActionButton(
        onPressed: () {
          testFlug();
         },
        child: Icon(Icons.get_app), // ボタンのアイコン
        backgroundColor: MAIN_COLOR, // ボタンの背景色
       ),),
      ),
    );
  }
}



class DataCard extends StatefulWidget {
  final String categories; // 授業名
  final String? description; // 課題
  final DateTime dtEnd; // 期限
  final String? memo;
  bool isDone; // 課題が終了したか(trueで済)

  DataCard({
    required this.categories,
    this.description,
    required this.dtEnd,
    required this.memo,
    required this.isDone,
  });

  @override
  _DataCardState createState() => _DataCardState();
}

Widget buildDataCards(List<Map<String, dynamic>> data) {
  if (data == null) {
    return CircularProgressIndicator();
  }
  for (int i = 0; i < data.length; i++) {
    print(data.length);
    print(data[i]["memo"]);
  }
  return ListView(
    children: [
      for (int i = 0; i < data.length; i++)
        DataCard(
          categories: data[i]["categories"],
          description: data[i]["description"],
          dtEnd: DateTime.fromMillisecondsSinceEpoch(data[i]["dtEnd"]),
          memo: null,
          isDone: false,
        )
    ],
  );
}

//ここにmemo追加しといてー。上のは追加した
class _DataCardState extends State<DataCard> {
  late TextEditingController _controller1;
  late TextEditingController _controller2;
  late TextEditingController _controller3;
  late TextEditingController _controller4;

  @override
  void initState() {
    super.initState();
    _controller1 = TextEditingController(text: widget.categories);
    _controller2 = TextEditingController(text: widget.description);
    _controller3 = TextEditingController(text: widget.dtEnd.toString());
    _controller4 = TextEditingController(text: widget.isDone.toString());
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
              height: SizeConfig.blockSizeHorizontal! * 35,
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
                               height: SizeConfig.blockSizeHorizontal!  *9.5),
                      Container(
                        width: SizeConfig.blockSizeHorizontal!  *68,
                        height: SizeConfig.blockSizeHorizontal!  *9.5,
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
                  Row(children:[
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
                    SizedBox(
                      width: SizeConfig.blockSizeHorizontal!  *96,
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: SizedBox(
                              width: SizeConfig.blockSizeHorizontal! * 35,
                              child: TextField(
                                style: TextStyle(
                                  fontSize: SizeConfig.blockSizeHorizontal! * 3,
                                ),
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
                              width: SizeConfig.blockSizeHorizontal! * 4.5,
                              height: SizeConfig.blockSizeHorizontal! * 4.5,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius:
                                    BorderRadius.circular(10), // ボタンの角を丸くする
                              ),
                              child: Icon(Icons.edit, // アイコンの種類
                                  color: Colors.brown, // アイコンの色
                                  size: SizeConfig.blockSizeHorizontal! * 4.5),
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
                              Container(
                               width:SizeConfig.blockSizeHorizontal!  *20,
                               height:SizeConfig.blockSizeHorizontal!  *5,
                               child: ButtonSwitching(),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  ),
                Row(children:[
                  Container(
                    height:SizeConfig.blockSizeHorizontal! * 4.2,
                    alignment: Alignment.topLeft, 
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
                  ),
                    SizedBox(
                      width: SizeConfig.blockSizeHorizontal!  *96,
                      height:SizeConfig.blockSizeHorizontal!  *10,
                      child: Row(
                         children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: SizedBox(
                              width: SizeConfig.blockSizeHorizontal!  *75,
                              height: SizeConfig.blockSizeHorizontal! *25,
                              child: TextField(
                                 maxLines: 3,
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
                  ],
                 ),
                  SizedBox(
                    height: SizeConfig.blockSizeHorizontal! * 1,
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 10), //カード間の隙間。固定値で。
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
        style: TextStyle(
          fontSize: SizeConfig.blockSizeHorizontal! * 2
        )
        ),
        style:ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.grey), // ボタンの背景色
          elevation: MaterialStateProperty.all(0),
          ),     
         );
    }else{
      //完了、期限切れ
        return ElevatedButton(
          onPressed: () {
          },
          child: Text('スワイプ→',
          style: TextStyle(
          fontSize: SizeConfig.blockSizeHorizontal! * 2
        ),
        ),
        style:ButtonStyle(
         backgroundColor: MaterialStateProperty.all(Colors.grey), // ボタンの背景色
         elevation: MaterialStateProperty.all(0),
        ), 
       );
    }
    }else {
      if (widget.variable3.isBefore(DateTime.now()) == false) {
        //未完了、期限内
        return ElevatedButton(
          onPressed: () {
            setState(() {
              widget.isDone = true;
            });
          },
          child: Text('終わった！',
          style: TextStyle(
          fontSize: SizeConfig.blockSizeHorizontal! * 2
        )
        ),
        style:ButtonStyle(
         backgroundColor: MaterialStateProperty.all(Colors.brown), // ボタンの背景色
         elevation: MaterialStateProperty.all(0),
        ), 
        );
      } else {
      //未完了、期限切れ
        return ElevatedButton(
          onPressed: () {
          },
          child: Text('スワイプ→',
          style: TextStyle(
          fontSize: SizeConfig.blockSizeHorizontal! * 2
        ),
        ),
        style:ButtonStyle(
         backgroundColor: MaterialStateProperty.all(Colors.grey), // ボタンの背景色
         elevation: MaterialStateProperty.all(0),
        ), 
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
  //

  TaskData() {
    String TodaysTask = _controller2.text;
    DateTime TimeLimit = widget.dtEnd;
    bool FinishOrNot = widget.isDone;

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
    super.dispose();
  }
}
