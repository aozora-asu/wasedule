import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/size_config.dart';
import 'package:flutter_calandar_app/frontend/colors.dart';
import 'package:intl/intl.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/cupertino.dart';
import 'package:form_field_validator/form_field_validator.dart';
import '../../../../frontend/validators.dart';

class InputForm extends StatefulWidget {
  @override
  _InputFormState createState() => _InputFormState();
}

class _InputFormState extends State<InputForm> {
  TextEditingController _ScheduleController = TextEditingController();
  TextEditingController _DtStartcontroller = TextEditingController();
  TextEditingController _TimeStartcontroller = TextEditingController();
  TextEditingController _DtEndcontroller = TextEditingController();
  TextEditingController _TimeEndcontroller = TextEditingController();
  

  bool isAllDay = false;
  bool isPrivate = false;
  TextEditingController _PublicScheduleController = TextEditingController();
 
  @override
  void initState() {
    isAllDay = false;
    isPrivate = false;
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
    super.dispose();
  }

  void _showInputDialog(BuildContext context) {
    // ダイアログを表示する前にコントローラーのテキストをクリア
    _ScheduleController.clear();
    _PublicScheduleController.clear();
    _DtEndcontroller.clear();
    _DtStartcontroller.clear();
    _TimeStartcontroller.clear();
    _TimeEndcontroller.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                  width:SizeConfig.blockSizeHorizontal! * 80,
                  height:SizeConfig.blockSizeHorizontal! *8.5,
              child:TextFormField(
                controller: _ScheduleController,
                decoration: InputDecoration(border: OutlineInputBorder(),errorMaxLines: 3,
                labelText: '予定名*',
                labelStyle: TextStyle(color:Colors.red),
                ),
                validator: nameValidator,
              ),),


              SizedBox(width:SizeConfig.blockSizeHorizontal! * 80,
                  height:SizeConfig.blockSizeHorizontal! *3,),
              DateTimePickerFormField(
                dateController: _DtStartcontroller,
                dateLabelText: '開始日*',
                timeController: _TimeStartcontroller,
                timeLabelText: '開始時刻',
              ),


              SizedBox(width:SizeConfig.blockSizeHorizontal! * 80,
                  height:SizeConfig.blockSizeHorizontal! *3,),
              DateTimePickerFormField(
                dateController: _DtEndcontroller,
                dateLabelText: '終了日',
                timeController: _TimeEndcontroller,
                timeLabelText: '終了時刻',
              ),

        Container(child: Row(mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('終日',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
           CupertinoSwitch(
              value: isAllDay,
              onChanged: (value) {
                super.setState(() {
                  isAllDay  = value;
                  print(value);
                });
              },
            ),
          ],
        ),),
        

              SizedBox(width:SizeConfig.blockSizeHorizontal! * 80,
                  height:SizeConfig.blockSizeHorizontal! *3,),
              Container(
                  width:SizeConfig.blockSizeHorizontal! * 80,
                  height:SizeConfig.blockSizeHorizontal! *8.5,
              child:TextField(
                controller: _PublicScheduleController,
                decoration: InputDecoration(border: OutlineInputBorder(),labelText: 'フレンド共有用'),
              ),),


              SizedBox(width:SizeConfig.blockSizeHorizontal! * 80,
                  height:SizeConfig.blockSizeHorizontal! *3,),


            ],
          ),
          actions: [Row(
            children:[ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color?>(ACCENT_COLOR),
                fixedSize: MaterialStateProperty.all<Size>(Size(
                  SizeConfig.blockSizeHorizontal! * 35,
                  SizeConfig.blockSizeHorizontal! * 7.5),
              ),
              ),
              child:Text('戻る'),),
              SizedBox(width:SizeConfig.blockSizeHorizontal! * 5,
                  height:SizeConfig.blockSizeHorizontal! *8.5,),
            ElevatedButton(
              onPressed: () {
                // ここに、入力データをDBにぶち込む処理を追加。
                print('Schedule: ${_ScheduleController.text}');
                print('Isallday: $isAllDay');
                print('DtStart: ${_DtStartcontroller.text}');
                print('DtEnd: ${_DtEndcontroller.text}');
                print('IsPrivate: $isPrivate');
                print('PublicSchedule: ${_PublicScheduleController.text}');
                Navigator.of(context).pop();
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color?>(MAIN_COLOR),
                 fixedSize: MaterialStateProperty.all<Size>(Size(
                  SizeConfig.blockSizeHorizontal! * 35,
                  SizeConfig.blockSizeHorizontal! * 7.5),
              ),
              ),
              child: Text('追加'),
            ),
          ])

          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return addEventButton();
  }

  Widget addEventButton() {
    return SizedBox(
      child: FloatingActionButton.extended(
        onPressed: () {
          // データカードを追加する処理をここに記述
          _showInputDialog(context);
        },
        foregroundColor: Colors.white,
        backgroundColor:MAIN_COLOR,
        isExtended: true,
        label: const Text('イベント追加'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class DateTimePickerFormField extends StatefulWidget {
  final TextEditingController dateController;
  final TextEditingController timeController;
  final String dateLabelText;
  final String timeLabelText;

  DateTimePickerFormField({
    required this.dateController,
    required this.timeController,
    required this.dateLabelText,
    required this.timeLabelText,
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
        primary: Colors.blue,
      ), // 日付選択部の色
      // textButtonTheme: TextButtonThemeData(
      //   style: TextButton.styleFrom(
      //     // 選択されたときの円の色
      //   ),
      // ),
    ),
    child: child!,
  );
},
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        widget.dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 200, // 適切な幅を指定してください
          height: 40, // 適切な高さを指定してください
          child: InkWell(
            onTap: () {
              _selectDate(context);
            },
            child: IgnorePointer(
              child: TextFormField(
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
          width: 200, // 適切な幅を指定してください
          height: 40, // 適切な高さを指定してください
          child: InkWell(
            onTap: () {
              _selectTime(context);
            },
            child: IgnorePointer(
              child: TextFormField(
                controller: widget.timeController,
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