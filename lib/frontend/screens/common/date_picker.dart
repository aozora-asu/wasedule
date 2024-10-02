import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:holiday_jp/holiday_jp.dart' as holiday_jp;
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;

class DatePickerBottomSheet extends StatefulWidget {
  final Function(DateTime) onSelected;
  final String pickerTitle;
  late bool containTime;
  late DateTime? initDateTime;

  DatePickerBottomSheet({
    super.key,
    required this.pickerTitle,
    required this.onSelected,
    required this.containTime,
    this.initDateTime,
  });

  @override
  _DatePickerBottomSheetState createState() => _DatePickerBottomSheetState();
}

class _DatePickerBottomSheetState extends State<DatePickerBottomSheet> {
  DateTime _selectedDay = DateTime.now();
  DateTime? _selectedTime;

  DateTime _currentDay = DateTime.now();
  final selectedDays = <DateTime>[];

  @override
  void initState(){
    _selectedDay =  widget.initDateTime ?? DateTime.now();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(16),
      height: 590,
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: Text(
              widget.pickerTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          const Divider(
            height: 1,
          ),
          Expanded(
            child: TableCalendar(
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2100, 3, 14),
              locale: "ja",
              focusedDay: _selectedDay,
              currentDay: _currentDay,
              headerStyle: _buildHeaderStyle(),
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: _onDaySelected,
              calendarBuilders: CalendarBuilders(
                dowBuilder: _dowBuilder,
                defaultBuilder: _defaultDayBuilder,
              ),
              calendarFormat: CalendarFormat.month,
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                todayDecoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                weekendDecoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

        if(widget.containTime)
          TextButton(
            onPressed: () {
              picker.DatePicker.showTimePicker(context,
                  showTitleActions: true,
                  showSecondsColumn: false, onConfirm: (date) {
                setState(() {
                  _selectedTime = date;
                });
              },
                  currentTime: DateTime.now()
              );
            },
            child: Row(
                mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Icon(Icons.access_time_filled_sharp),
                  SizedBox(width: 20),
                  _selectedTime != null
                      ? Text(
                          DateFormat("H:mm").format(_selectedTime!),
                          style:
                              const TextStyle(fontSize: 20, color: Colors.blue),
                        )
                      : Text(
                          "時間を選択",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              color: Colors.blue),
                        ),


                ]),
          ),
          Align(
            alignment: Alignment.topRight,
            child: ElevatedButton(
              onPressed: () {
                if (_selectedTime != null) {
                  final DateTime selectedDateTime = DateTime(
                    _selectedDay.year,
                    _selectedDay.month,
                    _selectedDay.day,
                    _selectedTime!.hour,
                    _selectedTime!.minute,
                  );
                  widget.onSelected(selectedDateTime);
                  Navigator.of(context).pop();

                } else {

                  final DateTime selectedDateTime = DateTime(
                    _selectedDay.year,
                    _selectedDay.month,
                    _selectedDay.day,
                    0,
                    0,
                  );
                  widget.onSelected(selectedDateTime);
                  Navigator.of(context).pop();
                }

              },
              child: Text(
                "完了"
              ),
            ),
          ),
          const SizedBox(
            height: 40,
          ),
        ],
      ),
    );
  }

  HeaderStyle _buildHeaderStyle() {
    return HeaderStyle(
      titleTextFormatter: (date, locale) =>
          DateFormat.yMMMM(locale).format(date),
      formatButtonVisible: false,
      leftChevronIcon: const Icon(Icons.arrow_back_ios),
      rightChevronIcon: const Icon(Icons.arrow_forward_ios),
      titleTextStyle: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
      rightChevronMargin: EdgeInsets.all(0.0),
      rightChevronPadding: EdgeInsets.all(0.0),
      leftChevronMargin: EdgeInsets.all(0.0),
      leftChevronPadding: EdgeInsets.all(0.0),
    );
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _currentDay = selectedDay;
      _selectedDay = selectedDay;
      if (selectedDays.contains(selectedDay)) {
        selectedDays.remove(selectedDay);
      } else {
        selectedDays.add(selectedDay);
      }
    });
  }

  Widget _dowBuilder(BuildContext context, DateTime day) {
    final text = DateFormat.E().format(day);
    return Center(
      child: Text(
        text,
        style: TextStyle(
          color: _getDayTextColor(day),
        ),
      ),
    );
  }

  Color _getDayTextColor(DateTime day) {
    if (day.weekday == DateTime.sunday || holiday_jp.isHoliday(day)) {
      return Colors.red;
    }

    if (day.weekday == DateTime.saturday) return Colors.blue;
    return Theme.of(context).colorScheme.onSurface;
  }

  Widget _defaultDayBuilder(
      BuildContext context, DateTime day, DateTime focusedDay) {
    return Container(
      decoration: _getDayDecoration(day),
      child: Center(
        child: Text(
          '${day.day}',
          style: _getDayTextStyle(day),
        ),
      ),
    );
  }

  BoxDecoration _getDayDecoration(DateTime day) {
    if (day.weekday == DateTime.sunday) {
      return _buildSpecialDecoration(Colors.red[100]!.withOpacity(0.8), day);
    }
    if (holiday_jp.isHoliday(day)) {
      return _buildHolidayDecoration(day);
    }
    if (day.weekday == DateTime.saturday) {
      return _buildSpecialDecoration(Colors.blue[100]!.withOpacity(0.8), day);
    }

    return const BoxDecoration();
  }

  BoxDecoration _buildSpecialDecoration(Color? backgroundColor, DateTime day) {
    bool isFirst = _isFirstWeekOfMonth(day);
    bool isLast = _isLastWeekOfMonth(day);

    BorderRadius borderRadius = _getDefaultBorderRadius(day, isFirst, isLast);

    DateTime leftDay = day.subtract(const Duration(days: 1));
    DateTime rightDay = day.add(const Duration(days: 1));

    if (_isBlocked(leftDay) && day.weekday == DateTime.saturday) {
      borderRadius = borderRadius.copyWith(
        topLeft: Radius.zero,
        bottomLeft: Radius.zero,
      );
    }
    if (_isBlocked(rightDay) && day.weekday == DateTime.sunday) {
      borderRadius = borderRadius.copyWith(
        topRight: Radius.zero,
        bottomRight: Radius.zero,
      );
    }

    return BoxDecoration(
      color: backgroundColor,
      shape: BoxShape.rectangle,
      borderRadius: borderRadius,
    );
  }

  bool _isFirstWeekOfMonth(DateTime day) {
    return day.isAtSameMomentAs(_getFirstSundayUtc(day.year, day.month)) ||
        day.isAtSameMomentAs(_getFirstSaturdayUtc(day.year, day.month));
  }

  bool _isLastWeekOfMonth(DateTime day) {
    return day.isAtSameMomentAs(_getLastSundayUtc(day.year, day.month)) ||
        day.isAtSameMomentAs(_getLastSaturdayUtc(day.year, day.month));
  }

  BorderRadius _getDefaultBorderRadius(
      DateTime day, bool isFirst, bool isLast) {
    if (day.weekday == DateTime.sunday) {
      return isFirst
          ? const BorderRadius.only(
              topRight: Radius.circular(15), topLeft: Radius.circular(15))
          : isLast
              ? const BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15))
              : BorderRadius.zero;
    }
    if (day.weekday == DateTime.saturday) {
      return isFirst
          ? const BorderRadius.only(
              topRight: Radius.circular(15), topLeft: Radius.circular(15))
          : isLast
              ? const BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15))
              : BorderRadius.zero;
    }
    return BorderRadius.zero;
  }

  bool _isBlocked(DateTime datetime) {
    return holiday_jp.isHoliday(datetime) ||
        datetime.weekday == DateTime.saturday ||
        datetime.weekday == DateTime.sunday;
  }

  BoxDecoration _buildHolidayDecoration(DateTime day) {
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(15));
    DateTime leftDay = day.subtract(const Duration(days: 1));
    DateTime topDay = day.subtract(const Duration(days: 7));
    DateTime rightDay = day.add(const Duration(days: 1));
    DateTime bottomDay = day.add(const Duration(days: 7));
    bool isFirst = _isFirstWeekOfMonth(day);
    bool isLast = _isLastWeekOfMonth(day);

    if (_isBlocked(leftDay)) {
      borderRadius = borderRadius.copyWith(
        topLeft: Radius.zero,
        bottomLeft: Radius.zero,
      );
    }
    if (_isBlocked(topDay)) {
      borderRadius = borderRadius.copyWith(
        topLeft: Radius.zero,
        topRight: Radius.zero,
      );
    }
    if (_isBlocked(rightDay)) {
      borderRadius = borderRadius.copyWith(
        topRight: Radius.zero,
        bottomRight: Radius.zero,
      );
    }
    if (_isBlocked(bottomDay)) {
      borderRadius = borderRadius.copyWith(
        bottomLeft: Radius.zero,
        bottomRight: Radius.zero,
      );
    }
    if (isFirst) {
      borderRadius = borderRadius.copyWith(
        topLeft: const Radius.circular(15),
        topRight: const Radius.circular(15),
      );
    }
    if (isLast) {
      borderRadius = borderRadius.copyWith(
        bottomRight: const Radius.circular(15),
        bottomLeft: const Radius.circular(15),
      );
    }
    return BoxDecoration(
      color: Colors.red[100]!.withOpacity(0.8),
      shape: BoxShape.rectangle,
      borderRadius: borderRadius,
    );
  }

  TextStyle _getDayTextStyle(DateTime day) {
    if (day.weekday == DateTime.sunday || holiday_jp.isHoliday(day)) {
      return const TextStyle(color: Colors.red, fontSize: 16);
    }
    if (day.weekday == DateTime.saturday) {
      return const TextStyle(color: Colors.blue, fontSize: 16);
    }
    return const TextStyle(fontSize: 16);
  }

  DateTime _getFirstSundayUtc(int year, int month) =>
      _getFirstDayOfWeekUtc(year, month, DateTime.sunday);

  DateTime _getLastSundayUtc(int year, int month) =>
      _getLastDayOfWeekUtc(year, month, DateTime.sunday);

  DateTime _getFirstSaturdayUtc(int year, int month) =>
      _getFirstDayOfWeekUtc(year, month, DateTime.saturday);

  DateTime _getLastSaturdayUtc(int year, int month) =>
      _getLastDayOfWeekUtc(year, month, DateTime.saturday);

  DateTime _getFirstDayOfWeekUtc(int year, int month, int weekday) {
    DateTime firstDayOfMonth = DateTime.utc(year, month, 1);
    int weekdayOffset = (weekday - firstDayOfMonth.weekday + 7) % 7;
    return firstDayOfMonth.add(Duration(days: weekdayOffset));
  }

  DateTime _getLastDayOfWeekUtc(int year, int month, int weekday) {
    DateTime firstDayOfNextMonth = month == 12
        ? DateTime.utc(year + 1, 1, 1)
        : DateTime.utc(year, month + 1, 1);
    DateTime lastDayOfMonth =
        firstDayOfNextMonth.subtract(const Duration(days: 1));
    int weekdayOffset = (lastDayOfMonth.weekday - weekday + 7) % 7;
    return lastDayOfMonth.subtract(Duration(days: weekdayOffset));
  }
}
