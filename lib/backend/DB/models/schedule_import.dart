// class ImportedScheduleItem {
//   String subject;

//   String startDate;
//   String? startTime;
//   String? endDate;
//   String? endTime;
//   int isPublic;
//   String? publicSubject;
//   String? tag;

//   ImportedScheduleItem({
//     required this.subject,
//     required this.startDate,
//     this.startTime,
//     this.endDate,
//     this.endTime,
//     required this.isPublic,
//     this.publicSubject,
//     this.tag,
//   });
//   @override
//   int get hashCode {
//     return subject.hashCode ^
//         startDate.hashCode ^
//         startTime.hashCode ^
//         endDate.hashCode ^
//         endTime.hashCode ^
//         isPublic.hashCode ^
//         publicSubject.hashCode ^
//         tag.hashCode;
//   }

//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;
//     return other is ImportedScheduleItem &&
//         other.subject == subject &&
//         other.startDate == startDate &&
//         other.startTime == startTime &&
//         other.endDate == endDate &&
//         other.endTime == endTime &&
//         other.isPublic == isPublic &&
//         other.publicSubject == publicSubject &&
//         other.tag == tag;
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'subject': subject,
//       'startDate': startDate,
//       'startTime': startTime,
//       'endDate': endDate,
//       'endTime': endTime,
//       'isPublic': isPublic,
//       "publicSubject": publicSubject,
//       "tag": tag,
//       "hash": hashCode.toString(),
//     };
//   }
// }
