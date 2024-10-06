
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_calandar_app/backend/DB/handler/task_db_handler.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/frontend/screens/common/ui_components.dart';
import 'package:flutter_calandar_app/frontend/screens/common/hyper_link_text_controller.dart';

import 'package:flutter_calandar_app/frontend/screens/moodle_view_page/moodle_view_page.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/add_data_card_button.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/task_data_manager.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:intl/intl.dart';
import 'package:toggle_switch/toggle_switch.dart';

Future<void> bottomSheet(context, targetData, setState) async {
  showModalBottomSheet(
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return TaskModalSheet(targetData: targetData, setosute: setState);
      });
}

class TaskModalSheet extends ConsumerStatefulWidget {
  Map<String, dynamic> targetData;
  StateSetter setosute;

  TaskModalSheet({
    super.key,
    required this.targetData,
    required this.setosute,
  });

  @override
  _TaskModalSheetState createState() => _TaskModalSheetState();
}

class _TaskModalSheetState extends ConsumerState<TaskModalSheet> {
  late TextEditingController summaryController = TextEditingController();
  late TextEditingController titleController = TextEditingController();
  late TextEditingController descriptionController = TextEditingController();
  late TextEditingController taskDraftController = TextEditingController();
  late String taskDraft = "";
  late bool moodleMode;

  @override
  void initState() {
    super.initState();
    Map targetData = widget.targetData;
    summaryController =
        TextEditingController(text: targetData["summary"] ?? "");
    titleController = TextEditingController(text: targetData["title"] ?? "");
    if (!kReleaseMode) {
      descriptionController = TextEditingController(
        text: targetData["description"] ?? "",
      );
    } else {
      descriptionController = LinkedTextEditingController(
        text: targetData["description"] ?? "",
      );
    }

    // if(prefs.getString(targetData["id"].toString()) != null){
    //   taskDraft = prefs.getString(targetData["id"].toString())!;
    // }
    if (targetData["memo"] != null) {
      taskDraft = targetData["memo"];
    }

    taskDraftController = TextEditingController(text: taskDraft);
    moodleMode = false;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    Map targetData = widget.targetData;
    StateSetter setosute = widget.setosute;
    final bottomSpace = MediaQuery.of(context).viewInsets.bottom;


    DateTime dtEnd = DateTime.fromMillisecondsSinceEpoch(targetData["dtEnd"]);
    int id = targetData["id"];
    int height = (SizeConfig.blockSizeVertical! * 100).round();
    String? pageID = targetData["pageID"];

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
          reverse: true,
          child: Scrollbar(
            interactive: true,
            thickness: 5,
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomSpace),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: SizeConfig.blockSizeVertical! *20,
                  maxHeight: SizeConfig.blockSizeVertical! *90),
                  child:
        Container(
            margin: const EdgeInsets.only(top: 0),
            decoration: BoxDecoration(
              color: FORGROUND_COLOR,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: SingleChildScrollView(
                primary: false,
                physics: moodleMode ?
                  const NeverScrollableScrollPhysics():
                  const ScrollPhysics(),
                  child: Column(
                    children: [
                      ModalSheetHeader(),

                      moodleModeSwitch(),

                      if(!moodleMode)
                      Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Column(children: [
                            Row(
                             crossAxisAlignment: CrossAxisAlignment.center,
                             children:[

                              Expanded(child:
                                textFieldModel(
                                  "タスク名",1,summaryController,
                                  (value) {
                                      TaskDatabaseHelper().updateSummary(id, value);

                                      final list =
                                          ref.read(taskDataProvider).taskDataList;
                                      final newList = [...list];
                                      ref.read(taskDataProvider.notifier).state =
                                          TaskData();
                                      ref.read(taskDataProvider).isRenewed = true;
                                      setosute(() {});
                                  },
                                ),
                              ),

                              GestureDetector(
                                onTap:() async {
                                  await showConfirmDeleteDialog(
                                    context,summaryController.text,
                                    ()async{
                                      await TaskDatabaseHelper().unDisplay(id);
                                      setState(() {});
                                      final list =
                                          ref.read(taskDataProvider).taskDataList;
                                      List<Map<String, dynamic>> newList = [...list];
                                      ref.read(taskDataProvider.notifier).state =
                                          TaskData(taskDataList: newList);
                                      ref.read(taskDataProvider).isRenewed = true;
                                      ref
                                          .read(taskDataProvider)
                                          .sortDataByDtEnd(list);
                                      setState(() {});
                                      Navigator.pop(context);
                                    });
                                },
                                child: const Icon(
                                    Icons.delete,
                                    color: Colors.grey
                                ),
                              ),

                            ]),

                            textFieldModel(
                              "カテゴリ",2,titleController,
                              (value) {
                                TaskDatabaseHelper().updateTitle(id, value);
                                final list =
                                    ref.read(taskDataProvider).taskDataList;
                                final newList = [...list];
                                ref.read(taskDataProvider.notifier).state =
                                    TaskData();
                                ref.read(taskDataProvider).isRenewed = true;
                                setosute(() {});
                              },
                            ),

                            textFieldModel(
                              "タスクの詳細",2,descriptionController,
                              weight: FontWeight.normal,
                              (value) {
                                TaskDatabaseHelper()
                                    .updateDescription(id, value);

                                final list =
                                    ref.read(taskDataProvider).taskDataList;
                                final newList = [...list];
                                ref.read(taskDataProvider.notifier).state =
                                    TaskData();
                                ref.read(taskDataProvider).isRenewed = true;
                                setState(() {});
                              },
                            ),

                            const SizedBox(height: 5),
                            indexModel("締め切り"),
                            GestureDetector(
                              child: Text(
                                  DateFormat("yyyy年MM月dd日  HH時mm分")
                                      .format(dtEnd),
                                 style: const TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 20)),
                              onTap: () async {
                                TextEditingController controller =
                                    TextEditingController();
                                await DateTimePickerFormField(
                                  controller: controller,
                                  labelText: "",
                                  labelColor: MAIN_COLOR,
                                ).selectDateAndTime(context, ref);
                                DateTime changedDateTime =
                                    DateTime.parse(controller.text);
                                int changedDateTimeSinceEpoch =
                                    changedDateTime.millisecondsSinceEpoch;

                                await TaskDatabaseHelper().updateDtEnd(
                                    id, changedDateTimeSinceEpoch);

                                final list =
                                    ref.read(taskDataProvider).taskDataList;
                                final newList = [...list];
                                ref.read(taskDataProvider.notifier).state =
                                    TaskData();
                                ref.read(taskDataProvider).isRenewed = true;
                                setState(() {});
                                Navigator.pop(context);
                              },
                            ),

                            const Divider(height: 30),

                          ])
                      ),

                        Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Column(children: [
                            textFieldModel(
                                "課題の下書き",3,taskDraftController,
                                (value) async {
                                      await TaskDatabaseHelper().updateMemo(
                                          id, taskDraftController.text);

                                      setState(() {});
                              },
                            ),
                                
                             Row(children: [

                                Text(
                                  "文字数：${countJapaneseAlphabetNumericCharacters(taskDraftController.text)}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: BLUEGREY),
                                ),
                                const Spacer(),
                                GestureDetector(
                                    onTap: () {
                                      Clipboard.setData(ClipboardData(
                                          text: taskDraftController.text));
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          backgroundColor: FORGROUND_COLOR,
                                          content: const Text(
                                            "テキストがクリップボードにコピーされました。",
                                            style: TextStyle(
                                                color: BLUEGREY,
                                                fontWeight:
                                                    FontWeight.bold),
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Row(children: [
                                      Icon(Icons.copy, color: BLUEGREY),
                                      Text("コピー",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: BLUEGREY))
                                  ])
                                ),
                              ])

                          ])
                        ),

                        const SizedBox(height: 20),
                        if(moodleMode)
                          webView(pageID, height),
                        const SizedBox(
                          height:40,
                        ),
                      ])
                    ),
                  ),
                

        )
      )
     )
    );
   });
  }

  bool isEditing = false;

  Widget webView(String? pageID, int height) {
    if (pageID != null) {
      return Column(children: [
        indexModel("  Moodle ページビュー"),
        Container(
            width: SizeConfig.blockSizeHorizontal! * 100,
            height: SizeConfig.blockSizeVertical! * 60,
            decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
            child: SizedBox(
                  width: SizeConfig.blockSizeHorizontal! * 100,
                  height: SizeConfig.blockSizeVertical! * height,
                  child: InAppWebView(
                    key: webMoodleViewKey,
                    initialUrlRequest: URLRequest(

                        //ここに課題ページのURLを受け渡し！

                        url: WebUri(
                            "https://wsdmoodle.waseda.jp/course/view.php?id=$pageID")),
                    onWebViewCreated: (controller) {
                      webMoodleViewController = controller;
                    },
                    onLoadStop: (a, b) async {
                      height =
                          await webMoodleViewController.getContentHeight() ??
                              100;
                      setState(() {});
                    },
                    onContentSizeChanged: (a, b, c) async {
                      height =
                          await webMoodleViewController.getContentHeight() ??
                              100;
                      setState(() {});
                    },
                  )),
            ),
            menuBar()
      ]);
    } else {
      return const SizedBox();
    }
  }

  Widget moodleModeSwitch(){
    return 
    FlutterToggleTab
        (height: 30,
          width: SizeConfig.blockSizeHorizontal! *24,
          borderRadius: 5,
          selectedIndex: moodleMode ? 1 : 0,
          selectedTextStyle:const TextStyle(
            color: Colors.white,
            fontSize: 15
          ),
          unSelectedTextStyle:const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
          labels: const ["課題概要","Moodle"],
          selectedBackgroundColors: const [BLUEGREY,BLUEGREY],
          selectedLabelIndex: (index) {
            setState(() {
              if(moodleMode){
                moodleMode = false;
              }else{
                moodleMode = true;
              }
            });
          },
          marginSelected:const EdgeInsets.symmetric(horizontal: 2,vertical:3),
          isScroll: true,
          isShadowEnable: false,
    );
  }

  int countJapaneseAlphabetNumericCharacters(String input) {
    int japaneseCount = 0;
    int alphabetCount = 0;
    int numericCount = 0;
    final RegExp japaneseRegex =
        RegExp(r'[\u3040-\u30FF\u3400-\u4DBF\u4E00-\u9FFF\uF900-\uFAFF]');
    final RegExp alphabetRegex = RegExp(r'[a-zA-Z]');
    final RegExp numericRegex = RegExp(r'[0-9]');

    for (int i = 0; i < input.length; i++) {
      if (japaneseRegex.hasMatch(input[i])) {
        japaneseCount++;
      } else if (alphabetRegex.hasMatch(input[i])) {
        alphabetCount++;
      } else if (numericRegex.hasMatch(input[i])) {
        numericCount++;
      }
    }
    return japaneseCount + alphabetCount + numericCount;
  }

  Widget textFieldModel(
    String title,
    int type,
    TextEditingController controller,
    Function(String)onChanged,
    {FontWeight weight = FontWeight.bold}
  ){
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 5),
          indexModel(title),
          CupertinoTextField(
            controller: controller,
            maxLines: null,
            textInputAction: TextInputAction.done,
            style: TextStyle(
                fontSize: 16, fontWeight: weight),
            onSubmitted: (value) async{
              await onChanged(value);
            }
          )
        ],
      ),
    );
  }

  Widget indexModel(String text) {
    return Column(children: [
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.normal, color: Colors.grey),
        ),
      ),
    ]);
  }

  Widget menuBar() {
    return Container(
        decoration: BoxDecoration(
            color: FORGROUND_COLOR,
            border: const Border(top: BorderSide(color: Colors.grey))),
        child: Row(children: [
          IconButton(
            onPressed: () {
              webMoodleViewController.goBack();
            },
            icon: Icon(
              Icons.arrow_back_ios,
              size: SizeConfig.blockSizeVertical! * 2.5,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              final url =
                  URLRequest(url: WebUri("https://wsdmoodle.waseda.jp/"));
              webMoodleViewController.loadUrl(urlRequest: url);
            },
            icon: Icon(
              Icons.home,
              size: SizeConfig.blockSizeVertical! * 3,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              webMoodleViewController.goForward();
            },
            icon: Icon(
              Icons.arrow_forward_ios,
              size: SizeConfig.blockSizeVertical! * 2.5,
            ),
          ),
        ]));
  }
}
