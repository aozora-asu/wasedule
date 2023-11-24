import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/size_config.dart';
import 'package:flutter_calandar_app/frontend/colors.dart';
import 'package:intl/intl.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_calandar_app/frontend/screens/components/template/data_card.dart';
import 'package:form_field_validator/form_field_validator.dart';
import '../../../../frontend/validators.dart';
import 'package:easy_autocomplete/easy_autocomplete.dart';
import '../../../../backend/DB/database_helper.dart';

class AddEventButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) => InputForm(),
          );
        },
        foregroundColor: Colors.white,
        backgroundColor: ACCENT_COLOR,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class InputForm extends StatefulWidget {
  @override
  _InputFormState createState() => _InputFormState();
}

class _InputFormState extends State<InputForm> {
  final TextEditingController _ScheduleController = TextEditingController();
  TextEditingController _DtStartcontroller = TextEditingController();
  TextEditingController _TimeStartcontroller = TextEditingController();
  TextEditingController _DtEndcontroller = TextEditingController();
  TextEditingController _TimeEndcontroller = TextEditingController();
  TextEditingController _Tagcontroller = TextEditingController();

  bool isAllDay = false;
  bool isPublic = false;
  TextEditingController _PublicScheduleController = TextEditingController();

  @override
  void initState() {
    isAllDay = false;
    isPublic = false;
    super.initState();
  }

  @override
  void dispose() {
    _ScheduleController.dispose();
    _PublicScheduleController.dispose();
    _DtEndcontroller.dispose();
    _TimeEndcontroller.dispose();
    _DtStartcontroller.dispose();
    _TimeStartcontroller.dispose();
    _Tagcontroller.dispose();
    super.dispose();
  }

  Widget publicScheduleField() {
    if (isPublic == true) {
      return Container(
        width: SizeConfig.blockSizeHorizontal! * 80,
        height: SizeConfig.blockSizeHorizontal! * 8.5,
        child: TextField(
          controller: _PublicScheduleController,
          decoration: InputDecoration(
              border: OutlineInputBorder(), labelText: 'フレンドに見せる予定名'),
        ),
      );
    } else {
      return SizedBox(width: 0, height: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    // テキストをクリア
    void clearContents() {
      _ScheduleController.clear();
      _PublicScheduleController.clear();
      _DtEndcontroller.clear();
      _DtStartcontroller.clear();
      _TimeStartcontroller.clear();
      _TimeEndcontroller.clear();
      _Tagcontroller.clear();
    }

    return AlertDialog(
      title: Text(
        '予定を入力…',
        style: TextStyle(
          fontSize: SizeConfig.blockSizeHorizontal! * 7,
          fontWeight: FontWeight.w900,
        ),
      ),
      content: Column(
        children: [
          Container(
            width: SizeConfig.blockSizeHorizontal! * 80,
            height: SizeConfig.blockSizeHorizontal! * 8.5,
            child: TextFormField(
              controller: _ScheduleController,
              onFieldSubmitted: (value) {
                setState(() {});
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                errorMaxLines: 3,
                labelText: '予定名*',
                labelStyle: TextStyle(color: Colors.red),
              ),
              validator: nameValidator,
            ),
          ),
          SizedBox(
            width: SizeConfig.blockSizeHorizontal! * 80,
            height: SizeConfig.blockSizeHorizontal! * 8,
          ),
          DateTimePickerFormField(
            dateController: _DtStartcontroller,
            dateLabelText: '開始日*',
            timeController: _TimeStartcontroller,
            timeLabelText: '開始時刻',
            whenSubmitted: (value) {
              setState(() {});
            },
          ),
          SizedBox(
            width: SizeConfig.blockSizeHorizontal! * 80,
            height: SizeConfig.blockSizeHorizontal! * 3,
          ),
          DateTimePickerFormField(
            dateController: _DtEndcontroller,
            dateLabelText: '終了日',
            timeController: _TimeEndcontroller,
            timeLabelText: '終了時刻',
            whenSubmitted: (value) {
              setState(() {});
            },
          ),
          SizedBox(
              width: SizeConfig.blockSizeHorizontal! * 80,
              height: SizeConfig.blockSizeHorizontal! * 16,
              child: EasyAutocomplete(
                suggestions: uniqueTitleList,
                inputTextStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  backgroundColor: Colors.blueAccent,
                ),
                controller: _Tagcontroller,
                decoration: const InputDecoration(
                    border: InputBorder.none,
                    labelText: 'タグを追加…',
                    labelStyle: TextStyle(
                      color: Colors.blueGrey,
                      backgroundColor: Colors.transparent,
                      fontWeight: FontWeight.w300,
                    )),
              )),
          SizedBox(
              height: SizeConfig.blockSizeHorizontal! * 3,
              width: SizeConfig.blockSizeHorizontal! * 80),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'フレンドに共有',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(
                    height: SizeConfig.blockSizeHorizontal! * 5,
                    width: SizeConfig.blockSizeHorizontal! * 16),
                CupertinoSwitch(
                  activeColor: ACCENT_COLOR,
                  value: isPublic,
                  onChanged: (value) {
                    setState(() {
                      isPublic = value;
                      print(value);
                      _PublicScheduleController.clear();
                    });
                  },
                ),
              ],
            ),
          ),
          SizedBox(
            width: SizeConfig.blockSizeHorizontal! * 80,
            height: SizeConfig.blockSizeHorizontal! * 3,
          ),
          publicScheduleField(),
          SizedBox(
            width: SizeConfig.blockSizeHorizontal! * 80,
            height: SizeConfig.blockSizeHorizontal! * 8,
          ),
        ],
      ),
      actions: [
        Row(children: [
          ElevatedButton(
            onPressed: () {
              clearContents();
              Navigator.of(context).pop();
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color?>(ACCENT_COLOR),
              fixedSize: MaterialStateProperty.all<Size>(
                Size(SizeConfig.blockSizeHorizontal! * 35,
                    SizeConfig.blockSizeHorizontal! * 7.5),
              ),
            ),
            child: Text('戻る'),
          ),
          SizedBox(
            width: SizeConfig.blockSizeHorizontal! * 5,
            height: SizeConfig.blockSizeHorizontal! * 8.5,
          ),
          ElevatedButton(
            onPressed: () {
              if (_DtStartcontroller.text.isEmpty ||
                  _ScheduleController.text.isEmpty) {
                //print("ボタン無効");
                print(
                    Future.value(ScheduleDatabaseHelper().getScheduleFromDB()));
              } else {
                int intIspublic;
                if (isPublic) {
                  intIspublic = 1;
                } else {
                  intIspublic = 0;
                }

                Map<String, dynamic> schedule = {
                  "subject": _ScheduleController.text,
                  "startDate": _DtStartcontroller.text,
                  "startTime": _TimeStartcontroller.text,
                  "endDate": _DtEndcontroller.text,
                  "endTime": _TimeEndcontroller.text,
                  "isPublic": intIspublic,
                  "publicSubject": "public用の予定",
                  "tag": _Tagcontroller.text
                };

                print('Schedule: ${_ScheduleController.text}');
                print('Ispublic: $isPublic');
                print('DtStart: ${_DtStartcontroller.text.runtimeType}');
                print('DtEnd: $_DtEndcontroller');
                print('IsPrivate: $isPublic');
                print('PublicSchedule: ${_PublicScheduleController.text}');
                print('Tag: ${_Tagcontroller.text}');

                ScheduleDatabaseHelper().resisterScheduleToDB(schedule);
                clearContents();
                Navigator.of(context).pop();
              }
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                // 条件によってボタンの色を選択
                if (_DtStartcontroller.text.isEmpty ||
                    _ScheduleController.text.isEmpty) {
                  return Colors.grey; // ボタンが無効の場合の色
                }
                return MAIN_COLOR; // ボタンが通常の場合の色
              }),
              fixedSize: MaterialStateProperty.all<Size>(Size(
                SizeConfig.blockSizeHorizontal! * 35,
                SizeConfig.blockSizeHorizontal! * 7.5,
              )),
            ),
            child: Text('追加'),
          ),
        ])
      ],
    );
  }
}

class DateTimePickerFormField extends StatefulWidget {
  final TextEditingController dateController;
  final TextEditingController timeController;
  final String dateLabelText;
  final String timeLabelText;
  final void Function(String)? whenSubmitted;

  DateTimePickerFormField({
    required this.dateController,
    required this.timeController,
    required this.dateLabelText,
    required this.timeLabelText,
    required this.whenSubmitted,
  });

  @override
  _DateTimePickerFormFieldState createState() =>
      _DateTimePickerFormFieldState();
}

class _DateTimePickerFormFieldState extends State<DateTimePickerFormField> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light().copyWith(
              // ヘッダーの色
              primary: MAIN_COLOR,
            ), // 日付選択部の色
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        widget.dateController.text =
            DateFormat('yyyy/MM/dd').format(pickedDate);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 00, minute: 00),
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
        _selectedTime = pickedTime;
        widget.timeController.text = pickedTime.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: SizeConfig.blockSizeHorizontal! * 33.5,
          height: SizeConfig.blockSizeHorizontal! * 8.5,
          child: InkWell(
            onTap: () {
              _selectDate(context);
            },
            child: IgnorePointer(
              child: TextFormField(
                onFieldSubmitted: widget.whenSubmitted,
                controller: widget.dateController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: widget.dateLabelText,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 16),
        Container(
          width: SizeConfig.blockSizeHorizontal! * 33.5,
          height: SizeConfig.blockSizeHorizontal! * 8.5,
          child: InkWell(
            onTap: () {
              _selectTime(context);
            },
            child: IgnorePointer(
              child: TextFormField(
                controller: widget.timeController,
                onFieldSubmitted: widget.whenSubmitted,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: widget.timeLabelText,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
