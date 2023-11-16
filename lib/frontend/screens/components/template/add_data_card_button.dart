import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/screens/components/template/data_card.dart';
import 'package:flutter_calandar_app/frontend/size_config.dart';
import 'package:flutter_calandar_app/frontend/colors.dart';
import 'package:intl/intl.dart';
import 'package:flutter/scheduler.dart';
import 'package:easy_autocomplete/easy_autocomplete.dart';

class InputForm extends StatefulWidget {
  @override
  _InputFormState createState() => _InputFormState();
}

class _InputFormState extends State<InputForm> {
  TextEditingController _TitleController = TextEditingController();
  TextEditingController _DescriptionController = TextEditingController();
  TextEditingController _SummaryController = TextEditingController();
  TextEditingController _DtEndcontroller = TextEditingController();
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _TitleController.addListener(_validateInput);
  }

  void _validateInput() {
    setState(() {
      _isButtonEnabled = _TitleController.text.isNotEmpty;
    });
  }

  void _handleSubmit() {
    // フォームが有効な場合の処理
    if (_isButtonEnabled) {
      // ここで次に進む処理を行います
      print('Valid input: ${_TitleController.text}');
    } else {
      // フォームが無効な場合の処理
      print('Input is empty. Cannot proceed.');
    }
  }

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


          Container( 
             width:SizeConfig.blockSizeHorizontal! * 80,
             height:SizeConfig.blockSizeHorizontal! *16,
            child: EasyAutocomplete(
              suggestions: uniqueTitleList,
              controller: _TitleController,
              decoration: InputDecoration(border: OutlineInputBorder(),labelText: '授業名/タスク名'),
            )
          ),


              SizedBox(width:SizeConfig.blockSizeHorizontal! * 80,
                  height:SizeConfig.blockSizeHorizontal! *3,),
              Container(
                  width:SizeConfig.blockSizeHorizontal! * 80,
                  height:SizeConfig.blockSizeHorizontal! *8.5,
              child:TextField(
                controller: _SummaryController,
                decoration: InputDecoration(border: OutlineInputBorder(),labelText: '要約(通知表示用)'),
              ),),
              SizedBox(width:SizeConfig.blockSizeHorizontal! * 80,
                  height:SizeConfig.blockSizeHorizontal! *3,),
              Container(
                  width:SizeConfig.blockSizeHorizontal! * 80,
                  height:SizeConfig.blockSizeHorizontal! *8.5,
              child:TextField(
                controller: _DescriptionController,
                decoration: InputDecoration(border: OutlineInputBorder(),labelText: '詳細'),
              ),),
              SizedBox(width:SizeConfig.blockSizeHorizontal! * 80,
                  height:SizeConfig.blockSizeHorizontal! *3,),
              DateTimePickerFormField(
                controller: _DtEndcontroller,
                labelText: '締め切り日時(２４時間表示)',
              ),
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
                print('Title: ${_TitleController.text}');
                print('Summary: ${_SummaryController.text}');
                print('Description: ${_DescriptionController.text}');
                print('DtEnd: ${_DtEndcontroller.text}');
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
  _DateTimePickerFormFieldState createState() => _DateTimePickerFormFieldState();
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
          data:ThemeData.light().copyWith(
                colorScheme: ColorScheme.light().copyWith(
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

          widget.controller.text = DateFormat('yyyy-MM-dd HH:mm').format(_selectedDate!);
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
        width:SizeConfig.blockSizeHorizontal! * 80,
        height:SizeConfig.blockSizeHorizontal! *8.5,
        child:InkWell(
          onTap: () {
            _selectDateAndTime(context);
          },
          child: IgnorePointer(
            child: TextFormField(
              controller: widget.controller,
              decoration: InputDecoration(
                border:OutlineInputBorder(),
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