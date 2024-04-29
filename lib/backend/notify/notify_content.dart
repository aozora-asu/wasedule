import 'package:flutter_calandar_app/backend/DB/handler/schedule_db_handler.dart';
import 'package:flutter_calandar_app/backend/DB/handler/task_db_handler.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';

class NotifyContent {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  late NotificationDetails notificationDetails;
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

  tz.TZDateTime _nextInstanceOfNAM(int n) {
    tz.initializeTimeZones();
    tz.Location _local = tz.getLocation('Asia/Tokyo');
    final tz.TZDateTime now = tz.TZDateTime.now(_local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(_local, now.year, now.month, now.day, n);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  Future<void> bookDailyNAMNotification(int n) async {
    tz.TZDateTime scheduleDate = _nextInstanceOfNAM(n);
    List<Map<String, dynamic>> notifyTaskList = await TaskDatabaseHelper()
        .getDuringTaskList(scheduleDate.millisecondsSinceEpoch,
            scheduleDate.add(const Duration(days: 1)).millisecondsSinceEpoch);

    late String body = "";
    body += "課題\n";
    if (notifyTaskList.isEmpty) {
      body = "本日が期限の課題はありません\n";
    } else {
      for (var task in notifyTaskList) {
        String due = "";
        if (task["isDone"] == 0) {
          try {
            if (tz.TZDateTime(
                  scheduleDate.add(const Duration(days: 1)).location,
                  scheduleDate.add(const Duration(days: 1)).year,
                  scheduleDate.add(const Duration(days: 1)).month,
                  scheduleDate.add(const Duration(days: 1)).day,
                  0,
                ).millisecondsSinceEpoch <
                task["dtEnd"]) {
              due = DateFormat("翌HH:mm")
                  .format(DateTime.fromMillisecondsSinceEpoch(task["dtEnd"]));
            } else {
              due = DateFormat("  HH:mm")
                  .format(DateTime.fromMillisecondsSinceEpoch(task["dtEnd"]));
            }
          } catch (e) {
            due = "";
          }
          String title = task["title"] ?? "";
          String summary = task["summary"] ?? "";
          body += "$dueまで $title   $summary\n";
        }
      }
    }
    List<Map<String, dynamic>> notifyScheduleList =
        await ScheduleDatabaseHelper().getTodaysSchedule(scheduleDate);
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
    notificationDetails = _setNotificationDetail(
        20,
        "今日${DateFormat("MM/dd").format(DateTime.now())}(${'月火水木金土日'[DateTime.now().weekday - 1]})のお知らせ",
        body);
    await flutterLocalNotificationsPlugin.zonedSchedule(
      20,
      "今日${DateFormat("MM/dd").format(DateTime.now())}(${'月火水木金土日'[DateTime.now().weekday - 1]})のお知らせ",
      body,
      scheduleDate,
      notificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  getScheduled() async {
    final List<PendingNotificationRequest> pendingNotificationRequests =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    print('予約済みの通知');
    for (var pendingNotificationRequest in pendingNotificationRequests) {
      print(
          '予約済みの通知: [id: ${pendingNotificationRequest.id}, title: ${pendingNotificationRequest.title}, body: ${pendingNotificationRequest.body}, payload: ${pendingNotificationRequest.payload}]');
    }
  }
}
