import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/frontend/assist_files/ui_components.dart';
import 'package:flutter_calandar_app/frontend/screens/common/plain_appbar.dart';
import 'package:flutter_calandar_app/frontend/screens/moodle_view_page/syllabus_query_request.dart';
import 'package:flutter_calandar_app/frontend/screens/moodle_view_page/syllabus_query_result.dart';
import 'package:flutter_calandar_app/frontend/screens/timetable_page/syllabus_description_view.dart';
import 'package:flutter_calandar_app/static/constant.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SyllabusSearchDialog extends ConsumerStatefulWidget {
  Term? gakki;
  DayOfWeek? youbi;
  Lesson? jigen;
  Department? gakubu;
  int radiusType;

  SyllabusSearchDialog({
    required this.radiusType,
    this.gakki,
    this.youbi,
    this.jigen,
    this.gakubu,
  });

  @override
  _SyllabusSearchDialogState createState() => _SyllabusSearchDialogState();
}

class _SyllabusSearchDialogState extends ConsumerState<SyllabusSearchDialog> {
  late SyllabusRequestQuery requestQuery;
  late bool isFullYear;
  late bool isGraduateSchool;

  @override
  void initState() {
    super.initState();
    requestQuery = SyllabusRequestQuery(
      keyword: null,
      kamoku: null,
      p_gakki: widget.gakki,
      p_youbi: widget.youbi,
      p_jigen: widget.jigen,
      p_gakubu: widget.gakubu,
      p_gengo: null,
      p_open: false,
      subjectClassification: null,
    );
    isFullYear = false;
    isGraduateSchool = false;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return GestureDetector(onTap: () {}, child: searchWindow());
  }

  Widget searchWindow() {
    String courseTimeText;
    String year = Term.whenSchoolYear(DateTime.now()).toString();
    int radiusType = widget.radiusType;

    if (widget.youbi != null && widget.jigen != null) {
      courseTimeText =
          "$year年 / ${widget.gakki?.text} / ${widget.youbi!.text}曜日 / ${widget.jigen!.period}限";
    } else {
      courseTimeText = "$year年 / ${widget.gakki?.text} / オンデマンド / 時限なし";
    }

    TextStyle searchConditionTextStyle = const TextStyle(
      fontSize: 15,
      color: Colors.grey,
    );

    return Container(
      decoration: roundedBoxdecorationWithShadow(radiusType: radiusType),
      width: SizeConfig.blockSizeHorizontal! * 100,
      padding: const EdgeInsets.symmetric(horizontal: 12.5, vertical: 5),
      child: Column(
        children: [
          Row(children: [
            const SizedBox(
                width: 60,
                child: Text(
                  "候補",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                )),
            const Spacer(),
            Text(
              courseTimeText,
              style: searchConditionTextStyle,
            ),
            const Spacer(),
          ]),
          const Divider(),
          Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  "学部",
                  style: searchConditionTextStyle,
                  textAlign: TextAlign.center,
                ),
              ),
            if(isGraduateSchool) 
              graduateSchoolPicker(requestQuery.p_gakubu)
            else
              departmentPicker(requestQuery.p_gakubu),
            ],
          ),
          const SizedBox(height: 5),
          subjectClassificationPicker(searchConditionTextStyle),
          const SizedBox(height: 5),
          Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  "キーワード",
                  style: searchConditionTextStyle,
                  textAlign: TextAlign.center,
                ),
              ),
              searchTextField(
                  TextEditingController(text: requestQuery.keyword ?? ""),
                  (value) {
                requestQuery.keyword = value;
              }),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              SizedBox(
                child: Text(
                  "オープン科目",
                  style: searchConditionTextStyle,
                  textAlign: TextAlign.center,
                ),
              ),
              CupertinoCheckbox(
                  value: requestQuery.p_open,
                  onChanged: (value) {
                    setState(() {
                      requestQuery.p_open = value!;
                    });
                  }),
              SizedBox(
                child: Text(
                  "通年",
                  style: searchConditionTextStyle,
                  textAlign: TextAlign.center,
                ),
              ),
              CupertinoCheckbox(
                  value: isFullYear,
                  onChanged: (value) {
                    isFullYear = value!;
                    if (value) {
                      setState(() {
                        requestQuery.p_gakki = Term.fullYear;
                      });
                    } else {
                      setState(() {
                        requestQuery.p_gakki = widget.gakki;
                      });
                    }
                  }),
            SizedBox(
              child: Text(
                "大学院/その他",
                style: searchConditionTextStyle,
                textAlign: TextAlign.center,
              ),
            ),
            CupertinoCheckbox(
              value: isGraduateSchool,
              onChanged: (value) {
                requestQuery.p_gakubu = null;
                setState(() {
                  isGraduateSchool = value!;
                });
              })
            ],
          ),
          const Divider(),
          Container(
              constraints:
                  BoxConstraints(maxHeight: SizeConfig.blockSizeVertical! * 50),
              child: searchResult())
        ],
      ),
    );
  }

  Widget searchTextField(
      TextEditingController controller, Function(String) onSubmitted) {
    return Expanded(
        child: CupertinoTextField(
      controller: controller,
      onChanged: (value) {},
      onSubmitted: (value) {
        setState(() {
          onSubmitted(value);
        });
      },
    ));
  }

  Widget departmentPicker(Department? gakubu) {
    List<Department?> departments = [];
    departments.add(gakubu);
    departments.addAll(Department.departments);
    departments.remove(gakubu);
    
    List<DropdownMenuItem<Department>> items = [];
    for(int i = 0; i < departments.length; i++){
      String menuText = "学部を選択";
      if(departments.elementAt(i) != null){
        menuText = departments.elementAt(i)!.text;
      }

      items.add(DropdownMenuItem(
        value: departments.elementAt(i),
        child: Center(
         child:Text(menuText,
          style: const TextStyle(
            fontSize:20,
            fontWeight: FontWeight.normal),))));
    }

    return Expanded(
      child: cupertinoLikeDropDownListModel(
        items,requestQuery.p_gakubu,
        (value) {
            setState(() {
              requestQuery.p_gakubu = value;
              requestQuery.subjectClassification = null;
            });
        },)
    );
  }

  Widget graduateSchoolPicker(Department? gakubu) {
    List<Department?> departments = [null];
    departments.add(gakubu);
    departments.addAll(Department.masters);
    departments.remove(gakubu);
    
    List<DropdownMenuItem<Department>> items = [];
    for(int i = 0; i < departments.length; i++){
      String menuText = "研究科/学校を選択";
      if(departments.elementAt(i) != null){
        menuText = departments.elementAt(i)!.text;
      }

      items.add(DropdownMenuItem(
        value: departments.elementAt(i),
        child: Center(
         child:Text(menuText,
          style: const TextStyle(
            fontSize:20,
            fontWeight: FontWeight.normal),))));
    }

    return Expanded(
      child: cupertinoLikeDropDownListModel(
        items,requestQuery.p_gakubu,
        (value) {
            setState(() {
              requestQuery.p_gakubu = value;
              requestQuery.subjectClassification = null;
            });
        },)
    );
  }

  Widget subjectClassificationPicker(TextStyle searchConditionTextStyle) {
    Widget value;
    Department? gakubu = requestQuery.p_gakubu;

    if (gakubu == null || gakubu.subjectClassifications == null) {
      value = const SizedBox();
    } else {
      List<SubjectClassification?> subjectClassifications = [];
      subjectClassifications.add(null);
      subjectClassifications.addAll(gakubu.subjectClassifications!);
    
    List<DropdownMenuItem<SubjectClassification>> items = [];
    for(int i = 0; i < subjectClassifications.length; i++){
      String menuText = "科目区分を選択";
      if(subjectClassifications.elementAt(i) != null){
        menuText = subjectClassifications.elementAt(i)!.text;
      }

      items.add(DropdownMenuItem(
        value: subjectClassifications.elementAt(i),
        child: Center(
         child:Text(menuText,
          style: const TextStyle(
            fontSize:20,
            fontWeight: FontWeight.normal),))));
    }
      value = Row(children: [
        SizedBox(
          width: 80,
          child: Text(
            "科目区分",
            style: searchConditionTextStyle,
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: cupertinoLikeDropDownListModel(
          items, requestQuery.subjectClassification,
           (value) {
              setState(() {
                requestQuery.subjectClassification = value;
              });
            },)
        )
      ]);
    }

    return value;
  }

  List<SyllabusQueryResult> resultList = [];
  Widget searchResult() {
    resultList = [];

    return StreamBuilder<SyllabusQueryResult>(
      stream: requestQuery.fetchAllSyllabusInfo(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 70,
            child: Center(
                child: CircularProgressIndicator(color: PALE_MAIN_COLOR)),
          );
        } else if (snapshot.hasError) {
          // エラーメッセージを表示
          return Text(snapshot.error.toString());
        } else if (!snapshot.hasData) {
          // 検索結果がない場合のメッセージを表示
          return const SizedBox(
            height: 70,
            child: Center(
              child: Text("検索結果なし", style: TextStyle(color: Colors.grey)),
            ),
          );
        } else {
          resultList.add(snapshot.data!);
          // シラバス情報をリスト形式で表示
          return ListView.separated(
            itemBuilder: (context, index) {
              // 取得したデータのコース名を表示
              return resultListChild(
                  resultList.elementAt(index)); // シラバス情報のコース名を表示
            },
            separatorBuilder: (context, index) {
              return const SizedBox(height: 2);
            },
            itemCount: resultList.length,
            shrinkWrap: true,
          );
        }
      },
    );
  }

  Widget resultListChild(SyllabusQueryResult result) {
    int boxRadiusType = 2;
    String credits = result.credit ?? "0";
    Color creditsIndiatorColor;

    switch (credits) {
      case "1":
        creditsIndiatorColor = Colors.lightBlue;
      case "2":
        creditsIndiatorColor = Colors.orange;
      case "3":
        creditsIndiatorColor = Colors.deepOrange;
      case "4":
        creditsIndiatorColor = Colors.red;
      case "8":
        creditsIndiatorColor = Colors.deepPurple;
      default:
        creditsIndiatorColor = Colors.yellow;
    }

    return GestureDetector(
        onTap: () async {
          await showCourseDescriptionModalSheet(result);
        },
        child: Container(
          decoration: roundedBoxdecorationWithShadow(
              radiusType: boxRadiusType, backgroundColor: BACKGROUND_COLOR),
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
          child: Row(children: [
            const Text("単\n位",
                style: TextStyle(color: Colors.grey, fontSize: 10)),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: creditsIndiatorColor,
              ),
              height: 25,
              width: 25,
              child: Center(
                  child: Text(credits,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white))),
            ),
            Expanded(
                child: Text(result.courseName,
                    overflow: TextOverflow.clip,
                    style: const TextStyle(fontWeight: FontWeight.bold))),
            Container(
                constraints: const BoxConstraints(maxWidth: 50),
                child: Text(result.classRoom,
                    style: const TextStyle(
                        overflow: TextOverflow.clip, color: Colors.grey))),
            const Icon(Icons.search, color: Colors.grey),
            GestureDetector(
                onTap: () async {
                  await showConfirmationDialog(context, result);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10), color: BLUEGREY),
                  height: 25,
                  child: const Center(
                      child: Text("  + 追加  ",
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white))),
                )),
          ]),
        ));
  }

  Future<void> showCourseDescriptionModalSheet(
      SyllabusQueryResult result) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Scaffold(
          backgroundColor: FORGROUND_COLOR,
          appBar: CustomAppBar(backButton: true),
          body:
              SyllabusDescriptonView(showHeader: true, syllabusQuery: result));
    }));
  }
}

Future<void> showConfirmationDialog(
    BuildContext context, SyllabusQueryResult courseData) async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: const Text("確認"),
        content: Text('" ' + courseData.courseName + ' "を時間割へ追加してもよろしいですか？'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              "キャンセル",
              style: TextStyle(color: Colors.red),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              showDisclaimerDialog(context);
            },
            child: const Text("追加"),
          ),
        ],
      );
    },
  );
}

Future<void> showDisclaimerDialog(BuildContext context) async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: const Text("追加しました！"),
        content: const Text(
            "※履修登録が完了したわけではありません。履修登録は、期間中に大学の「成績照会・科目登録専用」サイトから行ってください。",
            style: TextStyle(color: Colors.red)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("OK"),
          ),
        ],
      );
    },
  );
}
