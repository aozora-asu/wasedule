class ScheduleItem {
  String subject;

  String startDate;
  String? startTime;
  String? endDate;
  String? endTime;
  int isPublic;
  String? publicSubject;
  String? tag;

  ScheduleItem(
      {required this.subject,
      required this.startDate,
      this.startTime,
      this.endDate,
      this.endTime,
      required this.isPublic,
      this.publicSubject,
      this.tag});

  Map<String, dynamic> toMap() {
    return {
      'subject': subject,
      'startDate': startDate,
      'startTime': startTime,
      'endDate': endDate,
      'endTime': endTime,
      'isPublic': isPublic,
      "publicSubject": publicSubject,
      "tag": tag
    };
  }
}
