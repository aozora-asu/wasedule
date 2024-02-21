class CalendarConfig {
  String widgetName;
  int isVisible;
  String info;

  CalendarConfig (
      {
      required this.widgetName,
      required this.isVisible,
      required this.info,
      });

  Map<String, dynamic> toMap() {
    return {
      'widgetName' : widgetName,
      'isVisible': isVisible,
      'info': info,
    };
  }
}
