import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/converter.dart';
import 'package:flutter_calandar_app/frontend/screens/moodle_view_page/moodle_view_page.dart';

import "./vacant_room.dart";
import 'package:isar/isar.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import "../../../frontend/screens/moodle_view_page/classRoom.dart";

Isar? isar;

class IsarHandler {
  Future<Isar> initIsar() async {
    if (isar == null || !isar!.isOpen) {
      final dir = await getApplicationDocumentsDirectory();
      isar = await Isar.open([BuildingSchema, ClassRoomSchema, HasClassSchema],
          directory: dir.path, inspector: false);
    }

    return isar!;
  }

  Future<void> resisterClassRoom(Isar isar, Building building,
      ClassRoom classRoom, HasClass hasClass) async {
    await isar.writeTxnSync(() async {
      building.classRooms.add(classRoom);
      classRoom.hasClass.add(hasClass);

      isar.buildings.putSync(building);
      isar.classRooms.putSync(classRoom);
      isar.hasClass.putSync(hasClass);
    });
  }

  Future<List<String>?> getVacantRoomList(
      Isar isar, String building, int period, int weekday) async {
    String? quarter = datetime2quarter(DateTime.now());
    List<String> classRoomList = classMap[building] ?? [];
    if (quarter != null) {
      final roomsHasClass = await isar.classRooms
          .filter()
          .buildingName((q) => q.buildingNameEqualTo(building))
          .and()
          .hasClass((q) => q.periodEqualTo(period))
          .and()
          .hasClass((q) => q.quarterEqualTo(quarter))
          .and()
          .hasClass((q) => q.weekdayEqualTo(weekday))
          .findAll();
      print(roomsHasClass.map((e) => e.classRoomName).toList());
      return classRoomList
          .toSet()
          .difference(roomsHasClass.map((e) => e.classRoomName).toSet())
          .toList();
    } else {
      return [];
    }
  }

  Future<List<String>?> getNowVacantRoomList(
    Isar isar,
    String building,
  ) async {
    String? quarter = datetime2quarter(DateTime.now());
    int weekday = DateTime.now().weekday;
    int? period = datetime2Period(DateTime.now());
    List<String> classRoomList = classMap[building] ?? [];

    if (quarter != null && period != null) {
      final roomsHasClass = await isar.classRooms
          .filter()
          .buildingName((q) => q.buildingNameEqualTo(building))
          .and()
          .hasClass((q) => q.quarterEqualTo(quarter))
          .and()
          .hasClass((q) => q.weekdayEqualTo(weekday))
          .and()
          .hasClass((q) => q.periodEqualTo(period))
          .findAll();
      return classRoomList
          .toSet()
          .difference(roomsHasClass.map((e) => e.classRoomName).toSet())
          .toList();
    } else {
      return [];
    }
  }

  Future<bool> isNowVacant(Isar isar, String classRoomName) async {
    String? quarter = datetime2quarter(DateTime.now());
    int weekday = DateTime.now().weekday;
    int? period = datetime2Period(DateTime.now());
    if (quarter != null && period != null) {
      final existClass = await isar.hasClass
          .filter()
          .periodEqualTo(period)
          .and()
          .weekdayEqualTo(weekday)
          .and()
          .quarterEqualTo(quarter)
          .and()
          .classRoomName((q) => q.classRoomNameEqualTo(classRoomName))
          .findFirst();
      if (existClass != null) {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  }
}
