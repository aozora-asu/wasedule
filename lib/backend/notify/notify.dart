import 'dart:async';

import 'package:flutter_calandar_app/backend/DB/handler/task_db_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

import '../DB/handler/schedule_db_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';

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
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
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

class NotifyContent {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static const int SCHEDULE_NOTIFICATION_ID = 0;
  static const int TASK_NOTIFICATION_ID = 1;
  DateTime today = DateTime.now();

  Future<void> scheduleDailyEightAMNotification() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        SCHEDULE_NOTIFICATION_ID,
        '今日 ${DateFormat('MM/dd').format(today)} の予定',
        await ScheduleDatabaseHelper().todaysScheduleForNotify(today),
        _nextInstanceOfEightAM(),
        NotificationDetails(
            android: AndroidNotificationDetails(
              'daily schedule notification channel id',
              '今日の予定',
              channelDescription:
                  await ScheduleDatabaseHelper().todaysScheduleForNotify(today),
            ),
            iOS: const DarwinNotificationDetails(
              sound: 'slow_spring_board.aiff',
            )),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time);
  }

  Future<void> bookTomorrowNotify() async {}

  Future<void> taskDueTodayNotification() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        TASK_NOTIFICATION_ID,
        '期限が今日 ${DateFormat('MM/dd').format(today)} の課題',
        await TaskDatabaseHelper().taskDueTodayForNotify(today),
        _nextInstanceOfEightAM(),
        NotificationDetails(
            android: AndroidNotificationDetails(
              'daily task notification channel id',
              '期限が今日の課題',
              channelDescription:
                  await TaskDatabaseHelper().taskDueTodayForNotify(today),
            ),
            iOS: const DarwinNotificationDetails(
              sound: 'slow_spring_board.aiff',
            )),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
    //  matchDateTimeComponents: DateTimeComponents.time);
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
    if (today.isBefore(now)) {
      today = today.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  tz.TZDateTime _nextInstance() {
    tz.initializeTimeZones();
    tz.Location _local = tz.getLocation('Asia/Tokyo');
    final tz.TZDateTime now = tz.TZDateTime.now(_local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
        _local, now.year, now.month, now.day, now.hour, now.minute, 0);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(minutes: 1));
    }
    if (today.isBefore(DateTime.now())) {
      today = today.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  Future<void> sampleNotification() async {
    // 5秒後
    String data = "";
    int id = 0;

    data = "${DateTime.now().minute}分${DateTime.now().second}秒";
    id = 100;

    var androidChannelSpecifics = const AndroidNotificationDetails(
      'CHANNEL_ID 1',
      'CHANNEL_NAME 1',
      channelDescription: "CHANNEL_DESCRIPTION 1",
      icon: 'icon',
      //sound: RawResourceAndroidNotificationSound('my_sound'),
      largeIcon: DrawableResourceAndroidBitmap('icon'),
      enableLights: true,
      color: Color.fromARGB(255, 255, 0, 0),
      ledColor: Color.fromARGB(255, 255, 0, 0),
      ledOnMs: 1000,
      ledOffMs: 500,
      importance: Importance.max,
      priority: Priority.high,
      playSound: false,
      timeoutAfter: 5000,
      styleInformation: DefaultStyleInformation(true, true),
    );

    var iosChannelSpecifics = const DarwinNotificationDetails(
      sound: 'slow_spring_board.aiff',
    );

    var platformChannelSpecifics = NotificationDetails(
      android: androidChannelSpecifics,
      iOS: iosChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
        id, 'Testify', data, _nextInstance(), platformChannelSpecifics,
        payload: 'Test Payload',
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.wallClockTime);
  }

  Future<void> plainNotification() async {
    await flutterLocalNotificationsPlugin.show(
      400,
      'firebase由来の通知：今日までの予定',
      await TaskDatabaseHelper().taskDueTodayForNotify(today),
      NotificationDetails(
          android: AndroidNotificationDetails(
            'daily task notification channel id',
            '期限が今日の課題',
            channelDescription:
                await TaskDatabaseHelper().taskDueTodayForNotify(today),
          ),
          iOS: const DarwinNotificationDetails(
            sound: 'slow_spring_board.aiff',
          )),
    );
  }
}
