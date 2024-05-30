import "package:flutter_calandar_app/backend/DB/handler/my_course_db.dart";
import 'package:hive/hive.dart';
//part 'user.g.dart';
import "../../../frontend/screens/moodle_view_page/syllabus.dart";
import "../../../frontend/screens/moodle_view_page/classRoom.dart";

@HiveType(typeId: 1)
class User {
  User({required this.name, required this.age});

  @HiveField(0)
  String name;

  @HiveField(1)
  int age;
}

List<String> vacntRoomList(int buildingNum, int weekday, int period) {
  List<String> classRoomList = classMap[buildingNum.toString()] ?? [];

  for (var classRoom in classRoomList) {
    RequestQuery requestQuery = RequestQuery(
      p_gakki: "1",
      keyword: classRoom,
      p_number: "100",
    );
  }

  return [];
}
