import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/schedule_data_manager.dart';
import 'package:flutter_calandar_app/frontend/screens/outdated/data_card.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:intl/intl.dart';
import 'package:easy_autocomplete/easy_autocomplete.dart';

import '../common/app_bar.dart';
import '../common/burger_menu.dart';
import '../../../backend/DB/models/task.dart';
import '../../../backend/DB/handler/task_db_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_calandar_app/frontend/assist_files/data_manager.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/task_view_page.dart';

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
  TextEditingController titleController = TextEditingController();
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
      ..descriptionController.text =
          descriptionController ?? this.descriptionController.text
      ..summaryController.text =
          summaryController ?? this.summaryController.text
      ..dtEndController.text = dtEndController ?? this.dtEndController.text;
  }

  void clearContents() {
    titleController.clear();
    descriptionController.clear();
    dtEndController.clear();
    summaryController.clear();
  }
}


class DailyViewPage extends ConsumerStatefulWidget {
  DateTime target;

  DailyViewPage({
    required this.target
  });

 @override
  _DailyViewPageState createState() => _DailyViewPageState();
}

class _DailyViewPageState extends ConsumerState<DailyViewPage> {
  @override
  Widget build(BuildContext context) {
    final inputForm = ref.watch(inputFormProvider);
    final taskData = ref.read(taskDataProvider);
    final data = ref.read(calendarDataProvider);
    String targetKey =  widget.target.year.toString()+ "-" + widget.target.month.toString().padLeft(2,"0") + "-" + widget.target.day.toString().padLeft(2,"0");

    return Scaffold(
        appBar: const CustomAppBar(),
        drawer: burgerMenu(),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  SizedBox(width: SizeConfig.blockSizeHorizontal! * 3),
                  Image.asset('lib/assets/eye_catch/eyecatch.png',
                      height: 30, width: 30),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "  " + widget.target.month.toString() + "月" + widget.target.day.toString() +"日 " + weekDay(widget.target.weekday),
                        style: TextStyle(
                          fontSize: SizeConfig.blockSizeHorizontal! * 8,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    )
                ],
              ),
              Align(
                alignment: Alignment.centerLeft,
                child:
                    Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  SizedBox(width: SizeConfig.blockSizeHorizontal! * 5),
                  Text(
                    '',
                    style: TextStyle(
                        fontSize: SizeConfig.blockSizeHorizontal! * 4,
                        color:Colors.black),
                  ),
                ]),
              ),
              Container(
                width: SizeConfig.blockSizeHorizontal! * 100,
                child: listView(),
              ),
              SizedBox(
                width: SizeConfig.blockSizeHorizontal! * 90,
                height: SizeConfig.blockSizeHorizontal! * 3,
              ),
              Row(children: [
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
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
                  onPressed: () {
                    if (inputForm.dtEndController.text.isEmpty ||
                        inputForm.titleController.text.isEmpty) {
                      print("ボタン無効");
                    } else {
                      // ここに、入力データをDBにぶち込む処理を追加。
                      Map<String, dynamic> taskItem = {};
                      taskItem["title"] = inputForm.titleController.text;
                      taskItem["summary"] = inputForm.summaryController.text;
                      taskItem["description"] =
                          inputForm.descriptionController.text;
                      taskItem["dtEnd"] =
                          DateTime.parse(inputForm.dtEndController.text)
                              .millisecondsSinceEpoch;
                      registeTaskToDB(taskItem);

                      final list = ref.read(taskDataProvider).taskDataList;
                      final newList = [...list, taskItem];
                      ref.read(taskDataProvider.notifier).state =
                          TaskData(taskDataList: newList);
                      ref.read(taskDataProvider).isRenewed = true;
                      Navigator.of(context).pop();
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                        (Set<MaterialState> states) {
                      // 条件によってボタンの色を選択
                      if (inputForm.dtEndController.text.isEmpty ||
                          inputForm.titleController.text.isEmpty) {
                        return Colors.grey;
                      } else {
                        // ボタンが無効の場合の色
                        return MAIN_COLOR; // ボタンが通常の場合の色
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
                const Spacer(),
              ])
            ],
          ),
        )
      );
  }

  Widget listView(){
    final taskData = ref.read(taskDataProvider);
    final data = ref.read(calendarDataProvider);
    String targetKey =  widget.target.year.toString()+ "-" + widget.target.month.toString().padLeft(2,"0") + "-" + widget.target.day.toString().padLeft(2,"0");

    if(data.sortedDataByDay[targetKey] == null){
      return const SizedBox();
    }else{
   return
   ListView.builder(
          itemBuilder: (BuildContext context, int index) {
           return  Column(children:[
            Container(
             //height: SizeConfig.blockSizeVertical! * 10,
             width: SizeConfig.blockSizeHorizontal! *95,
             padding: const EdgeInsets.all(16.0),
             decoration: BoxDecoration(
              color: Colors.redAccent, // コンテナの背景色
              borderRadius: BorderRadius.circular(12.0), // 角丸の半径
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
              Text(data.sortedDataByDay[targetKey].elementAt(index)["startTime"] ?? " 終日",
              style: const TextStyle(color:Colors.white,fontSize: 13,fontWeight: FontWeight.bold),),
              Text(data.sortedDataByDay[targetKey].elementAt(index)["subject"],
                            style: const TextStyle(color:Colors.white,fontSize: 25,fontWeight: FontWeight.bold),)
            ]),
          ),
          const SizedBox(height:15)   
         ]);    
        },
        itemCount:
            data.sortedDataByDay[targetKey].length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      );
    }
  }

  String weekDay(weekday){
    String dayOfWeek = '';
      switch (weekday) {
    case 1:
      dayOfWeek = '(月)';
      break;
    case 2:
      dayOfWeek = '(火)';
      break;
    case 3:
      dayOfWeek = '(水)';
      break;
    case 4:
      dayOfWeek = '(木)';
      break;
    case 5:
      dayOfWeek = '(金)';
      break;
    case 6:
      dayOfWeek = '(土)';
      break;
    case 7:
      dayOfWeek = '(日)';
      break;
    }
   return dayOfWeek;
  }

}

class DateTimePickerFormField extends ConsumerWidget {
  final TextEditingController controller;
  final String labelText;
  final Color? labelColor;

  DateTimePickerFormField(
      {required this.controller,
      required this.labelText,
      required this.labelColor});

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  Future<void> _selectDateAndTime(BuildContext context, WidgetRef ref) async {
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
        controller.text = DateFormat('yyyy-MM-dd HH:mm').format(_selectedDate!);

        ref.read(inputFormProvider.notifier).updateDateTimeFields();
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: SizeConfig.blockSizeHorizontal! * 90,
          height: SizeConfig.blockSizeHorizontal! * 8.5,
          child: InkWell(
            onTap: () {
              _selectDateAndTime(context, ref);
            },
            child: IgnorePointer(
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: labelText,
                    labelStyle: TextStyle(color: labelColor)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
