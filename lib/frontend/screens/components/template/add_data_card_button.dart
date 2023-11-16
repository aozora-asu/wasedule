import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/screens/components/template/data_card.dart';
import 'package:flutter_calandar_app/frontend/size_config.dart';
import 'package:flutter_calandar_app/frontend/colors.dart';
import 'package:intl/intl.dart';
import 'package:flutter/scheduler.dart';
import 'package:easy_autocomplete/easy_autocomplete.dart';
import '../../../../backend/DB/models/task.dart';
import '../../../../backend/DB/database_helper.dart';

Future<void> registeTaskToDB(Map<String, dynamic> task) async {
  TaskItem taskItem;
  taskItem = TaskItem(
      title: task["title"],
      dtEnd: DateTime.parse(task["dtEnd"]).millisecondsSinceEpoch,
      isDone: 0,
      summary: task["summary"],
      description: task["description"]);
  await TaskDatabaseHelper().insertTask(taskItem);
}

class InputForm extends StatefulWidget {
  @override
  _InputFormState createState() => _InputFormState();
}

class _InputFormState extends State<InputForm> {
  final TextEditingController _TitleController = TextEditingController();
  final TextEditingController _DescriptionController = TextEditingController();
  final TextEditingController _SummaryController = TextEditingController();
  final TextEditingController _DtEndcontroller = TextEditingController();

  @override
  void dispose() {
    _TitleController.dispose();
    _SummaryController.dispose();
    _DtEndcontroller.dispose();
    _DescriptionController.dispose();
    super.dispose();
  }

  void _showInputDialog(BuildContext context) {
    // ダイアログを表示する前にコントローラーのテキストをクリア
    _TitleController.clear();
    _SummaryController.clear();
    _DtEndcontroller.clear();
    _DescriptionController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'タスク情報を入力…',
            style: TextStyle(
              fontSize: SizeConfig.blockSizeHorizontal! * 7,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Column(
            children: [
              // Container(
              //     width:SizeConfig.blockSizeHorizontal! * 80,
              //     height:SizeConfig.blockSizeHorizontal! *8.5,
              // child:TextField(
              //   controller: _TitleController,
              //   decoration: InputDecoration(border: OutlineInputBorder(),labelText: '授業名/タスク名'),
              // ),),
              // SizedBox(width:SizeConfig.blockSizeHorizontal! * 80,
              //     height:SizeConfig.blockSizeHorizontal! *3,),

              Container(
                  width: SizeConfig.blockSizeHorizontal! * 80,
                  height: SizeConfig.blockSizeHorizontal! * 16,
                  // padding: EdgeInsets.all(10),
                  // alignment: Alignment.center,
                  child: EasyAutocomplete(
                    suggestions: uniqueTitleList,
                    onChanged: (value) => print('onChanged value: $value'),
                    onSubmitted: (value) => print('onSubmitted value: $value'),
                    controller: _TitleController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), labelText: '授業名/タスク名'),
                  )),

              SizedBox(
                width: SizeConfig.blockSizeHorizontal! * 80,
                height: SizeConfig.blockSizeHorizontal! * 3,
              ),
              Container(
                width: SizeConfig.blockSizeHorizontal! * 80,
                height: SizeConfig.blockSizeHorizontal! * 8.5,
                child: TextField(
                  controller: _SummaryController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), labelText: '要約(通知表示用)'),
                ),
              ),
              SizedBox(
                width: SizeConfig.blockSizeHorizontal! * 80,
                height: SizeConfig.blockSizeHorizontal! * 3,
              ),
              Container(
                width: SizeConfig.blockSizeHorizontal! * 80,
                height: SizeConfig.blockSizeHorizontal! * 8.5,
                child: TextField(
                  controller: _DescriptionController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), labelText: '詳細'),
                ),
              ),
              SizedBox(
                width: SizeConfig.blockSizeHorizontal! * 80,
                height: SizeConfig.blockSizeHorizontal! * 3,
              ),
              DateTimePickerFormField(
                controller: _DtEndcontroller,
                labelText: '締め切り日時(２４時間表示)',
              ),
            ],
          ),
          actions: [
            Row(children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color?>(ACCENT_COLOR),
                  fixedSize: MaterialStateProperty.all<Size>(
                    Size(SizeConfig.blockSizeHorizontal! * 35,
                        SizeConfig.blockSizeHorizontal! * 7.5),
                  ),
                ),
                child: const Text('戻る'),
              ),
              SizedBox(
                width: SizeConfig.blockSizeHorizontal! * 5,
                height: SizeConfig.blockSizeHorizontal! * 8.5,
              ),
              ElevatedButton(
                onPressed: () {
                  // ここに、入力データをDBにぶち込む処理を追加。
                  Map<String, dynamic> taskItem = {};
                  taskItem["title"] = _TitleController.text;
                  taskItem["summary"] = _SummaryController.text;
                  taskItem["description"] = _DescriptionController.text;
                  taskItem["dtEnd"] = _DtEndcontroller.text;
                  registeTaskToDB(taskItem);
                  print("登録されたよん");

                  Navigator.of(context).pop();
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color?>(MAIN_COLOR),
                  fixedSize: MaterialStateProperty.all<Size>(
                    Size(SizeConfig.blockSizeHorizontal! * 35,
                        SizeConfig.blockSizeHorizontal! * 7.5),
                  ),
                ),
                child: const Text('追加'),
              ),
            ])
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return addDataCardButton();
  }

  Widget addDataCardButton() {
    return SizedBox(
      child: FloatingActionButton.extended(
        onPressed: () {
          // データカードを追加する処理をここに記述
          _showInputDialog(context);
        },
        foregroundColor: Colors.white,
        backgroundColor: ACCENT_COLOR,
        isExtended: true,
        label: const Text('タスク追加'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class DateTimePickerFormField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;

  DateTimePickerFormField({required this.controller, required this.labelText});

  @override
  _DateTimePickerFormFieldState createState() =>
      _DateTimePickerFormFieldState();
}

class _DateTimePickerFormFieldState extends State<DateTimePickerFormField> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  Future<void> _selectDateAndTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light().copyWith(
                // ヘッダーの色
                primary: MAIN_COLOR),
            // 日付選択部の色
            dialogBackgroundColor: WIDGET_COLOR,
            // 選択されたときの円の色
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.accent,
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: 23, minute: 59),
        initialEntryMode: TimePickerEntryMode.input,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );

          widget.controller.text =
              DateFormat('yyyy-MM-dd HH:mm').format(_selectedDate!);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: SizeConfig.blockSizeHorizontal! * 80,
          height: SizeConfig.blockSizeHorizontal! * 8.5,
          child: InkWell(
            onTap: () {
              _selectDateAndTime(context);
            },
            child: IgnorePointer(
              child: TextFormField(
                controller: widget.controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: widget.labelText,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
