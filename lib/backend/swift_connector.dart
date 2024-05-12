import 'package:flutter/services.dart';

MethodChannel _methodChannel = MethodChannel('com.example.show');

void main() {
  // プラットフォームチャンネルの作成
  const platform = MethodChannel('com.example.flutter_app/channel');

  // 外部から呼び出される関数の実装
  platform.setMethodCallHandler((call) async {
    if (call.method == 'getValue') {
      // 値を取得する処理を行う
      String value = getValueFromDart();
      return value;
    }
    return null;
  });
}

// Swiftから呼び出される関数
String getValueFromDart() {
  return 'Hello from Dart!';
}
