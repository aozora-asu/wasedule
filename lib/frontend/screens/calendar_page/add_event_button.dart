import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/schedule_data_manager.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/time_input_page.dart';
import 'package:flutter_calandar_app/frontend/screens/common/app_bar.dart';
import 'package:intl/intl.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_calandar_app/frontend/screens/outdated/data_card.dart';
import 'package:form_field_validator/form_field_validator.dart';
import '../../assist_files/validators.dart';
import 'package:easy_autocomplete/easy_autocomplete.dart';
import '../../../backend/DB/handler/schedule_db_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final scheduleFormProvider =
    StateNotifierProvider<ScheduleFormNotifier, ScheduleForm>(
  (ref) => ScheduleFormNotifier(),
);

class ScheduleFormNotifier extends StateNotifier<ScheduleForm> {
  ScheduleFormNotifier() : super(ScheduleForm());

  void updateDateTimeFields() {
    state = state.copyWith();
  }

  void toggleSwitch() {
    state = state.copyWith(isPublic: !state.isPublic);
  }
}

class ScheduleForm {
  TextEditingController scheduleController = TextEditingController();
  TextEditingController dtStartController = TextEditingController();
  TextEditingController timeStartController = TextEditingController();
  TextEditingController dtEndController = TextEditingController();
  TextEditingController timeEndController = TextEditingController();
  TextEditingController tagController = TextEditingController();
  bool isAllDay = false;
  bool isPublic = false;
  TextEditingController publicScheduleController = TextEditingController();

  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();

  ScheduleForm copyWith({
    String? scheduleController,
    String? dtStartController,
    String? timeStartController,
    String? dtEndController,
    String? timeEndController,
    String? tagController,
    bool? isAllDay,
    bool? isPublic,
    String? publicScheduleController,
    String? dateController,
    String? timeController,
  }) {
    return ScheduleForm()
      ..scheduleController.text =
          scheduleController ?? this.scheduleController.text
      ..dtStartController.text =
          dtStartController ?? this.dtStartController.text
      ..timeStartController.text =
          timeStartController ?? this.timeStartController.text
      ..dtEndController.text = dtEndController ?? this.dtEndController.text
      ..timeEndController.text =
          timeEndController ?? this.timeEndController.text
      ..tagController.text = tagController ?? this.tagController.text
      ..isAllDay = isAllDay ?? this.isAllDay
      ..isPublic = isPublic ?? this.isPublic
      ..publicScheduleController.text =
          publicScheduleController ?? this.publicScheduleController.text
      ..dateController.text = dateController ?? this.dateController.text
      ..timeController.text = timeController ?? this.timeController.text;
  }

  void clearContents() {
    scheduleController.clear();
    publicScheduleController.clear();
    dtEndController.clear();
    dtStartController.clear();
    timeStartController.clear();
    timeEndController.clear();
    tagController.clear();
  }

  void clearpublicScheduleController() {
    publicScheduleController.clear();
  }
}

class AddEventButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleForm = ref.watch(scheduleFormProvider);
    return SizedBox(
      child: FloatingActionButton(
        onPressed: () {
          scheduleForm.clearContents();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CalendarInputForm(target:DateTime.now())),
            );
        },
        foregroundColor: Colors.white,
        backgroundColor: ACCENT_COLOR,
        child: const Icon(Icons.add),
      ),
    );
  }
}


class CalendarInputForm extends ConsumerStatefulWidget {
  DateTime target;

  CalendarInputForm({
  required this.target
  });
  // final NotificationAppLaunchDetails? notificationAppLaunchDetails;
  // bool get didNotificationLaunchApp =>
  //     notificationAppLaunchDetails?.didNotificationLaunchApp ?? false;
  @override
  _CalendarInputFormState createState() => _CalendarInputFormState();
}

class _CalendarInputFormState extends ConsumerState<CalendarInputForm> {
  Widget publicScheduleField(ref) {
    final scheduleForm = ref.watch(scheduleFormProvider);
    if (scheduleForm.isPublic == true) {
      return Container(
        width: SizeConfig.blockSizeHorizontal! * 80,
        height: SizeConfig.blockSizeHorizontal! * 8.5,
        child: TextField(
          controller: scheduleForm.publicScheduleController,
          decoration: const InputDecoration(
              border: OutlineInputBorder(), labelText: 'フレンドに見せる予定名'),
        ),
      );
    } else {
      scheduleForm.clearpublicScheduleController();
      return const SizedBox(width: 0, height: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheduleForm = ref.watch(scheduleFormProvider);
    scheduleForm.isAllDay = false;
    return Scaffold(
      appBar:const CustomAppBar(),
      body: 
      Padding(
        padding: const EdgeInsets.only(right:10,left:10),
        child:Column(
        children: [Text(
        '予定を追加…',
        style: TextStyle(
          fontSize: SizeConfig.blockSizeHorizontal! * 7,
          fontWeight: FontWeight.w900,
          ),
        ),
          Container(
            width: SizeConfig.blockSizeHorizontal! * 85,
            height: SizeConfig.blockSizeHorizontal! * 8.5,
            child: TextFormField(
              controller: scheduleForm.scheduleController,
              onFieldSubmitted: (value) {
                ref.read(scheduleFormProvider.notifier).updateDateTimeFields();
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '予定名*',
                labelStyle: TextStyle(color: Colors.red),
              ),
            ),
          ),
          ElevatedButton(
           onPressed: (){
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => TimeInputPage(target:widget.target)),
            );
           },
           style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color?>(ACCENT_COLOR),
              ),
           child: const Text("+ 開始時刻",style:TextStyle(color:Colors.white))
          ),
          SizedBox(
              width: SizeConfig.blockSizeHorizontal! * 80,
              height: SizeConfig.blockSizeHorizontal! * 18,
              child: EasyAutocomplete(
                suggestions: uniqueTitleList,
                inputTextStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  backgroundColor: Colors.blueAccent,
                ),
                controller: scheduleForm.tagController,
                decoration: const InputDecoration(
                    border: InputBorder.none,
                    labelText: 'タグを追加…',
                    labelStyle: TextStyle(
                      color: Colors.blueGrey,
                      backgroundColor: Colors.transparent,
                      fontWeight: FontWeight.w300,
                    )),
              )),
          SizedBox(
              height: SizeConfig.blockSizeHorizontal! * 3,
              width: SizeConfig.blockSizeHorizontal! * 80),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  'フレンドに共有',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(
                    height: SizeConfig.blockSizeHorizontal! * 5,
                    width: SizeConfig.blockSizeHorizontal! * 16),
                CupertinoSwitch(
                    activeColor: ACCENT_COLOR,
                    value: scheduleForm.isPublic,
                    onChanged: (value) {
                      ref.read(scheduleFormProvider.notifier).toggleSwitch();
                      ref
                          .read(scheduleFormProvider.notifier)
                          .updateDateTimeFields();
                    }),
              ],
            ),
          ),
          SizedBox(
            width: SizeConfig.blockSizeHorizontal! * 80,
            height: SizeConfig.blockSizeHorizontal! * 3,
          ),
          publicScheduleField(ref),
          SizedBox(
            width: SizeConfig.blockSizeHorizontal! * 80,
            height: SizeConfig.blockSizeHorizontal! * 8,
          ),
          Row(children: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color?>(ACCENT_COLOR),
              fixedSize: MaterialStateProperty.all<Size>(
                Size(SizeConfig.blockSizeHorizontal! * 45,
                    SizeConfig.blockSizeHorizontal! * 7.5),
              ),
            ),
            child: const Text('戻る', style: TextStyle(color: Colors.white)),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              if (scheduleForm.dtStartController.text.isEmpty ||
                  scheduleForm.scheduleController.text.isEmpty) {
                print("ボタン無効");
              } else {
                if (scheduleForm.dtEndController.text.isEmpty &&
                    scheduleForm.timeEndController.text.isNotEmpty) {
                  print("ボタン無効");
                } else {
                  if (scheduleForm.dtEndController.text.isNotEmpty &&
                      scheduleForm.timeEndController.text.isEmpty) {
                    print("ボタン無効");
                  } else {
                    int intIspublic;
                    if (scheduleForm.isPublic) {
                      intIspublic = 1;
                    } else {
                      intIspublic = 0;
                    }

                    //共有用予定が空だったら、個人用予定と揃える
                    if (scheduleForm.publicScheduleController.text.isEmpty) {
                      scheduleForm.publicScheduleController =
                          scheduleForm.scheduleController;
                    }

                    Map<String, dynamic> schedule = {
                      "subject": scheduleForm.scheduleController.text,
                      "startDate": scheduleForm.dtStartController.text,
                      "startTime": scheduleForm.timeStartController.text,
                      "endDate": scheduleForm.dtStartController.text,
                      "endTime": scheduleForm.timeEndController.text,
                      "isPublic": intIspublic,
                      "publicSubject":
                          scheduleForm.publicScheduleController.text,
                      "tag": scheduleForm.tagController.text
                    };
                    ScheduleDatabaseHelper().resisterScheduleToDB(schedule);
                    ref.read(calendarDataProvider.notifier).state = CalendarData();
                    ref.read(scheduleFormProvider).clearContents();
                    Navigator.of(context).pop();
                  }
                }
              }
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                // 条件によってボタンの色を選択
                if (scheduleForm.dtStartController.text.isEmpty ||
                    scheduleForm.scheduleController.text.isEmpty) {
                  return Colors.grey;
                } else {
                  if (scheduleForm.dtEndController.text.isEmpty &&
                      scheduleForm.timeEndController.text.isNotEmpty) {
                    return Colors.grey;
                  } else {
                    if (scheduleForm.dtEndController.text.isNotEmpty &&
                        scheduleForm.timeEndController.text.isEmpty) {
                      return Colors.grey;
                      // ボタンが無効の場合の色
                    } else {
                      return MAIN_COLOR; // ボタンが通常の場合の色
                    }
                  }
                }
              }),
              fixedSize: MaterialStateProperty.all<Size>(Size(
                SizeConfig.blockSizeHorizontal! * 45,
                SizeConfig.blockSizeHorizontal! * 7.5,
              )),
            ),
            child: const Text('追加', style: TextStyle(color: Colors.white)),
          ),
        ],
       ),
     ]),)
      
    );
  }
}

class DateTimePickerFormField extends ConsumerWidget {
  final TextEditingController dateController;
  final TextEditingController timeController;
  final String dateLabelText;
  final String timeLabelText;

  DateTimePickerFormField({
    required this.dateController,
    required this.timeController,
    required this.dateLabelText,
    required this.timeLabelText,
  });

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  Future<void> _selectDate(BuildContext context, WidgetRef ref) async {
    final scheduleForm = ref.watch(scheduleFormProvider);
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light().copyWith(
              // ヘッダーの色
              primary: MAIN_COLOR,
            ), // 日付選択部の色
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      _selectedDate = pickedDate;
      dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      ref.read(scheduleFormProvider.notifier).updateDateTimeFields();
    }
  }

  Future<void> _selectTime(BuildContext context, WidgetRef ref) async {
    final scheduleForm = ref.watch(scheduleFormProvider);
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 00, minute: 00),
      initialEntryMode: TimePickerEntryMode.input,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      _selectedTime = pickedTime;
      timeController.text = pickedTime.format(context);
      ref.read(scheduleFormProvider.notifier).updateDateTimeFields();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleForm = ref.watch(scheduleFormProvider);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: SizeConfig.blockSizeHorizontal! * 33.5,
          height: SizeConfig.blockSizeHorizontal! * 8.5,
          child: InkWell(
            onTap: () {
              _selectDate(context, ref);
            },
            child: IgnorePointer(
              child: TextFormField(
                controller: dateController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: dateLabelText,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 16),
        Container(
          width: SizeConfig.blockSizeHorizontal! * 33.5,
          height: SizeConfig.blockSizeHorizontal! * 8.5,
          child: InkWell(
            onTap: () {
              _selectTime(context, ref);
            },
            child: IgnorePointer(
              child: TextFormField(
                controller: timeController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: timeLabelText,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
