// これらのimportは必要に応じて追加してください
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_calandar_app/frontend/screens/moodle_view_page/classRoom.dart';
import 'package:isar/isar.dart';
part 'vacant_room.g.dart';

// モデルの定義
@collection
class Building {
  Building({required this.buildingName});
  @Index(unique: true, replace: true)
  late String buildingName;

  late Id id = int.parse(buildingName);

  final classRooms = IsarLinks<ClassRoom>();
}

@collection
class ClassRoom {
  ClassRoom({required this.classRoomName});
  @Index()
  late String classRoomName;
  Id get classRoomId => fastHash(classRoomName);
  // Id id = Isar.autoIncrement;

  final hasClass = IsarLinks<HasClass>();
  @Backlink(to: "classRooms")
  final buildingName = IsarLink<Building>();
}

@collection
class HasClass {
  HasClass(
      {required this.weekday, required this.period, required this.quarter});

  Id get hasClassId =>
      fastHash(weekday.toString() + period.toString()) ^ fastHash(quarter);

  late int period;
  late int weekday;

  late String quarter;
  @Backlink(to: "hasClass")
  final classRoomName = IsarLinks<ClassRoom>();
}

int fastHash(String string) {
  var hash = 0xcbf29ce484222325;

  var i = 0;
  while (i < string.length) {
    final codeUnit = string.codeUnitAt(i++);
    hash ^= codeUnit >> 8;
    hash *= 0x100000001b3;
    hash ^= codeUnit & 0xFF;
    hash *= 0x100000001b3;
  }

  return hash;
}
