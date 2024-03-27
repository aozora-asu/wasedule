class ImportedScheduleItem {
  String subject;

  String startDate;
  String? startTime;
  String? endDate;
  String? endTime;
  int isPublic;
  String? publicSubject;
  String? tag;

  ImportedScheduleItem({
    required this.subject,
    required this.startDate,
    this.startTime,
    this.endDate,
    this.endTime,
    required this.isPublic,
    this.publicSubject,
    this.tag,
  });
  @override
  int get hashCode {
    return {
      'subject': subject,
      'startDate': startDate,
      'startTime': startTime,
      'endDate': endDate,
      'endTime': endTime,
      'isPublic': isPublic,
      "publicSubject": publicSubject,
      "tag": tag,
    }.hashCode;
  }

  @override
  bool operator ==(other) {
    if (identical(this, other)) return true;
    if (other is! ImportedScheduleItem) return false;
    return subject == other.subject &&
        startDate == other.startDate &&
        startTime == other.startTime &&
        endDate == other.endDate &&
        endTime == other.endTime &&
        isPublic == other.isPublic &&
        publicSubject == other.publicSubject &&
        tag == other.tag;
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
      "tag": tag,
      "hash": hashCode.toString(),
    };
  }
}
