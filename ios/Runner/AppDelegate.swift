import UIKit
import Flutter
import flutter_local_notifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

    // メソッドチャネルの定義
    private let methodChannelName = "com.example.wasedule/update_data"

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
        }

        // This is required to make any communication available in the action isolate.
        FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
            GeneratedPluginRegistrant.register(with: registry)
        }

        GeneratedPluginRegistrant.register(with: self)

        // Flutterメソッドチャネルの設定
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(name: methodChannelName, binaryMessenger: controller.binaryMessenger)

        channel.setMethodCallHandler { (call, result) in
            // Handle method calls here
            if call.method == "updateData" {
                // Do something with the data from Flutter
                if let args = call.arguments as? [String: Any],
                   let classRoom = args["classRoom"] as? String,
                   let className = args["className"] as? String,
                   let period = args["period"] as? String,
                   let startTime = args["startTime"] as? String {
                    // Process the data
                    print("Received data from Flutter: \(classRoom), \(className), \(period), \(startTime)")
                    result("Data received successfully")
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid argument from Flutter", details: nil))
                }
            } else {
                result(FlutterMethodNotImplemented)
            }
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
