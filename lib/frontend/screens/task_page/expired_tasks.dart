import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/task_view_page.dart';
import 'package:intl/intl.dart';

import '../common/app_bar.dart';
import '../common/burger_menu.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/task_data_manager.dart';

class ExpiredTaskPage extends ConsumerStatefulWidget {
  List<Map<String, dynamic>> expiredData = [];
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
        appBar: CustomAppBar(backButton: true,),
        drawer: burgerMenu(),
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
              String adjustedDtEnd = ("期限：" + DateFormat("yyyy年MM月dd日 hh:mm").format(dateEnd));
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
                              Text(adjustedDtEnd)
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
}
