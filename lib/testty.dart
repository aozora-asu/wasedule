Map<String, dynamic> map1 = {
  'subject': "subject",
  'startDate': "startDate",
  'startTime': "startTime",
  'endDate': "endDate",
  'endTime': "endTime",
  'isPublic': "isPublic",
  "publicSubject": "publicSubject",
  "tag": "tag",
};

Map<String, dynamic> map2 = {
  'subject': "subject2",
  'startDate': "startDate",
  'startTime': "startTime",
  'endDate': "endDate",
  'endTime': "endTime",
  'isPublic': "isPublic",
  "publicSubject": "publicSubject",
  "tag": "tag",
};

void main() {
  print(map1.hashCode.toString());
  print(map2.hashCode.toString());
  print(map1.hashCode.toString() == map2.hashCode.toString());
}
