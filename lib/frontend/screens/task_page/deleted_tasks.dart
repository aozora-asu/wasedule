import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/screens/outdated/data_card.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:intl/intl.dart';

import '../common/app_bar.dart';
import '../common/burger_menu.dart';
import '../../../../backend/DB/models/task.dart';
import '../../../backend/DB/handler/task_db_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/data_manager.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/task_view_page.dart';

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
        appBar: const CustomAppBar(),
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
          const Divider(
            thickness: 2.5,
            indent: 7,
            endIndent: 7,
          ),
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
                              Text(adjustedDtEnd)
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
          Row(children: [
            const SizedBox(width: 7),
            ElevatedButton(
                style: const ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(ACCENT_COLOR)),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("戻る", style: TextStyle(color: Colors.white)))
          ])
        ])));
  }
}