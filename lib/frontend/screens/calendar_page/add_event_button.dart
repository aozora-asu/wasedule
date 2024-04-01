import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/screens/common/tutorials.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/add_template_button.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/calendar_page.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/schedule_data_manager.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/tag_and_template_page.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/time_input_page.dart';
import 'package:flutter_calandar_app/frontend/screens/common/app_bar.dart';
import 'package:flutter_calandar_app/frontend/screens/common/burger_menu.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/data_manager.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';
import '../../../backend/DB/handler/schedule_db_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final scheduleFormProvider =
    StateNotifierProvider<ScheduleFormNotifier, ScheduleForm>(
  (ref) => ScheduleFormNotifier(),
);

class ScheduleFormNotifier extends StateNotifier<ScheduleForm> {
  ScheduleFormNotifier() : super(ScheduleForm());

  void updateDateTimeFields() {
    state = state.copyWith();
  }

  void toggleSwitch() {
    state = state.copyWith(isPublic: !state.isPublic);
  }
}

class ScheduleForm {
  TextEditingController scheduleController = TextEditingController();
  TextEditingController dtStartController = TextEditingController();
  TextEditingController timeStartController = TextEditingController();
  TextEditingController dtEndController = TextEditingController();
  TextEditingController timeEndController = TextEditingController();
  TextEditingController tagController = TextEditingController();
  bool isAllDay = false;
  bool isPublic = true;
  TextEditingController publicScheduleController = TextEditingController();

  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();

  var dtStartList = [];
  var dtEndList = [];

  ScheduleForm copyWith({
    String? scheduleController,
    String? dtStartController,
    String? timeStartController,
    String? dtEndController,
    String? timeEndController,
    String? tagController,
    bool? isAllDay,
    bool? isPublic,
    String? publicScheduleController,
    String? dateController,
    String? timeController,
    var dtStartList,
    var dtEndList,
  }) {
    return ScheduleForm()
      ..scheduleController.text =
          scheduleController ?? this.scheduleController.text
      ..dtStartController.text =
          dtStartController ?? this.dtStartController.text
      ..timeStartController.text =
          timeStartController ?? this.timeStartController.text
      ..dtEndController.text = dtEndController ?? this.dtEndController.text
      ..timeEndController.text =
          timeEndController ?? this.timeEndController.text
      ..tagController.text = tagController ?? this.tagController.text
      ..isAllDay = isAllDay ?? this.isAllDay
      ..isPublic = isPublic ?? this.isPublic
      ..publicScheduleController.text =
          publicScheduleController ?? this.publicScheduleController.text
      ..dateController.text = dateController ?? this.dateController.text
      ..timeController.text = timeController ?? this.timeController.text
      ..dtStartList = dtStartList ?? this.dtStartList
      ..dtEndList = dtEndList ?? this.dtEndList;
  }

  void clearTimeStart() {
    timeStartController.clear();
  }

  void clearTimeEnd() {
    timeEndController.clear();
  }

  void clearDateStartList() {
    dtStartList = [];
  }

  void clearDateEndList() {
    dtEndList = [];
  }

  void clearContents() {
    scheduleController.clear();
    publicScheduleController.clear();
    dtEndController.clear();
    dtStartController.clear();
    timeStartController.clear();
    timeEndController.clear();
    tagController.clear();
    dtStartList = [];
    dtEndList = [];
  }

  void clearpublicScheduleController() {
    publicScheduleController.clear();
  }
}

class AddEventButton extends ConsumerStatefulWidget {
  @override
  _AddEventButtonState createState() => _AddEventButtonState();
}

class _AddEventButtonState extends ConsumerState {
  @override
  Widget build(BuildContext context) {
    final scheduleForm = ref.watch(scheduleFormProvider);
    return SizedBox(
      child: FloatingActionButton(
        heroTag: "calendar_1",
        onPressed: () {
          scheduleForm.clearContents();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CalendarInputForm(
                target: DateTime.now(),
                setosute: setState,
              ),
            ),
          );
        },
        foregroundColor: Colors.white,
        backgroundColor: ACCENT_COLOR,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CalendarInputForm extends ConsumerStatefulWidget {
  DateTime target;
  StateSetter setosute;

  CalendarInputForm({required this.target, required this.setosute});
  // final NotificationAppLaunchDetails? notificationAppLaunchDetails;
  // bool get didNotificationLaunchApp =>
  //     notificationAppLaunchDetails?.didNotificationLaunchApp ?? false;
  @override
  _CalendarInputFormState createState() => _CalendarInputFormState();
}

class _CalendarInputFormState extends ConsumerState<CalendarInputForm> {
  @override
  void initState() {
    super.initState();
    ref.read(scheduleFormProvider).clearContents();
    ref
        .read(scheduleFormProvider)
        .dtStartList
        .add(DateFormat('yyyy-MM-dd').format(widget.target));
    ref.read(scheduleFormProvider).isPublic = true;
  }

  @override
  Widget build(BuildContext context) {
    final scheduleForm = ref.watch(scheduleFormProvider);
    scheduleForm.isAllDay = false;
    return Scaffold(
        appBar: CustomAppBar(backButton: true,),
        drawer: burgerMenu(),
        body: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.only(right: 10, left: 10),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
                height: SizeConfig.blockSizeVertical! * 1,
                width: SizeConfig.blockSizeHorizontal! * 80),
            Row(
              children: [
                SizedBox(width: SizeConfig.blockSizeHorizontal! * 3),
                Image.asset('lib/assets/eye_catch/eyecatch.png',
                    height: 30, width: 30),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "予定を追加…",
                      style: TextStyle(
                        fontSize: SizeConfig.blockSizeHorizontal! * 8,
                        fontWeight: FontWeight.w700,
                      ),
                    ))
              ],
            ),
            const Divider(indent: 7, endIndent: 7, thickness: 3),
            SizedBox(
                height: SizeConfig.blockSizeVertical! * 1,
                width: SizeConfig.blockSizeHorizontal! * 80),
            Container(
              height: SizeConfig.blockSizeVertical! * 10,
              child: TextFormField(
                controller: scheduleForm.scheduleController,
                onFieldSubmitted: (value) {
                  ref
                      .read(scheduleFormProvider.notifier)
                      .updateDateTimeFields();
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '予定名*',
                  labelStyle: TextStyle(color: Colors.red),
                ),
              ),
            ),

            Row(children: [
              ElevatedButton(
                  onPressed: () async {
                    scheduleForm.clearDateStartList();
                    _selectDateMultipul(
                        context, ref.read(scheduleFormProvider).dtStartList);
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color?>(ACCENT_COLOR),
                  ),
                  child: const Text(" + 日付       ",
                      style: TextStyle(color: Colors.white))),
              dateInputPreview(scheduleForm.dtStartList)
            ]),

            Row(children: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => TimeInputPage(
                                target: widget.target,
                                inputCategory: "startTime",
                              )),
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color?>(ACCENT_COLOR),
                  ),
                  child: const Text("+ 開始時刻",
                      style: TextStyle(color: Colors.white))),
              timeInputPreview(scheduleForm.timeStartController.text)
            ]),

            Row(children: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => TimeInputPage(
                                target: widget.target,
                                inputCategory: "endTime",
                              )),
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color?>(ACCENT_COLOR),
                  ),
                  child: const Text("+ 終了時刻",
                      style: TextStyle(color: Colors.white))),
              timeInputPreview(scheduleForm.timeEndController.text)
            ]),

            tagEmptyFlag(ref, Row(children: [
              ElevatedButton(
                  onPressed: () {
                    showTagDialogue(ref, context, setState);
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color?>(ACCENT_COLOR),
                  ),
                  child: const Text("+    タグ     ",
                      style: TextStyle(color: Colors.white))),
              timeInputPreview(
                  returnTagData(scheduleForm.tagController.text, ref))
            ]),),
            

            
            Row(children: [
              ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (scheduleForm.isPublic) {
                        scheduleForm.isPublic = false;
                      } else {
                        scheduleForm.isPublic = true;
                      }
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color?>(ACCENT_COLOR),
                  ),
                  child: const Text("共有時表示",
                      style: TextStyle(color: Colors.white))),
              isPublicPreview(scheduleForm.isPublic)
            ]),

            templateEmptyFlag(ref,
              Column(children:[
                SizedBox(
                  width: SizeConfig.blockSizeHorizontal! * 80,
                  height: SizeConfig.blockSizeVertical! * 0.5,
                ),
                addTemplateButton(),
                SizedBox(
                  width: SizeConfig.blockSizeHorizontal! * 80,
                  height: SizeConfig.blockSizeVertical! * 0.5,
                ),
              ])
            ),
            
            const Divider(indent: 7, endIndent: 7, thickness: 3),
            SizedBox(
              width: SizeConfig.blockSizeHorizontal! * 80,
              height: SizeConfig.blockSizeVertical! * 1,
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    scheduleForm.clearContents();
                    Navigator.pop(context);
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color?>(ACCENT_COLOR),
                    fixedSize: MaterialStateProperty.all<Size>(
                      Size(SizeConfig.blockSizeHorizontal! * 45,
                          SizeConfig.blockSizeHorizontal! * 7.5),
                    ),
                  ),
                  child:
                      const Text('戻る', style: TextStyle(color: Colors.white)),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    if (scheduleForm.dtStartList.isEmpty ||
                        scheduleForm.scheduleController.text.isEmpty) {
                      print("ボタン無効");
                    } else {
                      if (scheduleForm
                              .dtEndController.text.isNotEmpty && //仮で条件変更してます
                          scheduleForm.timeEndController.text.isNotEmpty) {
                        print("ボタン無効");
                      } else {
                        if (scheduleForm.dtEndController.text.isNotEmpty &&
                            scheduleForm.timeEndController.text.isEmpty) {
                          print("ボタン無効");
                        } else {
                          if (isConflict(scheduleForm.timeStartController.text,
                              scheduleForm.timeEndController.text)) {
                            print("ボタン無効");
                          } else {
                            int intIspublic;
                            if (scheduleForm.isPublic) {
                              intIspublic = 1;
                            } else {
                              intIspublic = 0;
                            }

                            //共有用予定が空だったら、個人用予定と揃える
                            if (scheduleForm
                                .publicScheduleController.text.isEmpty) {
                              scheduleForm.publicScheduleController =
                                  scheduleForm.scheduleController;
                            }
                            
                            for (int i = 0;
                                i < scheduleForm.dtStartList.length;
                                i++) {
                              
                              Map<String, dynamic> schedule = {
                                "subject": scheduleForm.scheduleController.text,
                                "startDate":
                                    scheduleForm.dtStartList.elementAt(i),
                                "startTime":
                                    scheduleForm.timeStartController.text,
                                "endDate": scheduleForm.dtStartList
                                    .elementAt(i),
                                "endTime": scheduleForm.timeEndController.text,
                                "isPublic": intIspublic,
                                "publicSubject":
                                    scheduleForm.publicScheduleController.text,
                                "tag": scheduleForm.tagController.text,
                                
                                //★ IDからtagIDを返す関数です！
                                //"tagID" : returnTagIdFromID(scheduleForm.tagController.text, ref)

                              };
                              await ScheduleDatabaseHelper()
                                  .resisterScheduleToDB(schedule);
                            }
                            ref.read(scheduleFormProvider).clearContents();

                            ref.read(calendarDataProvider.notifier).state =
                                CalendarData();
                            ref.read(taskDataProvider).isRenewed = true;
                            while (
                                ref.read(taskDataProvider).isRenewed != false) {
                              await Future.delayed(
                                  const Duration(milliseconds: 1));
                            }
                            widget.setosute(() {});
                            Navigator.pop(context);
                            if(ref.read(calendarDataProvider).calendarData.last["id"] == 1){
                              showTagAndTemplateGuide(context);
                            }
                          }
                        }
                      }
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                        (Set<MaterialState> states) {
                      // 条件によってボタンの色を選択
                      if (scheduleForm.dtStartList.isEmpty ||
                          scheduleForm.scheduleController.text.isEmpty) {
                        return Colors.grey;
                      } else {
                        if (scheduleForm.dtEndController.text.isNotEmpty &&
                            scheduleForm.timeEndController.text.isNotEmpty) {
                          return Colors.grey;
                        } else {
                          if (scheduleForm.dtEndController.text.isNotEmpty &&
                              scheduleForm.timeEndController.text.isEmpty) {
                            return Colors.grey;
                            // ボタンが無効の場合の色
                          } else {
                            if (isConflict(
                                scheduleForm.timeStartController.text,
                                scheduleForm.timeEndController.text)) {
                              return Colors.grey;
                            } else {
                              return MAIN_COLOR; // ボタンが通常の場合の色
                            }
                          }
                        }
                      }
                    }),
                    fixedSize: MaterialStateProperty.all<Size>(Size(
                      SizeConfig.blockSizeHorizontal! * 45,
                      SizeConfig.blockSizeHorizontal! * 7.5,
                    )),
                  ),
                  child:
                      const Text('追加', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ]),
        )));
  }

  Widget dateInputPreview(List textList) {
    String previewText = "なし";
    String convertedList = textList.join('\n');

    if (textList.isNotEmpty) {
      previewText = convertedList;
    }

    return Expanded(
        child: Center(
            child: Text(
      previewText,
      style: const TextStyle(
          color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 30),
      overflow: TextOverflow.visible,
    )));
  }

  Widget timeInputPreview(String text) {
    String previewText = "なし";
    if (text != "") {
      previewText = text;
    }

    return Expanded(
        child: Center(
            child: Text(
      previewText,
      style: const TextStyle(
          color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 30),
      overflow: TextOverflow.visible,
    )));
  }

  Widget isPublicPreview(bool isPublic) {
    String previewText = "表示しない";
    if (isPublic) {
      previewText = "表示する";
    }

    return Expanded(
        child: Center(
            child: Text(
      previewText,
      style: const TextStyle(
          color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 30),
      overflow: TextOverflow.visible,
    )));
  }

  Widget addTemplateButton() {
    return ElevatedButton(
      onPressed: () {
        showTemplateDialogue();
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color?>(MAIN_COLOR),
      ),
      child: const Row(children: [
        Spacer(),
        Icon(Icons.add, color: Colors.white),
        SizedBox(width: 10),
        Text('テンプレート', style: TextStyle(color: Colors.white)),
        Spacer(),
      ]),
    );
  }

  Widget publicScheduleField(ref) {
    final scheduleForm = ref.watch(scheduleFormProvider);
    if (scheduleForm.isPublic == true) {
      return Container(
        child: Column(children: [
          TextField(
            controller: scheduleForm.publicScheduleController,
            decoration: const InputDecoration(
                border: OutlineInputBorder(), labelText: 'フレンドに見せる予定名'),
          ),
          SizedBox(
            width: SizeConfig.blockSizeHorizontal! * 80,
            height: SizeConfig.blockSizeVertical! * 1,
          ),
        ]),
      );
    } else {
      scheduleForm.clearpublicScheduleController();
      return const SizedBox(width: 0, height: 0);
    }
  }

  Future<void> _showTextDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController _textEditingController = TextEditingController();
        return AlertDialog(
          title: const Text('タグを入力…'),
          content: TextField(
            controller: _textEditingController,
            decoration: const InputDecoration(
                labelText: '新しいタグ', border: OutlineInputBorder()),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('戻る'),
            ),
            TextButton(
              onPressed: () {
                ref.read(scheduleFormProvider).tagController.text =
                    _textEditingController.text;
                ref.read(scheduleFormProvider.notifier).updateDateTimeFields();
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  bool isConflict(String start, String end) {
    if (returnTagIsBeit(
                ref.watch(scheduleFormProvider).tagController.text, ref) ==
            1 &&
        (start == "" || end == "")) {
      return true;
    } else if (end == "") {
      return false;
    } else if (start == "" && end != "") {
      return true;
    } else {
      Duration startTime = Duration(
          hours: int.parse(start.substring(0, 2)),
          minutes: int.parse(start.substring(3, 5)));
      Duration endTime = Duration(
          hours: int.parse(end.substring(0, 2)),
          minutes: int.parse(end.substring(3, 5)));

      if (startTime >= endTime) {
        return true;
      } else {
        return false;
      }
    }
  }

  Future<void> _selectDateMultipul(BuildContext context, var targetList) async {
    await showDialog(
        context: context,
        builder: (_) {
          return SimpleDialog(
            contentPadding: const EdgeInsets.all(0.0),
            titlePadding: const EdgeInsets.all(0.0),
            title: SizedBox(
              height: 400,
              child: Scaffold(
                body: SizedBox(
                  child: SfDateRangePicker(
                    headerHeight: 60,
                    todayHighlightColor: MAIN_COLOR,
                    selectionColor: MAIN_COLOR,
                    headerStyle: const DateRangePickerHeaderStyle(
                        backgroundColor: MAIN_COLOR,
                        textStyle: TextStyle(color: Colors.white)),
                    // controllerは設定しなくてもOK!
                    // 他の項目も必要なものだけ設定してください。他にも色々あります。
                    view: DateRangePickerView.month,
                    initialSelectedDate: DateTime.now(), // 選択済みの日
                    // multiple 複数日
                    // range 連日
                    // multiRange 複数連日 などバリエーション豊かに選択範囲が設定できます！
                    selectionMode: DateRangePickerSelectionMode.multiple,
                    allowViewNavigation: true, // 月移動矢印
                    navigationMode: DateRangePickerNavigationMode
                        .snap, // スクロール量、止まる位置 snapは月毎にぴったり止まって切り替わる
                    showNavigationArrow: true,
                    showActionButtons: true, // 下のボタンを表示したい時
                    onSubmit: (dynamic value) {
                      if (value.isNotEmpty) {
                        for (int i = 0; i < value.length; i++) {
                          String result = DateFormat('yyyy-MM-dd')
                              .format(value.elementAt(i));
                          targetList.add(result);
                        }
                        ref
                            .read(scheduleFormProvider.notifier)
                            .updateDateTimeFields();
                      }
                      setState(() {
                        Navigator.pop(context);
                      });
                    },
                    onCancel: () {
                      Navigator.pop(context);
                    },
                    confirmText: "ＯＫ",
                    cancelText: "戻る",
                  ),
                ),
              ),
            ),
          );
        });
  }

  Future<void> showTemplateDialogue() async {
    final data = ref.read(calendarDataProvider);
    List tempLateMap = data.templateData;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("テンプレート選択"),
          actions:[ 
            SizedBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "テンプレート:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                SizedBox(
                  width: double.maxFinite,
                  height:listViewHeight(50, tempLateMap.length),
                  child: ListView.separated(
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 5),
                    itemCount: tempLateMap.length,
                    itemBuilder: (BuildContext context, index) => InkWell(
                      onTap: () async {
                        setState(() {
                          final inputform = ref.watch(scheduleFormProvider);
                          inputform.scheduleController.text =
                              data.templateData.elementAt(index)["subject"];
                          inputform.timeStartController.text =
                              data.templateData.elementAt(index)["startTime"];
                          inputform.timeEndController.text =
                              data.templateData.elementAt(index)["endTime"];
                          inputform.tagController.text =
                              data.templateData.elementAt(index)["tag"];
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              timedata(index),
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.white),
                            ),
                            Text(
                              "  " +
                                  ref
                                      .read(calendarDataProvider)
                                      .templateData
                                      .elementAt(index)["subject"],
                              style: const TextStyle(
                                  fontSize: 20, color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
             SizedBox(
              width:1700,
                child:ElevatedButton(
                  style: const ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll(Colors.blueAccent)),
      
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            TemplateInputForm(setosute: setState),
                      ),
                    );
                  },
                  child: const Text(
                    "+ テンプレートを追加…",
                    style: TextStyle(color: Colors.white),
                  ),
                ),)
              ],
            ),
          ),

            ],
        );
      },
    );
  }

  String timedata(index) {
    if (ref
                .read(calendarDataProvider)
                .templateData
                .elementAt(index)["startTime"] ==
            "" &&
        ref
                .read(calendarDataProvider)
                .templateData
                .elementAt(index)["endTime"] ==
            "") {
      return "      終日";
    } else {
      return "      " +
          ref
              .read(calendarDataProvider)
              .templateData
              .elementAt(index)["startTime"] +
          " ～ " +
          ref
              .read(calendarDataProvider)
              .templateData
              .elementAt(index)["endTime"];
    }
  }
}



double listViewHeight(double itemHeight, int itemLength){
  switch (itemLength){
    case 0: return 0;
    case 1: return itemHeight;
    case 2: return itemHeight * 2;
    case 3: return itemHeight *3;
    case 4: return itemHeight *4;
    default : return itemHeight *5;
  }
}