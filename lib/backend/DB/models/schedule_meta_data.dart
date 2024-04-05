class ScheduleMetaInfo {
  String scheduleID;
  String tagID;
  String scheduleType;
  String? dtEnd;

  ScheduleMetaInfo(
      {required this.scheduleID,
      required this.scheduleType,
      this.dtEnd,
      required this.tagID});

  Map<String, dynamic> toMap() {
    return {
      'scheduleID': scheduleID,
      'scheduleType': scheduleType,
      "dtEnd": dtEnd,
      "tagID": tagID
    };
  }
}
