import 'package:flutter_calandar_app/converter.dart';
import 'package:flutter_calandar_app/frontend/screens/moodle_view_page/my_course_db.dart';
import 'package:flutter_calandar_app/main.dart';
import 'package:home_widget/home_widget.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

import 'package:html/parser.dart'; // 追加

const String appGroupID = "group.com.example.wasedule";
const String iOSWidgetName = 'nextCourseWidget';
const String androidWidgetName = 'nextCourseWidget';

class NextCourseHomeWidget {
  NextCourseHomeWidget();

  Future<void> updateNextCourse() async {
    NextCourse nextCourse;
    List<Map<String, dynamic>> nextCourseList =
        await MyCourseDatabaseHandler().getNextCourse();

    HomeWidget.setAppGroupId(appGroupID);
    if (nextCourseList.isEmpty) {
      nextCourse = NextCourse(
        classRoom: "",
        className: "",
        period: "  ",
        startTime: "",
      );
    } else {
      nextCourse = NextCourse(
        classRoom: nextCourseList.last["classRoom"],
        className: nextCourseList.last["courseName"],
        period: nextCourseList.last["period"].toString(),
        startTime: "${period2startTime(nextCourseList.last["period"])}~",
      );
    }

    // DartからJSON文字列に変換
    String jsonData = jsonEncode(nextCourse.toJson());
    print("Saving JSON data: $jsonData"); // デバッグログを追加

    try {
      // Save the data to UserDefaults
      await HomeWidget.saveWidgetData<String>('widgetData', jsonData);
      print("Data saved successfully"); // デバッグログを追加

      // ウィジェットを更新
      await HomeWidget.updateWidget(
        iOSName: iOSWidgetName,
        androidName: androidWidgetName,
      );
    } catch (error) {
      print("Error saving widget data: $error");
    }
  }
}

class NextCourse {
  final String classRoom;
  final String className;
  final String period;
  final String startTime;

  NextCourse({
    required this.classRoom,
    required this.className,
    required this.period,
    required this.startTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'classRoom': classRoom,
      'className': className,
      'period': period,
      'startTime': startTime,
    };
  }
}
