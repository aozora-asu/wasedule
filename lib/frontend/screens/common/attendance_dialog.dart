import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/handler/my_course_db.dart';
import 'package:flutter_calandar_app/backend/DB/sharepreference.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/assist_files/data_loader.dart';
import 'package:flutter_calandar_app/frontend/assist_files/ui_components.dart';
import 'package:flutter_calandar_app/frontend/screens/timetable_page/timetable_data_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import "../../../static/constant.dart";

Widget showAttendDialogAutomaticallySwitch = const SizedBox();

Future<void> showAttendanceDialog(
    BuildContext context, DateTime targetDate, WidgetRef ref,
    [bool enforceShowing = false]) async {
  bool isShowDialog = true;
  bool showAttendDialogAutomatically = await SharepreferenceHandler()
      .getValue(SharepreferenceKeys.showAttendDialogAutomatically);

  await ref
      .read(timeTableProvider)
      .getData(TimeTableDataLoader().getTimeTableDataSource());

  List data = ref.read(timeTableProvider).targetDateClasses(targetDate);

  int numOfNotEmptyData = 0;

  for (var classMap in data) {
    int myCourseId = classMap["id"];
    String date = DateFormat("MM/dd").format(targetDate);
    Map<String, dynamic>? attendStatusData =
        await MyCourseDatabaseHandler().getAttendStatus(myCourseId, date);
    if (attendStatusData != null) {
      numOfNotEmptyData += 1;
    }
  }

  if (numOfNotEmptyData == data.length) {
    isShowDialog = false;
  }

  if (data.isEmpty) {
    isShowDialog = false;
  }

  if (!showAttendDialogAutomatically) {
    isShowDialog = false;
  }

  if (enforceShowing) {
    isShowDialog = true;
  }

  if (isShowDialog) {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AttendanceDialog(
          targetDate: targetDate,
          showAutomatically: showAttendDialogAutomatically,
          enforceShowing: enforceShowing,
        );
      },
    );
  }
}

class AttendanceDialog extends ConsumerStatefulWidget {
  DateTime targetDate;
  bool enforceShowing;
  bool showAutomatically;
  AttendanceDialog(
      {required this.targetDate,
      required this.enforceShowing,
      required this.showAutomatically});
  @override
  _AttendanceDialogState createState() => _AttendanceDialogState();
}

class _AttendanceDialogState extends ConsumerState<AttendanceDialog> {
  late bool dontShowAutomatically;

  @override
  void initState() {
    super.initState();
    if (widget.showAutomatically) {
      dontShowAutomatically = false;
    } else {
      dontShowAutomatically = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enforceShowing) {
      {
        showAttendDialogAutomaticallySwitch = Row(children: [
          const Text("以降自動的に表示しない：", style: TextStyle(color: Colors.grey)),
          CupertinoCheckbox(
              value: dontShowAutomatically,
              onChanged: (value) async {
                SharepreferenceHandler().setValue(
                    SharepreferenceKeys.showAttendDialogAutomatically,
                    dontShowAutomatically);
                dontShowAutomatically = value!;
                setState(() {});
                if (dontShowAutomatically) {
                  showAutoshowTurnedOffDialog(context);
                }
              })
        ]);
      }
    } else {
      showAttendDialogAutomaticallySwitch = const SizedBox();
    }
    return Column(children: [
      const Spacer(),
      Container(
          width: 800,
          decoration: roundedBoxdecoration(),
          margin: const EdgeInsets.symmetric(horizontal: 10),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          child: Material(child: buildMainBody())),
      const Spacer(),
    ]);
  }

  void showAutoshowTurnedOffDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('出欠記録の自動表示がオフになりました。'),
          content: const Text('設定ページ「時間割」の項目から再度オンにしていただくことができます。'),
          actions: [
            TextButton(
              child: const Text('閉じる'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Map<int, String> enteredData = {};
  Map<int, int> remainingNumData = {};

  bool isInit = true;

  Future<void> initClassData(List data) async {
    if (isInit) {
      enteredData = {};
      remainingNumData = {};

      for (int i = 0; i < data.length; i++) {
        int id = data[i]["id"];
        String date = DateFormat("MM/dd").format(widget.targetDate);
        Map<String, dynamic>? attendStatusData =
            await MyCourseDatabaseHandler().getAttendStatus(id, date);

        if (attendStatusData != null) {
          enteredData[id] = attendStatusData["attendStatus"];
        } else {
          enteredData[id] = "attend";
        }

        int currentAbsentNum = await MyCourseDatabaseHandler()
            .getAttendStatusCount(id, AttendStatus.absent);
        int remainAbsent = data.elementAt(i)["remainAbsent"] ?? 0;
        int remainingNum = remainAbsent - currentAbsentNum;
        if (remainingNum <= 0) {
          remainingNum = 0;
        }

        remainingNumData[data.elementAt(i)["id"]] = remainingNum;
      }
      isInit = false;
    }
  }

  Widget buildMainBody() {
    List data =
        ref.read(timeTableProvider).targetDateClasses(widget.targetDate);
    if (data.isEmpty) {
      return const SizedBox(
          height: 60,
          child: Center(
              child: Text(
            "この日の授業はありません。",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          )));
    } else {
      return FutureBuilder(
          future: initClassData(data),
          builder: (context, snapShot) {
            if (snapShot.connectionState == ConnectionState.done) {
              return mainBody(data);
            } else {
              if (!isInit) {
                return mainBody(data);
              } else {
                return const SizedBox();
              }
            }
          });
    }
  }

  Widget mainBody(data) {
    String dateText = DateFormat("M月d日(E)", 'ja_JP').format(widget.targetDate);

    DateTime now = DateTime.now();
    if (widget.targetDate.year == now.year &&
        widget.targetDate.month == now.month &&
        widget.targetDate.day == now.day) {
      dateText = "今日";
    }

    return Column(children: [
      Text(dateText + "の出席記録",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
      const SizedBox(height: 10),
      ListView.builder(
        itemBuilder: (context, index) {
          return classObject(
              data.elementAt(index), enteredData[data.elementAt(index)["id"]]!,
              (value) {
            enteredData[data.elementAt(index)["id"]] = value;
            setState(() {});
          }, remainingNumData[data.elementAt(index)["id"]]!);
        },
        itemCount: data.length,
        shrinkWrap: true,
      ),
      const SizedBox(height: 5),
      showAttendDialogAutomaticallySwitch,
      const SizedBox(height: 10),
      Row(children: [
        const Spacer(),
        buttonModel(() async {
          for (int i = 0; i < enteredData.length; i++) {
            await MyCourseDatabaseHandler().recordAttendStatus(AttendanceRecord(
                attendDate: DateFormat("MM/dd").format(widget.targetDate),
                attendStatus:
                    AttendStatus.values[enteredData.values.elementAt(i)]!,
                myCourseID: enteredData.keys.elementAt(i)));
          }
          Navigator.pop(context);
        }, Colors.blue, "記録する", horizontalPadding: 50)
      ])
    ]);
  }

  Widget classObject(Map data, String selectedStatus, Function(String) onTap,
      int remainCount) {
    Color attendColor = selectedStatus == AttendStatus.attend.value
        ? AttendStatus.values[selectedStatus]!.color
        : Colors.grey;
    Color lateColor = selectedStatus == AttendStatus.late.value
        ? AttendStatus.values[selectedStatus]!.color
        : Colors.grey;
    Color absentColor = selectedStatus == AttendStatus.absent.value
        ? AttendStatus.values[selectedStatus]!.color
        : Colors.grey;

    return Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
        decoration: BoxDecoration(
            color: BACKGROUND_COLOR, borderRadius: BorderRadius.circular(5)),
        child: Row(children: [
          Expanded(
              child: Text(data["courseName"],
                  style: const TextStyle(fontWeight: FontWeight.bold))),
          const Text(
            "残\n機 ",
            style: TextStyle(color: Colors.grey, fontSize: 12.5),
          ),
          const Icon(Icons.favorite, color: Colors.redAccent, size: 20),
          Text(remainCount.toString(),
              style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 20)),
          const SizedBox(width: 5),
          buttonModel(() {
            setState(() {
              onTap("attend");
            });
          }, attendColor, "出", horizontalPadding: 10),
          buttonModel(() {
            setState(() {
              onTap("late");
            });
          }, lateColor, "遅", horizontalPadding: 10),
          buttonModel(() {
            setState(() {
              onTap("absent");
            });
          }, absentColor, "欠", horizontalPadding: 10),
        ]));
  }
}

Future<bool> showIndividualCourseEditDialog(
    context, Map myCourseData, Function onDone,
    {Map? initData}) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return Column(children: [
        const Spacer(),
        IndividualCourseEditDialog(
          initData: initData,
          myCourseData: myCourseData,
          onDone: onDone,
        ),
        const Spacer()
      ]);
    },
  );
  return true;
}

class IndividualCourseEditDialog extends StatefulWidget {
  late Map myCourseData;
  late Map? initData;
  late Function onDone;
  IndividualCourseEditDialog({
    required this.initData,
    required this.myCourseData,
    required this.onDone,
  });
  @override
  _IndividualCourseEditDialogState createState() =>
      _IndividualCourseEditDialogState();
}

class _IndividualCourseEditDialogState
    extends State<IndividualCourseEditDialog> {
  String dateString = DateFormat("MM/dd").format(DateTime.now());
  String attendStatus = "attend";
  String buttonText = "追加";
  bool isInit = true;

  void initDialogData() {
    if (widget.initData != null && isInit) {
      dateString = widget.initData!["attendDate"];
      attendStatus = widget.initData!["attendStatus"];
      buttonText = "変更";
      isInit = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    initDialogData();

    EdgeInsets containerPadding =
        const EdgeInsets.symmetric(vertical: 2, horizontal: 5);
    BoxDecoration containerDecoration = BoxDecoration(
      color: BACKGROUND_COLOR,
      border: Border.all(color: Colors.black),
      borderRadius: BorderRadius.circular(5),
    );

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: roundedBoxdecoration(),
      child: Column(children: [
        Text(widget.myCourseData["courseName"] + " の出欠記録",
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                overflow: TextOverflow.clip,
                fontSize: 22.5)),
        Row(children: [
          const Text("日付",
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey,
              )),
          const Spacer(),
          GestureDetector(
              onTap: () async {
                await selectDate(context);
              },
              child: Container(
                width: 150,
                padding: containerPadding,
                decoration: containerDecoration,
                child: Text(
                  dateString,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ))
        ]),
        Row(children: [
          const Text("ステータス",
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey,
              )),
          const Spacer(),
          Material(
            child: SizedBox(
              width: 150,
              child: DropdownButtonFormField(
                value: attendStatus,
                decoration: const InputDecoration.collapsed(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "ステータス",
                    border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: "attend", child: Text("  出席")),
                  DropdownMenuItem(value: "late", child: Text("  遅刻")),
                  DropdownMenuItem(value: "absent", child: Text("  欠席")),
                ],
                onChanged: (value) {
                  setState(() {
                    attendStatus = value!;
                  });
                },
              ),
            ),
          ),
        ]),
        const SizedBox(height: 5),
        Row(children: [
          const Spacer(),
          buttonModel(() async {
            await MyCourseDatabaseHandler().recordAttendStatus(AttendanceRecord(
                attendDate: dateString,
                attendStatus: AttendStatus.values[attendStatus]!,
                myCourseID: widget.myCourseData["id"]));
            widget.onDone();
            Navigator.pop(context);
          }, Colors.blue, buttonText, verticalpadding: 5, horizontalPadding: 40)
        ])
      ]),
    );
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(
          widget.myCourseData["year"],
          int.parse(dateString.substring(0, 2)),
          int.parse(dateString.substring(3, 5))),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        dateString = DateFormat("MM/dd").format(picked);
      });
    }
  }
}
