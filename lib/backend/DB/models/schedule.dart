class ScheduleItem {
  String subject;

  String startDate;
  String? startTime;
  String? endDate;
  String? endTime;
  int isPublic;
  String? publicSubject;
  String? tag;
  String tagID;

  ScheduleItem(
      {required this.subject,
      required this.startDate,
      this.startTime,
      this.endDate,
      this.endTime,
      required this.isPublic,
      this.publicSubject,
      this.tag,
      required this.tagID});
  @override
  int get hashCode {
    return DateTime.now().microsecondsSinceEpoch.hashCode;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScheduleItem &&
        other.subject == subject &&
        other.startDate == startDate &&
        other.startTime == startTime &&
        other.endDate == endDate &&
        other.endTime == endTime &&
        other.isPublic == isPublic &&
        other.publicSubject == publicSubject &&
        other.tagID == tagID;
  }

  Map<String, dynamic> toMap() {
    return {
      'subject': subject,
      'startDate': startDate,
      'startTime': startTime,
      'endDate': endDate,
      'endTime': endTime,
      'isPublic': isPublic,
      "publicSubject": publicSubject,
      "hash": hashCode.toString(),
      "tagID": tagID
    };
  }
}
