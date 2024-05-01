import 'package:flutter_calandar_app/backend/DB/handler/schedule_db_handler.dart';
import 'package:flutter_calandar_app/backend/DB/handler/task_db_handler.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';
import "notify_db.dart";

class NotifyContent {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  late NotificationDetails notificationDetails;
  static const int SAMPLENOTIFYID = 0;
  static const int DAILYNOTIFYID = 1;
  static const int WEEKLYNOTIFYID = 2;

  int BEFOREHOURNOTIFYID = 100;
  NotificationDetails _setNotificationDetail(
      int id, String title, String body) {
    notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          'notification channel $id',
          title,
          channelDescription: body,
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        ),
        iOS: const DarwinNotificationDetails(
          sound: 'slow_spring_board.aiff',
        ));
    return notificationDetails;
  }

  tz.TZDateTime _nextInstanceOfWeeklyTime(String timeString, int weekday) {
    tz.initializeTimeZones();
    tz.Location _local = tz.getLocation('Asia/Tokyo');
    final tz.TZDateTime now = tz.TZDateTime.now(_local);

    // 時刻文字列をパースして、DateTimeオブジェクトに変換
    DateTime parsedTime = DateFormat.Hm().parse(timeString);

    // 現在の曜日を取得し、指定された曜日までの日数を計算
    int currentWeekday = now.weekday;
    int daysUntilNextWeekday = (weekday - currentWeekday + 7) % 7;

    // 次の週の指定された曜日の日付を計算
    tz.TZDateTime nextWeekDay = tz.TZDateTime(_local, now.year, now.month,
        now.day + daysUntilNextWeekday, parsedTime.hour, parsedTime.minute);

    // 次の週が過去の場合は1週間後の同じ曜日の日付にする
    if (nextWeekDay.isBefore(now)) {
      nextWeekDay = nextWeekDay.add(const Duration(days: 7));
    }

    return nextWeekDay;
  }

  tz.TZDateTime _nextInstanceOfDailyTime(String timeString) {
    tz.initializeTimeZones();
    tz.Location _local = tz.getLocation('Asia/Tokyo');
    final tz.TZDateTime now = tz.TZDateTime.now(_local);
    // 時刻文字列をパースして、DateTimeオブジェクトに変換
    DateTime parsedTime = DateFormat.Hm().parse(timeString);

    tz.TZDateTime scheduledDate = tz.TZDateTime(_local, now.year, now.month,
        now.day, parsedTime.hour, parsedTime.minute);

    if (scheduledDate.isBefore(now)) {
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

  String? _getDueDate(
      tz.TZDateTime dailyScheduleDate, int daysAfter, int taskEnd) {
    DateTime cinderellaTime =
        _cinderellaTimeAfterNdayLater(dailyScheduleDate, daysAfter);
    if (daysAfter == 0 && taskEnd < cinderellaTime.millisecondsSinceEpoch) {
      return DateFormat("   HH:mm")
          .format(DateTime.fromMillisecondsSinceEpoch(taskEnd));
    } else if (daysAfter == 1 &&
        taskEnd < cinderellaTime.millisecondsSinceEpoch) {
      return DateFormat("翌    HH:mm")
          .format(DateTime.fromMillisecondsSinceEpoch(taskEnd));
    } else if (cinderellaTime
                .subtract(const Duration(days: 1))
                .millisecondsSinceEpoch <
            taskEnd &&
        taskEnd < cinderellaTime.millisecondsSinceEpoch) {
      return DateFormat("$daysAfter日後 HH:mm")
          .format(DateTime.fromMillisecondsSinceEpoch(taskEnd));
    }
    return null;
  }

  Future<void> _bookDailyNotify(
      NotifyConfig notifyConfig, NotifyFormat notifyFormat) async {
    tz.TZDateTime dailyScheduleDate =
        _nextInstanceOfDailyTime(notifyConfig.time);
    List<Map<String, dynamic>> notifyTaskList = await TaskDatabaseHelper()
        .getDuringTaskList(
            dailyScheduleDate.millisecondsSinceEpoch,
            dailyScheduleDate
                .add(Duration(days: notifyConfig.days!))
                .millisecondsSinceEpoch);
    late String body = "";
    String title;
    String summary;
    String? due;
    String notifyTitle;

    body += "課題\n";
    String taskBody = "";

    for (var task in notifyTaskList) {
      if (task["isDone"] == 0) {
        for (int i = 0; i < notifyConfig.days!; i++) {
          due = _getDueDate(dailyScheduleDate, i, task["dtEnd"]);
          title = task["title"] ?? "";
          summary = task["summary"] ?? "";
          taskBody += "$dueまで $title   $summary\n";
        }
      }
    }
    if (taskBody == "") {
      taskBody = "直近の課題はありません";
    }
    body += taskBody;

    List<Map<String, dynamic>> notifyScheduleList =
        await ScheduleDatabaseHelper().getSchedule(dailyScheduleDate);
    body += "予定\n";
    if (notifyScheduleList.isEmpty) {
      body += "本日の予定はありません";
    } else {
      for (var schedule in notifyScheduleList) {
        String startTime = schedule["startTime"] ?? "";
        String endTime = schedule["endTime"] ?? "";
        String subject = schedule["subject"] ?? "";
        if (endTime == "" && startTime == "") {
          body += "終日    $subject\n";
        } else {
          body += "$startTime~$endTime  $subject\n";
        }
      }
      body = body.trimRight();
    }
    if (notifyFormat.isContainWeekday == 0) {
      if (notifyFormat.notifyFormat == null) {
        notifyTitle = "今日のお知らせ";
      } else {
        notifyTitle =
            "${DateFormat(notifyFormat.notifyFormat).format(dailyScheduleDate)}のお知らせ";
      }
    } else {
      if (notifyFormat.notifyFormat == null) {
        notifyTitle = "今日(${'月火水木金土日'[dailyScheduleDate.weekday - 1]})のお知らせ";
      } else {
        notifyTitle =
            "${DateFormat(notifyFormat.notifyFormat).format(dailyScheduleDate)}(${'月火水木金土日'[dailyScheduleDate.weekday - 1]})のお知らせ";
      }
    }
    notificationDetails =
        _setNotificationDetail(WEEKLYNOTIFYID, notifyTitle, body);
    await flutterLocalNotificationsPlugin.zonedSchedule(
      WEEKLYNOTIFYID,
      notifyTitle,
      body,
      dailyScheduleDate,
      notificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> _bookWeeklyNotify(
      NotifyConfig notifyConfig, NotifyFormat notifyFormat) async {
    tz.TZDateTime dailyScheduleDate =
        _nextInstanceOfWeeklyTime(notifyConfig.time, notifyConfig.weekday!);
    List<Map<String, dynamic>> notifyTaskList = await TaskDatabaseHelper()
        .getDuringTaskList(
            dailyScheduleDate.millisecondsSinceEpoch,
            dailyScheduleDate
                .add(Duration(days: notifyConfig.days!))
                .millisecondsSinceEpoch);
    late String body = "";
    String title;
    String summary;
    String? due;
    String notifyTitle;

    body += "課題\n";
    String taskBody = "";

    for (var task in notifyTaskList) {
      if (task["isDone"] == 0) {
        for (int i = 0; i < notifyConfig.days!; i++) {
          due = _getDueDate(dailyScheduleDate, i, task["dtEnd"]);
          title = task["title"] ?? "";
          summary = task["summary"] ?? "";
          taskBody += "$dueまで $title   $summary\n";
        }
      }
    }
    if (taskBody == "") {
      taskBody = "近日中の課題はありません";
    }
    body += taskBody;

    List<Map<String, dynamic>> notifyScheduleList;
    String prefix;
    body += "予定\n";
    String planString = "";
    for (int day = 0; day <= notifyConfig.days!; day++) {
      notifyScheduleList = await ScheduleDatabaseHelper()
          .getSchedule(dailyScheduleDate.add(Duration(days: day)));

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
    body += planString;
    body = body.trimRight();
    if (notifyFormat.isContainWeekday == 0) {
      if (notifyFormat.notifyFormat == null) {
        notifyTitle = "近日のお知らせ";
      } else {
        notifyTitle =
            "${DateFormat(notifyFormat.notifyFormat).format(dailyScheduleDate)}のお知らせ";
      }
    } else {
      if (notifyFormat.notifyFormat == null) {
        notifyTitle = "${'月火水木金土日'[dailyScheduleDate.weekday - 1]}曜日のお知らせ";
      } else {
        notifyTitle =
            "${DateFormat(notifyFormat.notifyFormat).format(dailyScheduleDate)}(${'月火水木金土日'[dailyScheduleDate.weekday - 1]})のお知らせ";
      }
    }
    notificationDetails =
        _setNotificationDetail(DAILYNOTIFYID, notifyTitle, body);
    await flutterLocalNotificationsPlugin.zonedSchedule(
      DAILYNOTIFYID,
      notifyTitle,
      body,
      dailyScheduleDate,
      notificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> _bookBeforeHourNotify(
      NotifyConfig notifyConfig, NotifyFormat notifyFormat) async {
    String notifyTitle;
    String body;

    tz.initializeTimeZones();
    tz.Location _local = tz.getLocation('Asia/Tokyo');
    final tz.TZDateTime now = tz.TZDateTime.now(_local);
    // 時刻文字列をパースして、DateTimeオブジェクトに変換
    DateTime parsedTime = DateFormat.Hm().parse(notifyConfig.time);
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

    for (var task in notifyTaskList) {
      if (task["isDone"] == 0) {
        due = _getDueDate(now, 1, task["dtEnd"]);
        if (due != null) {
          title = task["title"] ?? "";
          summary = task["summary"] ?? "";
          body = "$dueまで $title   $summary";

          notificationDetails =
              _setNotificationDetail(DAILYNOTIFYID, notifyTitle, body);
          await flutterLocalNotificationsPlugin.zonedSchedule(
            BEFOREHOURNOTIFYID++,
            notifyTitle,
            body,
            tz.TZDateTime.fromMillisecondsSinceEpoch(_local, task["dtEnd"])
                .subtract(Duration(
                    hours: parsedTime.hour, minutes: parsedTime.minute)),
            notificationDetails,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
        }
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
          tz.TZDateTime.parse(_local, "${schedule["startDate"]} $startDatetime")
              .subtract(
                  Duration(hours: parsedTime.hour, minutes: parsedTime.minute));

      String endTime = schedule["endTime"];
      String startTime = schedule["startTime"];
      String subject = schedule["subject"];

      if (endTime == "" && schedule["startTime"] == "") {
        body = "終日  $subject\n";
      } else {
        body = "$startTime~$endTime  $subject\n";
      }

      notificationDetails =
          _setNotificationDetail(DAILYNOTIFYID, notifyTitle, body);
      await flutterLocalNotificationsPlugin.zonedSchedule(
        BEFOREHOURNOTIFYID++,
        notifyTitle,
        body,
        scheduleDatetime,
        notificationDetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> setNotify() async {
    Map<String, dynamic>? notifyFormatMap =
        await NotifyDatabaseHandler().getNotifyFormat();
    List<Map<String, dynamic>>? notifyConfigList =
        await NotifyDatabaseHandler().getNotifyConfigList();
    if (notifyConfigList != null && notifyFormatMap != null) {
      NotifyFormat notifyFormat = NotifyFormat(
          isContainWeekday: notifyFormatMap["isContainWeekday"],
          notifyFormat: notifyFormatMap["notifyFormat"]);
      for (Map<String, dynamic> notifyConfigMap in notifyConfigList) {
        if (notifyConfigMap["isValidNotify"] == 1) {
          NotifyConfig notifyConfig = NotifyConfig(
              notifyType: notifyConfigMap["notifyType"],
              time: notifyConfigMap["time"],
              isValidNotify: notifyConfigMap["isValidNotify"],
              days: notifyConfigMap["days"],
              weekday: notifyConfigMap["weekday"]);
          switch (notifyConfig.notifyType) {
            case "daily":
              await _bookDailyNotify(notifyConfig, notifyFormat);
            case "weekly":
              await _bookWeeklyNotify(notifyConfig, notifyFormat);
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
    tz.Location _local = tz.getLocation('Asia/Tokyo');
    tz.TZDateTime now = tz.TZDateTime.now(_local);
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
      notificationDetails =
          _setNotificationDetail(DAILYNOTIFYID, notifyTitle, "このように通知されます");
      await flutterLocalNotificationsPlugin.show(
        SAMPLENOTIFYID,
        notifyTitle,
        "このように通知されます",
        notificationDetails,
      );
    } else {
      notificationDetails =
          _setNotificationDetail(DAILYNOTIFYID, "通知のフォーマットを設定してください", "");
      await flutterLocalNotificationsPlugin.show(
        SAMPLENOTIFYID,
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
          '予約済みの通知: [id: ${pendingNotificationRequest.id}, title: ${pendingNotificationRequest.title}, body: ${pendingNotificationRequest.body}, payload: ${pendingNotificationRequest.payload}]');
    }
  }

  Future<void> cancelAllNotify() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> cancelNotify(int notifyID) async {
    await flutterLocalNotificationsPlugin.cancel(notifyID);
  }
}
