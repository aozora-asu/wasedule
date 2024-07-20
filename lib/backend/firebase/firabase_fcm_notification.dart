// import "package:firebase_messaging/firebase_messaging.dart";
// import "./notify/notify.dart";

// Future<void> FCMnotificationSetting() async {
//   // FCM の通知権限リクエスト
//   final messaging = FirebaseMessaging.instance;
//   await messaging.requestPermission(
//     alert: true,
//     announcement: false,
//     badge: true,
//     carPlay: false,
//     criticalAlert: false,
//     provisional: false,
//     sound: true,
//   );

//   // トークンの取得
//   final token = await messaging.getToken();
//   // print('🐯 FCM TOKEN: $token');
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//     if (message.notification != null) {
//       NotifyContent().plainNotification();
//     }
//   });
// }
