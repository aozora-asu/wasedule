import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/widgets.dart';

import '../../size_config.dart';
import '../../colors.dart';
import '../../../../backend/DB/db_Manager.dart';
import '../../../../backend/temp_file.dart';

void testFlug(){
int flug = 0;          //0=Y 1=Tです。
if(flug == 0){

}else{

}
}

//このデータが出力されてきたと想定
//Map <String,dynamic> events = resisterTaskToDb(url_y);
  Map <String,dynamic> events = {"events":[{
						"SUMMARY":"#1 アンケート (アンケート開始)",
						"DESCRIPTION":"#1 アンケート",
						"DTEND":"2023-10-30 03:59:00.000",
						"CATEGORIES":"素数の魅力と暗号理論 02(20239S0200010202)",
						"MEMO":null
						},{
						"SUMMARY":"#2 アンケート (アンケート開始)",
						"DESCRIPTION":"#2 アンケート",
						"DTEND":"2023-10-23 00:00:00.000",
						"CATEGORIES":"素数の魅力と暗号理論 02(20239S0200010202)",
						"MEMO":null
						},{
						"SUMMARY":"質問申請フォーム/Question Application Form (アンケート開始)",
						"DESCRIPTION":"質問申請フォーム/Question Application Form",
						"DTEND":"2023-10-05 05:00:00.000",
						"CATEGORIES":"グローバルエデュケーションセンター情報対面指導室/Global Education Center IT Personal Tut",
						"MEMO":null
						},{
						"SUMMARY":"「第6回小レポート」の提出期限",
						"DESCRIPTION":"sample04.dbのstockテーブルを使って、以下の要件ああああ",
						"DTEND":"2023-10-05 05:00:00.000",
						"CATEGORIES":"データベース（SQL入門）　０２",
						"MEMO":null
						},{
						"SUMMARY":"「第5回課題」の提出期限",
						"DESCRIPTION":"5-1SQLiteにはREPLACE(X, Y, Z)という文字列関数",
						"DTEND":"2023-10-05 05:00:00.000",
						"CATEGORIES":"データベース（SQL入門）　０２",
						"MEMO":null
						},
					 ]
          };





class TaskPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: 
        Center(
        child: ListView(
          children: [
        for (int i = 0; i < events["events"].length; i++)...
          {
            DataCard(
		            variable1: events["events"][i]["CATEGORIES"],
                variable2: events["events"][i]["DESCRIPTION"],
                variable3: DateTime.parse(events["events"][i]["DTEND"]),
                variable4: false)
          }
        ],
       ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          testFlug();
         },
        child: Icon(Icons.get_app), // ボタンのアイコン
        backgroundColor: MAIN_COLOR, // ボタンの背景色
       ),
      
     
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
                                width:SizeConfig.blockSizeHorizontal! * 5,
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
    //課題完了、期限内
      return ElevatedButton(
        onPressed: () {
          setState(() {
              widget.variable4 = false;
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
              widget.variable4 = true;
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

