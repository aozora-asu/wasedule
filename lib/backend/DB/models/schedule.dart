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
  String? hash;

  ScheduleItem(
      {required this.subject,
      required this.startDate,
      this.startTime,
      this.endDate,
      this.endTime,
      required this.isPublic,
      this.publicSubject,
      this.tag,
      required this.tagID,
      this.hash});
  @override
  int get hashCode {
    return DateTime.now().microsecondsSinceEpoch.hashCode;
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
      "hash": hash ?? hashCode.toString(),
      "tagID": tagID
    };
  }
}
