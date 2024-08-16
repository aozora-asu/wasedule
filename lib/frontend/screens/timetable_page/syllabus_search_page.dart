import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/sharepreference.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/assist_files/ui_components.dart';
import 'package:flutter_calandar_app/frontend/screens/common/plain_appbar.dart';
import 'package:flutter_calandar_app/backend/service/syllabus_query_request.dart';
import 'package:flutter_calandar_app/backend/service/syllabus_query_result.dart';
import 'package:flutter_calandar_app/frontend/screens/timetable_page/syllabus_description_view.dart';
import 'package:flutter_calandar_app/frontend/screens/timetable_page/syllabus_search_dialog.dart';
import 'package:flutter_calandar_app/frontend/screens/to_do_page/todo_assist_files/size_config.dart';
import 'package:flutter_calandar_app/static/constant.dart';
import 'package:rxdart/rxdart.dart';

class SyllabusSearchPage extends StatefulWidget {
  @override
  _SyllabusSearchPageState createState() => _SyllabusSearchPageState();
}

class _SyllabusSearchPageState extends State<SyllabusSearchPage> {
  late SyllabusRequestQuery requestQuery;
  late bool isFullYear;
  late bool isGraduateSchool;
  TextEditingController keyWordController = TextEditingController();
  TextEditingController courseNameController = TextEditingController();
  TextEditingController teacherNameController = TextEditingController();
  Term? currentTerm = Term.whenSemester(DateTime.now());

  @override
  void initState() {
    super.initState();
    keyWordController.text = "";
    courseNameController.text = "";
    teacherNameController.text = "";

    if (currentTerm == null) {
      if (DateTime.now().month <= 6) {
        currentTerm = Term.springSemester;
      } else {
        currentTerm = Term.fallSemester;
      }
    }

    requestQuery = SyllabusRequestQuery(
      keyword: null,
      kamoku: null,
      p_gakki: currentTerm,
      p_youbi: null,
      p_jigen: null,
      p_gakubu: Department.byValue(SharepreferenceHandler()
          .getValue(SharepreferenceKeys.userDepartment)),
      p_gengo: null,
      p_open: false,
      subjectClassification: null,
    );

    isFullYear = false;
    isGraduateSchool = false;
    updateQuery(requestQuery);
  }

  void updateQuery(SyllabusRequestQuery newQuery) {
    setState(() {
      requestQuery = newQuery;
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(backgroundColor: BACKGROUND_COLOR, body: searchWindow());
  }

  TextStyle searchConditionTextStyle = const TextStyle(
    fontSize: 12,
    color: Colors.grey,
  );

  Widget searchWindow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.5, vertical: 5),
      child: Column(
        children: [
          ExpandablePanel(
              controller: ExpandableController(initialExpanded: true),
              header: searchHeader(),
              collapsed: const SizedBox(),
              expanded: searchConditionPanel()),
          const Divider(height: 1),
          Expanded(child: searchResult())
        ],
      ),
    );
  }

  Widget searchHeader() {
    return const Row(children: [
      Icon(Icons.search, color: BLUEGREY, size: 30),
      SizedBox(
        width: 5,
      ),
      Text(
        "シラバス検索",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 25,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      Spacer(),
    ]);
  }

  Widget searchConditionPanel() {
    return Column(children: [
      const Divider(),
      Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              "学期\n曜日/時限",
              style: searchConditionTextStyle,
              textAlign: TextAlign.center,
            ),
          ),
          termPicker(),
          const SizedBox(width: 2),
          weekDayPicker(),
          const SizedBox(width: 2),
          periodPicker(),
        ],
      ),
      const SizedBox(height: 5),
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
          if (isGraduateSchool)
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
          searchTextField(keyWordController, (value) {
            requestQuery.keyword = value;
          }),
        ],
      ),
      const SizedBox(height: 5),
      Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              "科目名",
              style: searchConditionTextStyle,
              textAlign: TextAlign.center,
            ),
          ),
          searchTextField(courseNameController, (value) {
            requestQuery.kamoku = value;
          }),
        ],
      ),
      const SizedBox(height: 5),
      Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              "教員名",
              style: searchConditionTextStyle,
              textAlign: TextAlign.center,
            ),
          ),
          searchTextField(teacherNameController, (value) {
            requestQuery.kyoin = value;
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
                requestQuery.p_open = value!;
                updateQuery(requestQuery);
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

                isGraduateSchool = value!;
                updateQuery(requestQuery);
              })
        ],
      ),
    ]);
  }

  Widget searchTextField(
      TextEditingController controller, Function(String) onSubmitted) {
    return Expanded(
        child: CupertinoTextField(
      controller: controller,
      onChanged: (value) {},
      onSubmitted: (value) {
        onSubmitted(value);
        updateQuery(requestQuery);
      },
    ));
  }

  Widget termPicker() {
    List<Term?> terms = [
      null,
      Term.springSemester,
      Term.fallSemester,
      Term.fullYear,
      Term.others
    ];

    List<DropdownMenuItem<Term>> items = [];
    for (int i = 0; i < terms.length; i++) {
      String menuText = "なし";
      if (terms.elementAt(i) != null) {
        menuText = terms.elementAt(i)!.text;
      }

      items.add(DropdownMenuItem(
          value: terms.elementAt(i),
          child: Center(
              child: Text(
            menuText,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
          ))));
    }

    return Expanded(
        child: cupertinoLikeDropDownListModel(items, requestQuery.p_gakki,
            (value) {
      requestQuery.p_gakki = value;
      updateQuery(requestQuery);
    }));
  }

  Widget weekDayPicker() {
    List<DayOfWeek?> weekDays = [
      null,
      DayOfWeek.monday,
      DayOfWeek.tuesday,
      DayOfWeek.wednesday,
      DayOfWeek.thursday,
      DayOfWeek.friday,
      DayOfWeek.saturday,
      DayOfWeek.sunday,
      DayOfWeek.anotherday
    ];

    List<DropdownMenuItem<DayOfWeek>> items = [];
    for (int i = 0; i < weekDays.length; i++) {
      String menuText = "なし";
      if (weekDays.elementAt(i) != null) {
        menuText = weekDays.elementAt(i)!.text;
      }

      items.add(DropdownMenuItem(
          value: weekDays.elementAt(i),
          child: Center(
              child: Text(
            menuText,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
          ))));
    }

    return Expanded(
        child: cupertinoLikeDropDownListModel(
      items,
      requestQuery.p_youbi,
      (value) {
        requestQuery.p_youbi = value;
        updateQuery(requestQuery);
      },
    ));
  }

  Widget periodPicker() {
    List<Lesson?> period = [
      null,
      Lesson.ondemand,
      Lesson.first,
      Lesson.second,
      Lesson.third,
      Lesson.fourth,
      Lesson.fifth,
      Lesson.sixth,
      Lesson.seventh,
      Lesson.zeroth,
      Lesson.others
    ];

    List<DropdownMenuItem<Lesson>> items = [];
    for (int i = 0; i < period.length; i++) {
      String menuText = "なし";
      if (period.elementAt(i) != null) {
        menuText = period.elementAt(i)!.text;
      }

      items.add(DropdownMenuItem(
          value: period.elementAt(i),
          child: Center(
              child: Text(
            menuText,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
          ))));
    }

    return Expanded(
        child: cupertinoLikeDropDownListModel(
      items,
      requestQuery.p_jigen,
      (value) {
        requestQuery.p_jigen = value;
        updateQuery(requestQuery);
      },
    ));
  }

  Widget departmentPicker(Department? gakubu) {
    List<Department?> departments = [null];
    departments.add(gakubu);
    departments.addAll(Department.departments);
    departments.remove(gakubu);

    List<DropdownMenuItem<Department>> items = [];
    for (int i = 0; i < departments.length; i++) {
      String menuText = "学部を選択";
      if (departments.elementAt(i) != null) {
        menuText = departments.elementAt(i)!.text;
      }

      items.add(DropdownMenuItem(
          value: departments.elementAt(i),
          child: Center(
              child: Text(
            menuText,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
          ))));
    }

    return Expanded(
        child: cupertinoLikeDropDownListModel(
      items,
      requestQuery.p_gakubu,
      (value) {
        requestQuery.p_gakubu = value;
        requestQuery.subjectClassification = null;
        updateQuery(requestQuery);
      },
    ));
  }

  Widget graduateSchoolPicker(Department? gakubu) {
    List<Department?> departments = [null];
    departments.add(gakubu);
    departments.addAll(Department.masters);
    departments.remove(gakubu);

    List<DropdownMenuItem<Department>> items = [];
    for (int i = 0; i < departments.length; i++) {
      String menuText = "研究科/学校を選択";
      if (departments.elementAt(i) != null) {
        menuText = departments.elementAt(i)!.text;
      }

      items.add(DropdownMenuItem(
          value: departments.elementAt(i),
          child: Center(
              child: Text(
            menuText,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
          ))));
    }

    return Expanded(
        child: cupertinoLikeDropDownListModel(
      items,
      requestQuery.p_gakubu,
      (value) {
        requestQuery.p_gakubu = value;
        requestQuery.subjectClassification = null;
        updateQuery(requestQuery);
      },
    ));
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
      for (int i = 0; i < subjectClassifications.length; i++) {
        String menuText = "科目区分を選択";
        if (subjectClassifications.elementAt(i) != null) {
          menuText = subjectClassifications.elementAt(i)!.text;
        }

        items.add(DropdownMenuItem(
            value: subjectClassifications.elementAt(i),
            child: Center(
                child: Text(
              menuText,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
            ))));
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
          items,
          requestQuery.subjectClassification,
          (value) {
            requestQuery.subjectClassification = value;
            updateQuery(requestQuery);
          },
        ))
      ]);
    }

    return value;
  }

  Widget searchResult() {
    List<SyllabusQueryResult> resultList = [];
    return StreamBuilder<List<SyllabusQueryResult>>(
      stream: requestQuery.fetchAllSyllabusInfo().scan(
          (accumulated, current, index) {
        if (index == 0) {
          resultList = [];
        }
        resultList.add(current);
        return resultList;
      }, <SyllabusQueryResult>[]).asBroadcastStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            snapshot.data == null) {
          return const SizedBox(
            height: 70,
            child: Center(
              child: CircularProgressIndicator(color: PALE_MAIN_COLOR),
            ),
          );
        } else if (snapshot.hasError) {
          return Text('エラーが発生しました: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox(
            height: 70,
            child: Center(
              child: Text("検索結果なし", style: TextStyle(color: Colors.grey)),
            ),
          );
        } else {
          final results = snapshot.data!;
          return ListView.separated(
            itemBuilder: (context, index) {
              return resultListChild(results[index]);
            },
            separatorBuilder: (context, index) {
              return const SizedBox(height: 2);
            },
            itemCount: results.length,
            shrinkWrap: true,
          );
        }
      },
    );
  }

  Widget resultListChild(SyllabusQueryResult result) {
    int boxRadiusType = 2;
    int credits = result.credit ?? 0;
    Color creditsIndiatorColor;

    switch (credits) {
      case 1:
        creditsIndiatorColor = Colors.lightBlue;
      case 2:
        creditsIndiatorColor = Colors.orange;
      case 3:
        creditsIndiatorColor = Colors.deepOrange;
      case 4:
        creditsIndiatorColor = Colors.red;
      case 8:
        creditsIndiatorColor = Colors.deepPurple;
      default:
        creditsIndiatorColor = Colors.yellow;
    }

    return GestureDetector(
        onTap: () async {
          await showCourseDescriptionModalSheet(result);
        },
        child: Container(
            decoration: roundedBoxdecoration(
                radiusType: boxRadiusType, backgroundColor: FORGROUND_COLOR),
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const SizedBox(width: 15),
                Text(result.semesterAndWeekdayAndPeriod,
                    style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.bold))
              ]),
              Row(children: [
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
                      child: Text(credits.toString(),
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
                      await showAddCourseConfirmationDialog(context, result);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: BLUEGREY),
                      height: 25,
                      child: const Center(
                          child: Text("  + 追加  ",
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white))),
                    )),
              ]),
            ])));
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
