import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/screens/common/date_picker.dart';
import 'package:flutter_calandar_app/frontend/screens/common/ui_components.dart';
import 'package:intl/intl.dart';
import 'package:nholiday_jp/nholiday_jp.dart' as holiday_jp;
import 'package:table_calendar/table_calendar.dart';


class ScheduleController {
  late DateTime? startDate;
  late DateTime? startTime;
  late DateTime? endDate;
  late DateTime? endTime;

  ScheduleController({
    this.startDate,
    this.startTime,
    this.endDate,
    this.endTime,
  });

  DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  DateFormat timeFormat = DateFormat("hh:mm");
  DateTime now = DateTime.now();

  void setInitDateTimeFromString(String? startDateStr,String? startTimeStr,String? endDateStr, String? endTimeStr){

    if(startDateStr != null){
      startDate = dateFormat.tryParse(startDateStr);
    }

    if(startTimeStr != null){
      startTime = timeFormat.tryParse(startTimeStr);
    }

    if(endDateStr != null){
      endDate = dateFormat.tryParse(endDateStr);
    }

    if(endTimeStr != null){
      endTime = timeFormat.tryParse(endTimeStr);
    }
  }



  Future<void> showDatePickerModal(BuildContext context,
  {bool showStartDate = true, bool showStartTime= true, bool showEndDate = true,bool showEndTime = true}) async{
  
    await showModalBottomSheet(
      context: context,
      backgroundColor: FORGROUND_COLOR,
      isDismissible: true,
      isScrollControlled: true,
      builder: (context) {

        return SizedBox(
          width: double.maxFinite, // サイズを調整
          child: DatePickerBottomSheet(
            pickerTitle: "日付を選択",
            containTime: false,
            initDateTime: startDate,
            onSelected: (dateTime){
              startDate = dateTime;
          })
        );
      },
    );
  }


  DateTimePickerResultString valueString(){
    String? startDateStr;
    String? startTimeStr;
    String? endDateStr;
    String? endTimeStr;

    if(startDate != null){
      startDateStr = dateFormat.format(startDate!);
    }

    if(startTime != null){
      startTimeStr = timeFormat.format(startTime!);
    }

    if(endDate != null){
      endDateStr = dateFormat.format(endDate!);
    }

    if(endTime != null){
      endTimeStr = timeFormat.format(endTime!);
    }
    return DateTimePickerResultString(
      startDate: startDateStr ?? "",
      startTime: startTimeStr ?? "",
      endDate: endDateStr ?? "",
      endTime: endTimeStr ?? "",
    );
  }

  DateTimePickerResult value(){
    return DateTimePickerResult(
      startDate: startDate,
      startTime: startTime,
      endDate: endDate,
      endTime: endTime,
    );
  }

}

class DateTimePickerResultString{
  late String? startDate;
  late String? startTime;
  late String? endDate;
  late String? endTime;

  DateTimePickerResultString({
    this.startDate,
    this.startTime,
    this.endDate,
    this.endTime,
  });
}

class DateTimePickerResult{
  late DateTime? startDate;
  late DateTime? startTime;
  late DateTime? endDate;
  late DateTime? endTime;

  DateTimePickerResult({
    this.startDate,
    this.startTime,
    this.endDate,
    this.endTime,
  });
}