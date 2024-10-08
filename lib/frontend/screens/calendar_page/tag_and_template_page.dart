import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_calandar_app/backend/DB/handler/schedule_template_db_handler.dart';
import 'package:flutter_calandar_app/backend/DB/handler/tag_db_handler.dart';
import 'package:flutter_calandar_app/frontend/screens/common/ui_components.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/daily_view_sheet.dart';
import 'package:flutter_calandar_app/frontend/screens/common/plain_appbar.dart';
import 'package:flutter_calandar_app/frontend/screens/common/tutorials.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/add_event_dialog.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/add_template_dialog.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/calendar_data_manager.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/task_data_manager.dart';
import 'package:intl/intl.dart';

class TagAndTemplatePage extends ConsumerStatefulWidget {
  const TagAndTemplatePage({super.key});

  @override
  _TagAndTemplatePageState createState() => _TagAndTemplatePageState();
}

class _TagAndTemplatePageState extends ConsumerState<TagAndTemplatePage> {
  @override
  Widget build(BuildContext context) {
    ref.watch(taskDataProvider);
    return Scaffold(
      appBar: CustomAppBar(backButton: true),
      body: SingleChildScrollView(
          child: Column(children: [
        const SizedBox(height: 8),
        const Align(
          alignment: Alignment.centerLeft,
          child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            SizedBox(width: 20),
            Text(
              ' 入力テンプレート',
              style: TextStyle(
                  fontSize: 25,
                  fontWeight:FontWeight.bold,
                  color: BLUEGREY),
            ),
          ]),
        ),
        SizedBox(
          width: SizeConfig.blockSizeHorizontal! * 100,
          child: templateListView(),
        ),
        Column(children: [
          InkWell(
              child: Container(
                width: SizeConfig.blockSizeHorizontal! * 95,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(12.0), // 角丸の半径
                ),
                child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "  +   テンプレートの追加...",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold),
                      )
                    ]),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => TemplateInputForm(
                            setosute: setState,
                          )),
                );
              }),
          const SizedBox(height: 15)
        ]),
        const Divider(
          thickness: 3,
          indent: 10,
          endIndent: 10,
        ),
        const SizedBox(height: 5),
        Align(
          alignment: Alignment.centerLeft,
          child: Row(children: [
            const SizedBox(width: 20),
            const Text(
              'タグ',
              style: TextStyle(
                  fontSize: 25,
                  fontWeight:FontWeight.bold,
                  color: BLUEGREY),
            ),
            SizedBox(width: SizeConfig.blockSizeHorizontal! * 2),
          ]),
        ),
        tagDataList(),
          InkWell(
              child: Container(
                width: SizeConfig.blockSizeHorizontal! * 95,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 239, 218), // コンテナの背景色
                  borderRadius: BorderRadius.circular(12.0), // 角丸の半径
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5), // 影の色と透明度
                      spreadRadius: 2, // 影の広がり
                      blurRadius: 4, // 影のぼかし
                      offset: const Offset(0, 2), // 影の方向（横、縦）
                    ),
                  ],
                ),
                child: const Row(
                    children: [
                      Text(
                        "  +   タグの追加...",
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 25,
                            fontWeight: FontWeight.bold),
                      )
                    ]),
              ),
              onTap: () {
                tagDialog();
              }),
      ])),
    );
  }

  Widget templateListView() {
    final taskData = ref.read(taskDataProvider);
    final data = ref.read(calendarDataProvider);
    ref.watch(calendarDataProvider);

    List targetData = data.templateData;
    return ListView.separated(
      itemBuilder: (BuildContext context, int index) {
        Widget dateTimeData = Container();
        if (targetData.elementAt(index)["startTime"].trim() != "" &&
            targetData.elementAt(index)["endTime"].trim() != "") {
          dateTimeData = Text(
            "${" " +
                targetData.elementAt(index)["startTime"]}～" +
                targetData.elementAt(index)["endTime"],
            style: const TextStyle(
                color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
          );
        } else if (targetData.elementAt(index)["startTime"].trim() != "") {
          dateTimeData = Text(
            " " + targetData.elementAt(index)["startTime"],
            style: const TextStyle(
                color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
          );
        } else {
          dateTimeData = const Text(
            " 終日",
            style: TextStyle(
                color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
          );
        }

        return Column(children: [
          InkWell(
              onTap: () {
                inittodaiarogu(data.templateData.elementAt(index));
                _showTextDialog(context, data.templateData.elementAt(index));
              },
              child: Container(
                  width: SizeConfig.blockSizeHorizontal! * 95,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.blue[100], // コンテナの背景色
                    borderRadius: BorderRadius.circular(12.0), // 角丸の半径
                  ),
                  child: Row(children: [
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            dateTimeData,
                            const SizedBox(width: 15),
                            tagChip(
                                data.templateData.elementAt(index)["tagID"], ref)
                          ]),
                          SizedBox(
                              width: SizeConfig.blockSizeHorizontal! * 70,
                              child: Text(
                                data.templateData.elementAt(index)["subject"],
                                overflow: TextOverflow.clip,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold),
                              ))
                        ]),
                    const Spacer(),
                    Column(children: [
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.white),
                        onPressed: () async {
                          showDeleteDialogue(context,
                              data.templateData.elementAt(index)["subject"],
                              () async {
                            await ScheduleTemplateDatabaseHelper()
                                .deleteSchedule(
                                    data.templateData.elementAt(index)["id"]);
                            ref.read(scheduleFormProvider).clearContents();
                            ref.read(calendarDataProvider.notifier).state =
                                CalendarData();
                            ref.read(taskDataProvider).isRenewed = true;
                            while (
                                ref.read(taskDataProvider).isRenewed != false) {
                              await Future.delayed(
                                  const Duration(microseconds: 1));
                            }
                            setState(() {});
                          });
                        },
                      ),
                    ])
                  ]))),
        ]);
      },
      separatorBuilder: (context, index) {
        return const SizedBox(height: 15);
      },
      itemCount: data.templateData.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
    );
  }

  Widget tagDataList() {
    final tagData = ref.watch(calendarDataProvider);
    List sortedData = tagData.tagData;

    return ListView.separated(
      itemBuilder: (BuildContext context, int index) {
        Widget dateTimeData = Container();
        dateTimeData = const Text(
          "通常タグ",
          style: TextStyle(
              color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
        );

        if (sortedData.elementAt(index)["isBeit"] == 1) {
          dateTimeData = Row(children: [
            const Text(
              "アルバイトタグ",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  backgroundColor: Colors.red),
            ),
            const SizedBox(width: 15),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                "時給：${sortedData.elementAt(index)["wage"]}円",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                "交通費：${sortedData.elementAt(index)["fee"]}円",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              )
            ])
          ]);
        }

        return Column(children: [
          InkWell(
            onTap: () {
              editTagDialog(sortedData.elementAt(index));
            },
            child: Container(
              width: SizeConfig.blockSizeHorizontal! * 95,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: sortedData.elementAt(index)["color"], // コンテナの背景色
                borderRadius: BorderRadius.circular(12.0), // 角丸の半径
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5), // 影の色と透明度
                    spreadRadius: 2, // 影の広がり
                    blurRadius: 4, // 影のぼかし
                    offset: const Offset(0, 2), // 影の方向（横、縦）
                  ),
                ],
              ),
              child:Row(children: [
                Expanded(child:
                 Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  dateTimeData,
                  Text(
                      sortedData.elementAt(index)["title"] ?? "(詳細なし)",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.clip
                        ),
                      )
                ]),),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  onPressed: () {
                    final data = ref.watch(calendarDataProvider);
                    showDeleteDialogue(context,
                        sortedData.elementAt(index)["title"] ?? "(詳細なし)",
                        () async {
                      await TagDatabaseHelper()
                          .deleteTag(sortedData.elementAt(index)["id"]);

                      showDeleteDialogue(
                        context,
                        "タグ「${returnTagTitle(sortedData.elementAt(index)["tagID"],ref)}」が紐づいているすべての予定",
                        () async {
                          await deleteAllScheduleWithTag(sortedData.elementAt(index)["tagID"],ref,setState);
                        }
                      );
                      ref.read(scheduleFormProvider).clearContents();
                      ref.read(calendarDataProvider.notifier).state =
                          CalendarData();
                      ref.read(taskDataProvider).isRenewed = true;
                      while (ref.read(taskDataProvider).isRenewed != false) {
                        await Future.delayed(const Duration(microseconds: 1));
                      }
                      setState(() {});
                    });
                  },
                ),
              ]),
            ),
          ),
        ]);
      },
      separatorBuilder:(context,index){
        return const SizedBox(height: 15);
      },
      itemCount: sortedData.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
    );
  }

  void inittodaiarogu(Map targetData) {
    final provider = ref.watch(scheduleFormProvider);
    provider.timeStartController.text = targetData["startTime"];
    provider.timeEndController.text = targetData["endTime"];
    provider.tagController.text = targetData["tag"];
  }

  Future<void> _showTextDialog(BuildContext context, Map targetData) async {
    final provider = ref.read(scheduleFormProvider);
    TextEditingController titlecontroller = TextEditingController();
    titlecontroller.text = targetData["subject"];

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('テンプレートの編集...', style: TextStyle(fontSize: 20)),
          actions: <Widget>[
            StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(children: [
                  TextField(
                    controller: titlecontroller,
                    decoration: const InputDecoration(
                        labelText: 'テンプレート予定名', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height:5),
                  Row(children: [
                    buttonModel(
                        ()async {
                            DateTime now = DateTime.now();
                            await DatePicker.showTimePicker(context,
                              showTitleActions: true,
                              showSecondsColumn: false,
                              onConfirm: (date) {
                                provider.timeStartController.text
                                  = DateFormat("HH:mm").format(date);
                                  setState((){});
                              },
                              currentTime: DateTime(now.year,now.month,now.day,12,00),
                              locale: LocaleType.jp
                            );
                        },
                        ACCENT_COLOR,
                        "  + 開始時刻 "),
                    timeInputPreview(provider.timeStartController.text)
                  ]),
                  const SizedBox(height:5),
                  Row(children: [
                    buttonModel(
                        ()async {
                            DateTime now = DateTime.now();
                            await DatePicker.showTimePicker(context,
                              showTitleActions: true,
                              showSecondsColumn: false,
                              onConfirm: (date) {
                                provider.timeEndController.text
                                  = DateFormat("HH:mm").format(date);
                                  setState((){});
                              },
                              currentTime: DateTime(now.year,now.month,now.day,12,00),
                              locale: LocaleType.jp
                            );
                        },
                        ACCENT_COLOR,
                        "  + 終了時刻 "),
                    timeInputPreview(provider.timeEndController.text)
                  ]),
                  const SizedBox(height:5),
                  Row(children: [
                    buttonModel(
                        () {
                          showTagDialogue(ref, context, setState);
                        },
                        ACCENT_COLOR,
                        "  +    タグ      "),
                    timeInputPreview(
                        returnTagData(provider.tagController.text, ref))
                  ])
                ]);
              },
            ),
             const SizedBox(height:10),
            SizedBox(
              width: 500,
              child: buttonModel(
                () async {
                  Map<String, dynamic> newMap = {};
                  newMap["subject"] = titlecontroller.text;
                  newMap["startTime"] = provider.timeStartController.text;
                  newMap["endTime"] = provider.timeEndController.text;
                  newMap["isPublic"] = targetData["isPublic"];
                  newMap["publicSubject"] = targetData["publicSubject"];
                  newMap["tag"] = provider.tagController.text;
                  newMap["id"] = targetData["id"];
                  newMap["tagID"] = returnTagId(provider.tagController.text, ref);

                  await ScheduleTemplateDatabaseHelper().updateSchedule(newMap);
                  ref.read(scheduleFormProvider).clearContents();
                  ref.read(taskDataProvider).isRenewed = true;
                  ref.read(calendarDataProvider.notifier).state = CalendarData();
                  while (ref.read(taskDataProvider).isRenewed != false) {
                    await Future.delayed(const Duration(microseconds: 1));
                  }
                  setState(() {});
                  Navigator.pop(context);
                },
                MAIN_COLOR,
                '      変更      ',
                ),
            ),
          ],
        );
      },
    );
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
          color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 20),
      overflow: TextOverflow.visible,
    )));
  }

  void tagDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TagDialog(setosute: setState); // カスタムダイアログを表示
      },
    );
  }

  void editTagDialog(tagData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditTagDialog(
            tagData: tagData, setosute: setState); // カスタムダイアログを表示
      },
    );
  }
}

class TagDialog extends ConsumerStatefulWidget {
  StateSetter setosute;

  TagDialog({super.key, required this.setosute});

  @override
  _TagDialogState createState() => _TagDialogState();
}

class _TagDialogState extends ConsumerState<TagDialog> {
  TextEditingController titleController = TextEditingController();
  TextEditingController wageController = TextEditingController();
  TextEditingController feeController = TextEditingController();
  late Color tagColor;
  late bool isBeit;

  @override
  void initState() {
    super.initState();
    isBeit = false;
    tagColor = Colors.redAccent; // コンテナの背景色
    wageController.text = "0";
    feeController.text = "0";
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("タグの新規追加...", style: TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "タグ名",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 5),
            Row(children: [
              ElevatedButton(
                style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(ACCENT_COLOR)),
                onPressed: () {
                  colorPickerDialogue();
                },
                child: const Text('  色を選択 ',
                    style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 10),
              Expanded(child: Container(height: 30, color: tagColor))
            ]),
            Row(children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  // ボタンの背景色を条件に応じて変更する
                  backgroundColor: isBeit ? ACCENT_COLOR : Colors.grey,
                  // その他のスタイル設定
                  textStyle: const TextStyle(color: Colors.white),
                  // 他のスタイルプロパティを設定する
                ),
                onPressed: () {
                  setState(() {
                    if (isBeit) {
                      isBeit = false;
                    } else {
                      isBeit = true;
                    }
                  });
                },
                child:
                    const Text('アルバイト', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 10),
              Expanded(child: wageField())
            ]),
            const SizedBox(height: 10),
            SizedBox(
              width: 500,
              child: ElevatedButton(
                style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(MAIN_COLOR)),
                onPressed: () async {
                  if (wageController.text == "") {
                    wageController.text = "0";
                  }
                  if (feeController.text == "") {
                    feeController.text = "0";
                  }
                  await TagDatabaseHelper().resisterTagToDB({
                    "title": titleController.text,
                    "color": tagColor,
                    "isBeit": boolToInt(isBeit),
                    "wage": int.parse(wageController.text),
                    "fee": int.parse(feeController.text)
                  });
                  ref.read(scheduleFormProvider).clearContents();
                  ref.read(taskDataProvider).isRenewed = true;
                  ref.read(calendarDataProvider.notifier).state =
                      CalendarData();
                  while (ref.read(taskDataProvider).isRenewed != false) {
                    await Future.delayed(const Duration(microseconds: 1));
                  }
                  widget.setosute(() {});
                  Navigator.pop(context);
                  if (ref.read(calendarDataProvider).tagData.last["id"] == 1) {
                    showTagGuide(context);
                  }
                },
                child: const Text('追加', style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  int boolToInt(bool) {
    if (bool) {
      return 1;
    } else {
      return 0;
    }
  }

  Widget wageField() {
    if (isBeit) {
      return Column(children: [
        SizedBox(
            height: 40,
            child: TextField(
              controller: wageController,
              decoration: const InputDecoration(
                labelText: "時給*",
                labelStyle: TextStyle(color: Colors.red),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')), // 半角数字のみ許可
              ],
            )),
        const SizedBox(height: 10),
        SizedBox(
            height: 40,
            child: TextField(
              controller: feeController,
              decoration: const InputDecoration(
                labelText: "片道交通費",
                labelStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')), // 半角数字のみ許可
              ],
            ))
      ]);
    } else {
      return const Text("OFF",
          style: TextStyle(
              color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 20));
    }
  }

  void colorPickerDialogue() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('タグの色を選択...'),
            content: SingleChildScrollView(
              child: BlockPicker(
                  pickerColor: Colors.redAccent,
                  onColorChanged: (color) {
                    setState(() {
                      tagColor = color;
                    });
                  }),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('選択'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

}

class EditTagDialog extends ConsumerStatefulWidget {
  Map<String, dynamic> tagData;
  StateSetter setosute;

  EditTagDialog({super.key, required this.tagData, required this.setosute});
  @override
  _EditTagDialogState createState() => _EditTagDialogState();
}

class _EditTagDialogState extends ConsumerState<EditTagDialog> {
  TextEditingController titleController = TextEditingController();
  TextEditingController wageController = TextEditingController();
  TextEditingController feeController = TextEditingController();
  late Color tagColor;
  late bool isBeit;

  @override
  void initState() {
    super.initState();
    titleController.text = widget.tagData["title"];
    isBeit = intToBool(widget.tagData["isBeit"]);
    tagColor = widget.tagData["color"];
    wageController.text = widget.tagData["wage"].toString();
    feeController.text = widget.tagData["fee"].toString();
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor = isBeit ? ACCENT_COLOR : Colors.grey;
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("タグの編集...", style: TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "タグ名",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 5),
            Row(children: [
              buttonModel(
                () {
                  colorPickerDialogue();
                },
                ACCENT_COLOR,
                '  色を選択  '),
              const SizedBox(width: 10),
              Expanded(child: Container(height: 30, color: tagColor))
            ]),
            const SizedBox(height: 10),
            Row(children: [
              buttonModel(
                () {},
                bgColor,
                'アルバイト',
              ),
              const SizedBox(width: 10),
              Expanded(child: wageField())
            ]),
            const SizedBox(height: 10),
            SizedBox(
              width: 500,
              child: buttonModel(
                () async {
                  if (feeController.text == "") {
                    feeController.text = "0";
                  }
                  if (wageController.text == "") {
                    wageController.text = "0";
                  }
                  await TagDatabaseHelper().updateTag({
                    "id": widget.tagData["id"],
                    "title": titleController.text,
                    "color": colorToInt(tagColor),
                    "isBeit": boolToInt(isBeit),
                    "wage": int.parse(wageController.text),
                    "fee": int.parse(feeController.text),
                    "tagID" : widget.tagData["tagID"],
                  });
                  ref.read(scheduleFormProvider).clearContents();
                  ref.read(taskDataProvider).isRenewed = true;
                  ref.read(calendarDataProvider.notifier).state =
                      CalendarData();
                  while (ref.read(taskDataProvider).isRenewed != false) {
                    await Future.delayed(const Duration(microseconds: 1));
                  }
                  widget.setosute(() {});
                  Navigator.pop(context);
                },
                MAIN_COLOR,
                '      変更      ',
              ),
            )
          ],
        ),
      ),
    );
  }

  bool intToBool(int int) {
    if (int == 1) {
      return true;
    } else {
      return false;
    }
  }

  int boolToInt(bool bool) {
    if (bool) {
      return 1;
    } else {
      return 0;
    }
  }

  // Color型からint型への変換関数
  int colorToInt(Color? color) {
    color ??= MAIN_COLOR;
    // 16進数の赤、緑、青、アルファの値を結合して1つの整数に変換する
    return (color.alpha << 24) |
        (color.red << 16) |
        (color.green << 8) |
        color.blue;
  }

  Widget wageField() {
    if (isBeit) {
      return Column(children: [
        SizedBox(
            height: 40,
            child: TextField(
              controller: wageController,
              decoration: const InputDecoration(
                labelText: "時給*",
                labelStyle: TextStyle(color: Colors.red),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')), // 半角数字のみ許可
              ],
            )),
        const SizedBox(height: 10),
        SizedBox(
            height: 40,
            child: TextField(
              controller: feeController,
              decoration: const InputDecoration(
                labelText: "片道交通費",
                labelStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')), // 半角数字のみ許可
              ],
            ))
      ]);
    } else {
      return const Text("OFF",
          style: TextStyle(
              color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 20));
    }
  }

  void colorPickerDialogue() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('タグの色を選択...'),
            content: SingleChildScrollView(
              child: BlockPicker(
                  pickerColor: Colors.redAccent,
                  onColorChanged: (color) {
                    setState(() {
                      tagColor = color;
                    });
                  }),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('選択'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}

Future<String> showTagDialogue(
    WidgetRef ref, BuildContext context, StateSetter setState) async {
  final data = ref.read(calendarDataProvider);
  List tagMap = data.tagData;
  String result = "";
  await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("タグを選択："),
          actions: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("登録  タグ一覧",
                  style: (TextStyle(fontWeight: FontWeight.bold))),
              SizedBox(
                  width: double.maxFinite,
                  height: listViewHeight(65, tagMap.length),
                  child: ListView.separated(
                    separatorBuilder: (context, index) {
                      if (tagMap.isEmpty) {
                        return const SizedBox();
                      } else {
                        return const SizedBox(height: 5);
                      }
                    },
                    itemBuilder: (BuildContext context, index) {
                      if (tagMap.isEmpty) {
                        return const SizedBox();
                      } else {
                        Widget dateTimeData = Container();
                        dateTimeData = const Text(
                          "通常タグ",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        );

                        if (data.tagData.elementAt(index)["isBeit"] == 1) {
                          dateTimeData = Row(children: [
                            const Text(
                              "アルバイトタグ",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  backgroundColor: Colors.red),
                            ),
                            const SizedBox(width: 15),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "時給：${data.tagData
                                            .elementAt(index)["wage"]}円",
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "交通費：${data.tagData
                                            .elementAt(index)["fee"]}円",
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                  )
                                ])
                          ]);
                        }

                        return InkWell(
                            onTap: (){
                              final inputform = ref.watch(scheduleFormProvider);
                              setState(() {
                                inputform.tagController.text = data.tagData
                                    .elementAt(index)["id"]
                                    .toString();
                                result = data.tagData
                                    .elementAt(index)["id"]
                                    .toString();
                              });
                              Navigator.pop(context);

                              
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                    color:
                                        data.tagData.elementAt(index)["color"],
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(20))),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                          padding: const EdgeInsets.only(
                                              left: 15, top: 3),
                                          child: dateTimeData),
                                      Text(
                                        "  " +
                                            data.tagData
                                                .elementAt(index)["title"],
                                        style: const TextStyle(
                                            fontSize: 20, color: Colors.white),
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    ])));
                      }
                    },
                    shrinkWrap: true,
                    itemCount: tagMap.length,
                  )),
              const SizedBox(height:15),
              buttonModel(
                () {
                  setState(() {
                    ref.read(scheduleFormProvider).tagController.text = "";
                  });
                  result = "";
                  Navigator.pop(context);
                },
                Colors.blueAccent,
                " - タグを外す",
              ),
            ]),
          ],
        );
      });
      return result;
}

void showDeleteDialogue(BuildContext context, String name, VoidCallback onTap) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('削除の確認'),
          content: Text('$name を削除しますか？'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ダイアログを閉じる
              },
              child: const Text('いいえ'),
            ),
            TextButton(
              onPressed: () {
                onTap();
                Navigator.of(context).pop(); // ダイアログを閉じる
              },
              child: const Text(
                '削除',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      });
}

String returnTagTitle(String tagId, WidgetRef ref) {
  final data = ref.read(calendarDataProvider);
  List tagMap = data.tagData;
  if (tagId == "") {
    return "";
  } else {
    for (var data in tagMap) {
      if (data["tagID"] == tagId) {
        return data["title"];
      }
    }
    return "無効なタグです";
  }
}

int returnTagIsBeit(String tagId, WidgetRef ref) {
  final data = ref.read(calendarDataProvider);
  List tagMap = data.tagData;
  if (tagId == "") {
    return 0;
  } else {
    for (var data in tagMap) {
      if (data["tagID"] == tagId) {
        return data["isBeit"];
      }
    }
    return 0;
  }
}

Color? returnTagColor(String tagId, WidgetRef ref) {
  final data = ref.read(calendarDataProvider);
  List tagMap = data.tagData;
  if (tagId == "") {
    return null;
  } else {
    for (var data in tagMap) {
      if (data["tagID"] == tagId) {
        return data["color"];
      }
    }
    return null;
  }
}

String? returnTagId(String id, WidgetRef ref) {
  final data = ref.read(calendarDataProvider);
  List tagMap = data.tagData;
  if (id == "") {
    return null;
  } else {
    for (var data in tagMap) {
      if (data["id"] == int.parse(id)) {
        return data["tagID"];
      }
    }
    return null;
  }
}

Widget tagChip(String? tagID, WidgetRef ref,{editMode = false}) {
  final data = ref.read(calendarDataProvider);
  List tagMap = data.tagData;
  if (tagID == "" || tagID == null) {
    return const SizedBox();
  } else {
    for (var data in tagMap) {
      if (data["tagID"] == tagID) {
        return validTagChip(data,editMode);
      }
    }
    return invalidTagChip();
  }
}

Widget validTagChip(Map data,bool isEditMode) {
  var color = data["color"];
  if (color.runtimeType == int) {
    color = intToColor(color);
  }

  return Container(
    height: 20,
    padding: const EdgeInsets.only(right: 15, left: 5),
    child: Row(children: [
      Icon(CupertinoIcons.tag_fill,color: color,size: 15),
      Expanded(
        child:Text(
          "${data["title"]}",
          style: TextStyle(
            color: isEditMode ? Colors.blue : BLUEGREY,
            fontSize: null, overflow: TextOverflow.ellipsis),
      )),
    ]),
  );
}

Widget invalidTagChip() {
  return Container(
    height: 20,
    padding: const EdgeInsets.only(right: 15, left: 5),
    child:const Row(children: [
      Icon(CupertinoIcons.tag_fill,color:Colors.red,size: 15),
      Text(
        " ! 無効なタグ",
        style: TextStyle(
            color: Colors.red, fontSize: 15, overflow: TextOverflow.ellipsis),
      ),
    ]),
  );
}

Color intToColor(int colorValue) {
  // 0xFF000000から0xFFFFFFの範囲の整数をColorオブジェクトに変換する
  return Color(colorValue);
}

String truncateString(String input) {
  if (input.length <= 8) {
    return input;
  } else {
    return "${input.substring(0, 8)}…";
  }
}

String returnTagData(String id, WidgetRef ref) {
  final data = ref.read(calendarDataProvider);
  List tagMap = data.tagData;
  if (id == "") {
    return "";
  } else {
    for (var data in tagMap) {
      if (data["id"] == int.parse(id)) {
        return data["title"];
      }
    }

    return "無効なタグです";
  }
}
