import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/schedule_import.dart';
import "./schedule_id_db_handler.dart";
import "./schedule_db_handler.dart";

class ImportedScheduleDatabaseHelper {
  late Database _database;
  // データベースの初期化
  ImportedScheduleDatabaseHelper() {
    _initImportedScheduleDatabase();
  }

  Future<void> _initImportedScheduleDatabase() async {
    String path = join(await getDatabasesPath(), 'schedule_import.db');
    _database =
        await openDatabase(path, version: 2, onCreate: _createScheduleDatabase);
  }

  // データベースの作成
  Future<void> _createScheduleDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS schedule_import(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
         hash TEXT UNIQUE, -- UNIQUE,
        subject TEXT,
        startDate TEXT,
        startTime TEXT,
        endDate TEXT,
        endTime TEXT,
        isPublic INTEGER, 
        publicSubject TEXT,
        tag TEXT
       
      )
    ''');
  }

  Future<void> insertSchedule(ImportedScheduleItem importedSchedule) async {
    await _initImportedScheduleDatabase();
    await _database.insert('schedule_import', importedSchedule.toMap());
  }

  Future<List<Map<String, dynamic>>> getImportedScheduleFromDB() async {
    await _initImportedScheduleDatabase();
    final List<Map<String, dynamic>> data =
        await _database.rawQuery('SELECT * FROM schedule_import');

    return data;
  }

  Future<void> importScheduleToDB(
      List<Map<String, dynamic>> importedScheduleList) async {
    await _initImportedScheduleDatabase();
    for (var importedSchedule in importedScheduleList) {
      ImportedScheduleItem importedScheduleItem = ImportedScheduleItem(
        subject: importedSchedule["subject"],
        startDate: importedSchedule["startDate"],
        startTime: importedSchedule["startTime"],
        endDate: importedSchedule["endDate"],
        endTime: importedSchedule["endTime"],
        isPublic: importedSchedule["isPublic"],
        publicSubject: importedSchedule["publicSubject"],
        tag: importedSchedule["tag"],
      );

      await insertSchedule(importedScheduleItem);
    }
  }

  Future<List<Map<String, List<Map<String, dynamic>>>>>
      getScheduleForID() async {
    List<Map<String, dynamic>> scheduleIDTagList =
        await ScheduleIDDatabaseHelper().getScheduleIDFromDB();
    List<Map<String, List<Map<String, dynamic>>>> list = [];
    for (var scheduleIDTag in scheduleIDTagList) {
      List<Map<String, dynamic>> scheduleList = await ScheduleDatabaseHelper()
          .pickScheduleByTag(scheduleIDTag["tagID"]);
      Map<String, List<Map<String, dynamic>>> map = {
        scheduleIDTag["scheduleID"]: scheduleList
      };
      list.add(map);
    }
    return list;
  }
}
