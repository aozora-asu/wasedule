

import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/handler/my_course_db.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/frontend/screens/common/ui_components.dart';
import 'package:flutter_calandar_app/static/constant.dart';

class CoursecolorSettingSheet {
  final targetColor = Colors.red;

  Future<void> showBottomSheet(BuildContext context) async{
    await showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      backgroundColor: FORGROUND_COLOR,
      builder: (BuildContext context) {
        return _bottomSheet(context);
      }
    );
  }

  Widget _bottomSheet(context){
    final bottomSpace = MediaQuery.of(context).viewInsets.bottom;
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 0);
    SizeConfig().init(context);

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
      return SingleChildScrollView(
          reverse: true,
          child: Padding(
              padding: EdgeInsets.only(bottom: bottomSpace),
              child: ConstrainedBox(
                  constraints: BoxConstraints(
                      minHeight: SizeConfig.blockSizeVertical! *30,
                      maxHeight:  SizeConfig.blockSizeVertical! *80),
                      child:SingleChildScrollView(
                          child: Padding(
                              padding: padding,
                              child: Container(
                                decoration: roundedBoxdecoration(
                                  backgroundColor: FORGROUND_COLOR,
                                ),
                                child:Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ModalSheetHeader(),

                                  ])
                                )
                              )
                            )
                          )
                        )
                    );
      }
    );
  }

}

class CourseClassification{

  static CourseClassification ondemand = CourseClassification._internal(
    value: "ondemand",
    text: "オンデマンド授業",
    type: ClassificationType.classStyle,
    searchCondition: (course){return course.weekday == null;}
  );

  static CourseClassification faceToFace = CourseClassification._internal(
    value: "faceToFace",
    text: "対面授業",
    type: ClassificationType.classStyle,
    searchCondition: (course){return course.weekday != null;}
  );

  static CourseClassification spring_semester = CourseClassification._internal(
    value: Term.springSemester.value,
    text: Term.springSemester.text,
    type: ClassificationType.term,
    searchCondition: (course){return course.semester == Term.springSemester;}
  );

  static CourseClassification spring_quarter = CourseClassification._internal(
    value: Term.springQuarter.value,
    text: Term.springQuarter.text,
    type: ClassificationType.term,
    searchCondition: (course){return course.semester == Term.springQuarter;}
  );

  static CourseClassification summer_quarter = CourseClassification._internal(
    value: Term.summerQuarter.value,
    text: Term.summerQuarter.text,
    type: ClassificationType.term,
    searchCondition: (course){return course.semester == Term.summerQuarter;}
  );

  static CourseClassification fall_semester = CourseClassification._internal(
    value: Term.fallSemester.value,
    text: Term.fallSemester.text,
    type: ClassificationType.term,
    searchCondition: (course){return course.semester == Term.fallSemester;}
  );

  static CourseClassification fall_quarter = CourseClassification._internal(
    value: Term.fallQuarter.value,
    text: Term.fallQuarter.text,
    type: ClassificationType.term,
    searchCondition: (course){return course.semester == Term.fallQuarter;}
  );

  static CourseClassification winter_quarter = CourseClassification._internal(
    value: Term.winterQuarter.value,
    text: Term.winterQuarter.text,
    type: ClassificationType.term,
    searchCondition: (course){return course.semester == Term.winterQuarter;}
  );

  static CourseClassification credits_1 = CourseClassification._internal(
    value: "credits_1",
    text: "１単位",
    type: ClassificationType.credits,
    searchCondition: (course){return course.credit == 1;}
  );

  static CourseClassification credits_2 = CourseClassification._internal(
    value: "credits_2",
    text: "２単位",
    type: ClassificationType.credits,
    searchCondition: (course){return course.credit == 2;}
  );

  static CourseClassification credits_3 = CourseClassification._internal(
    value: "credits_3",
    text: "３単位",
    type: ClassificationType.credits,
    searchCondition: (course){return course.credit == 3;}
  );

  static CourseClassification credits_4 = CourseClassification._internal(
    value: "credits_4",
    text: "４単位",
    type: ClassificationType.credits,
    searchCondition: (course){return course.credit == 4;}
  );

  static CourseClassification all = CourseClassification._internal(
    value: "all",
    text: "全て",
    type: ClassificationType.others,
    searchCondition: (course){return true;}
  );

  List<CourseClassification> _subjectClassificationList(List<MyCourse> courseList){  
    List<CourseClassification> list = [];
    int i = 1;
    for(var course in courseList){
      String? subjectClassification = course.subjectClassification;
      list.add(
        CourseClassification._internal(
            value: "classification$i",
            text: course.subjectClassification ?? "科目分類なし",
            type: ClassificationType.subjectClassification,
            searchCondition: (course){return course.subjectClassification == subjectClassification;}
          )
      );
      i++;
    }
    return list;
  }

  List<CourseClassification> getList(List<MyCourse> courseList){
    List<CourseClassification> list = [
      all,
      ondemand,
      faceToFace,
      spring_semester,
      spring_quarter,
      summer_quarter,
      fall_semester,
      fall_quarter,
      winter_quarter,
      credits_1,
      credits_2,
      credits_3,
      credits_4,
    ];
    list.addAll(
      _subjectClassificationList(courseList)
    );
    return list;
  }

  const CourseClassification._internal({
    required this.value,
    required this.text,
    required this.type,
    required this.searchCondition,
  });
  

  final String value;
  final String text;
  final ClassificationType type;
  final bool Function(MyCourse) searchCondition;
 
}

enum ClassificationType{
  classStyle,
  term,
  subjectClassification,
  credits,
  others,
}