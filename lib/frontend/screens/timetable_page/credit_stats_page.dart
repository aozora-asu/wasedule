import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/handler/my_grade_db.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';

class CreditStatsPage extends StatefulWidget{
  @override
  _CreditStatsPageState createState() => _CreditStatsPageState();
}

class _CreditStatsPageState extends State<CreditStatsPage>{
  @override
  Widget build(BuildContext context){
    
    // MyGrade(
    //   courseName: courseName,
    //   credit: credit,
    //    grade: grade,
    //    term: term,
    //    majorClassification: majorClassification,
    //    middleClassification: middleClassification,
    //    minorClassification: minorClassification,
    //    year: year,
    //    gradePoint: gradePoint);

    return Scaffold(
      backgroundColor: BACKGROUND_COLOR,
      body: const SizedBox()
    );
  }
}