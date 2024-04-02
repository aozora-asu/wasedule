class ScheduleTemplateItem {
  String subject;

  String? startTime;
  String? endTime;
  int isPublic;
  String? publicSubject;
  String? tag;
  String tagID;

  ScheduleTemplateItem(
      {required this.subject,
      this.startTime,
      this.endTime,
      required this.isPublic,
      this.publicSubject,
      this.tag,
      required this.tagID});

  Map<String, dynamic> toMap() {
    return {
      'subject': subject,
      'startTime': startTime,
      'endTime': endTime,
      'isPublic': isPublic,
      "publicSubject": publicSubject,
      "tag": tag,
      "tagID": tagID
    };
  }
}
