import 'package:flutter_calandar_app/static/converter.dart';
import 'package:flutter_calandar_app/backend/DB/handler/my_course_db.dart';
import 'package:home_widget/home_widget.dart';
import 'dart:convert';
import "../../static/constant.dart";
import 'package:intl/intl.dart';

const String appGroupID = "group.com.example.wasedule";
const String iOSWidgetName = 'nextCourseWidget';
const String androidWidgetName = 'nextCourseWidget';

class NextCourseHomeWidget {
  NextCourseHomeWidget();

  Future<void> updateNextCourse() async {
    NextCourse nextCourse;
    List<MyCourse> nextCourseList = await MyCourse.getNextCourse();

    // Set the app group ID for iOS
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
          classRoom: course.classRoom,
          className: course.courseName,
          period: course.period?.period.toString() ?? "",
          startTime: DateFormat("H:mm")
              .format(Lesson.atPeriod(course.period!.period)!.start));
    }

    // Convert Dart object to JSON string
    String jsonData = jsonEncode(nextCourse.toJson());
    try {
      // Save the data to UserDefaults
      await HomeWidget.saveWidgetData<String>('widgetData', jsonData);

      // Update the widget on iOS and Android
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
