import 'package:flutter_calandar_app/backend/DB/handler/calendarpage_config_db_handler.dart';
import 'package:flutter_calandar_app/backend/DB/handler/schedule_db_handler.dart';
import 'package:flutter_calandar_app/backend/DB/handler/schedule_import_db.dart';
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
    List<Map<String, dynamic>> importedSchedule =
        await ImportedScheduleDatabaseHelper().getImportedScheduleFromDB();

    List<Map<String, dynamic>> combinedList =
        List.from(scheduleList);

    combinedList.insertAll(0,importedSchedule);

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
    //★仮のデータです。ここにDBから受け渡して下さい。
    Map<String, dynamic> data = sample;

    // List<Map<String, List<Map<String, dynamic>>>> dataSause =
    //     await ImportedScheduleDatabaseHelper().getScheduleForID();

    // for (int i = 0; i < dataSause.length; i++) {
    //   String key = dataSause.elementAt(i).keys.elementAt(0);
    //   List value = dataSause.elementAt(i).values.elementAt(0);
    //   data[key] = value;
    // }

    return data;
  }

  Future<void> insertUploadDataToProvider(ref) async {
    Future<Map<String, dynamic>> data = getUploadDataSource();
    await ref.read(calendarDataProvider).getUploadData(data);
  }

}

Map<String,dynamic> sample = {
  "ee0171cf-dcf5-411e-8e63-206e712ee709":
  {
    "tag" : {
        "id" : 1,
        "title" : "サンプルプル1",
        "color" : 4294961979,
        "isBeit" : 0,
        "wage" : 0,
        "fee" : 0,
        "tagID" : "2024030914155319"
      },
    "schedule":[
      {
        "id": 1,
        "subject": "予定１",
        "startDate": "2024-03-08",
        "startTime": "18:15",
        "endDate": "2024-02-08",
        "endTime": "21:05",
        "hash": "0187464823"
      },
      {
        "id": 2,
        "subject": "予定2",
        "startDate": "2024-03-11",
        "startTime": "",
        "endDate": "2024-02-08",
        "endTime": "",
        "hash": "972849263"
      },
      {
        "id": 3,
        "subject": "予定3",
        "startDate": "2024-03-12",
        "startTime": "18:15",
        "endDate": "2024-02-08",
        "endTime": "",
        "hash": "693756593"
      },
      {
        "id": 4,
        "subject": "予定4",
        "startDate": "2024-03-12",
        "startTime": "18:15",
        "endDate": "2024-02-08",
        "endTime": "21:05",
        "hash": "603929574"
      }
    ],
  },
  "443e50a1-a12c-4daa-9029-4e981c731fc6" : {
    "tag" : {
        "id" : 2,
        "title" : "サンプル2",
        "color" : 4294961979,
        "isBeit" : 1,
        "wage" : 1200,
        "fee" : 356,
        "tagID" : "2024031120300124"
      },
    "schedule":[
      {
        "id": 1,
        "subject": "バイト",
        "startDate": "2024-03-08",
        "startTime": "18:15",
        "endDate": "",
        "endTime": "21:05",
        "hash": "593782659"
      },
      {
        "id": 2,
        "subject": "バイト2",
        "startDate": "2024-03-11",
        "startTime": "12:00",
        "endDate": "",
        "endTime": "15:00",
        "hash": "583726592"
      },
      {
        "id": 3,
        "subject": "バイト3",
        "startDate": "2024-03-12",
        "startTime": "18:15",
        "endDate": "",
        "endTime": "22:00",
        "hash": "6937826596"
      },
    ],
  },
  "ae0171cf-dcf5-411e-8d63-206e712ee709":
  {
    "tag" : {
        "id" : 3,
        "title" : "サンプル3",
        "color" : 4294961979,
        "isBeit" : 0,
        "wage" : 0,
        "fee" : 0,
        "tagID" : "2024031214155319"
      },
    "schedule":[
      {
        "id": 1,
        "subject": "予定１",
        "startDate": "2024-03-08",
        "startTime": "18:15",
        "endDate": "2024-02-08",
        "endTime": "21:05",
        "hash": "649274927"
      },
    ],
  },
};
