import 'package:flutter_calandar_app/backend/DB/handler/schedule_db_handler.dart';
import 'package:flutter_calandar_app/backend/DB/handler/task_db_handler.dart';
import 'package:flutter_calandar_app/backend/DB/handler/my_course_db.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';
import "notify_db.dart";
import "../../converter.dart";
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

int notifyID = 0;

class NotifyContent {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  late NotificationDetails notificationDetails;
  NotificationDetails _setNotificationDetail(int id, String title, String body,
      String notifyGroupID, String notifyActionCategory) {
    notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          'notification channel $id',
          title,
          channelDescription: body,
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        ),
        iOS: DarwinNotificationDetails(
            sound: 'slow_spring_board.aiff',
            threadIdentifier: notifyGroupID,
            categoryIdentifier: notifyActionCategory));
    return notificationDetails;
  }

  //@params 通知をしたい毎週何曜日に何時に通知するのかを決める
  //timeString: 3:59 H:mm型の文字列
  //weekday 月~日まで1~7
  //return
  tz.TZDateTime _nextInstanceOfWeeklyTime(String timeString, int weekday) {
    tz.initializeTimeZones();
    tz.Location local = tz.getLocation('Asia/Tokyo');
    final tz.TZDateTime now = tz.TZDateTime.now(local);

    // 時刻文字列をパースして、DateTimeオブジェクトに変換
    DateTime parsedTime = DateFormat("H:mm").parse(timeString);

    // 現在の曜日を取得し、指定された曜日までの日数を計算
    int currentWeekday = now.weekday;
    int daysUntilNextWeekday = (weekday - currentWeekday + 7) % 7;

    // 次の週の指定された曜日の日付を計算
    tz.TZDateTime nextWeekDay = tz.TZDateTime(local, now.year, now.month,
        now.day + daysUntilNextWeekday, parsedTime.hour, parsedTime.minute);

    // 次の週が過去の場合は1週間後の同じ曜日の日付にする
    while (nextWeekDay.isBefore(now)) {
      nextWeekDay = nextWeekDay.add(const Duration(days: 7));
    }

    return nextWeekDay;
  }

  tz.TZDateTime _nextInstanceOfDailyTime(String timeString) {
    tz.initializeTimeZones();
    tz.Location local = tz.getLocation('Asia/Tokyo');
    final tz.TZDateTime now = tz.TZDateTime.now(local);
    // 時刻文字列をパースして、DateTimeオブジェクトに変換
    DateTime parsedTime = DateFormat("H:mm").parse(timeString);

    tz.TZDateTime scheduledDate = tz.TZDateTime(local, now.year, now.month,
        now.day, parsedTime.hour, parsedTime.minute);

    while (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  tz.TZDateTime _cinderellaTimeAfterNdayLater(tz.TZDateTime datetime, int n) {
    return tz.TZDateTime(
        datetime.add(Duration(days: n + 1)).location,
        datetime.add(Duration(days: n + 1)).year,
        datetime.add(Duration(days: n + 1)).month,
        datetime.add(Duration(days: n + 1)).day,
        0);
  }

  Future<void> _bookDailyTaskNotify(
      NotifyConfig notifyConfig, NotifyFormat notifyFormat) async {
    tz.TZDateTime dailyScheduleDate =
        _nextInstanceOfDailyTime(notifyConfig.time);

    String notifyTitle = makeNotifyTitle(notifyFormat, dailyScheduleDate);

    String body = await makeTaskNotifyBody(notifyConfig, dailyScheduleDate);
    String encodedPayload = jsonEncode({"route": "taskPage"});

    notificationDetails = _setNotificationDetail(
        notifyID++, notifyTitle, body, "dailyNotify_task", "");
    await flutterLocalNotificationsPlugin.zonedSchedule(
        notifyID++, notifyTitle, body, dailyScheduleDate, notificationDetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: encodedPayload);
  }

  Future<void> _bookDailyScheduleNotify(
      NotifyConfig notifyConfig, NotifyFormat notifyFormat) async {
    tz.TZDateTime dailyScheduleDate =
        _nextInstanceOfDailyTime(notifyConfig.time);

    String notifyTitle = makeNotifyTitle(notifyFormat, dailyScheduleDate);
    String encodedPayload = jsonEncode({"route": "calendarPage"});
    List<Map<String, dynamic>> notifyScheduleList =
        await ScheduleDatabaseHelper().getSchedule(dailyScheduleDate);
    String scheduleNotifyBody = "";
    if (notifyScheduleList.isEmpty) {
      scheduleNotifyBody += "本日の予定はありません";
    } else {
      for (var schedule in notifyScheduleList) {
        String startTime = schedule["startTime"] ?? "";
        String endTime = schedule["endTime"] ?? "";
        String subject = schedule["subject"] ?? "";
        if (endTime == "" && startTime == "") {
          scheduleNotifyBody += "終日    $subject\n";
        } else {
          scheduleNotifyBody += "$startTime~$endTime  $subject\n";
        }
      }
      scheduleNotifyBody = scheduleNotifyBody.trimRight();
    }
    notificationDetails = _setNotificationDetail(notifyID++, notifyTitle,
        scheduleNotifyBody, "dailyNotify_schedule", "");
    await flutterLocalNotificationsPlugin.zonedSchedule(notifyID++, notifyTitle,
        scheduleNotifyBody, dailyScheduleDate, notificationDetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: encodedPayload);
  }

  String makeNotifyTitle(
      NotifyFormat notifyFormat, tz.TZDateTime scheduleDate) {
    String notifyTitle = "";
    if (notifyFormat.isContainWeekday == 0) {
      notifyTitle =
          "${DateFormat(notifyFormat.notifyFormat).format(scheduleDate)}のお知らせ";
    } else {
      notifyTitle =
          "${DateFormat(notifyFormat.notifyFormat).format(scheduleDate)}(${'月火水木金土日'[scheduleDate.weekday - 1]})のお知らせ";
    }
    return notifyTitle;
  }

  Future<String> makeScheduleNotifyBody(
      NotifyConfig notifyConfig, tz.TZDateTime scheduleDate) async {
    List<Map<String, dynamic>> notifyScheduleList;
    String prefix;
    String scheduleNotifyBody = "";
    String planString = "";
    for (int day = 0; day <= notifyConfig.days!; day++) {
      notifyScheduleList = await ScheduleDatabaseHelper()
          .getSchedule(scheduleDate.add(Duration(days: day)));

      for (var schedule in notifyScheduleList) {
        String startTime = schedule["startTime"] ?? "";
        String endTime = schedule["endTime"] ?? "";
        String subject = schedule["subject"] ?? "";
        switch (day) {
          case 0:
            prefix = "今日";
          case 1:
            prefix = "翌";
          default:
            prefix = "$day日後";
        }
        if (endTime == "" && startTime == "") {
          planString += "$prefix    $subject\n";
        } else {
          planString += "$startTime~$endTime  $subject\n";
        }
      }
    }
    if (planString == "") {
      planString = "近日の予定はありません";
    }
    scheduleNotifyBody += planString;
    scheduleNotifyBody = scheduleNotifyBody.trimRight();
    return scheduleNotifyBody;
  }

  Future<String> makeTaskNotifyBody(
      NotifyConfig notifyConfig, tz.TZDateTime scheduleDate) async {
    String body;
    String taskBody = "";
    String due = "";
    String title;
    String summary;
    List<Map<String, dynamic>> notifyTaskList = await TaskDatabaseHelper()
        .getDuringTaskList(
            scheduleDate.millisecondsSinceEpoch,
            scheduleDate
                .add(Duration(days: notifyConfig.days!))
                .millisecondsSinceEpoch);
    for (var task in notifyTaskList) {
      if (task["isDone"] == 0) {
        if (task["dtEnd"] <
            _cinderellaTimeAfterNdayLater(scheduleDate, 0)
                .millisecondsSinceEpoch) {
          due = DateFormat("今日   H:mm")
              .format(DateTime.fromMillisecondsSinceEpoch(task["dtEnd"]));
        } else if (task["dtEnd"] <
            _cinderellaTimeAfterNdayLater(scheduleDate, 1)
                .millisecondsSinceEpoch) {
          due = DateFormat("翌    H:mm")
              .format(DateTime.fromMillisecondsSinceEpoch(task["dtEnd"]));
        } else {
          int n = DateTime.fromMillisecondsSinceEpoch(task["dtEnd"])
              .difference(scheduleDate)
              .inDays;
          due = DateFormat("$n日後 H:mm")
              .format(DateTime.fromMillisecondsSinceEpoch(task["dtEnd"]));
        }

        title = task["title"] ?? "";
        summary = task["summary"] ?? "";
        taskBody += "$dueまで $title\n  $summary\n";
      }
    }
    if (taskBody == "") {
      taskBody = "近日中の課題はありません\n";
    }
    body = taskBody.trimRight();

    return body;
  }

  Future<void> _bookWeeklyTaskNotify(
      NotifyConfig notifyConfig, NotifyFormat notifyFormat) async {
    String encodedPayload = jsonEncode({"route": "taskPage"});
    tz.TZDateTime weeklyScheduleDate =
        _nextInstanceOfWeeklyTime(notifyConfig.time, notifyConfig.weekday!);
    String body = await makeTaskNotifyBody(notifyConfig, weeklyScheduleDate);
    String notifyTitle = makeNotifyTitle(notifyFormat, weeklyScheduleDate);
    notificationDetails = _setNotificationDetail(
        notifyID++, notifyTitle, body, "weeklyNotify_task", "");
    await flutterLocalNotificationsPlugin.zonedSchedule(
        notifyID++, notifyTitle, body, weeklyScheduleDate, notificationDetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: encodedPayload);
  }

  Future<void> _bookWeeklyScheduleNotify(
      NotifyConfig notifyConfig, NotifyFormat notifyFormat) async {
    tz.TZDateTime weeklyScheduleDate =
        _nextInstanceOfWeeklyTime(notifyConfig.time, notifyConfig.weekday!);
    String notifyTitle = makeNotifyTitle(notifyFormat, weeklyScheduleDate);
    String scheduleNotifyBody =
        await makeScheduleNotifyBody(notifyConfig, weeklyScheduleDate);
    String encodedPayload = jsonEncode({"route": "calendarPage"});
    notificationDetails = _setNotificationDetail(notifyID++, notifyTitle,
        scheduleNotifyBody, "weeklyNotify_schedule", "");
    await flutterLocalNotificationsPlugin.zonedSchedule(notifyID++, notifyTitle,
        scheduleNotifyBody, weeklyScheduleDate, notificationDetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: encodedPayload);
  }

  Future<void> _bookBeforeHourNotify(
      NotifyConfig notifyConfig, NotifyFormat notifyFormat) async {
    String notifyTitle;
    String body;

    tz.initializeTimeZones();
    tz.Location local = tz.getLocation('Asia/Tokyo');
    final tz.TZDateTime now = tz.TZDateTime.now(local);
    // 時刻文字列をパースして、DateTimeオブジェクトに変換
    DateTime parsedTime = DateFormat("H:mm").parse(notifyConfig.time);
    if (parsedTime.hour == 0) {
      notifyTitle = "${parsedTime.minute}分前のお知らせです";
    } else {
      notifyTitle = "${parsedTime.hour}時間${parsedTime.minute}分前のお知らせです";
    }
    //それぞれ2日先まで取得して、期限のn時間前予約を行う
    List<Map<String, dynamic>> notifyTaskList = await TaskDatabaseHelper()
        .getDuringTaskList(now.millisecondsSinceEpoch,
            now.add(const Duration(days: 2)).millisecondsSinceEpoch);
    List<Map<String, dynamic>> notifyScheduleList =
        await ScheduleDatabaseHelper()
            .getDuringScheduleList(now, now.add(const Duration(days: 2)));

    String title;
    String summary;
    String? due;
    String encodedPayload;

    for (var task in notifyTaskList) {
      tz.TZDateTime scheduleDate =
          tz.TZDateTime.fromMillisecondsSinceEpoch(local, task["dtEnd"])
              .subtract(
                  Duration(hours: parsedTime.hour, minutes: parsedTime.minute));
      int n = DateTime.fromMillisecondsSinceEpoch(task["dtEnd"])
          .difference(scheduleDate)
          .inDays;
      if (task["isDone"] == 0 && now.isBefore(scheduleDate)) {
        if (task["dtEnd"] <=
            _cinderellaTimeAfterNdayLater(scheduleDate, 0)
                .millisecondsSinceEpoch) {
          due = DateFormat("今日   H:mm")
              .format(DateTime.fromMillisecondsSinceEpoch(task["dtEnd"]));
        } else if (task["dtEnd"] <=
            _cinderellaTimeAfterNdayLater(scheduleDate, 1)
                .millisecondsSinceEpoch) {
          due = DateFormat("翌    H:mm")
              .format(DateTime.fromMillisecondsSinceEpoch(task["dtEnd"]));
        } else {
          due = DateFormat("$n日後 H:mm")
              .format(DateTime.fromMillisecondsSinceEpoch(task["dtEnd"]));
        }

        title = task["title"] ?? "";
        summary = task["summary"] ?? "";
        body = "$dueまで $title   $summary".trimRight();
        encodedPayload =
            jsonEncode({"route": "taskPage", "databaseID": task["id"]});
        notificationDetails = _setNotificationDetail(notifyID++, notifyTitle,
            body, "beforHourNotify_task", "markTaskStatus");

        await flutterLocalNotificationsPlugin.zonedSchedule(
          notifyID++,
          notifyTitle,
          body,
          scheduleDate,
          notificationDetails,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: encodedPayload,
        );
      }
    }
    for (var schedule in notifyScheduleList) {
      String startDatetime;
      if (schedule["startTime"] == "") {
        startDatetime = "00:00";
      } else {
        startDatetime = schedule["startTime"];
      }
      tz.TZDateTime scheduleDatetime =
          tz.TZDateTime.parse(local, "${schedule["startDate"]} $startDatetime")
              .subtract(
                  Duration(hours: parsedTime.hour, minutes: parsedTime.minute));
      if (now.isBefore(scheduleDatetime)) {
        String endTime = schedule["endTime"];
        String startTime = schedule["startTime"];
        String subject = schedule["subject"];

        if (endTime == "" && schedule["startTime"] == "") {
          body = "終日  $subject\n";
        } else {
          body = "$startTime~$endTime  $subject\n";
        }
        encodedPayload = jsonEncode({"route": "calendarPage"});
        notificationDetails = _setNotificationDetail(
            notifyID++, notifyTitle, body, "beforHourNotify_schedule", "");
        await flutterLocalNotificationsPlugin.zonedSchedule(notifyID++,
            notifyTitle, body, scheduleDatetime, notificationDetails,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            payload: encodedPayload);
      }
    }
  }

  Future<void> setNotify() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    Map<String, dynamic>? notifyFormatMap =
        await NotifyDatabaseHandler().getNotifyFormat();
    List<Map<String, dynamic>>? notifyConfigList =
        await NotifyDatabaseHandler().getNotifyConfigList();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isCalendarNotify = prefs.getBool('isCalendarNotify') ?? true;
    bool isTaskNotify = prefs.getBool('isTaskNotify') ?? true;
    if (notifyConfigList != null && notifyFormatMap != null) {
      NotifyFormat notifyFormat = NotifyFormat(
          isContainWeekday: notifyFormatMap["isContainWeekday"],
          notifyFormat: notifyFormatMap["notifyFormat"]);
      for (Map<String, dynamic> notifyConfigMap in notifyConfigList) {
        NotifyConfig notifyConfig = NotifyConfig(
            notifyType: notifyConfigMap["notifyType"],
            time: notifyConfigMap["time"],
            isValidNotify: notifyConfigMap["isValidNotify"],
            days: notifyConfigMap["days"],
            weekday: notifyConfigMap["weekday"]);
        if (notifyConfigMap["isValidNotify"] == 1) {
          switch (notifyConfig.notifyType) {
            case "daily":
              if (isCalendarNotify) {
                await _bookDailyScheduleNotify(notifyConfig, notifyFormat);
              }
              if (isTaskNotify) {
                await _bookDailyTaskNotify(notifyConfig, notifyFormat);
              }

            case "weekly":
              if (isCalendarNotify) {
                await _bookWeeklyScheduleNotify(notifyConfig, notifyFormat);
              }
              if (isTaskNotify) {
                await _bookWeeklyTaskNotify(notifyConfig, notifyFormat);
              }
            case "beforeHour":
              await _bookBeforeHourNotify(notifyConfig, notifyFormat);
          }
        }
      }
    }
  }

  Future<void> sampleNotify() async {
    Map<String, dynamic>? notifyFormatMap =
        await NotifyDatabaseHandler().getNotifyFormat();
    String notifyTitle;
    tz.initializeTimeZones();
    tz.Location local = tz.getLocation('Asia/Tokyo');
    tz.TZDateTime now = tz.TZDateTime.now(local);
    if (notifyFormatMap != null) {
      NotifyFormat notifyFormat = NotifyFormat(
          isContainWeekday: notifyFormatMap["isContainWeekday"],
          notifyFormat: notifyFormatMap["notifyFormat"]);
      if (notifyFormat.isContainWeekday == 0) {
        if (notifyFormat.notifyFormat == null) {
          notifyTitle = "今日のお知らせ";
        } else {
          notifyTitle =
              "${DateFormat(notifyFormat.notifyFormat).format(now)}のお知らせ";
        }
      } else {
        if (notifyFormat.notifyFormat == null) {
          notifyTitle = "今日(${'月火水木金土日'[now.weekday - 1]})のお知らせ";
        } else {
          notifyTitle =
              "${DateFormat(notifyFormat.notifyFormat).format(now)}(${'月火水木金土日'[now.weekday - 1]})のお知らせ";
        }
      }
      notificationDetails = _setNotificationDetail(
          notifyID++, notifyTitle, "このように通知されます", "notifyConfig", "");
      await flutterLocalNotificationsPlugin.show(
        notifyID++,
        notifyTitle,
        "このように通知されます",
        notificationDetails,
      );
    } else {
      notificationDetails = _setNotificationDetail(
          notifyID++, "通知のフォーマットを設定してください", "", "notifyConfig", "");
      await flutterLocalNotificationsPlugin.show(
        notifyID++,
        "通知のフォーマットを設定してください",
        "",
        notificationDetails,
      );
    }
  }

  getScheduledNotify() async {
    final List<PendingNotificationRequest> pendingNotificationRequests =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    print('予約済みの通知');
    for (var pendingNotificationRequest in pendingNotificationRequests) {
      print(
          "通知id:${pendingNotificationRequest.id}\nタイトル:${pendingNotificationRequest.title}\n内容:${pendingNotificationRequest.body}\n------------------------------------------\n");
    }
  }

  Future<void> cancelAllNotify() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  static const String classNotifyTitle = "授業のお知らせ";
  Future<void> setClassNotify() async {
    List<Map<String, dynamic>>? myCourseList =
        await MyCourseDatabaseHandler().getPresentTermCourseList();
    if (myCourseList.isNotEmpty) {
      tz.TZDateTime weeklyScheduleDate;
      String body;

      for (var myCourse in myCourseList) {
        if (myCourse["period"] != null && myCourse["weekday"] != null) {
          weeklyScheduleDate = _nextInstanceOfWeeklyTime(
              period2endTime(myCourse["period"] - 1)!, myCourse["weekday"]);
          body =
              "${myCourse["period"]}限 ${period2startTime(myCourse["period"])}~ ${myCourse["courseName"]}\n    ${myCourse["classRoom"]}";
          String encodedPayload = jsonEncode({
            "route": "timeTablePage",
            "attendDate": DateFormat("M/d").format(weeklyScheduleDate),
            "myCourseID": myCourse["id"]
          });
          notificationDetails = _setNotificationDetail(notifyID++,
              classNotifyTitle, body, "classNotify", "markAttendStatus");
          await flutterLocalNotificationsPlugin.zonedSchedule(notifyID++,
              classNotifyTitle, body, weeklyScheduleDate, notificationDetails,
              uiLocalNotificationDateInterpretation:
                  UILocalNotificationDateInterpretation.absoluteTime,
              payload: encodedPayload);
        }
      }
    }
  }
}
