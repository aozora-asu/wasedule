import 'package:flutter_calandar_app/backend/DB/handler/task_db_handler.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/task_data_manager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationContent {
  String title;
  String body;
  String? payload;
  int id;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  NotificationDetails notificationDetails = const NotificationDetails();
  DateTime today = DateTime.now();
  void _initialize() {
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
    if (today.isBefore(now)) {
      today = today.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  NotificationContent(
      {required this.id,
      required this.title,
      required this.body,
      this.payload});

  Future<void> bookDailyNAMNotification(int n) async {
    tz.TZDateTime schedule = _nextInstanceOfNAM(n);
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      schedule,
      notificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> testNotification() async {
    _initialize();
    await flutterLocalNotificationsPlugin
        .show(id, title, body, notificationDetails, payload: payload);
  }
}
