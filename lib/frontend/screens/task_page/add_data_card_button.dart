import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/calendar_data_manager.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/screens/menu_pages/arbeit_stats_page.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';

import '../common/app_bar.dart';
import '../common/burger_menu.dart';
import '../../../backend/DB/models/task.dart';
import '../../../backend/DB/handler/task_db_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/task_data_manager.dart';

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


class AddDataCardButton extends ConsumerStatefulWidget {
  late StateSetter setosute;

  AddDataCardButton({
   required this.setosute
  });

  @override
  AddDataCardButtonState createState() => AddDataCardButtonState();
}

class AddDataCardButtonState extends ConsumerState<AddDataCardButton>{
  @override
  Widget build(BuildContext context) {
    final inputForm = ref.watch(inputFormProvider);
    return SizedBox(
      child: FloatingActionButton(
        heroTag: "task_1",
        onPressed: () {
          inputForm.clearContents();
          showDialog(
            context: context,
            builder: (BuildContext context){
              return TaskInputForm(setosute: widget.setosute);
          });
        },
        foregroundColor: Colors.white,
        backgroundColor: ACCENT_COLOR,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TaskInputForm extends ConsumerStatefulWidget {
  late StateSetter setosute;
  TaskInputForm({
   required this.setosute
  });
  @override
  TaskInputFormState createState() => TaskInputFormState();
}

class TaskInputFormState extends ConsumerState<TaskInputForm> {

  @override
  Widget build(BuildContext context) {
    ref.watch(taskDataProvider);
    return GestureDetector(
      child:Scaffold(
        backgroundColor: Colors.transparent,
        body:Center(
         child: Padding(
          padding:const EdgeInsets.symmetric(horizontal:15),
            child:pageBody()
          ) 
      ),
      ),
      onTap: (){Navigator.pop(context);},
      );
  }

  Widget preview(){
      final inputForm = ref.watch(inputFormProvider);
      String dateEnd = "締め切り日*";
      String timeEnd = "HH:MM*";

      if(inputForm.dtEndController.text.isNotEmpty){
        DateTime dtEnd = DateTime.parse(inputForm.dtEndController.text);
        dateEnd = DateFormat("MM月dd日(E)",'ja_JP').format(dtEnd);
        timeEnd = DateFormat("HH:mm").format(dtEnd);
      }
      
      return Container(
        padding: const EdgeInsets.symmetric(vertical:7,horizontal:10),
        decoration: roundedBoxdecorationWithShadow(),
        child:Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:[

          Text(dateEnd,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize :SizeConfig.blockSizeHorizontal! *8,
                color:Colors.black
            ),
          ),

          Row(children:[

            Text(timeEnd,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize :SizeConfig.blockSizeHorizontal! *3,
                color:Colors.black
              ),
            ),

            const SizedBox(width:5),

            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2), // 影の色と透明度
                      spreadRadius: 1.5, // 影の広がり
                      blurRadius: 1, // ぼかしの強さ
                      offset: const Offset(0, 1), // 影の位置（横方向、縦方向）
                    ),
                  ]),
              child: Row(children: [
                CupertinoCheckbox(
                    value: false,
                    onChanged: (value) {}),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                          width: SizeConfig.blockSizeHorizontal! * 60,
                          child: Text(title(inputForm.summaryController.text),
                            style: TextStyle(
                                fontSize: SizeConfig.blockSizeHorizontal! * 4.5,
                                fontWeight: FontWeight.w700)
                              )
                            ),
                      SizedBox(
                          width: SizeConfig.blockSizeHorizontal! * 60,
                          child: Text(category(inputForm.titleController.text),
                            style: TextStyle(
                              fontSize:SizeConfig.blockSizeVertical! * 1.75,
                              color: Colors.grey,
                    )
                  )
                )
              ]),
            ])
          )
         
        ]),

        const SizedBox(height:5),

        const Divider(
          thickness: 2.5,
          indent: 7,
          endIndent: 7,
        ),

      ])
    );    
  }

  String title(String text){
    if(text == ""){
      return "タスク名";
    }else{
      return text;
    }
  }

  String category(String text){
    if(text == ""){
      return "カテゴリー*";
    }else{
      return text;
    }
  }

  String categoryWithNum(String text){
    if(text == ""){
      return "④カテゴリー*";
    }else{
      return text;
    }
  }

  String description(String text){
    if(text == ""){
      return "タスクの詳細";
    }else{
      return text;
    }
  }

  Widget pageBody() {
    final inputForm = ref.watch(inputFormProvider);
    final taskData = ref.read(taskDataProvider);
    return SingleChildScrollView(
      child: Column(children:[
 
     GestureDetector(
        onTap: (){},
        child:Container(
          decoration: roundedBoxdecorationWithShadow(),
          padding: const EdgeInsets.symmetric(horizontal:20),
          child: Column(
            children: [

            const SizedBox(height:10),

              Align(
                alignment: Alignment.centerLeft,
                  child: Row(children:[
                    const Icon(Icons.check,size:35,color:Colors.grey),
                    Text(
                      ' 新タスクを入力',
                      style: TextStyle(
                        fontSize: SizeConfig.blockSizeHorizontal! * 7,
                      ),
                    )
                  ]) 
              ),

              const Divider(height:7),

              SizedBox(
                width: SizeConfig.blockSizeHorizontal! * 90,
                height: SizeConfig.blockSizeHorizontal! * 2,
              ),

              SizedBox(
                width: SizeConfig.blockSizeHorizontal! * 90,
                //height: SizeConfig.blockSizeHorizontal! * 8.5,
                child: TextField(
                  controller: inputForm.summaryController,
                  maxLines: null,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '①タスク名',
                  ),
                  onChanged: (value) {setState(() {});},
                ),
              ),

              SizedBox(
                width: SizeConfig.blockSizeHorizontal! * 90,
                height: SizeConfig.blockSizeHorizontal! * 3,
              ),

              SizedBox(
                width: SizeConfig.blockSizeHorizontal! * 90,
                //height: SizeConfig.blockSizeHorizontal! * 8.5,
                child: TextField(
                  textInputAction: TextInputAction.done,
                  controller: inputForm.descriptionController,
                  maxLines: null,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: '②詳細'),
                  onChanged: (value) {setState(() {});},
                ),
              ),

              SizedBox(
                width: SizeConfig.blockSizeHorizontal! * 90,
                height: SizeConfig.blockSizeHorizontal! * 3,
              ),

              DateTimePickerFormField(
                  controller: inputForm.dtEndController,
                  labelText: '③締め切り日時(２４時間表示)*',
                  labelColor: requiredColour(inputForm.dtEndController.text)
              ),

              SizedBox(
                width: SizeConfig.blockSizeHorizontal! * 90,
                height: SizeConfig.blockSizeHorizontal! * 3,
              ),


              InkWell(
                onTap:(){categoryBottomSheet();},
                child:Container(
                  width: SizeConfig.blockSizeHorizontal! * 90,
                  height: SizeConfig.blockSizeHorizontal! * 8.5,
                  padding: const EdgeInsets.symmetric(vertical:5,horizontal:10),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                    border: Border.all(
                      color: Colors.grey, 
                      width: 1,            
                    ),
                  ),
                  child: Text(
                    categoryWithNum(inputForm.titleController.text),
                    style: TextStyle(
                      color:requiredColour(inputForm.titleController.text),
                      fontSize: 15
                    )
                  ),
                ),
              ),
              

                ElevatedButton(
                  onPressed: () async{
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
                      await registeTaskToDB(taskItem);

                      final list = ref.read(taskDataProvider).taskDataList;
                      final newList = [...list, taskItem];
                      ref.read(taskDataProvider.notifier).state =
                          TaskData(taskDataList: newList);
                     
                      ref.read(taskDataProvider).isRenewed = true;
                      inputForm.clearContents();
                      ref.read(calendarDataProvider.notifier).state =
                          CalendarData();
                      
                      Navigator.of(context).popUntil((route) => route.isFirst);
                      
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
                      SizeConfig.blockSizeHorizontal! * 85,
                      SizeConfig.blockSizeHorizontal! * 7.5,
                    )),
                  ),
                  child:
                      const Text('追加', style: TextStyle(color: Colors.white)),
                ),

                SizedBox(
                  width: SizeConfig.blockSizeHorizontal! * 90,
                  height: SizeConfig.blockSizeHorizontal! * 5,
                ),

              ])
          )
        )
      ]) 
    );
  }

  Color tileColour(int index) {
    if (index.isEven) {
      return Colors.white;
    }
    return Colors.grey;
  }

  Color categoryColour(String str) {
    if (str == "") {
      return Colors.transparent;
    }
    return Colors.blue;
  }

  String categoryText(String str) {
    if (str == "") {
      return "";
    }
    return "選択中：";
  }

  Color? requiredColour(String str) {
    if (str == "") {
      return Colors.red;
    }
    return Colors.grey[700];
  }

  void descriptionBottomSheet() {
    final inputForm = ref.read(inputFormProvider);

    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return Container(
            height: SizeConfig.blockSizeVertical! * 60,
            margin: const EdgeInsets.only(top: 0),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: SingleChildScrollView(
                child: Scrollbar(
              child: Column(
                children: [
                  Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5), // 影の色と透明度
                            spreadRadius: 2, // 影の広がり
                            blurRadius: 4, // 影のぼかし
                            offset: const Offset(0, 2), // 影の方向（横、縦）
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      height: SizeConfig.blockSizeHorizontal! * 13,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: SizeConfig.blockSizeHorizontal! * 4,
                          ),
                          SizedBox(
                              width: SizeConfig.blockSizeHorizontal! * 92,
                              child: Row(
                                children: [
                                  Container(
                                    constraints: BoxConstraints(
                                        maxWidth:
                                            SizeConfig.blockSizeHorizontal! *
                                                73.5),
                                    child: Text(
                                      title(inputForm.summaryController.text),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize:
                                              SizeConfig.blockSizeHorizontal! *
                                                  5,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  Text(
                                    "  の詳細",
                                    style: TextStyle(
                                        fontSize:
                                            SizeConfig.blockSizeHorizontal! * 5,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ],
                              )),
                          SizedBox(
                            width: SizeConfig.blockSizeHorizontal! * 4,
                          ),
                        ],
                      )),
                  SizedBox(
                    height: SizeConfig.blockSizeHorizontal! * 2,
                  ),
                  Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "タスク名",
                            style: TextStyle(
                                fontSize: SizeConfig.blockSizeHorizontal! * 4,
                                fontWeight: FontWeight.normal,
                                color: Colors.grey),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            title(inputForm.summaryController.text),
                            style: TextStyle(
                                fontSize: SizeConfig.blockSizeHorizontal! * 4,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                        SizedBox(
                          height: SizeConfig.blockSizeHorizontal! * 2,
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "カテゴリ",
                            style: TextStyle(
                                fontSize: SizeConfig.blockSizeHorizontal! * 4,
                                fontWeight: FontWeight.normal,
                                color: Colors.grey),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            category(inputForm.titleController.text),
                            maxLines: 1,
                            style: TextStyle(
                                fontSize: SizeConfig.blockSizeHorizontal! * 4,
                                fontWeight: FontWeight.w400
                            ),
                          ),
                        ),
                        SizedBox(
                          height: SizeConfig.blockSizeHorizontal! * 2,
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "タスクの詳細",
                            style: TextStyle(
                                fontSize: SizeConfig.blockSizeHorizontal! * 4,
                                fontWeight: FontWeight.normal,
                                color: Colors.grey),
                          ),
                        ),
                        SizedBox(
                          height: SizeConfig.blockSizeHorizontal! * 0.5,
                        ),
                        Text(
                          description(inputForm.descriptionController.text),
                          style: TextStyle(
                            fontSize: SizeConfig.blockSizeHorizontal! * 4,
                          ),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          height: SizeConfig.blockSizeVertical! * 70,
                        )
                      ]))
                ],
              ),
            )));
      },
    );
  }

 void categoryBottomSheet(){
  final inputForm = ref.read(inputFormProvider);
  final taskData = ref.read(taskDataProvider);
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    enableDrag: true,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (context) {        
               
      return  Container(
        height:SizeConfig.blockSizeVertical! *30,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        margin:const  EdgeInsets.only(top: 80),
        child: SizedBox(
          child: Column(children:[
            const SizedBox(height:10),
              Align(
                alignment: Alignment.centerLeft,
                child:
                   Text(
                    '    カテゴリーを選択*',
                    style: TextStyle(
                        fontSize: SizeConfig.blockSizeHorizontal! * 4,
                        color: requiredColour(inputForm.titleController.text)),
                  ),
              ),
              Container(
                width: SizeConfig.blockSizeHorizontal! * 90,
                height: SizeConfig.blockSizeVertical! * 20,
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.grey)),
                child: ListView.builder(
                  itemExtent: SizeConfig.blockSizeVertical! * 4.5,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Column(children: [
                        Text(
                          taskData
                              .extractTitles(taskData.taskDataList)
                              .elementAt(index),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Divider(
                          height: 1,
                          thickness: 1,
                        )
                      ]),
                      contentPadding: const EdgeInsets.all(0),
                      onTap: () {
                        inputForm.titleController = TextEditingController(
                            text: taskData
                                .extractTitles(taskData.taskDataList)
                                .elementAt(index));
                        ref
                            .read(inputFormProvider.notifier)
                            .updateDateTimeFields();
                        Navigator.pop(context);
                      },
                    );
                  },
                  itemCount:
                      taskData.extractTitles(taskData.taskDataList).length,
                ),
              ),

                 Row(crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                  const Spacer(),
                  TextButton(
                      onPressed: () {
                        inputForm.titleController.clear();
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('新しいカテゴリ名を追加'),
                                content: TextField(
                                  controller: inputForm.titleController,
                                  decoration: const InputDecoration(
                                      labelText: 'カテゴリ名',
                                      border: OutlineInputBorder()),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(); // ダイアログを閉じる
                                    },
                                    child: const Text('戻る'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      String enteredText =
                                          inputForm.titleController.text;
                                      ref
                                          .read(inputFormProvider.notifier)
                                          .updateDateTimeFields();
                                      Navigator.of(context).pop(); // ダイアログを閉じる
                                    },
                                    child: const Text('登録'),
                                  ),
                                ],
                              );
                            });
                      },
                      style: const ButtonStyle(
                          padding: MaterialStatePropertyAll(EdgeInsets.all(1)),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                      child: Text(
                        "カテゴリの追加",
                        style: TextStyle(
                            color: Colors.blue,
                            fontSize: SizeConfig.blockSizeHorizontal! * 3),
                      )),
                  SizedBox(width: SizeConfig.blockSizeHorizontal! * 5),
                ]),

          ])
        ),
      );
   });
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

  Future<void> selectDateAndTime(BuildContext context, WidgetRef ref) async {
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
      DateTime now = DateTime.now();
      TimeOfDay? pickedTime = TimeOfDay.fromDateTime(
        await DatePicker.showTimePicker(
        context,
        showTitleActions: true,
        showSecondsColumn: false,
        currentTime: DateTime.now(),
        locale: LocaleType.jp
      ) ?? DateTime(now.year,now.month,now.day,23,59));

      // await showTimePicker(
      //   context: context,
      //   initialTime: const TimeOfDay(hour: 23, minute: 59),
      //   initialEntryMode: TimePickerEntryMode.input,
      //   builder: (context, child) {
      //     return MediaQuery(
      //       data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
      //       child: child!,
      //     );
      //   },
      // );

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
        SizedBox(
          width: SizeConfig.blockSizeHorizontal! * 90,
          height: SizeConfig.blockSizeHorizontal! * 8.5,
          child: InkWell(
            onTap: () {
              selectDateAndTime(context, ref);
            },
            child: IgnorePointer(
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
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
