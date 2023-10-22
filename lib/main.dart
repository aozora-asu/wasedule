import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

main(){ 

Map<String,String> TodaysPlan={

//カレンダーから今日の予定を取得させる予定。
  "きょうの予定":"バイト18:00～"
 };

runApp(MyApp());

}

//以下はUI表示関連の関数です。
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.notoSansTextTheme(),
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 142, 23, 40),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'わせジュール(仮)',
                style: TextStyle(fontSize: 24),
              ),
              Text(
                '早稲田生のためのスケジュールアプリ',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
        body: Center(
          child: ListView(
            children: [
              DataCard(
                variable1: "線文字A 入門",
                variable2: "近くの遺跡を調査し、石板を発見して解読してくる。",
                variable3: DateTime(2023, 10, 25, 23, 59),
              ),
              DataCard(
                variable1: "ワセメシを探求する",
                variable2: "油そば4店舗をめぐり、感想を各1000字のレポートに書く。",
                variable3: DateTime(2023, 10, 22, 23, 59),
              ),
              DataCard(
                variable1: "マネーロンダリング論 入門",
                variable2: "違法行為により資金を調達してくる。最低40万円。",
                variable3: DateTime(2023, 10, 19, 23, 59),
              ),
              DataCard(
                variable1: "エスペラント語 1-1 S",
                variable2: "エスペラント語でのディスカッション資料を準備する。",
                variable3: DateTime(2023, 10, 31, 23, 59),
              ),
              DataCard(
                variable1: "線文字B 入門",
                variable2: "線文字Bにて詩を書く。最低4つ、400文字",
                variable3: DateTime(2023, 10, 25, 23, 59),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class DataCard extends StatefulWidget {
  final String variable1;
  final String variable2;
  final DateTime variable3;

  DataCard({
    required this.variable1,
    required this.variable2,
    required this.variable3,
  });

  @override
  _DataCardState createState() => _DataCardState();
}

class _DataCardState extends State<DataCard> {
  late TextEditingController _controller1;
  late TextEditingController _controller2;
  late TextEditingController _controller3;

  @override
  void initState() {
    super.initState();
    _controller1 = TextEditingController(text: widget.variable1);
    _controller2 = TextEditingController(text: widget.variable2);
    _controller3 = TextEditingController(text: widget.variable3.toString());
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(1.0),
      child: Card(
        child: SizedBox(
          width:500,
          height: 212,
          child: Column(
            children: <Widget>[
              ListTile(
                title: TextField(
                  controller: _controller1,
                  onChanged: (newValue) {
                    // テキストが変更された際の処理
                  },
                  decoration: InputDecoration(
                    hintText: "授業名",
                  ),
                ),
              ),
              Divider(
                color: Colors.yellow,
                thickness: 5,
              ),
              Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: TextField(
                  controller: _controller2,
                  onChanged: (newValue) {
                    // テキストが変更された際の処理
                  },
                  decoration: InputDecoration(
                    hintText: "課題",
                  ),
                ),
              ),
              
              Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: TextField(
                  controller: _controller3,
                  onChanged: (newValue) {
                    // 日付が変更された際の処理
                  },
                  decoration: InputDecoration(
                    hintText: "日付 (yyyy-MM-dd HH:mm)",
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // ボタンが押された時の処理
                  FinishProsess();
                },
                child: Text('タスク完了！'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 以下のメソッドはそのまま使います
  String initialData() {
    return TaskData();
  }

  String Titlename() {
    return _controller1.text;
  }

  TaskData() {
    String TodaysTask = _controller2.text;
    DateTime TimeLimit = widget.variable3;
    bool FinishOrNot = false;

    String Limit = "\n締切…";
    String Task = "課題…";

    if (TimeLimit.isBefore(DateTime.now()) == false) {
      if (FinishOrNot == false) {
        String aaa = "$TodaysTask$Limit$TimeLimit";
        return aaa;
      } else {
        return "";
      }
    } else {
      if (FinishOrNot == false) {
        String bbb = "$TodaysTask\n!!!期限超過!!!";
        return bbb;
      } else {
        return "課題はありません";
      }
    }
  }

  

  FinishProsess() {
    int FinishNumber = 0;

    if (FinishNumber == 0) {
      FinishNumber = 1;
      return "yet";
    } else {
      FinishNumber = 0;
      return "already";
    }
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }
}