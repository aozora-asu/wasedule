import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/frontend/assist_files/ui_components.dart';
import 'package:flutter_calandar_app/frontend/screens/moodle_view_page/syllabus_query_request.dart';
import 'package:flutter_calandar_app/frontend/screens/moodle_view_page/syllabus_query_result.dart';
import 'package:flutter_calandar_app/static/constant.dart';
import 'package:path/path.dart';

class SyllabusSearchDialog extends StatefulWidget {
  @override
  _SyllabusSearchDialogState createState() => _SyllabusSearchDialogState();
}

class _SyllabusSearchDialogState extends State<SyllabusSearchDialog> {
  @override
  Widget build(BuildContext context) {
    return searchWindow();
  }

  SyllabusRequestQuery requestQuery = SyllabusRequestQuery(
      keyword: null,
      kamoku: null,
      p_gakki: null,
      p_youbi: null,
      p_jigen: null,
      p_gengo: null,
      p_gakubu: null,
      p_open: false,
      subjectClassification: null);

  Widget searchWindow() {
    TextStyle searchConditionTextStyle =
        const TextStyle(fontSize: 18, color: Colors.grey);

    return Container(
      decoration: roundedBoxdecorationWithShadow(),
      width: SizeConfig.blockSizeHorizontal! * 100,
      padding: const EdgeInsets.all(12.5),
      child: Column(children: [
        const Text("シラバス検索",
            style: TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold)),
        Row(children: [
          SizedBox(
              width: 80,
              child: Text(
                "学部",
                style: searchConditionTextStyle,
                textAlign: TextAlign.center,
              )),
          departmentPicker()
        ])
      ]),
    );
  }

  Widget departmentPicker() {
    List<String> items = [
      "基幹理工学部",
      Department.education.text,
      Department.internationalEducation.text,
      Department.socialScience.text,
      Department.commerce.text,
      Department.sportsScience.text,
      Department.politicalEconomy.text,
      "先進理工学部",
      "創造理工学部",
      Department.humanScience.text,
      Department.cultureAndMediaStudy.text,
      Department.literature.text,
      Department.law.text,
      Department.global.text,
    ];

    return Expanded(
        child: CupertinoPicker(
      itemExtent: 32.0,
      onSelectedItemChanged: (int index) {
        //selectedDepartment = Department.byValue(items.elementAt(index));
      },
      children: List<Widget>.generate(items.length, (int index) {
        return Center(
          child: Text(items[index]),
        );
      }),
    ));
  }
}
