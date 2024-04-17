import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/handler/task_db_handler.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';

import '../common/app_bar.dart';
import '../common/burger_menu.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/task_data_manager.dart';

class DeletedTaskPage extends ConsumerStatefulWidget {
  List<Map<String, dynamic>> deletedData = [];
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
        appBar: CustomAppBar(backButton: true,),
        drawer: burgerMenu(),
        body: SizedBox(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              "削除済みタスク",
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 25),
            ),
          ),
          const Text(
              "！ 削除済みタスクは、期限から30日後に自動削除されます。",
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15,color:Colors.grey),
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
                  deletedData.elementAt(i)["dtEnd"]);
              String adjustedDtEnd = ("期限：${dateEnd.month}月${dateEnd.day}日");
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
                                    ref.read(taskDataProvider).sortDataByDtEnd(list);
                                    ref.read(taskDataProvider.notifier).state = TaskData(taskDataList: list);
                                    setState((){});
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
                            ]),
                        const Divider(
                          thickness: 2.5,
                          indent: 7,
                          endIndent: 7,
                        )
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

}
