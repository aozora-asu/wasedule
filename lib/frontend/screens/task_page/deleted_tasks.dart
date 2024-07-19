import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/handler/task_db_handler.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/frontend/assist_files/ui_components.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/task_data_manager.dart';

class DeletedTaskPage extends ConsumerStatefulWidget {
  List<Map<String, dynamic>> deletedData = [];
  StateSetter setosute;
  DeletedTaskPage ({super.key, 
     required this.setosute
  });
  @override
  _DeletedTaskPageState createState() => _DeletedTaskPageState();
}

class _DeletedTaskPageState extends ConsumerState<DeletedTaskPage> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final taskData = ref.watch(taskDataProvider);
    List<Map<String, dynamic>> deletedData = widget.deletedData;
    deletedData = taskData.deletedTaskDataList;
    ref.watch(taskDataProvider.notifier);
    ref.watch(taskDataProvider);

    return Scaffold(
      backgroundColor: BACKGROUND_COLOR,
        body: SizedBox(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding:const EdgeInsets.all(8),
            child: Row(children:[
             const Text(
                "削除済みタスク",
                style: TextStyle(fontWeight:FontWeight.bold,fontSize: 20,color:BLUEGREY),
              ),
            const SizedBox(width:10),
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
                  deletedData.elementAt(i)["dtEnd"]);
              String adjustedDtEnd = ("期限：${dateEnd.month}月${dateEnd.day}日");
              return Container(
                margin:const EdgeInsets.symmetric(horizontal: 15,vertical:7.5),
                padding: const EdgeInsets.only(
                      left: 15.0, right: 15.0, bottom: 10.0, top: 10.0),
                decoration: roundedBoxdecorationWithShadow(),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                              Text(
                                "${deletedData.elementAt(i)["summary"]}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800),
                              ),
                              Text("${deletedData.elementAt(i)["title"]}"),
                              Text(
                                  "${deletedData.elementAt(i)["description"]}"),
                              Row(children:[
                                Text(adjustedDtEnd),
                                const SizedBox(width:10),
                                InkWell(
                                  onTap: () async {
                                    await TaskDatabaseHelper().beDisplay(deletedData.elementAt(i)["id"]);
                                    
                                    List<Map<String, dynamic>> list = ref.read(taskDataProvider).taskDataList;
                                    int indexToRemove = returnIndexFromId(deletedData.elementAt(i)["id"]);
                                    list.removeAt(indexToRemove);
                                    ref.read(taskDataProvider).isRenewed = true;
                                    
                                    ref.read(taskDataProvider.notifier).state = TaskData(taskDataList: list);
                                    ref.read(taskDataProvider).sortDataByDtEnd(list);
                                    setState((){});
                                    widget.setosute((){});
                                  },
                                  child:const 
                                    Row(children:[
                                    Icon(
                                      Icons.undo,color:Colors.grey),
                                    SizedBox(width:2),
                                    Text(
                                      "復元",
                                      style:TextStyle(color:Colors.grey)),
                                    ])
                                )
                              ])
                      ]));
            },
            itemCount: deletedData.length,
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
          title: Text('「削除済みタスク」ページ'),
          content: Text('削除された課題は、期限から30日後に自動削除されます。',
            style:TextStyle(color:Colors.grey)),
        );
      },
    );
  }

}
