

import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/assist_files/ui_components.dart';

class ScheduleCandidatesFromGPT {
  late List classCandidateList;

  ScheduleCandidatesFromGPT({
    required this.classCandidateList,
  });

  List<Schedule> convertData(){
    List<Schedule> result = [];
    for(int i = 0; i < classCandidateList.length; i++){
      Map scheduleMap = classCandidateList.elementAt(i);

      result.add(
        Schedule(
          id: i,
          subject: scheduleMap["subject"],
          startDate: scheduleMap["startDate"],
          startTime: scheduleMap["startTime"],
          endTime: scheduleMap["endTime"])
      );

    }
    return result;
  }


Future<void> dialog(BuildContext context) async {
  List<Schedule> scheduleList = convertData();

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: FORGROUND_COLOR,
        title: Text('スケジュール一覧'),
        content: SizedBox(
          width: double.maxFinite, // サイズを調整
          child: ListView.builder(
            itemCount: scheduleList.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              Schedule target = scheduleList.elementAt(index);
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 3),
                decoration: roundedBoxdecoration(radiusType: 2,backgroundColor: BACKGROUND_COLOR),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${target.subject}'),
                    Text('${target.startDate ?? "なし"}'),
                    Text('${target.startTime ?? "なし"}'),
                    Text('${target.endTime ?? "なし"}'),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // ダイアログを閉じる
            },
            child: Text('閉じる'),
          ),
        ],
      );
    },
  );
}

}

class Schedule{
  int? id;
  String subject;
  String? startDate;
  String? startTime;
  String? endDate = "";
  String? endTime;
  int? isPublic = 0;
  String? publicSubject = "";
  String? tag;
  String? tagID;

  Schedule(
    {
      this.id,
      required this.subject,
      required this.startDate,
      required this.startTime,
      this.endDate,
      required this.endTime,
      this.isPublic,
      this.publicSubject,
      this.tag,
      this.tagID,
    }
  );

  Map<String,dynamic> toMap(){
    return {
      "subject": subject,
      "startDate":startDate,
      "startTime":startTime,
      "endDate":endDate,
      "endTime": endTime,
      "isPublic": isPublic,
      "publicSubject": publicSubject,
      "tag": tag,
      "tagID": tagID,
    };
  }

}