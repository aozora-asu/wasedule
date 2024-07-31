import 'package:shared_preferences/shared_preferences.dart';
import "../../frontend/screens/map_page/const_map_info.dart";

SharedPreferences? pref;

class SharepreferenceHandler {
  dynamic getValue(SharepreferenceKeys sharepreference) {
    return pref!.get(sharepreference.key);
  }

  void setValue(SharepreferenceKeys sharepreference, dynamic value) {
    switch (value.runtimeType) {
      case String:
        pref!.setString(sharepreference.key, value);
        break;
      case bool:
        pref!.setBool(sharepreference.key, value);
        break;
      case int:
        pref!.setInt(sharepreference.key, value);
        break;
      case double:
        pref!.setDouble(sharepreference.key, value);
        break;
      case List<String> _:
        pref!.setStringList(sharepreference.key, value);
        break;
    }
  }

  Future<SharedPreferences> initSharepreference() async {
    SharepreferenceKeys mapDBEmptyKey;
    pref = await SharedPreferences.getInstance();
    for (var key in SharepreferenceKeys.keys) {
      if (getValue(key) == null) {
        setValue(key, key.defaultValue);
      }
    }
    for (int campusID = 0;
        campusID < campusID2buildingsList().length;
        campusID++) {
      mapDBEmptyKey = SharepreferenceKeys.isMapDBEmpty(campusID);
      if (getValue(mapDBEmptyKey) == null) {
        setValue(mapDBEmptyKey, mapDBEmptyKey.defaultValue);
      }
    }
    return pref!;
  }
}

class SharepreferenceKeys {
  final String key;
  final dynamic defaultValue;

  const SharepreferenceKeys._({required this.key, required this.defaultValue});

  static const isClassNotify =
      SharepreferenceKeys._(key: "isClassNotify", defaultValue: true);
  static const isCalendarNotify =
      SharepreferenceKeys._(key: "isCalendarNotify", defaultValue: true);
  static const isTaskNotify =
      SharepreferenceKeys._(key: "isTaskNotify", defaultValue: true);
  static const hasCompletedIntro =
      SharepreferenceKeys._(key: "hasCompletedIntro", defaultValue: false);
  static const initCampusNum =
      SharepreferenceKeys._(key: "initCampusNum", defaultValue: 0);
  static const hasCompletedCalendarIntro = SharepreferenceKeys._(
      key: "hasCompletedCalendarIntro", defaultValue: false);
  static const bgColorTheme =
      SharepreferenceKeys._(key: "bgColorTheme", defaultValue: "white");
  static const showAttendDialogAutomatically = SharepreferenceKeys._(
      key: "showAttendDialogAutomatically", defaultValue: true);
  static const calendarURL =
      SharepreferenceKeys._(key: "calendarURL", defaultValue: null);
  static const backupID =
      SharepreferenceKeys._(key: "backupID", defaultValue: null);
  static const expireDayBackupID =
      SharepreferenceKeys._(key: "expireDayBackupID", defaultValue: true);
  static const user_department =
      SharepreferenceKeys._(key: "user_department", defaultValue: null);

  static SharepreferenceKeys isMapDBEmpty(int id) {
    SharepreferenceKeys key =
        SharepreferenceKeys._(key: "isMapDBEmpty_$id", defaultValue: true);
    return key;
  }

  static List<SharepreferenceKeys> get keys => [
        isClassNotify,
        isCalendarNotify,
        isTaskNotify,
        hasCompletedIntro,
        hasCompletedCalendarIntro,
        bgColorTheme,
        initCampusNum,
        showAttendDialogAutomatically,
        user_department,
      ];
}
