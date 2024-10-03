import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import "package:flutter/services.dart";
import 'package:flutter_calandar_app/backend/DB/handler/user_info_db_handler.dart';
import 'package:flutter_calandar_app/backend/DB/models/user.dart';
import 'package:flutter_calandar_app/backend/DB/sharepreference.dart';
import 'package:settings_ui/settings_ui.dart';

class MoodleSettingPage extends StatefulWidget {
  const MoodleSettingPage({super.key});

  @override
  _MoodleSettingPageState createState() => _MoodleSettingPageState();
}

class _MoodleSettingPageState extends State<MoodleSettingPage> {
  final _calendarUrlController = TextEditingController();

  bool _isCalendarURLEditing = false;
  String _calendarUrl = "";

  @override
  void initState() {
    super.initState();
    _initDB();
  }

  @override
  void dispose() {
    _calendarUrlController.dispose();
    super.dispose();
  }

  void _initDB() async {
    _calendarUrl = await UserDatabaseHelper().getUrl() ?? "";
    _calendarUrlController.text = _calendarUrl;
    setState(() {});
  }


  void _cancelChanges() {
    _calendarUrlController.text = _calendarUrl;
    setState(() {
      _isCalendarURLEditing = false;
    });
  }


  void _saveCalendarUrl() async {
    final calendarUrl = _calendarUrlController.text;
    
  bool isValid = await UserDatabaseHelper().resisterUserInfo(calendarUrl);

  if(isValid){
    // カレンダーURLの保存処理をここに追加
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text("カレンダーURLを保存しました。"),
        actions: [
          CupertinoDialogAction(
            child: Text("OK"),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }else{
    // カレンダーURLの保存処理をここに追加
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text("URLを保存できませんでした。"),
        content: Text("無効なURLです。"),
        actions: [
          CupertinoDialogAction(
            child: Text("OK"),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

    setState(() {
      _isCalendarURLEditing = false;
    });
  }

  void _deleteCalendarUrl() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text("moodleカレンダーURLを削除しますか？"),
        content: Text("課題の自動取得機能がOFFになります。"),
        actions: [
          CupertinoDialogAction(
            child: Text(
              "キャンセル",
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.of(context).pop();
              setState(() {
                _calendarUrlController.clear();
              });
              SharepreferenceHandler().setValue(
                  SharepreferenceKeys.calendarURL, null);
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  void _copyCalendarUrlToClipboard() {
    final calendarUrl = _calendarUrlController.text;
    Clipboard.setData(ClipboardData(text: calendarUrl));
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text("コピー完了"),
        content: Text("カレンダーURLがクリップボードにコピーされました。"),
        actions: [
          CupertinoDialogAction(
            child: Text("OK"),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _cancelChanges,
      child: CupertinoPageScaffold(
        child: Stack(
          children: [
            SettingsList(
              platform: DevicePlatform.iOS,
              sections: [
                SettingsSection(
                  title: Text("カレンダーURL"),
                  tiles: <SettingsTile>[
                    SettingsTile(
                      leading: const Icon(CupertinoIcons.link),
                      title: _buildCalendarURLSection(),
                      trailing: null,
                    ),
                    SettingsTile(
                      description: Text("Moodleから課題情報を取得する際に使用されるURLです。手動で登録する場合はMoodleのメニュー内「カレンダー」「エクスポート」からURLを取得いただけます。"),
                      leading: CupertinoButton(
                        onPressed: () => {
                          setState(() {
                            _isCalendarURLEditing = true;
                          })
                        },
                        child: Text(
                          "編集",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface),
                        ),
                      ),
                      title: SizedBox(),
                      trailing: CupertinoButton(
                        onPressed: _saveCalendarUrl,
                        child: Text(
                          "保存",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface),
                        ),
                      ),
                    ),
                    SettingsTile(
                      title: Text("カレンダーURLを削除する",
                        style: TextStyle(
                          color: CupertinoColors.destructiveRed,
                        ),
                      ),
                      trailing: null,
                      onPressed: (context) => _deleteCalendarUrl(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarURLSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CupertinoTextField(
          controller: _calendarUrlController,
          placeholder:
              "Waseda MoodleのカレンダーURL",
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          decoration: _isCalendarURLEditing
              ? BoxDecoration(
                  color: const CupertinoDynamicColor.withBrightness(
                    color: CupertinoColors.white,
                    darkColor: CupertinoColors.black,
                  ),
                  border:
                      Border.all(color: Theme.of(context).colorScheme.primary),
                  borderRadius: const BorderRadius.all(Radius.circular(5.0)))
              : BoxDecoration(
                  color: const CupertinoDynamicColor.withBrightness(
                    color: CupertinoColors.white,
                    darkColor: CupertinoColors.black,
                  ),
                  border: Border.all(color: Colors.transparent),
                  borderRadius: const BorderRadius.all(Radius.circular(5.0))),

          suffix: GestureDetector(
            onTap: _copyCalendarUrlToClipboard,
            child: const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Icon(CupertinoIcons.doc_on_doc),
            ),
          ),
          readOnly: !_isCalendarURLEditing, // 編集モードに応じて読み取り専用か
        ),
      ],
    );
  }
}
