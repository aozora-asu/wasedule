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
      case Null:
        pref!.remove(sharepreference.key);
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

  //通知関連
  static const isClassNotify =
      SharepreferenceKeys._(key: "isClassNotify", defaultValue: true);
  static const isCalendarNotify =
      SharepreferenceKeys._(key: "isCalendarNotify", defaultValue: true);
  static const isTaskNotify =
      SharepreferenceKeys._(key: "isTaskNotify", defaultValue: true);
  
  //チュートリアル完了フラグ
  static const hasCompletedIntro =
      SharepreferenceKeys._(key: "hasCompletedIntro", defaultValue: false);
  static const initCampusNum =
      SharepreferenceKeys._(key: "initCampusNum", defaultValue: 0);
  static const hasCompletedCalendarIntro = SharepreferenceKeys._(
      key: "hasCompletedCalendarIntro", defaultValue: false);
  
  //アプリの色設定
  static const bgColorTheme =
      SharepreferenceKeys._(key: "bgColorTheme", defaultValue: "white");
  
  //出欠自動表示設定
  static const showAttendDialogAutomatically = SharepreferenceKeys._(
      key: "showAttendDialogAutomatically", defaultValue: true);

  //時間割関連
  static const isShowSaturday = SharepreferenceKeys._(
      key: "isShowSaturday", defaultValue: true);
  static const isOndemandTableSide = SharepreferenceKeys._(
      key: "isOndemandTableSide", defaultValue: true);

  //課題URL
  static const calendarURL =
      SharepreferenceKeys._(key: "calendarURL", defaultValue: null);
  
  //バックアップ関連
  static const backupID =
      SharepreferenceKeys._(key: "backupID", defaultValue: null);
  static const expireDayBackupID =
      SharepreferenceKeys._(key: "expireDayBackupID", defaultValue: true);
  static const userDepartment =
      SharepreferenceKeys._(key: "userDepartment", defaultValue: null);
  
  //シラバス検索履歴
  static const recentSyllabusQueryIsGraduateSchool = SharepreferenceKeys._(
      key: "recentSyllabusQueryIsGraduate", defaultValue: false);
  static const recentSyllabusQueryKeyword = SharepreferenceKeys._(
      key: "recentSyllabusQueryKeyword", defaultValue: null);
  static const recentSyllabusQueryKamoku = SharepreferenceKeys._(
      key: "recentSyllabusQueryKamoku", defaultValue: null);
  static const recentSyllabusQueryIsOpen = SharepreferenceKeys._(
      key: "recentSyllabusQueryIsOpen", defaultValue: false);
  static const recentSyllabusQueryKeya =
      SharepreferenceKeys._(key: "recentSyllabusQueryKeya", defaultValue: null);
  static const recentSyllabusQueryDepartmentValue = SharepreferenceKeys._(
      key: "recentSyllabusQueryDepartmentValue", defaultValue: null);
  static const recentSyllabusQueryIsFullYear = SharepreferenceKeys._(
      key: "recentSyllabusQueryIsFullYear", defaultValue: false);

  //タイムライン表示関連
  static const isShowTimelineSchedule =
      SharepreferenceKeys._(key: "isShowTimelineSchedule", defaultValue: true);
  static const isShowTimelineTask =
      SharepreferenceKeys._(key: "isShowTimelineTask", defaultValue: true);
  static const isShowTimelineCourse =
      SharepreferenceKeys._(key: "isShowTimelineCourse", defaultValue: true);
  static const isShowTimelineAutomatically = SharepreferenceKeys._(
      key: "isShowTimelineAutomatically", defaultValue: true);

  //成績・単位関連
  static const graduationRequireCredit =
      SharepreferenceKeys._(key: "GraduationRequireCredit", defaultValue: "");
  
  //マップの空き教室表示
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
        userDepartment,
        recentSyllabusQueryIsGraduateSchool,
        recentSyllabusQueryKeyword,
        recentSyllabusQueryKamoku,
        recentSyllabusQueryIsOpen,
        recentSyllabusQueryKeya,
        recentSyllabusQueryDepartmentValue,
        recentSyllabusQueryIsFullYear,
        isShowTimelineSchedule,
        isShowTimelineCourse,
        isShowTimelineTask,
        isShowTimelineAutomatically,
        graduationRequireCredit,
        isShowSaturday,
        isOndemandTableSide,
      ];
}
