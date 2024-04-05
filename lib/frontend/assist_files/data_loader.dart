import 'package:flutter_calandar_app/backend/DB/handler/calendarpage_config_db_handler.dart';
import 'package:flutter_calandar_app/backend/DB/handler/schedule_db_handler.dart';
import 'package:flutter_calandar_app/backend/DB/handler/tag_db_handler.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/schedule_data_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

    return scheduleList;
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
  Future<String?> getUserIDSource() async {
    String? userID = "c539ed57-9119-4a20-862d-e3c74861c9c1";

    //仮のIDです。ここにDBから受け渡して下さい。
    //await UserInfoDatabaseHelper().getUserIDFromDB();

    return userID;
  }

  Future<void> insertDataToProvider(ref) async {
    Future<String?> userID = getUserIDSource();
    await ref.read(calendarDataProvider).getUserID(userID);
  }
}

class BroadcastLoader {
  Future<Map<String, dynamic>> getUploadDataSource() async {
    Map<String, dynamic> data = await ScheduleDatabaseHelper().getExportedSchedule();
    return data;
  }

  Future<void> insertUploadDataToProvider(ref) async {
    Future<Map<String, dynamic>> data = getUploadDataSource();
    await ref.read(calendarDataProvider).getUploadData(data);
  }
}