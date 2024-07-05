import 'package:flutter/material.dart';
import 'package:rate_my_app/rate_my_app.dart';

final RateMyApp _rateMyApp = RateMyApp(
    preferencesPrefix: 'rateMyApp_',
    minDays: 7, 
    minLaunches: 10,
    remindDays: 7,
    remindLaunches: 10,
    appStoreIdentifier: "6479050214",
    googlePlayIdentifier: ""
  );

void initRateMyApp(BuildContext context) {
  _rateMyApp.init().then((_) {
    if (_rateMyApp.shouldOpenDialog) {
      _rateMyApp.showRateDialog(
        context,
        title:"'わせジュール'はいかがですか？",
        laterButton: "あとで",
        rateButton: "送信",
        noButton: "キャンセル"
        );
    }
  });
}


