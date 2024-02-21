import 'dart:async';

import 'package:flutter_calandar_app/backend/DB/handler/task_db_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../DB/handler/schedule_db_handler.dart';

/// A notification action which triggers a url launch event
const String urlLaunchActionId = 'id_1';

/// A notification action which triggers a App navigation event
const String navigationActionId = 'id_3';

/// Defines a iOS/MacOS notification category for text input actions.
const String darwinNotificationCategoryText = 'textCategory';

/// Defines a iOS/MacOS notification category for plain actions.
const String darwinNotificationCategoryPlain = 'plainCategory';

class Notify {
  int id = 0;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  String? selectedNotificationPayload;
  Future<void> initializeNotifications() async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('icon');
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Notify() {
    initializeNotifications();
  }

  Future<void> scheduleDailyEightAMNotification() async {
    String todaysSchedule =
        await ScheduleDatabaseHelper().todaysScheduleForNotify();
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        '今日の予定',
        todaysSchedule,
        _nextInstanceOfEightAM(),
        NotificationDetails(
            android: AndroidNotificationDetails(
                'daily notification channel id', '今日の予定',
                channelDescription: todaysSchedule,
                sound: const RawResourceAndroidNotificationSound(
                    'slow_spring_board')),
            iOS: const DarwinNotificationDetails(
              sound: 'slow_spring_board.aiff',
            )),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time);
  }

  Future<void> taskDueTodayNotification() async {
    String taskDueToday = await TaskDatabaseHelper().taskDueTodayForNotify();

    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        '今日が期限の課題',
        taskDueToday,
        _nextInstanceOfEightAM(),
        NotificationDetails(
            android: AndroidNotificationDetails(
                'daily notification channel id', '今日が期限の課題',
                channelDescription: taskDueToday,
                sound: const RawResourceAndroidNotificationSound(
                    'slow_spring_board')),
            iOS: const DarwinNotificationDetails(
              sound: 'slow_spring_board.aiff',
            )),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time);
  }

  tz.TZDateTime _nextInstanceOfEightAM() {
    tz.initializeTimeZones();
    tz.Location _local = tz.getLocation('Asia/Tokyo');
    final tz.TZDateTime now = tz.TZDateTime.now(_local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(_local, now.year, now.month, now.day, 8);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> _showNotificationWithActions() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          urlLaunchActionId,
          'Action 1',
          icon: DrawableResourceAndroidBitmap('food'),
          contextual: true,
        ),
        AndroidNotificationAction(
          'id_2',
          'Action 2',
          titleColor: Color.fromARGB(255, 255, 0, 0),
          icon: DrawableResourceAndroidBitmap('secondary_icon'),
        ),
        AndroidNotificationAction(
          navigationActionId,
          'Action 3',
          icon: DrawableResourceAndroidBitmap('secondary_icon'),
          showsUserInterface: true,
          // By default, Android plugin will dismiss the notification when the
          // user tapped on a action (this mimics the behavior on iOS).
          cancelNotification: false,
        ),
      ],
    );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      categoryIdentifier: darwinNotificationCategoryPlain,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );
    await flutterLocalNotificationsPlugin.show(
        id++, 'plain title', 'plain body', notificationDetails,
        payload: 'item z');
  }
}
