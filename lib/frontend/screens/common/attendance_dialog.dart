import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/handler/my_course_db.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/assist_files/data_loader.dart';
import 'package:flutter_calandar_app/frontend/assist_files/ui_components.dart';
import 'package:flutter_calandar_app/frontend/screens/timetable_page/timetable_data_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import "../../../constant.dart";

Future<void> showAttendanceDialog(
    BuildContext context, DateTime targetDate, WidgetRef ref) async {
  bool isShowDialog = true;

  await ref
      .read(timeTableProvider)
      .getData(TimeTableDataLoader().getTimeTableDataSource());

  List data = ref.read(timeTableProvider).targetDateClasses(targetDate);

  int numOfNotEmptyData = 0;

  for (int i = 0; i < data.length; i++) {
    int myCourseId = data.elementAt(i)["id"];
  }

  if (numOfNotEmptyData == data.length) {
    isShowDialog = false;
  }

  if (data.isEmpty) {
    isShowDialog = false;
  }

  if (isShowDialog) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AttendanceDialog(targetDate: targetDate);
      },
    );
  }
}

class AttendanceDialog extends ConsumerStatefulWidget {
  DateTime targetDate;
  AttendanceDialog({required this.targetDate});
  @override
  _AttendanceDialogState createState() => _AttendanceDialogState();
}

class _AttendanceDialogState extends ConsumerState<AttendanceDialog> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Spacer(),
      Container(
          width: 800,
          decoration: roundedBoxdecorationWithShadow(),
          margin: const EdgeInsets.symmetric(horizontal: 10),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          child: Material(child: buildMainBody())),
      const Spacer(),
    ]);
  }

  Map<int, String> enteredData = {};
  Map<int, int> remainingNumData = {};

  bool isInit = true;

  Future<void> initClassData(List data) async {
    if (isInit) {
      enteredData = {};
      remainingNumData = {};

      for(int i = 0; i < data.length; i++){
        int id = data[i]["id"];
        String date = DateFormat("MM/dd").format(widget.targetDate);
        Map<String, dynamic>? attendStatusData
          = await MyCourseDatabaseHandler().getAttendStatus(id, date);
        print(attendStatusData);
        
        if(attendStatusData != null){
          enteredData[id] = attendStatusData["attendStatus"];
        }else{
          enteredData[id] = "attend";
        }

        remainingNumData[data.elementAt(i)["id"]]
         = data.elementAt(i)["remainAbsent"] ?? 0;

      }
      isInit = false;

    }
  }

  Widget buildMainBody() {
    List data =
        ref.read(timeTableProvider).targetDateClasses(widget.targetDate);

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
            data.elementAt(index),
            enteredData[data.elementAt(index)["id"]]!,
            (value){
              enteredData[data.elementAt(index)["id"]] = value;
              setState(() {
                
              });
            },remainingNumData[data.elementAt(index)["id"]]!
            );

        },
        itemCount: data.length,
        shrinkWrap: true,
      ),
      const SizedBox(height: 10),
      Row(children: [
        const Spacer(),
        buttonModel(() async {
          for (int i = 0; i < enteredData.length; i++) {
            await MyCourseDatabaseHandler().recordAttendStatus(AttendanceRecord(
                attendDate: DateFormat("M/d").format(widget.targetDate),
                attendStatus:
                    AttendStatus.values.byName(enteredData.values.elementAt(i)),
                myCourseID: enteredData.keys.elementAt(i)));
          }
          Navigator.pop(context);
        }, Colors.blue, "記録", horizontalPadding: 50)
      ])
    ]);
  }

  Widget classObject(Map data, String selectedStatus, Function(String) onTap,
      int remainCount) {
    Color attendColor = Colors.grey;
    Color lateColor = Colors.grey;
    Color absentColor = Colors.grey;
    if (selectedStatus == "attend") {
      attendColor = Colors.blueAccent;
    } else if (selectedStatus == "late") {
      lateColor = const Color.fromARGB(255, 223, 200, 0);
    } else if (selectedStatus == "absent") {
      absentColor = Colors.redAccent;
    }

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
