import 'package:home_widget/home_widget.dart';

Future<void> updateAppWidget() async {
  HomeWidget.saveWidgetData<String>('_srcText', "Sample Data from Dart");
  HomeWidget.updateWidget(
      name: 'SampleAppWidget',
      androidName: 'SampleAppWidgetProvider',
      iOSName: 'SampleAppWidgetExtention');
}

init() {
  // AppGroupsの設定を行う
  const appGroupID = "group.com.example.wasedule";
  HomeWidget.setAppGroupId(appGroupID);
}
