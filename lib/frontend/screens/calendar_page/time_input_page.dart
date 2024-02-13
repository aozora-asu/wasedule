import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/add_event_button.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/daily_view_page.dart';
import 'package:flutter_calandar_app/frontend/screens/common/app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TimeInputPage extends ConsumerStatefulWidget {
  DateTime target;
  String inputCategory;


  TimeInputPage({required this.target, required this.inputCategory});


  @override
  TimeInputPageState createState() => TimeInputPageState();
}

class TimeInputPageState extends ConsumerState<TimeInputPage> {
  Map<String, int> userImput = {};

  @override
  void initState() {
    super.initState();
    userImput = {
      "hourDigit10": 0,
      "hourDigit1": 0,
      "minuteDigit10": 0,
      "minuteDigit1": 0
    };
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        appBar: const CustomAppBar(),

        body: Padding(
            padding: EdgeInsets.only(
                left: SizeConfig.blockSizeHorizontal! * 3,
                right: SizeConfig.blockSizeHorizontal! * 3),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 5),
              Row(
                children: [
                  SizedBox(width: SizeConfig.blockSizeHorizontal! * 3),
                  Image.asset('lib/assets/eye_catch/eyecatch.png',
                      height: 30, width: 30),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        " 時間を入力(24時間)…",
                        style: TextStyle(
                          fontSize: SizeConfig.blockSizeHorizontal! * 8,
                          fontWeight: FontWeight.w700,
                        ),
                      ))
                ],
              ),
              const SizedBox(height: 15),
              Row(children: [
                numPanel(1, "時間"),
                numPanel(2, "時間"),
                numPanel(3, "時間"),
                numPanel(4, "時間"),
                numPanel(5, "時間")
              ]),
              Row(children: [
                numPanel(6, "時間"),
                numPanel(7, "時間"),
                numPanel(8, "時間"),
                numPanel(9, "時間"),
                numPanel(0, "時間")
              ]),
              imputButton("時"),
              const SizedBox(height: 15),
              Row(children: [
                numPanel(1, "分"),
                numPanel(2, "分"),
                numPanel(3, "分"),
                numPanel(4, "分"),
                numPanel(5, "分")
              ]),
              Row(children: [
                numPanel(6, "分"),
                numPanel(7, "分"),
                numPanel(8, "分"),
                numPanel(9, "分"),
                numPanel(0, "分")
              ]),
              imputButton("分"),
              const SizedBox(height: 15),
              const Divider(indent: 7, endIndent: 7, thickness: 4),
              Row(children: [modoruButton(), const Spacer(), submitButton()])
            ])));

  }

  Widget numPanel(int num, String category) {
    return InkWell(
        child: Container(

          width: SizeConfig.blockSizeHorizontal! * 18.8,

          height: SizeConfig.blockSizeHorizontal! * 20,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            border: Border.all(
              color: Colors.grey,
              width: 2.0,
            ),
          ),
          child: Center(
            child: Text(
              num.toString(),
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        onTap: () {
          if (category == "時間") {
            if (userImput["hourDigit10"]! > 2) {
              setState(() {
                userImput["hourDigit10"] = 2;
                userImput["hourDigit1"] = 3;
              });
            } else {
              if (userImput["hourDigit10"] == 0 &&
                  userImput["hourDigit1"] == 0) {
                setState(() {
                  userImput["hourDigit1"] = num;
                });
              } else {
                setState(() {
                  userImput["hourDigit10"] = userImput["hourDigit1"]!;
                  userImput["hourDigit1"] = num;
                });

                if (userImput["hourDigit10"]! * 10 + userImput["hourDigit1"]! >
                    23) {
                  setState(() {
                    userImput["hourDigit10"] = 2;
                    userImput["hourDigit1"] = 3;
                  });
                }
              }
            }
          } else {
            if (userImput["minuteDigit10"]! > 6) {
              setState(() {
                userImput["minuteDigit10"] = 0;
                userImput["minuteDigit1"] = 0;
              });
            } else {
              if (userImput["minuteDigit10"] == 0 &&
                  userImput["minuteDigit1"] == 0) {
                setState(() {
                  userImput["minuteDigit1"] = num;
                });
              } else {
                setState(() {
                  userImput["minuteDigit10"] = userImput["minuteDigit1"]!;
                  userImput["minuteDigit1"] = num;
                });

                if (userImput["minuteDigit10"]! * 10 +
                        userImput["minuteDigit10"]! >
                    60) {
                  setState(() {
                    userImput["minuteDigit10"] = 0;
                    userImput["minuteDigit1"] = 0;
                  });
                }
              }
            }
          }
        });
  }

  Widget imputButton(String category) {
    return ElevatedButton(
      onPressed: () {
        if (category == "時") {
          setState(() {
            userImput["hourDigit10"] = 0;
            userImput["hourDigit1"] = 0;
          });
        } else {
          setState(() {
            userImput["minuteDigit10"] = 0;
            userImput["minuteDigit1"] = 0;
          });
        }
      },
      style: ElevatedButton.styleFrom(
        fixedSize: Size(
          SizeConfig.blockSizeHorizontal! * 100,
          SizeConfig.blockSizeVertical! * 5,
        ),
        backgroundColor: Colors.blueAccent, // ボタンの背景色
        textStyle: const TextStyle(color: Colors.white), // テキストの色
      ),
      child: Row(children: [
        const Spacer(),
        Text(preview(category) + category,style:const TextStyle(color:Colors.white)),
        const SizedBox(width: 20),
        const Icon(
          Icons.delete,
          color: Colors.white,
        ),
        const Spacer(),
      ]), // ボタンのテキスト
    );

  }

  String preview(category) {
    if (category == "時") {
      return userImput["hourDigit10"].toString() +
          userImput["hourDigit1"].toString();
    } else {
      return userImput["minuteDigit10"].toString() +
          userImput["minuteDigit1"].toString();
    }
  }

  Widget submitButton() {
    return ElevatedButton(
      onPressed: () async {
        String inputResult;
        String hour = "";
        String minute = "";
        hour = userImput["hourDigit10"].toString() +
            userImput["hourDigit1"].toString();
        minute = userImput["minuteDigit10"].toString() +
            userImput["minuteDigit1"].toString();
        inputResult = hour + ":" + minute;

        TextEditingController timeController = TextEditingController();
        final inputForm = ref.watch(scheduleFormProvider);

        if (widget.inputCategory == "startTime") {
          timeController = inputForm.timeStartController;
          timeController.text = inputResult;
          ref.read(scheduleFormProvider.notifier).updateDateTimeFields();
        } else if (widget.inputCategory == "endTime"){
          timeController = inputForm.timeEndController;
          timeController.text = inputResult;
          ref.read(scheduleFormProvider.notifier).updateDateTimeFields();
        }
        Navigator.pop(context);
      },
      style: ElevatedButton.styleFrom(
        fixedSize: Size(
          SizeConfig.blockSizeHorizontal! * 45,
          SizeConfig.blockSizeVertical! * 5,
        ),
        backgroundColor: MAIN_COLOR, // ボタンの背景色
        textStyle: const TextStyle(color: Colors.white), // テキストの色
      ),
      child: Text(userImput["hourDigit10"].toString() +
          userImput["hourDigit1"].toString() +
          "時" +
          userImput["minuteDigit10"].toString() +
          userImput["minuteDigit1"].toString() +
          "分で登録",
          style:const TextStyle(color:Colors.white)
          ), // ボタンのテキスト
    );
  }

  Widget modoruButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context);
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color?>(ACCENT_COLOR),
        fixedSize: MaterialStateProperty.all<Size>(
          Size(SizeConfig.blockSizeHorizontal! * 45,
              SizeConfig.blockSizeVertical! * 5),
        ),
      ),
      child: const Text('戻る', style: TextStyle(color: Colors.white)),

    );
  }
}
