import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/schedule_import.dart';

class ImportedScheduleDatabaseHelper {
  late Database _database;
  // データベースの初期化
  ImportedScheduleDatabaseHelper() {
    _initImportedScheduleDatabase();
  }

  Future<void> _initImportedScheduleDatabase() async {
    String path = join(await getDatabasesPath(), 'schedule_import.db');
    _database =
        await openDatabase(path, version: 1, onCreate: _createScheduleDatabase);
  }

  // データベースの作成
  Future<void> _createScheduleDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS schedule_import(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
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
    await _database.insert('schedule', importedSchedule.toMap());
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
      await _database.insert('schedule', importedSchedule);
    }
  }
}
