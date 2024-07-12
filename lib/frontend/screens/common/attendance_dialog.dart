import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/ui_components.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void showAttendanceDialog(BuildContext context) {
  bool isShowDialog = false;
  if(isShowDialog){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AttendanceDialog();
        },
      );
    }
  }

class AttendanceDialog extends ConsumerStatefulWidget {
  @override
  _AttendanceDialogState createState() => _AttendanceDialogState();
}

class _AttendanceDialogState extends ConsumerState<AttendanceDialog> {

  @override
  Widget build(BuildContext context) {
    return Column(children:[
      const Spacer(),
      Container(
        width: 800,
        decoration: roundedBoxdecorationWithShadow(),
        margin:const EdgeInsets.symmetric(horizontal:10),
        padding:const EdgeInsets.all(10),
        child: Material(
        child:Column(children:[
          const Text("今日の出席記録",
            style: TextStyle(
              fontWeight:FontWeight.bold,
              fontSize: 25
              )),
          
        ])
      )
    ),
    const Spacer(),
    ]);
  }
}