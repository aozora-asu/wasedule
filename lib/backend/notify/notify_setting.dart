import 'dart:async';

import 'dart:io';
// ignore: unnecessary_import

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:flutter/material.dart';

import '../../frontend/assist_files/screen_manager.dart';
import "../DB/handler/task_db_handler.dart";
import "./notify_content.dart";
import "../DB/handler/my_course_db.dart";
import 'dart:convert';
import "../../frontend/screens/common/eyecatch_page.dart";
import "../../constant.dart";

@pragma('vm:entry-point')
void notificationTapBackground(
    NotificationResponse notificationResponse) async {
  // ignore: avoid_print
  Map<String, dynamic> decodedPayload =
      jsonDecode(notificationResponse.payload!);

  if (notificationResponse.actionId == "markAsComplete" &&
      decodedPayload["route"] == "taskPage") {
    await TaskDatabaseHelper().unDisplay(decodedPayload["databaseID"]);
    await NotifyContent().setAllNotify();
  }
  if (decodedPayload["route"] == "timeTablePage") {
    AttendanceRecord attendanceRecord = AttendanceRecord(
        attendDate: decodedPayload["attendDate"],
        attendStatus: AttendStatus.values.byName(
          notificationResponse.actionId!,
        ),
        myCourseID: decodedPayload["myCaurseID"]);
    await MyCourseDatabaseHandler().recordAttendStatus(attendanceRecord);
  }
  // print('notification(${notificationResponse.id}) action tapped: '
  //     '${notificationResponse.actionId} with'
  //     ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print(
        'notification action tapped with input: ${notificationResponse.input}');
  }
}

class LocalNotificationSetting {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  Future<void> requestIOSPermission() async {
    if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: false,
            badge: true,
            sound: false,
          );
    }
  }

  Future<void> requestAndroidPermission() async {
    if (Platform.isAndroid) {
      final androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
      }
      await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.areNotificationsEnabled() ??
          false;
    }
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> initializePlatformSpecifics(BuildContext context) async {
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('icon');

    var initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: false,
      notificationCategories: [
        DarwinNotificationCategory(
          'markAttendStatus',
          actions: <DarwinNotificationAction>[
            DarwinNotificationAction.plain(AttendStatus.attend.value, "出席"),
            DarwinNotificationAction.plain(
              AttendStatus.late.value,
              '遅刻',
              //破壊的な設定
              // options: <DarwinNotificationActionOption>{
              //   DarwinNotificationActionOption.destructive,
              // },
            ),
            DarwinNotificationAction.plain(
              AttendStatus.absent.value,
              '欠席',
              //一緒にアプリを起動
              // options: <DarwinNotificationActionOption>{
              //   DarwinNotificationActionOption.foreground,
              // },
            ),
          ],
          // options: <DarwinNotificationCategoryOption>{
          //   DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
          // },
        ),
        DarwinNotificationCategory("markTaskStatus",
            actions: <DarwinNotificationAction>[
              DarwinNotificationAction.plain('markAsComplete', '完了としてマーク'),
            ])
      ],
      onDidReceiveLocalNotification: (id, title, body, payload) async {
        // your call back to the UI
      },
    );

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse res) async {
        Map<String, dynamic> decodedPayload = {};
        if (res.payload != null) {
          decodedPayload = jsonDecode(res.payload!);
        }
        if (decodedPayload.isEmpty) {
          // 何もしない
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (decodedPayload["route"] == "taskPage") {
              navigatorKey.currentState?.pushReplacement(
                MaterialPageRoute(
                  builder: (_) => AppPage(initIndex: 3),
                ),
              );
            } else if (decodedPayload["route"] == "timeTablePage") {
              navigatorKey.currentState?.pushReplacement(
                MaterialPageRoute(
                  builder: (_) => AppPage(initIndex: 1),
                ),
              );
            } else if (decodedPayload["route"] == "calendarPage") {
              navigatorKey.currentState?.pushReplacement(
                MaterialPageRoute(
                  builder: (_) => AppPage(initIndex: 2),
                ),
              );
            }
          });
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }
}
