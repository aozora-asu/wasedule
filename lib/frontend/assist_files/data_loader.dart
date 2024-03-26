import 'package:flutter_calandar_app/backend/DB/handler/calendarpage_config_db_handler.dart';
import 'package:flutter_calandar_app/backend/DB/handler/schedule_db_handler.dart';
import 'package:flutter_calandar_app/backend/DB/handler/tag_db_handler.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/schedule_data_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import "../../backend/DB/handler/schedule_import_db.dart";

class ConfigDataLoader {
  Future<void> initConfig(WidgetRef ref) async {
    await createConfigData("tips", 1, ref);
    await createConfigData("todaysSchedule", 0, ref);
    await createConfigData("taskList", 1, ref);
    await createConfigData("moodleLink", 0, ref);
    await createConfigData("holidayPaint", 1, ref);
    await createConfigData("holidayName", 0, ref);
  }

  Future<void> createConfigData(
      String widgetName, int defaultState, WidgetRef ref) async {
    final calendarData = ref.watch(calendarDataProvider);
    bool found = false;
    await ref.read(calendarDataProvider).getConfigData(getConfigDataSource());
    for (var data in calendarData.configData) {
      String targetWidgetName = data["widgetName"];

      if (targetWidgetName == widgetName) {
        found = true;
        break;
      }
    }

    if (!found) {
      await CalendarConfigDatabaseHelper().resisterConfigToDB(
          {"widgetName": widgetName, "isVisible": defaultState, "info": "3"});
      ref.read(calendarDataProvider).getConfigData(getConfigDataSource());
    }
  }

  Future<List<Map<String, dynamic>>> getConfigDataSource() async {
    List<Map<String, dynamic>> arbeitList =
        await CalendarConfigDatabaseHelper().getConfigFromDB();
    return arbeitList;
  }

  int searchConfigData(String widgetName, WidgetRef ref) {
    final calendarData = ref.watch(calendarDataProvider);
    int result = 0;
    for (var data in calendarData.configData) {
      String targetWidgetName = data["widgetName"];

      if (targetWidgetName == widgetName) {
        result = data["isVisible"];
      }
    }
    return result;
  }

  int searchConfigInfo(String widgetName, WidgetRef ref) {
    final calendarData = ref.watch(calendarDataProvider);
    int result = 0;
    for (var data in calendarData.configData) {
      String targetWidgetName = data["widgetName"];

      if (targetWidgetName == widgetName) {
        result = int.parse(data["info"]);
      }
    }
    return result;
  }
}

class CalendarDataLoader {
  Future<List<Map<String, dynamic>>> getDataSource() async {
    List<Map<String, dynamic>> scheduleList =
        await ScheduleDatabaseHelper().getScheduleFromDB();
    List<Map<String, dynamic>> importedSchedule =
        await ImportedScheduleDatabaseHelper().getImportedScheduleFromDB();

    List<Map<String, dynamic>> combinedList =
        List.from(scheduleList); // スケジュールリストを複製

    combinedList.addAll(importedSchedule);

    return combinedList;
  }

  Future<void> insertDataToProvider(ref) async {
    List<Map<String, dynamic>> scheduleList = await getDataSource();
    await ref.read(calendarDataProvider).getData(scheduleList);
  }
}

class TagDataLoader {
  Future<List<Map<String, dynamic>>> getTagDataSource() async {
    List<Map<String, dynamic>> tagList =
        await TagDatabaseHelper().getTagFromDB();
    return tagList;
  }

  Future<void> insertDataToProvider(ref) async {
    List<Map<String, dynamic>> tagList = await getTagDataSource();
    await ref.read(calendarDataProvider).getTagData(tagList);
  }
}

class UserInfoLoader {
  Future<String> getUserIDSource() async {
    String userID = "c539ed57-9119-4a20-862d-e3c74861c9c1";
    //仮のIDです。ここにDBから受け渡して下さい。
    //await UserInfoDatabaseHelper().getUserIDFromDB();

    return userID;
  }

  Future<void> insertDataToProvider(ref) async {
    Future<String> userID = getUserIDSource();
    await ref.read(calendarDataProvider).getUserID(userID);
  }
}

class BroadcastLoader {
  Future<Map<String, dynamic>> getUploadDataSource() async {
    Map<String, dynamic> data = {
      "c539ed57-9119-4a20-862d-e3c74861c9c1": sample1,
      "d722ac73-7365-9e27-442e-a2a65357b2d2": sample1,
    };

    //仮のデータです。変数dataにDBから受け渡して下さい。
    //await HogeHogeDatabaseHelper().getHogeHogeFromDB();

    return data;
  }

  Future<void> insertUploadDataToProvider(ref) async {
    Future<Map<String, dynamic>> data = getUploadDataSource();
    await ref.read(calendarDataProvider).getUploadData(data);
  }

  Future<Map<String, dynamic>> getDownloadDataSource() async {
    Map<String, dynamic> data = {
      "c539ed57-9119-4a20-862d-e3c74861c9c1": sample1,
      "d722ac73-7365-9e27-442e-a2a65357b2d2": sample1,
    };

    //仮のデータです。変数dataにDBから受け渡して下さい。
    //await HogeHogeDatabaseHelper().getHogeHogeFromDB();

    return data;
  }

  Future<void> insertDownloadDataToProvider(ref) async {
    Future<Map<String, dynamic>> data = getDownloadDataSource();
    await ref.read(calendarDataProvider).getDownloadData(data);
  }
}

List<dynamic> sample1 = [
  {
    "id": 1,
    "subject": "予定１",
    "startDate": "2024-03-08",
    "startTime": "18:15",
    "endDate": "2024-02-08",
    "endTime": "21:05",
    "hash": "予定１2024-03-08"
  },
  {
    "id": 2,
    "subject": "予定2",
    "startDate": "2024-03-11",
    "startTime": "",
    "endDate": "2024-02-08",
    "endTime": "",
    "hash": "予定22024-03-11"
  },
  {
    "id": 3,
    "subject": "予定3",
    "startDate": "2024-03-12",
    "startTime": "18:15",
    "endDate": "2024-02-08",
    "endTime": "",
    "hash": "予定32024-03-12"
  },
  {
    "id": 4,
    "subject": "予定4",
    "startDate": "2024-03-12",
    "startTime": "18:15",
    "endDate": "2024-02-08",
    "endTime": "21:05",
    "hash": "予定42024-03-12"
  },
];
