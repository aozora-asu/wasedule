import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/handler/my_course_db.dart';
import 'package:flutter_calandar_app/backend/DB/handler/my_grade_db.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/assist_files/ui_components.dart';
import 'package:flutter_calandar_app/frontend/screens/common/tutorials.dart';
import 'package:flutter_calandar_app/frontend/screens/timetable_page/credit/requiredcredits_stats.dart';
import 'package:flutter_calandar_app/frontend/screens/to_do_page/todo_assist_files/size_config.dart';

class CreditStatsPage extends StatefulWidget {
  Function() moveToMyWaseda;

  CreditStatsPage({required this.moveToMyWaseda});
  @override
  _CreditStatsPageState createState() => _CreditStatsPageState();
}

class _CreditStatsPageState extends State<CreditStatsPage> {
  List<MajorClass> majorClassificationGroupList = [];
  late List<String> yearList;
  late String selectedYear;
  late List<String> termList;
  late String selectedTerm;
  late bool isGPview;

  @override
  void initState() {
    super.initState();
    isGPview = false;
    yearList = [];
    selectedYear = "すべて";
    termList = [];
    selectedTerm = "すべて";
  }

  void generateOptions(List<MajorClass> data) {
    yearList = [];
    termList = [];

    for (var majorClass in data) {
      for (var middleClass in majorClass.middleClass) {
        for (var myCourse in middleClass.myGrade) {
          if (!yearList.contains(myCourse.year)) {
            yearList.add(myCourse.year);
          }
          if (!termList.contains(myCourse.term)) {
            termList.add(myCourse.term);
          }
        }
        for (var minorClass in middleClass.minorClass) {
          for (var myCourse in minorClass.myGrade) {
            if (!yearList.contains(myCourse.year)) {
              yearList.add(myCourse.year);
            }
            if (!termList.contains(myCourse.term)) {
              termList.add(myCourse.term);
            }
          }
        }
      }
    }
  }

  double calculateGradeAverage(List<MyGrade> data) {
    double result = 0;
    for (int i = 0; i < data.length; i++) {
      if (data.elementAt(i).gradePoint != null) {
        result += int.tryParse(data.elementAt(i).gradePoint!) ?? 0;
      }
    }

    double roundedNumber = data.isNotEmpty
        ? double.parse(((result / data.length) * 100).round().toString()) / 100
        : 0;
    return roundedNumber;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: BACKGROUND_COLOR,
        body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(children: [
              pageHeader(),
              const Divider(height: 1),
              Row(children: [
                changeGPviewButton(),
                const SizedBox(width: 5),
                yearPicker(),
                const SizedBox(width: 5),
                termPicker(),
              ]),
              Expanded(
                  child: ListView(children: [
                individualDataListBuilder(),
              ]))
            ])));
  }

  Widget changeGPviewButton() {
    return GestureDetector(
        onTap: () {
          setState(() {
            if (isGPview) {
              isGPview = false;
            } else {
              isGPview = true;
            }
          });
        },
        child: Container(
          decoration: roundedBoxdecoration(),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 1),
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            isGPview ? "表示：GP" : "表示：成績",
            style: const TextStyle(
                color: Colors.blue,
                fontSize: 15,
                fontWeight: FontWeight.normal),
          ),
        )
      );
  }

  Widget termPicker() {
    List<String> terms = ["すべて"];
    terms.addAll(termList);

    List<DropdownMenuItem<String>> items = [];
    for (int i = 0; i < terms.length; i++) {
      String menuText = "なし";
      menuText = terms.elementAt(i);

      items.add(DropdownMenuItem(
          value: terms.elementAt(i),
          child: Center(
              child: Text(
            menuText,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
          ))));
    }

    return Expanded(
        child: cupertinoLikeDropDownListModel(items, selectedTerm, (value) {
      setState(() {
        selectedTerm = value;
      });
    }, verticalPadding: 0));
  }

  Widget yearPicker() {
    List<String> years = ["すべて"];
    years.addAll(yearList);

    List<DropdownMenuItem<String>> items = [];
    for (int i = 0; i < years.length; i++) {
      String menuText = "なし";
      menuText = years.elementAt(i);

      items.add(DropdownMenuItem(
          value: years.elementAt(i),
          child: Center(
              child: Text(
            menuText,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
          ))));
    }

    return Expanded(
        child: cupertinoLikeDropDownListModel(items, selectedYear, (value) {
      setState(() {
        selectedYear = value;
      });
    }, verticalPadding: 0));
  }

  Widget pageHeader() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: Row(children: [
          const Icon(Icons.abc, color: BLUEGREY, size: 30),
          const SizedBox(
            width: 5,
          ),
          const Text(
            "単位情報",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          buttonModel(() async {
            await showMoodleRegisterGuide(
                context, false, MoodleRegisterGuideType.credit);
            widget.moveToMyWaseda();
          }, PALE_MAIN_COLOR, "データ取得",
              verticalpadding: 10, horizontalPadding: 30),
        ]));
  }

  Widget individualDataListBuilder() {
    return FutureBuilder(
        future: MyGradeDB.getMyCredit(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.majorClass != []) {
            majorClassificationGroupList = snapshot.data!.majorClass;
            generateOptions(snapshot.data!.majorClass);
            return dataListByMajorClassification(snapshot.data!);
          } else {
            return noGradeDataScreen();
          }
        });
  }

  Widget noGradeDataScreen() {
    return const SizedBox(
        height: 500,
        child: Center(
            child: Text("成績のデータがありません。",
                style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.normal,
                    overflow: TextOverflow.clip,
                    fontSize: 20))));
  }

  Widget dataListByMajorClassification(MyCredit data) {
    SizeConfig().init(context);
    int requiredCredit = data.requiredCredit;
    int countedCredit = data.countedCredit;

    if(requiredCredit == 0 && countedCredit == 0){
      requiredCredit == 1;
    }else if(requiredCredit == 0){
      requiredCredit == countedCredit;
    }

    double circularIndicatorValue = countedCredit / requiredCredit;
    if(circularIndicatorValue > 1){
     circularIndicatorValue = 1;
    }

    String circularIndicatorValueString = "${(circularIndicatorValue * 100).round().toString()}％";

    return Column(children: [
      const SizedBox(height: 15),
      Container(
        decoration: roundedBoxdecoration(radiusType: 0),
        padding:const EdgeInsets.symmetric(vertical: 7),
        child: Column(children:[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children:[
            Stack(
              alignment:const Alignment(0,0),
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                  width: 75,height:75,
                  child:CircularProgressIndicator(
                    strokeCap: StrokeCap.round,
                    backgroundColor: lighten(Colors.grey,0.25),
                    value: circularIndicatorValue,
                    strokeWidth: 10.0,
                )),
                Text(circularIndicatorValueString,
                  style: const TextStyle(fontSize: 22.5, fontWeight: FontWeight.bold))
            ]),
            Text(data.text,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
        ]),
          necessaryCreditsIndicator(
              data.requiredCredit, data.acquiredCredit, data.countedCredit),
         const Divider(),
         RequiredCreditsStats(),
      ])),
      ListView.builder(
        itemBuilder: (context, index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(" ${(index+1).toString()}. ${data.majorClass.elementAt(index).text}",
                  style:
                      const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              const Divider(thickness:2,height:2,color:BLUEGREY),
              Row(children:[
                necessaryCreditsIndicator(
                    data.majorClass[index].requiredCredit,
                    data.majorClass[index].acquiredCredit,
                    data.majorClass[index].countedCredit,
                )
              ]),
              const SizedBox(height: 15),
              dataListByMiddleClassification(data.majorClass[index].middleClass,index),
            ]);
        },
        itemCount: data.majorClass.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
      )
    ]);
  }

  Widget dataListByMiddleClassification(List<MiddleClass> data,int parentIndex) {
    TextStyle smallGreyFont = const TextStyle(
        fontSize: 10, fontWeight: FontWeight.normal, color: Colors.grey);

    return ListView.builder(
      itemBuilder: (context, index) {
        double gradeAverage = calculateGradeAverage(data[index].myGrade);

        return Column(children: [
          Row(crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                " ${(parentIndex + 1).toString()}-${(index + 1).toString()}  ${data[index].text != "" ? data[index].text : "(中分類なし)"}",
                overflow: TextOverflow.clip,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey)),
          ]),
          Divider(height: 1, color: FORGROUND_COLOR),
          Row(crossAxisAlignment: CrossAxisAlignment.end,
            children:[
              necessaryCreditsIndicator(data[index].requiredCredit,
                  data[index].acquiredCredit, data[index].countedCredit),
              const Spacer(),
              Text("GP平均：$gradeAverage", style: smallGreyFont),
          ]),
          const SizedBox(height: 3),
          // Row(mainAxisSize: MainAxisSize.max,
          //   mainAxisAlignment: MainAxisAlignment.start,
          //   crossAxisAlignment: CrossAxisAlignment.end,
          //   children:[
          //       if(data[index].minorClass.isEmpty && data[index].myGrade.isNotEmpty) 
          //         Text("単位", style: smallGreyFont)
          //       else
          //         Text("　　", style: smallGreyFont),
          // ]),
          gradeDataList(data[index].myGrade),
          dataListByMinorClassification(data[index].minorClass),
          const SizedBox(height: 10),
        ]);
      },
      itemCount: data.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
    );
  }

  Widget dataListByMinorClassification(
      List<MinorClass> minorClassificationGroupList) {
    return ListView.builder(
      itemBuilder: (context, index) {
        return Column(children: [
          if (minorClassificationGroupList.elementAt(index).text != "")
            const SizedBox(height: 10),
          Row(children: [
            if (minorClassificationGroupList.elementAt(index).text != "")
              Text(minorClassificationGroupList.elementAt(index).text,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey)),
          ]),
          gradeDataList(minorClassificationGroupList.elementAt(index).myGrade),
        ]);
      },
      itemCount: minorClassificationGroupList.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
    );
  }

  Widget necessaryCreditsIndicator(
      int? requiredCredit, int acquiredCredit, int countedCredit) {
    TextStyle categoryStyle = const TextStyle(fontSize: 14, color: Colors.grey);
    TextStyle numberStyle = const TextStyle(
        fontSize: 18, fontWeight: FontWeight.bold, color: BLUEGREY);
    String requiredCreditString =
        requiredCredit != null ? requiredCredit.toString() : "？";

    return Container(
      decoration: roundedBoxdecoration(
          backgroundColor: Colors.transparent, radiusType: 2),
      margin: const EdgeInsets.symmetric(vertical: 0),
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("算入 ", style: categoryStyle),
            Text(countedCredit.toString(), style: numberStyle),
            Text(" 単位 / 所定 ", style: categoryStyle),
            Text(requiredCreditString, style: numberStyle),
            Text(" 単位  (既得 ", style: categoryStyle),
            Text(acquiredCredit.toString(), style: categoryStyle),
            Text(" 単位)", style: categoryStyle),
          ]),
    );
  }

  Widget gradeDataList(List<MyGrade> minorClassificationGroupList) {
    List<MyGrade> data =
        minorClassificationGroupList; //.expand((e) => e.myGrade).toList();

    return ListView.builder(
      itemBuilder: (context, index) {
        MyGrade target = data.elementAt(index);
        bool showList = true;

        if (selectedYear != "すべて" && target.year != selectedYear) {
          showList = false;
        }

        if (selectedTerm != "すべて" && target.term != selectedTerm) {
          if (selectedTerm == "春期" && target.term == "春ク" ||
              selectedTerm == "春期" && target.term == "夏ク") {
          } else if (selectedTerm == "秋期" && target.term == "秋ク" ||
              selectedTerm == "秋期" && target.term == "冬ク") {
          } else {
            showList = false;
          }
        }

        return showList ? gradeDataListChild(target) : const SizedBox();
      },
      itemCount: data.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
    );
  }

  Widget gradeDataListChild(MyGrade data) {
    return Row(children: [
      SizedBox(
        width: 20,
        child: Text(data.credit.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: data.gradePoint == "0" || data.gradePoint == "＊"
                    ? Colors.grey
                    : BLUEGREY)),
      ),
      Expanded(
          child: Container(
              decoration: roundedBoxdecoration(radiusType: 2),
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              margin: const EdgeInsets.symmetric(
                vertical: 1,
              ),
              child: Column(children: [
                Row(children: [
                  gradeIcon(data),
                  const SizedBox(width: 5),
                  Expanded(
                      child: Text(data.courseName,
                          style: TextStyle(
                              color: data.gradePoint == "0"
                                  ? Colors.grey
                                  : Colors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.bold))),
                  Text("${data.year}/${data.term}",
                      style: const TextStyle(fontSize: 10, color: Colors.grey))
                ])
              ])))
    ]);
  }

  Widget gradeIcon(MyGrade myGrade) {
    String grade = myGrade.grade;
    String gradePoint = myGrade.gradePoint ?? "?";
    Color iconColor;

    switch (grade) {
      case "A+":
        {
          iconColor = Colors.red;
        }
      case "A":
        {
          iconColor = Colors.deepOrangeAccent;
        }
      case "B":
        {
          iconColor = Colors.blue;
        }
      case "C":
        {
          iconColor = Colors.green;
        }
      case "F":
        {
          iconColor = Colors.black;
        }
      case "G":
        {
          iconColor = Colors.black;
        }
      case "P":
        {
          iconColor = Colors.pink;
        }
      case "*":
        {
          iconColor = Colors.grey;
        }
      default:
        {
          iconColor = Colors.grey;
        }
    }

    return Container(
      margin: const EdgeInsets.all(2),
      padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 4),
      decoration: BoxDecoration(
          color: iconColor, borderRadius: BorderRadius.circular(3)),
      constraints: const BoxConstraints(minWidth: 25),
      child: Text(
        isGPview ? gradePoint : grade,
        textAlign: TextAlign.center,
        style: const TextStyle(
            fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}

