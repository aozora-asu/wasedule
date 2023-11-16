import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/size_config.dart';
import 'package:flutter_calandar_app/frontend/colors.dart';
import 'package:intl/intl.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/cupertino.dart';

class InputForm extends StatefulWidget {
  @override
  _InputFormState createState() => _InputFormState();
}

class _InputFormState extends State<InputForm> {
  TextEditingController _DescriptionController = TextEditingController();//
    TextEditingController _ScheduleController = TextEditingController();
  TextEditingController _DtEndcontroller = TextEditingController();
  TextEditingController _DtStartcontroller = TextEditingController();
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
    _DtStartcontroller.dispose();
    super.dispose();
  }

  void _showInputDialog(BuildContext context) {
    // ダイアログを表示する前にコントローラーのテキストをクリア
    _ScheduleController.clear();
    _PublicScheduleController.clear();
    _DtEndcontroller.clear();
    _DescriptionController.clear();
    _DtStartcontroller.clear();

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
              child:TextField(
                controller: _ScheduleController,
                decoration: InputDecoration(border: OutlineInputBorder(),labelText: '予定名'),
              ),),


              SizedBox(width:SizeConfig.blockSizeHorizontal! * 80,
                  height:SizeConfig.blockSizeHorizontal! *3,),
              DateTimePickerFormField(
                controller: _DtStartcontroller,
                labelText: '開始日時',
              ),


              SizedBox(width:SizeConfig.blockSizeHorizontal! * 80,
                  height:SizeConfig.blockSizeHorizontal! *3,),
              DateTimePickerFormField(
                controller: _DtEndcontroller,
                labelText: '終了日時',
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









//入力サジェスチョン/////////////////////////////////////////////////////////////////////////////////////////////
// class SuggestionListDialog extends StatelessWidget {
//   final TextEditingController controller;

//   SuggestionListDialog({required this.controller});

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       content: SuggestionList(controller: controller),
//     );
//   }
// }

// class SuggestionList extends StatefulWidget {
//   final TextEditingController controller;

//   SuggestionList({required this.controller});

//   @override
//   _SuggestionListState createState() => _SuggestionListState();
// }

// class _SuggestionListState extends State<SuggestionList> {
//   Map<String, List<dynamic>> data = {
//     'fruits': ['Apple', 'Banana', 'Orange'],
//     'colors': ['Red', 'Blue', 'Green'],
//   };

//   bool isTextFieldFocused = false;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Container(
//           width: SizeConfig.blockSizeHorizontal! * 80,
//           height: SizeConfig.blockSizeHorizontal! * 8.5,
//           child: TextField(
//             // ... 既存のコード
//           ),
//         ),
//         SizedBox(height: 16),
//         if (isTextFieldFocused)
//           Expanded(
//             // Wrap the ListView with Expanded
//             child: _buildSuggestions(widget.controller.text),
//           ),
//       ],
//     );
//   }
  

//   Widget _buildSuggestions(String input) {
//     List<String> suggestions = [];

//     // Iterate through each key in the map
//     data.forEach((key, value) {
//       // Check if the key contains the input text
//       if (key.toLowerCase().contains(input.toLowerCase())) {
//         suggestions.add(key);
//       }

//       // Check if any value in the list contains the input text
//       value.forEach((item) {
//         if (item.toString().toLowerCase().contains(input.toLowerCase())) {
//           suggestions.add(item.toString());
//         }
//       });
//     });

//     // Display the suggestions as a simple text list
//     return ListView(
//       children: suggestions
//           .map(
//             (suggestion) => Padding(
//               padding: const EdgeInsets.symmetric(vertical: 4.0),
//               child: Text(suggestion),
//             ),
//           )
//           .toList(),
//     );
//   }
// }