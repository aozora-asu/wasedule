import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/add_event_button.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/schedule_data_manager.dart';
import 'package:flutter_calandar_app/frontend/screens/outdated/data_card.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/add_data_card_button.dart';
import 'package:intl/intl.dart';
import 'package:easy_autocomplete/easy_autocomplete.dart';

import '../common/app_bar.dart';
import '../common/burger_menu.dart';
import '../../../backend/DB/models/task.dart';
import '../../../backend/DB/handler/task_db_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/data_manager.dart';
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
   DailyViewPageState createState() => DailyViewPageState();
}

class DailyViewPageState extends ConsumerState<DailyViewPage> {
  @override
  Widget build(BuildContext context) {
    final inputForm = ref.watch(inputFormProvider);
    final taskData = ref.read(taskDataProvider);
    final data = ref.read(calendarDataProvider);
    String targetKey =  widget.target.year.toString()+ "-" + widget.target.month.toString().padLeft(2,"0") + "-" + widget.target.day.toString().padLeft(2,"0");
    ref.watch(taskDataProvider);
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

            const Divider(thickness:3, indent: 10,endIndent: 10,),

              Align(
                alignment: Alignment.centerLeft,
                child:
                    Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  SizedBox(width: SizeConfig.blockSizeHorizontal! * 5),
                  Text(
                    '予定',
                    style: TextStyle(
                        fontSize: SizeConfig.blockSizeHorizontal! *7,
                        color:Colors.grey),
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
            
            Column(children:[
             InkWell(
              child:Container(
               width: SizeConfig.blockSizeHorizontal! *95,
               padding: const EdgeInsets.all(16.0),
               decoration: BoxDecoration(
                color: Colors.redAccent, // コンテナの背景色
                borderRadius: BorderRadius.circular(12.0), // 角丸の半径
               ),
              child:const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
                Text("  +   予定の追加...",
                     style:TextStyle(color:Colors.white,fontSize: 25,fontWeight: FontWeight.bold),)
              ]),
            ),
            onTap: (){
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => CalendarInputForm(target: widget.target)),
              );
            }
          ),
          const SizedBox(height:15) 
          ]),

            const Divider(thickness:3, indent: 10,endIndent: 10,),

              const SizedBox(height:5),
              Align(
                alignment: Alignment.centerLeft,
                child:
                  Row(
                  children: [
                   SizedBox(width: SizeConfig.blockSizeHorizontal! * 5),
                   Text(
                    '期限のタスク',
                    style: TextStyle(
                        fontSize: SizeConfig.blockSizeHorizontal! *7,
                        color:Colors.grey),
                  ),
                  SizedBox(width: SizeConfig.blockSizeHorizontal! * 2),
                  taskListLength(18.0),
              ]),
            ),
            taskDataList(),
            SizedBox(width: SizeConfig.blockSizeHorizontal! * 5),
                        Column(children:[
             InkWell(
              child:Container(
               width: SizeConfig.blockSizeHorizontal! *95,
               padding: const EdgeInsets.all(16.0),
               decoration: BoxDecoration(
                color: Colors.white, // コンテナの背景色
                borderRadius: BorderRadius.circular(12.0), // 角丸の半径
                boxShadow: [
                BoxShadow(
                  color:
                      Colors.grey.withOpacity(0.5), // 影の色と透明度
                  spreadRadius: 2, // 影の広がり
                  blurRadius: 4, // 影のぼかし
                  offset: const Offset(0, 2), // 影の方向（横、縦）
                ),
            ],
               ),
              child:const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
                Text("  +   タスクの追加...",
                     style:TextStyle(color:Colors.grey,fontSize: 25,fontWeight: FontWeight.bold),)
              ]),
            ),
            onTap: (){
              Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TaskInputForm()),
            );
            }
          ),
          const SizedBox(height:15) 
          ]),
            const Divider(thickness:3, indent: 10,endIndent: 10,),

            SizedBox(height:SizeConfig.blockSizeVertical! *10),
          ])
        ),
        floatingActionButton:
            Row(
              children:[
                const Spacer(),
                FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  backgroundColor: ACCENT_COLOR,
                  label: 
                    SizedBox(
                      width: SizeConfig.blockSizeHorizontal! *80,
                      child:const 
                       Center(child:Text('戻る', style: TextStyle(color: Colors.white)),)
                      )
                ),
              ])
              
                
      );
  }

  Widget listView(){
    final taskData = ref.read(taskDataProvider);
    final data = ref.read(calendarDataProvider);
    String targetKey =  widget.target.year.toString()+ "-" + widget.target.month.toString().padLeft(2,"0") + "-" + widget.target.day.toString().padLeft(2,"0");

    if(data.sortedDataByDay[targetKey] == null){
      return  const SizedBox();
    }else{
     List targetDayData = data.sortedDataByDay[targetKey];
   return
     ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            Widget dateTimeData = Container();
            if (targetDayData.elementAt(index)["startTime"].trim() != "" && targetDayData.elementAt(index)["endTime"].trim() != ""){
              dateTimeData =
                  Text(
                    " " + targetDayData.elementAt(index)["startTime"] + "～" + targetDayData.elementAt(index)["endTime"],
                    style: const TextStyle(color:Colors.white,fontSize: 13,fontWeight: FontWeight.bold),
                  );
            } else if (targetDayData.elementAt(index)["startTime"].trim() != ""){
              dateTimeData =
                  Text(
                    " " + targetDayData.elementAt(index)["startTime"],
                    style: const TextStyle(color:Colors.white,fontSize: 13,fontWeight: FontWeight.bold),
                  );
            } else {
              dateTimeData = const Text(
                    " 終日",
                    style: TextStyle(color:Colors.white,fontSize: 13,fontWeight: FontWeight.bold),
                  );
            }


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
              dateTimeData,
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



  Widget taskListLength(fontSize){
    final taskData = ref.watch(taskDataProvider);
    Map<DateTime, List<Map<String, dynamic>>> sortedData = 
    taskData.sortDataByDtEnd(taskData.taskDataList);
    return Container(
      decoration: const BoxDecoration(
        color: Colors.redAccent,
        shape: BoxShape.circle,
      ),
      padding: EdgeInsets.all(fontSize / 3),
      child:Text(
        (sortedData[widget.target]?.length ?? 0).toString(),
        style:  TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize:fontSize
          ),
        )
      );
  }

  Widget taskDataList(){
    final taskData = ref.watch(taskDataProvider);
    Map<DateTime, List<Map<String, dynamic>>> sortedData = 
    taskData.sortDataByDtEnd(taskData.taskDataList);

    if(sortedData.keys.contains(widget.target)){
      return ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            Widget dateTimeData = Container();
              dateTimeData =
                  Text(
                    sortedData[widget.target]!.elementAt(index)["title"],
                    style: const TextStyle(color:Colors.grey,fontSize: 13,fontWeight: FontWeight.bold),
                  );

           return  Column(children:[
            Container(
             width: SizeConfig.blockSizeHorizontal! *95,
             padding: const EdgeInsets.all(16.0),
             decoration: BoxDecoration(
              color: Colors.white, // コンテナの背景色
              borderRadius: BorderRadius.circular(12.0), // 角丸の半径
              boxShadow: [
               BoxShadow(
                color:
                    Colors.grey.withOpacity(0.5), // 影の色と透明度
                spreadRadius: 2, // 影の広がり
                blurRadius: 4, // 影のぼかし
                offset: const Offset(0, 2), // 影の方向（横、縦）
              ),
            ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
              dateTimeData,
              Text(sortedData[widget.target]!.elementAt(index)["summary"] ?? "(詳細なし)",
                            style: const TextStyle(color:Colors.black,fontSize: 25,fontWeight: FontWeight.bold),)
            ]),
          ),
          const SizedBox(height:15)   
         ]);    
        },
        itemCount:
            sortedData[widget.target]!.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      );

    }else{

      return  const SizedBox();
    }
  }
}

