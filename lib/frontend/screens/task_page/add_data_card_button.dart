import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/screens/outdated/data_card.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:intl/intl.dart';
import 'package:easy_autocomplete/easy_autocomplete.dart';


import '../common/app_bar.dart';
import '../common/burger_menu.dart';
import '../../../backend/DB/models/task.dart';
import '../../../backend/DB/database_helper.dart';
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TaskInputForm()),
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
   final taskData = ref.read(taskDataProvider);
   
        return Scaffold(
          appBar:  const CustomAppBar(),
          drawer: burgerMenu(),
          body: 
          SingleChildScrollView(
            child: Column(
             children: [
              const SizedBox(height:4),
              Row(children:[
                SizedBox(width: SizeConfig.blockSizeHorizontal! * 3),
                Image.asset('lib/assets/eye_catch/eyecatch.png',
                height: 30, width: 30),
              Align(
               alignment: Alignment.centerLeft,
               child:Text(
                ' 新タスクを追加',
                style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal! * 7,
                fontWeight: FontWeight.w700,
                ),
               )
              )
             ],
            ),

            Align(
              alignment: Alignment.centerLeft,
              child:Row(
               crossAxisAlignment:CrossAxisAlignment.end,
               children:[
                SizedBox(width: SizeConfig.blockSizeHorizontal! * 5),
                Text(
               ' カテゴリーを選択*',
               style: TextStyle(
               fontSize: SizeConfig.blockSizeHorizontal! * 4,
               color: requiredColour(inputForm.titleController.text)
               ),
              ),
              const Spacer(),
              TextButton(
               onPressed: (){
                inputForm.titleController.clear();
                showDialog(
                  context: context, 
                  builder: (BuildContext context){
                        return AlertDialog(
      title: const Text('新しいカテゴリ名を追加'),
      content: TextField(
        controller: inputForm.titleController,
        decoration: const InputDecoration(
          labelText: 'カテゴリ名',
          border: OutlineInputBorder()
          ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // ダイアログを閉じる
          },
          child:const Text('戻る'),
        ),
        TextButton(
          onPressed: () {
            String enteredText = inputForm.titleController.text;
            ref.read(inputFormProvider.notifier).updateDateTimeFields();
            Navigator.of(context).pop(); // ダイアログを閉じる
          },
          child:const Text('登録'),
        ),
      ],
    );
                  }
                  );
               },
              style: const ButtonStyle(
            padding: MaterialStatePropertyAll(EdgeInsets.all(1)),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap
            ),
    child:
     Text(
            "カテゴリの追加",
            style:TextStyle(color:Colors.blue,fontSize: SizeConfig.blockSizeHorizontal! *3),
            ) ),
    SizedBox(width: SizeConfig.blockSizeHorizontal! * 5),        
             ]),
            ),
              Container(
               width: SizeConfig.blockSizeHorizontal! * 90,
               height: SizeConfig.blockSizeVertical! * 20,
               decoration: BoxDecoration(border: Border.all(color:Colors.grey)),
               child:ListView.builder(
                itemExtent: SizeConfig.blockSizeVertical!*4.5,
                itemBuilder:(BuildContext context, int index){
                return ListTile(
                  title:Column(children:[
                   Text(
                    taskData.extractTitles(taskData.taskDataList).elementAt(index),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                   ),
                   const Divider(height:1,thickness: 1,)
                  ]),
                  selectedColor: Colors.amber,
                  contentPadding: const EdgeInsets.all(0),
                  //tileColor:tileColour(index),
                  onTap:() {
                     inputForm.titleController = TextEditingController(text:taskData.extractTitles(taskData.taskDataList).elementAt(index));
                     ref.read(inputFormProvider.notifier).updateDateTimeFields();
                   },
                  );
               },
               itemCount:taskData.extractTitles(taskData.taskDataList).length,
               ),
              ),
              Container(
                  width: SizeConfig.blockSizeHorizontal! * 90,
                  height: SizeConfig.blockSizeHorizontal! * 10,
                  padding:const EdgeInsets.all(5),
                  child:Container(
                  width: SizeConfig.blockSizeHorizontal! * 90,
                  child:
                  Row(
                  children:[
                  Text(
                    categoryText(inputForm.titleController.text),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    ),
                  Container(
                    padding: const EdgeInsets.only(
                      top:3,
                      bottom:3,
                      left:10,
                      right:10
                    ),
                    decoration: BoxDecoration(
                      color:categoryColour(inputForm.titleController.text),
                      borderRadius: BorderRadius.circular(20)
                    ),
                  child:
                  Text(
                  inputForm.titleController.text,
                  style:TextStyle(
                    fontSize: SizeConfig.blockSizeHorizontal! * 4,
                    fontWeight: FontWeight.w700,
                    color:Colors.white
                    )
                   ),
                  ),
                  const Spacer()       
                 ]),
                 )
                ),
              
              SizedBox(
                width: SizeConfig.blockSizeHorizontal! * 90,
                height: SizeConfig.blockSizeHorizontal! * 3,
              ),
              Container(
                width: SizeConfig.blockSizeHorizontal! * 90,
                height: SizeConfig.blockSizeHorizontal! * 8.5,
                child: TextField(
                  controller: inputForm.summaryController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), 
                      labelText: 'タスク名',
                      //labelStyle: TextStyle(color:requiredColour(inputForm.titleController.text))
                      ),
                ),
              ),
              SizedBox(
                width: SizeConfig.blockSizeHorizontal! * 90,
                height: SizeConfig.blockSizeHorizontal! * 3,
              ),
              Container(
                width: SizeConfig.blockSizeHorizontal! * 90,
                height: SizeConfig.blockSizeHorizontal! * 8.5,
                child: TextField(
                  controller: inputForm.descriptionController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: '詳細'),
                ),
              ),
              SizedBox(
                width: SizeConfig.blockSizeHorizontal! * 90,
                height: SizeConfig.blockSizeHorizontal! * 3,
              ),
              DateTimePickerFormField(
                controller: inputForm.dtEndController,
                labelText: '締め切り日時(２４時間表示)*',
                labelColor:requiredColour(inputForm.dtEndController.text)
              ),
              SizedBox(
                width: SizeConfig.blockSizeHorizontal! * 90,
                height: SizeConfig.blockSizeVertical! * 5,
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
                child: const Text('戻る',style:TextStyle(color: Colors.white)),
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
                  taskItem["description"] = inputForm.descriptionController.text;
                  taskItem["dtEnd"] = DateTime.parse(inputForm.dtEndController.text)
                      .millisecondsSinceEpoch;
                  registeTaskToDB(taskItem);

                  final list = ref.read(taskDataProvider).taskDataList;
                  final newList = [...list, taskItem];
                  ref.read(taskDataProvider.notifier).state = TaskData(taskDataList:newList);
                  ref.read(taskDataProvider).isRenewed = true;
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
                SizeConfig.blockSizeHorizontal! * 45,
                SizeConfig.blockSizeHorizontal! * 7.5,
              )),
            ),
                child: const Text('追加',style:TextStyle(color: Colors.white)),
              ),
            const Spacer(),
            ])
            ],
          ),)

        );
  }

  Color tileColour(int index){
   if(index.isEven){
    return Colors.white;
   }
    return Colors.grey;
  }

  Color categoryColour(String str){
   if(str == ""){
    return Colors.transparent;
   }
    return Colors.blue;
  }

  String categoryText(String str){
   if(str == ""){
    return "";
   }
    return "選択中：";
  }

  Color? requiredColour(String str){
   if(str == ""){
    return Colors.red;
   }
    return Colors.grey[700];
  }

}

class DateTimePickerFormField extends ConsumerWidget {
  final TextEditingController controller;
  final String labelText;
  final Color? labelColor;

  DateTimePickerFormField({
    required this.controller,
    required this.labelText,
    required this.labelColor
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
          width: SizeConfig.blockSizeHorizontal! * 90,
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
                  labelStyle:TextStyle(color:labelColor)
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
