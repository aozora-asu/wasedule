import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/handler/task_db_handler.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
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
        body: SizedBox(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding:const EdgeInsets.all(8),
            child:Row(children:[
            const Text(
              "未達成の期限切れタスク",
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 25),
             ),
             const SizedBox(width:10),
             listLengthView(expiredData.length, 15.0)
           ]) 
          ),
          const Divider(
            thickness: 2.5,
            height:2.5,
            indent: 7,
            endIndent: 7,
          ),
          Expanded(child:
          ListView.builder(
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int i) {
              DateTime dateEnd = DateTime.fromMillisecondsSinceEpoch(
                  expiredData.elementAt(i)["dtEnd"]);
              String adjustedDtEnd = ("期限：${DateFormat("yyyy年MM月dd日 HH:mm").format(dateEnd)}");
              return Container(
                  width: SizeConfig.blockSizeHorizontal! * 100,
                  padding: const EdgeInsets.only(
                      left: 8.0, right: 8.0, bottom: 0.0, top: 4.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${expiredData.elementAt(i)["summary"]}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800),
                              ),
                              Text("${expiredData.elementAt(i)["title"]}"),
                              Text(
                                  "${expiredData.elementAt(i)["description"]}"),
                              Row(children:[
                                Text(adjustedDtEnd),
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
                            ]),
                        const Divider(
                          thickness: 2.5,
                          indent: 7,
                          endIndent: 7,
                        )
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

}