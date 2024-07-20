import 'package:flutter_calandar_app/static/converter.dart';
import 'package:flutter_calandar_app/backend/DB/handler/my_course_db.dart';
import 'package:home_widget/home_widget.dart';
import 'dart:convert';

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
        period: "",
        startTime: "",
      );
    } else {
      var course = nextCourseList.last;
      nextCourse = NextCourse(
        classRoom: course["classRoom"] ?? "",
        className: course["courseName"] ?? "",
        period: course["period"]?.toString() ?? "",
        startTime: period2startTime(course["period"]) ?? "",
      );
    }
    // nextCourse = NextCourse(
    //     classRoom: DateTime.fromMicrosecondsSinceEpoch(34567876543).toString(),
    //     className: "className",
    //     period: DateTime.now().second.toString(),
    //     startTime: DateTime.now().minute.toString());

    // DartからJSON文字列に変換
    String jsonData = jsonEncode(nextCourse.toJson());
    try {
      // Save the data to UserDefaults
      await HomeWidget.saveWidgetData<String>('widgetData', jsonData);
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
