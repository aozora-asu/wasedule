class ScheduleItem {
  String subject;

  int startDate;
  int? startTime;
  int? endDate;
  int? endTime;
  bool isPublic;
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
