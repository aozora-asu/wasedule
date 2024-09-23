# Diff Details

Date : 2024-09-21 17:19:45

Directory /Users/ryotarotakatsu/development/wase_dule/lib/frontend

Total : 58 files,  -12048 codes, -652 comments, -1192 blanks, all -13892 lines

[Summary](results.md) / [Details](details.md) / [Diff Summary](diff.md) / Diff Details

## Files
| filename | language | code | comment | blank | total |
| :--- | :--- | ---: | ---: | ---: | ---: |
| [lib/backend/DB/chache.dart](/lib/backend/DB/chache.dart) | Dart | -25 | -5 | -11 | -41 |
| [lib/backend/DB/handler/arbeit_db_handler.dart](/lib/backend/DB/handler/arbeit_db_handler.dart) | Dart | -72 | -6 | -11 | -89 |
| [lib/backend/DB/handler/calendarpage_config_db_handler.dart](/lib/backend/DB/handler/calendarpage_config_db_handler.dart) | Dart | -61 | -4 | -11 | -76 |
| [lib/backend/DB/handler/my_course_db.dart](/lib/backend/DB/handler/my_course_db.dart) | Dart | -553 | -13 | -53 | -619 |
| [lib/backend/DB/handler/my_grade_db.dart](/lib/backend/DB/handler/my_grade_db.dart) | Dart | -498 | -14 | -51 | -563 |
| [lib/backend/DB/handler/schedule_db_handler.dart](/lib/backend/DB/handler/schedule_db_handler.dart) | Dart | -204 | -19 | -26 | -249 |
| [lib/backend/DB/handler/schedule_metaInfo_db_handler.dart](/lib/backend/DB/handler/schedule_metaInfo_db_handler.dart) | Dart | -125 | -7 | -19 | -151 |
| [lib/backend/DB/handler/schedule_template_db_handler.dart](/lib/backend/DB/handler/schedule_template_db_handler.dart) | Dart | -122 | -10 | -15 | -147 |
| [lib/backend/DB/handler/tag_db_handler.dart](/lib/backend/DB/handler/tag_db_handler.dart) | Dart | -168 | -14 | -23 | -205 |
| [lib/backend/DB/handler/task_db_handler.dart](/lib/backend/DB/handler/task_db_handler.dart) | Dart | -367 | -39 | -43 | -449 |
| [lib/backend/DB/handler/todo_db_handler.dart](/lib/backend/DB/handler/todo_db_handler.dart) | Dart | -220 | -85 | -43 | -348 |
| [lib/backend/DB/handler/user_info_db_handler.dart](/lib/backend/DB/handler/user_info_db_handler.dart) | Dart | -160 | -11 | -20 | -191 |
| [lib/backend/DB/isar_collection/isar_handler.dart](/lib/backend/DB/isar_collection/isar_handler.dart) | Dart | -100 | -1 | -15 | -116 |
| [lib/backend/DB/isar_collection/vacant_room.dart](/lib/backend/DB/isar_collection/vacant_room.dart) | Dart | -44 | -2 | -13 | -59 |
| [lib/backend/DB/isar_collection/vacant_room.g.dart](/lib/backend/DB/isar_collection/vacant_room.g.dart) | Dart | -1,702 | -10 | -182 | -1,894 |
| [lib/backend/DB/models/arbeit.dart](/lib/backend/DB/models/arbeit.dart) | Dart | -17 | 0 | -3 | -20 |
| [lib/backend/DB/models/calendar_config.dart](/lib/backend/DB/models/calendar_config.dart) | Dart | -18 | 0 | -3 | -21 |
| [lib/backend/DB/models/schedule.dart](/lib/backend/DB/models/schedule.dart) | Dart | -40 | 0 | -4 | -44 |
| [lib/backend/DB/models/schedule_import.dart](/lib/backend/DB/models/schedule_import.dart) | Dart | 0 | -57 | -5 | -62 |
| [lib/backend/DB/models/schedule_import_id.dart](/lib/backend/DB/models/schedule_import_id.dart) | Dart | 0 | -11 | -3 | -14 |
| [lib/backend/DB/models/schedule_meta_data.dart](/lib/backend/DB/models/schedule_meta_data.dart) | Dart | -19 | 0 | -3 | -22 |
| [lib/backend/DB/models/schedule_template.dart](/lib/backend/DB/models/schedule_template.dart) | Dart | -28 | 0 | -4 | -32 |
| [lib/backend/DB/models/tag.dart](/lib/backend/DB/models/tag.dart) | Dart | -29 | 0 | -3 | -32 |
| [lib/backend/DB/models/task.dart](/lib/backend/DB/models/task.dart) | Dart | -28 | 0 | -3 | -31 |
| [lib/backend/DB/models/user.dart](/lib/backend/DB/models/user.dart) | Dart | -9 | 0 | -3 | -12 |
| [lib/backend/DB/sharepreference.dart](/lib/backend/DB/sharepreference.dart) | Dart | -134 | -11 | -19 | -164 |
| [lib/backend/firebase/firabase_fcm_notification.dart](/lib/backend/firebase/firabase_fcm_notification.dart) | Dart | 0 | -23 | -3 | -26 |
| [lib/backend/firebase/firebase_handler.dart](/lib/backend/firebase/firebase_handler.dart) | Dart | -226 | 0 | -31 | -257 |
| [lib/backend/firebase/firebase_options.dart](/lib/backend/firebase/firebase_options.dart) | Dart | -54 | -16 | -4 | -74 |
| [lib/backend/notify/notify_content.dart](/lib/backend/notify/notify_content.dart) | Dart | -538 | -12 | -49 | -599 |
| [lib/backend/notify/notify_db.dart](/lib/backend/notify/notify_db.dart) | Dart | -231 | -14 | -25 | -270 |
| [lib/backend/notify/notify_setting.dart](/lib/backend/notify/notify_setting.dart) | Dart | -137 | -19 | -15 | -171 |
| [lib/backend/service/classRoom.dart](/lib/backend/service/classRoom.dart) | Dart | -622 | -24 | -1 | -647 |
| [lib/backend/service/cookie.dart](/lib/backend/service/cookie.dart) | Dart | -22 | -2 | -5 | -29 |
| [lib/backend/service/email.dart](/lib/backend/service/email.dart) | Dart | -33 | 0 | -7 | -40 |
| [lib/backend/service/home_widget.dart](/lib/backend/service/home_widget.dart) | Dart | -62 | -4 | -11 | -77 |
| [lib/backend/service/http_request.dart](/lib/backend/service/http_request.dart) | Dart | -63 | -27 | -18 | -108 |
| [lib/backend/service/js/auto_login_checkbox.js](/lib/backend/service/js/auto_login_checkbox.js) | JavaScript | -56 | -4 | -11 | -71 |
| [lib/backend/service/js/get_complete_task.js](/lib/backend/service/js/get_complete_task.js) | JavaScript | -84 | -3 | -12 | -99 |
| [lib/backend/service/js/get_course_button.js](/lib/backend/service/js/get_course_button.js) | JavaScript | -381 | -49 | -63 | -493 |
| [lib/backend/service/js/get_document.js](/lib/backend/service/js/get_document.js) | JavaScript | -3 | 0 | -1 | -4 |
| [lib/backend/service/js/get_myGrade.js](/lib/backend/service/js/get_myGrade.js) | JavaScript | -33 | 0 | -7 | -40 |
| [lib/backend/service/js/go_to_myCreditPage.js](/lib/backend/service/js/go_to_myCreditPage.js) | JavaScript | -4 | 0 | -1 | -5 |
| [lib/backend/service/js/go_to_myGradePage.js](/lib/backend/service/js/go_to_myGradePage.js) | JavaScript | -5 | 0 | -1 | -6 |
| [lib/backend/service/js/hide_loading_screen.js](/lib/backend/service/js/hide_loading_screen.js) | JavaScript | -10 | -2 | -1 | -13 |
| [lib/backend/service/js/scroll_controller.js](/lib/backend/service/js/scroll_controller.js) | JavaScript | -29 | -1 | -3 | -33 |
| [lib/backend/service/js/show_loading_screen.js](/lib/backend/service/js/show_loading_screen.js) | JavaScript | -28 | -4 | -3 | -35 |
| [lib/backend/service/request_calendar_url.dart](/lib/backend/service/request_calendar_url.dart) | Dart | -28 | -5 | -5 | -38 |
| [lib/backend/service/share_from_web.dart](/lib/backend/service/share_from_web.dart) | Dart | -213 | -12 | -23 | -248 |
| [lib/backend/service/syllabus_query_request.dart](/lib/backend/service/syllabus_query_request.dart) | Dart | -379 | -11 | -30 | -420 |
| [lib/backend/service/syllabus_query_result.dart](/lib/backend/service/syllabus_query_result.dart) | Dart | -265 | -9 | -33 | -307 |
| [lib/main.dart](/lib/main.dart) | Dart | -33 | 0 | -4 | -37 |
| [lib/static/constant.dart](/lib/static/constant.dart) | Dart | -787 | 0 | -28 | -815 |
| [lib/static/converter.dart](/lib/static/converter.dart) | Dart | -28 | -2 | -6 | -36 |
| [lib/static/error_exception/error.dart](/lib/static/error_exception/error.dart) | Dart | -53 | -6 | -7 | -66 |
| [lib/static/error_exception/exception.dart](/lib/static/error_exception/exception.dart) | Dart | -43 | -3 | -7 | -53 |
| [lib/static/error_exception/status_code.dart](/lib/static/error_exception/status_code.dart) | Dart | -18 | 0 | -4 | -22 |
| [lib/test.dart](/lib/test.dart) | Dart | -2,837 | -81 | -184 | -3,102 |

[Summary](results.md) / [Details](details.md) / [Diff Summary](diff.md) / Diff Details