import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/screens/components/template/data_card.dart';
import 'package:flutter_calandar_app/frontend/size_config.dart';
import 'package:flutter_calandar_app/frontend/colors.dart';
import 'package:intl/intl.dart';
import 'package:easy_autocomplete/easy_autocomplete.dart';
import '../../../../backend/DB/models/task.dart';
import '../../../../backend/DB/database_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> registeTaskToDB(Map<String, dynamic> task) async {
  TaskItem taskItem;
  taskItem = TaskItem(
      uid: null,
      title: task["title"],
      dtEnd: task["dtEnd"],
      isDone: 0,
      summary: task["summary"],
      description: task["description"]);
  await TaskDatabaseHelper().insertTask(taskItem);
}

final inputFormProvider = StateNotifierProvider<InputFormNotifier, InputForm>(
  (ref) => InputFormNotifier(),
);

class InputFormNotifier extends StateNotifier<InputForm> {
  InputFormNotifier() : super(InputForm());

  void updateDateTimeFields() {
    state = state.copyWith();
  }

}

class InputForm {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController summaryController = TextEditingController();
  final TextEditingController dtEndController = TextEditingController();

  InputForm copyWith({
    String? titleController,
    String? descriptionController,
    String? summaryController,
    String? dtEndController,
  }) {
    return InputForm()
      ..titleController.text = titleController ?? this.titleController.text
      ..descriptionController.text = descriptionController ?? this.descriptionController.text
      ..summaryController.text = summaryController ?? this.summaryController.text
      ..dtEndController.text = dtEndController ?? this.dtEndController.text;
  }

    void clearContents() {
    titleController.clear();
    descriptionController.clear();
    dtEndController.clear();
    summaryController.clear();
  }

}

class AddDataCardButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final inputForm = ref.watch(inputFormProvider);
    return SizedBox(
      child: FloatingActionButton(
        onPressed: () {
          inputForm.clearContents();
          showDialog(
            context: context,
            builder: (BuildContext context) => TaskInputForm(),
          );
        },
        foregroundColor: Colors.white,
        backgroundColor: ACCENT_COLOR,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TaskInputForm extends ConsumerWidget {
  
  @override
  Widget build(BuildContext context ,WidgetRef ref) {
   final inputForm = ref.watch(inputFormProvider);
     
        return AlertDialog(
          title: Text(
            ' 新タスクを追加',
            style: TextStyle(
              fontSize: SizeConfig.blockSizeHorizontal! * 7,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Column(
            children: [
              Container(
                  width: SizeConfig.blockSizeHorizontal! * 80,
                  height: SizeConfig.blockSizeHorizontal! * 16,
                  child: TextFormField( 
                  //child: EasyAutoComplete(
                  //suggestions: uniqueTitleList,
                  onFieldSubmitted: (value) {
                    ref.read(inputFormProvider.notifier).updateDateTimeFields();
                  },
                  controller: inputForm.titleController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '授業名/タスク名',
                    ),
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
                  controller: inputForm.summaryController,
                  decoration: const InputDecoration(
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
                  controller: inputForm.descriptionController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: '詳細'),
                ),
              ),
              SizedBox(
                width: SizeConfig.blockSizeHorizontal! * 80,
                height: SizeConfig.blockSizeHorizontal! * 3,
              ),
              DateTimePickerFormField(
                controller: inputForm.dtEndController,
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
                    Size(SizeConfig.blockSizeHorizontal! * 31,
                        SizeConfig.blockSizeHorizontal! * 7.5),
                  ),
                ),
                child: const Text('戻る',style:TextStyle(color: Colors.white)),
              ),
              SizedBox(
                width: SizeConfig.blockSizeHorizontal! * 5,
                height: SizeConfig.blockSizeHorizontal! * 8.5,
              ),
              ElevatedButton(
                onPressed: () {
                 if (inputForm.dtEndController.text.isEmpty ||
                  inputForm.titleController.text.isEmpty) {
                  print("ボタン無効");
                } else {
                  // ここに、入力データをDBにぶち込む処理を追加。
                  Map<String, dynamic> taskItem = {};
                  taskItem["title"] = inputForm.titleController.text;
                  taskItem["summary"] = inputForm.summaryController.text;
                  taskItem["description"] = inputForm.descriptionController.text;
                  taskItem["dtEnd"] = DateTime.parse(inputForm.dtEndController.text)
                      .millisecondsSinceEpoch;
                  registeTaskToDB(taskItem);
                  Navigator.of(context).pop();}
                },

          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
                // 条件によってボタンの色を選択
              if (inputForm.dtEndController.text.isEmpty ||inputForm.titleController.text.isEmpty) {
               return Colors.grey;}else{
                    // ボタンが無効の場合の色
                return MAIN_COLOR; // ボタンが通常の場合の色
                   }
              }
              ),
              fixedSize: MaterialStateProperty.all<Size>(Size(
                SizeConfig.blockSizeHorizontal! * 31,
                SizeConfig.blockSizeHorizontal! * 7.5,
              )),
            ),
                child: const Text('追加',style:TextStyle(color: Colors.white)),
              ),
            ])
          ],
        );
  }


}

class DateTimePickerFormField extends ConsumerWidget {
  final TextEditingController controller;
  final String labelText;

  DateTimePickerFormField({
    required this.controller,
    required this.labelText
    });

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  Future<void> _selectDateAndTime(BuildContext context,WidgetRef ref) async {
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
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          controller.text =
              DateFormat('yyyy-MM-dd HH:mm').format(_selectedDate!);

        ref.read(inputFormProvider.notifier).updateDateTimeFields();
      }
    }
  }

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: SizeConfig.blockSizeHorizontal! * 80,
          height: SizeConfig.blockSizeHorizontal! * 8.5,
          child: InkWell(
            onTap: () {
              _selectDateAndTime(context,ref);
            },
            child: IgnorePointer(
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: labelText,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
