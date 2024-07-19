import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/handler/task_db_handler.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/frontend/assist_files/ui_components.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/task_view_page.dart';
import 'package:intl/intl.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/task_data_manager.dart';

class ExpiredTaskPage extends ConsumerStatefulWidget {
  List<Map<String, dynamic>> expiredData = [];
  StateSetter setosute;
  ExpiredTaskPage ({super.key, 
     required this.setosute
  });
  
  @override
  _ExpiredTaskPageState createState() => _ExpiredTaskPageState();
}

class _ExpiredTaskPageState extends ConsumerState<ExpiredTaskPage> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final taskData = ref.watch(taskDataProvider);
    List<Map<String, dynamic>> expiredData = widget.expiredData;
    expiredData = taskData.expiredTaskDataList;
    ref.watch(taskDataProvider.notifier);
    ref.watch(taskDataProvider);

    return Scaffold(
      backgroundColor: BACKGROUND_COLOR,
        body: SizedBox(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding:const EdgeInsets.all(8),
            child:Row(children:[
            const Text(
              "未達成の期限切れタスク",
              style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 20,color:BLUEGREY),
             ),
             const SizedBox(width:5),
             listLengthView(expiredData.length, 15.0),
             const SizedBox(width:5),
             GestureDetector(
              onTap:()=> showPageDescriptionDialog(context),
              child:const Icon(Icons.info,color:Colors.grey),
             ),
             const Spacer(),
           ]) 
          ),
          const Divider(
            thickness: 1,
            height:2.5,
          ),
          Expanded(child:
          ListView.builder(
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int i) {
              DateTime dateEnd = DateTime.fromMillisecondsSinceEpoch(
                  expiredData.elementAt(i)["dtEnd"]);
              String adjustedDtEnd = ("期限：${DateFormat("yyyy年MM月dd日 HH:mm").format(dateEnd)}");
              return Container(
                margin:const EdgeInsets.symmetric(horizontal: 15,vertical:7.5),
                padding: const EdgeInsets.only(
                      left: 15.0, right: 15.0, bottom: 10.0, top: 10.0),
                decoration: roundedBoxdecorationWithShadow(),
                child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${expiredData.elementAt(i)["summary"]}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800),
                              ),
                              Text("${expiredData.elementAt(i)["title"]}",
                                style:const TextStyle(
                                  color: Colors.grey,
                                )
                              ),
                              const SizedBox(height:7.5),
                              Text(
                                  "${expiredData.elementAt(i)["description"]}"),
                              Row(children:[
                                Text(adjustedDtEnd,
                                  style:const TextStyle(
                                    color: Colors.grey,
                                  )
                                ),
                                const SizedBox(width:10),
                                InkWell(
                                  onTap: () async {
                                    await TaskDatabaseHelper().unDisplay(expiredData.elementAt(i)["id"]);
                                    List<Map<String, dynamic>> list = ref.read(taskDataProvider).taskDataList;
                                    int indexToRemove = returnIndexFromId(expiredData.elementAt(i)["id"]);
                                    list.removeAt(indexToRemove);
                                    ref.read(taskDataProvider).isRenewed = true;
                                    ref.read(taskDataProvider.notifier).state = TaskData(taskDataList: list);
                                    ref.read(taskDataProvider).sortDataByDtEnd(list);
                                    setState((){});
                                    widget.setosute((){});
                                  },
                                  child:const Icon(
                                    Icons.delete,color:Colors.grey)),
                                
                              ])
                            ]));
            },
            itemCount: expiredData.length,
          ),
        ),
          
        ])
      )
    );
  }
  
  int returnIndexFromId(int id){
    final taskData = ref.watch(taskDataProvider);
    int result = 0;
    List<Map<String,dynamic>> taskDataList = taskData.taskDataList;
    for(int i = 0; i < taskDataList.length; i++){
      if(taskDataList.elementAt(i)["id"] == id){
        result = i;
      }
    }
    return result;
  }

  void showPageDescriptionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const CupertinoAlertDialog(
          title: Text('「未達成の期限切れタスク」ページ'),
          content: Text('このページには、アプリ内で「完了」操作がされないまま期限を超過した課題が表示されます。完了した課題は、課題ページ内のチェックボックスまたは通知アクションから「完了」状態にしましょう。',
            style:TextStyle(color:Colors.grey)),
        );
      },
    );
  }
}