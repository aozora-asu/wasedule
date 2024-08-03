import UIKit
import Flutter
import flutter_local_notifications
import WidgetKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

    private let methodChannelName = "com.example.wasedule/update_data"
    private let sharedContentChannelName = "com.example.wasedule/shared"
    private let navigationChannelName = "com.example.wasedule/navigation"
    private let appGroupID = "group.com.example.wasedule"

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        print("AppDelegate didFinishLaunchingWithOptions called")

        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
        }

        FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
            GeneratedPluginRegistrant.register(with: registry)
        }

        GeneratedPluginRegistrant.register(with: self)

        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(name: methodChannelName, binaryMessenger: controller.binaryMessenger)
        let sharedContentChannel = FlutterMethodChannel(name: sharedContentChannelName, binaryMessenger: controller.binaryMessenger)
        let navigationChannel = FlutterMethodChannel(name: navigationChannelName, binaryMessenger: controller.binaryMessenger)

        sharedContentChannel.setMethodCallHandler { (call, result) in
            if call.method == "getSharedContent" {
                print("getSharedContent method called")
                if let userDefaults = UserDefaults(suiteName: self.appGroupID),
                   let sharedContent = userDefaults.string(forKey: "sharedContent") {
                    print("Shared content retrieved: \(sharedContent)")
                    result(sharedContent)
                    // コンテンツを取得後、クリアする
                    userDefaults.removeObject(forKey: "sharedContent")
                    userDefaults.synchronize()
                } else {
                    print("No shared content found")
                    result(nil)
                }
            } else {
                result(FlutterMethodNotImplemented)
            }
        }

        channel.setMethodCallHandler { (call, result) in
            if call.method == "updateData" {
                if let args = call.arguments as? [String: Any],
                   let classRoom = args["classRoom"] as? String,
                   let className = args["className"] as? String,
                   let period = args["period"] as? String,
                   let startTime = args["startTime"] as? String {

                    print("Received data from Flutter: \(classRoom), \(className), \(period), \(startTime)")
                    
                    if let userDefaults = UserDefaults(suiteName: self.appGroupID) {
                        userDefaults.setValue(classRoom, forKey: "classRoom")
                        userDefaults.setValue(className, forKey: "className")
                        userDefaults.setValue(period, forKey: "period")
                        userDefaults.setValue(startTime, forKey: "startTime")
                        userDefaults.synchronize()
                    }
                    
                    if #available(iOS 14.0, *) {
                        WidgetCenter.shared.reloadTimelines(ofKind: "com.example.wasedule.HomeWidget")
                    } else {
                        print("WidgetKit is not available on this iOS version.")
                    }

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

    override func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        let flutterViewController = window?.rootViewController as! FlutterViewController
        let navigationChannel = FlutterMethodChannel(name: navigationChannelName, binaryMessenger: flutterViewController.binaryMessenger)
        
        let urlString = url.absoluteString
        print("URLスキームで呼び出されたURL: \(urlString)")
        
        // URLからクエリパラメータを抽出
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems {
            for item in queryItems {
                if item.name == "content", let content = item.value {
                    // 共有されたコンテンツをUserDefaultsに保存
                    if let userDefaults = UserDefaults(suiteName: self.appGroupID) {
                        userDefaults.setValue(content, forKey: "sharedContent")
                        userDefaults.synchronize()
                        print("Shared content saved: \(content)")
                    }
                    break
                }
            }
        }
        
        navigationChannel.invokeMethod("navigateTo", arguments: urlString)
        
        return true
    }
}
