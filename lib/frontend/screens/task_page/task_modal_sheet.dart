import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_calandar_app/backend/DB/handler/task_db_handler.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/frontend/assist_files/ui_components.dart';
import 'package:flutter_calandar_app/frontend/screens/moodle_view_page/moodle_view_page.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/add_data_card_button.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/task_data_manager.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import "../../../backend/DB/handler/task_db_handler.dart";

Future<void> bottomSheet(context, targetData, setState) async {
  showModalBottomSheet(
      isScrollControlled: true,
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
  @override
  void initState() {
    super.initState();
    Map targetData = widget.targetData;
    summaryController =
        TextEditingController(text: targetData["summary"] ?? "");
    titleController = TextEditingController(text: targetData["title"] ?? "");
    descriptionController =
        TextEditingController(text: targetData["description"] ?? "");

    // if(prefs.getString(targetData["id"].toString()) != null){
    //   taskDraft = prefs.getString(targetData["id"].toString())!;
    // }
    if (targetData["memo"] != null) {
      taskDraft = targetData["memo"];
    }

    taskDraftController = TextEditingController(text: taskDraft);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    Map targetData = widget.targetData;
    StateSetter setosute = widget.setosute;

    DateTime dtEnd = DateTime.fromMillisecondsSinceEpoch(targetData["dtEnd"]);
    int id = targetData["id"];
    String? pageID = targetData["pageID"];
    Widget dividerModel = const Divider(height: 1);
    int height = (SizeConfig.blockSizeVertical! * 100).round();

    double bottomMargin = 10;
    if (isEditing) {
      bottomMargin = 50;
    }

    return Stack(children: [
      Stack(alignment: Alignment.bottomCenter, children: [
        Container(
            height: SizeConfig.blockSizeVertical! * 85,
            margin: const EdgeInsets.only(top: 0),
            decoration: BoxDecoration(
              color: BACKGROUND_COLOR,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: SingleChildScrollView(
                primary: false,
                child: Scrollbar(
                  child: Column(
                    children: [
                      SizedBox(
                        height: SizeConfig.blockSizeHorizontal! * 15,
                      ),
                      Padding(
                          padding: const EdgeInsets.only(left: 15, right: 15),
                          child: Column(children: [
                            textFieldModel(
                              "タスク名",
                              1,
                              TextField(
                                controller: summaryController,
                                maxLines: null,
                                textInputAction: TextInputAction.done,
                                decoration: const InputDecoration.collapsed(
                                  hintText: "タスク名を入力…",
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                style: TextStyle(
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal! * 4,
                                    fontWeight: FontWeight.bold),
                                onSubmitted: (value) {
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
                            textFieldModel(
                              "カテゴリ",
                              2,
                              TextField(
                                controller: titleController,
                                maxLines: 1,
                                decoration: const InputDecoration.collapsed(
                                  hintText: "カテゴリを入力...",
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                style: TextStyle(
                                    fontSize:
                                        SizeConfig.blockSizeHorizontal! * 4,
                                    fontWeight: FontWeight.bold),
                                onSubmitted: (value) {
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
                            ),
                            textFieldModel(
                                "締切日時",
                                2,
                                GestureDetector(
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
                                  child: Text(
                                      DateFormat("yyyy年MM月dd日  HH時mm分")
                                          .format(dtEnd),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                )),
                            textFieldModel(
                              "タスクの詳細",
                              2,
                              TextField(
                                maxLines: null,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (value) {
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
                                controller: descriptionController,
                                style: TextStyle(
                                  fontSize: SizeConfig.blockSizeHorizontal! * 4,
                                ),
                                decoration: const InputDecoration(
                                  hintText: "(タスクの詳細やメモを入力…)",
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                            textFieldModel(
                              "タスクの削除",
                              2,
                              buttonModelWithChild(() async {
                                TaskDatabaseHelper().unDisplay(id);
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
                              },
                                  Colors.red,
                                  Row(
                                    children: [
                                      const Spacer(),
                                      Icon(Icons.delete, color: WHITE),
                                      const SizedBox(width: 10),
                                      Text(
                                        "削除",
                                        style: TextStyle(
                                            color: WHITE,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const Spacer()
                                    ],
                                  )),
                            ),
                            textFieldModel(
                                "課題の下書き",
                                3,
                                Column(children: [
                                  TextField(
                                    maxLines: null,
                                    textInputAction: TextInputAction.done,
                                    onChanged: (value) async {
                                      await TaskDatabaseHelper().updateMemo(
                                          id, taskDraftController.text);

                                      setState(() {});
                                    },
                                    controller: taskDraftController,
                                    style: TextStyle(
                                      fontSize:
                                          SizeConfig.blockSizeHorizontal! * 4,
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: "(課題の下書きをここに作成…)",
                                      border: InputBorder.none,
                                      hintStyle: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
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
                                              backgroundColor: WHITE,
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
                                        ])),
                                  ])
                                ])),
                            SizedBox(height: SizeConfig.blockSizeVertical! * 2),
                            webView(pageID, height),
                            SizedBox(
                              height: SizeConfig.blockSizeVertical! * 2,
                            ),
                            SizedBox(
                              height:
                                  SizeConfig.blockSizeVertical! * bottomMargin,
                            ),
                          ])),
                    ],
                  ),
                ))),
        menuBar(),
      ]),
      Container(
          decoration: BoxDecoration(
            color: BACKGROUND_COLOR,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
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
                            maxWidth: SizeConfig.blockSizeHorizontal! * 73.5),
                        child: Text(
                          targetData["summary"] ?? "(詳細なし)",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: BLUEGREY,
                              fontSize: SizeConfig.blockSizeHorizontal! * 5,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        "  の詳細",
                        style: TextStyle(
                            color: BLUEGREY,
                            fontSize: SizeConfig.blockSizeHorizontal! * 5,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  )),
              SizedBox(
                width: SizeConfig.blockSizeHorizontal! * 4,
              ),
            ],
          )),
    ]);
  }

  bool isEditing = false;

  Widget webView(String? pageID, int height) {
    if (pageID != null) {
      return Column(children: [
        indexModel("■ Moodle ページビュー"),
        SizedBox(
          height: SizeConfig.blockSizeVertical! * 1,
        ),
        Container(
            width: SizeConfig.blockSizeHorizontal! * 100,
            height: SizeConfig.blockSizeVertical! * 75,
            decoration: BoxDecoration(border: Border.all()),
            child: SingleChildScrollView(
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
            )),
      ]);
    } else {
      return SizedBox(
        height: SizeConfig.blockSizeVertical! * 50,
      );
    }
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

  Widget textFieldModel(String title, int type, Widget child) {
    return Container(
      decoration: roundedBoxdecorationWithShadow(radiusType: type),
      margin: const EdgeInsets.symmetric(vertical: 1),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [indexModel(title), child],
      ),
    );
  }

  Widget indexModel(String text) {
    return Column(children: [
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(
              fontSize: SizeConfig.blockSizeHorizontal! * 4,
              fontWeight: FontWeight.normal,
              color: Colors.grey),
        ),
      ),
    ]);
  }

  Widget menuBar() {
    return Container(
        decoration: BoxDecoration(
            color: WHITE,
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
