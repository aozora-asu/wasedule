import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/size_config.dart';
import 'package:flutter_calandar_app/frontend/colors.dart';
import 'package:intl/intl.dart';

class InputForm extends StatefulWidget {
  @override
  _InputFormState createState() => _InputFormState();
}

class _InputFormState extends State<InputForm> {
  TextEditingController _TitleController = TextEditingController();
  TextEditingController _DescriptionController = TextEditingController();
  TextEditingController _SummaryController = TextEditingController();
  TextEditingController _DtEndcontroller = TextEditingController();

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
              TextField(
                controller: _TitleController,
                decoration: InputDecoration(labelText: '授業名/タスク名'),
              ),
              TextField(
                controller: _SummaryController,
                decoration: InputDecoration(labelText: '通知表示用の要約'),
              ),
              TextField(
                controller: _DescriptionController,
                decoration: InputDecoration(labelText: 'タスク詳細'),
              ),
              DateTimePickerFormField(
                controller: _DtEndcontroller,
                labelText: 'タスクの締め切り日',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('戻る'),
            ),
            TextButton(
              onPressed: () {
                // ここに、入力データをDBにぶち込む処理を追加。
                print('Field 1: ${_TitleController.text}');
                print('Field 3: ${_SummaryController.text}');
                print('Field 2: ${_DescriptionController.text}');
                print('Field 4: ${_DtEndcontroller.text}');
                Navigator.of(context).pop();
              },
              child: Text('追加'),
            ),
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
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
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
        InkWell(
          onTap: () {
            _selectDateAndTime(context);
          },
          child: IgnorePointer(
            child: TextFormField(
              controller: widget.controller,
              decoration: InputDecoration(
                labelText: widget.labelText,
              ),
            ),
          ),
        ),
      ],
    );
  }
}