import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/calendar_data_manager.dart';
import 'package:flutter_calandar_app/frontend/screens/common/plain_appbar.dart';
import 'package:flutter_calandar_app/frontend/screens/common/logo_and_title.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class CodeSharePage extends ConsumerStatefulWidget {
  late String id;
  late String tagName;
  late List<dynamic> scheduleData;

  CodeSharePage(
      {super.key, required this.id, required this.tagName, required this.scheduleData});

  @override
  CodeSharePageState createState() => CodeSharePageState();
}

class CodeSharePageState extends ConsumerState<CodeSharePage> {
  final ScreenshotController _screenShotController = ScreenshotController();
  late bool isPreview;
  late String targetMonth = "";
  String thisMonth = "${DateTime.now().year}/${DateTime.now().month.toString().padLeft(2, '0')}";
  String today = "${DateTime.now().year}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().day.toString().padLeft(2, '0')}";
  late Color colorTheme;
  late Color backgroundColorTheme;
  late TextEditingController textController;

  @override
  void initState() {
    super.initState();
    isPreview = false;
    targetMonth = thisMonth;
    colorTheme = MAIN_COLOR;
    backgroundColorTheme = Colors.white;
    generateCalendarData();
    ref.read(calendarDataProvider).getDataForShare(widget.scheduleData);
    textController = TextEditingController(text: widget.tagName);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: CustomAppBar(backButton: true),
      body: pageBody(context),
    );
  }

  Widget pageBody(context) {
    return Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
          image: AssetImage('lib/assets/page_background/sky_wallpaper.png'),
          fit: BoxFit.cover,
        )),
        child: Column(children: [
          const Spacer(),
          Center(
              child: Screenshot(
                  controller: _screenShotController, child: switchScreen())),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: shareButton(context),
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: previewButton(),
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: colorPickButton(),
          ),
          const Spacer(),
        ]));
  }

  Widget switchScreen() {
    if (isPreview) {
      return calendarBody();
    } else {
      return qrcodeView();
    }
  }

  Widget qrcodeView() {
    return Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
          image: AssetImage('lib/assets/calendar_background/ookuma_day.png'),
          fit: BoxFit.cover,
        )),
        child: Container(
            width: SizeConfig.blockSizeHorizontal! * 95,
            height: SizeConfig.blockSizeHorizontal! * 95,
            color: backgroundColorTheme.withOpacity(0.6),
            child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.blockSizeHorizontal! * 5),
                child: Column(children: [
                  Row(children: [
                    Text(
                      "わせジュールで",
                      style: TextStyle(
                        fontSize: SizeConfig.blockSizeHorizontal! * 5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                  ]),
                  Row(children: [
                    Expanded(
                      child: TextField(
                        controller: textController,
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(0),
                            hintText: "予定",
                            isCollapsed: true,
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: colorTheme),
                            )),
                      ),
                    ),
                    Text(
                      "を共有中！",
                      style: TextStyle(
                          fontSize: SizeConfig.blockSizeHorizontal! * 5,
                          fontWeight: FontWeight.bold),
                    ),
                  ]),
                  const Spacer(),
                  QrImageView(
                    data: widget.id,
                    version: QrVersions.auto,
                    size: SizeConfig.blockSizeHorizontal! * 55,
                    backgroundColor: Colors.white,
                    eyeStyle: QrEyeStyle(
                        eyeShape: QrEyeShape.square, color: colorTheme),
                    dataModuleStyle: QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: colorTheme),
                  ),
                  const Spacer(),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("スケジュールID:",
                            style: TextStyle(
                                fontSize: SizeConfig.blockSizeHorizontal! * 4)),
                        Text(widget.id,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: SizeConfig.blockSizeHorizontal! * 4,
                                overflow: TextOverflow.clip)),
                        Row(children: [
                          const Spacer(),
                          LogoAndTitle(
                              size: SizeConfig.blockSizeHorizontal! * 1.5),
                        ])
                      ])
                ]))));
  }

  Widget shareButton(BuildContext context) {
    String text = "QRコードをシェア";
    if (isPreview) {
      text = "プレビューをシェア";
    }

    return ElevatedButton(
        style: const ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(MAIN_COLOR),
        ),
        child: Row(children: [
          const Icon(Icons.ios_share, color: Colors.white),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          )
        ]),
        onPressed: () async {
          final screenshot = await _screenShotController.capture(
            delay: const Duration(milliseconds: 0),
          );
          if (screenshot != null) {
            final shareFile = XFile.fromData(screenshot, mimeType: "image/png");

            await Share.shareXFiles([
              shareFile,
            ],
                sharePositionOrigin: Rect.fromLTWH(
                    0,
                    0,
                    MediaQuery.of(context).size.width,
                    MediaQuery.of(context).size.height / 2));
          }
        });
  }

  Widget previewButton() {
    IconData icon = Icons.calendar_month;
    String text = "予定のプレビュー";

    if (isPreview) {
      icon = Icons.qr_code_2;
    }
    if (isPreview) {
      text = "QRコードを表示";
    }

    return ElevatedButton(
        style: const ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(ACCENT_COLOR),
        ),
        child: Row(children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          )
        ]),
        onPressed: () async {
          setState(() {
            if (isPreview) {
              isPreview = false;
            } else {
              isPreview = true;
            }
          });
        });
  }

  Widget colorPickButton() {
    return Row(children: [
      ElevatedButton(
        style: const ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(ACCENT_COLOR)),
        onPressed: () {
          changeColorTheme();
        },
        child: const Text("テーマ色", style: TextStyle(color: Colors.white)),
      ),
      const SizedBox(width: 10),
      ElevatedButton(
        style: const ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(ACCENT_COLOR)),
        onPressed: () {
          changeBackgroundColorTheme();
        },
        child: const Text("背景色", style: TextStyle(color: Colors.white)),
      ),
    ]);
  }

  Widget calendarBody() {
    return Column(children: [
      Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
            image: AssetImage('lib/assets/calendar_background/ookuma_day.png'),
            fit: BoxFit.cover,
          )),
          child: Container(
              width: SizeConfig.blockSizeHorizontal! * 95,
              height: SizeConfig.blockSizeHorizontal! * 95,
              color: backgroundColorTheme.withOpacity(0.8),
              child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.blockSizeHorizontal! * 2.5),
                  child: Column(children: [
                    Row(children: [
                      SizedBox(
                        width: SizeConfig.blockSizeHorizontal! * 3,
                        height: SizeConfig.blockSizeHorizontal! * 10,
                      ),
                      InkWell(
                        onTap: () {
                          decreasePgNumber();
                        },
                        child: Icon(
                          Icons.arrow_back_ios,
                          size: SizeConfig.blockSizeHorizontal! * 3,
                        ),
                      ),
                      SizedBox(
                        width: SizeConfig.blockSizeHorizontal! * 3,
                        height: SizeConfig.blockSizeHorizontal! * 10,
                      ),
                      Text(
                        targetMonth,
                        style: TextStyle(
                          fontSize: SizeConfig.blockSizeHorizontal! * 5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(
                        width: SizeConfig.blockSizeHorizontal! * 3,
                        height: SizeConfig.blockSizeHorizontal! * 10,
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            increasePgNumber();
                          });
                        },
                        child: Icon(Icons.arrow_forward_ios,
                            size: SizeConfig.blockSizeHorizontal! * 3),
                      ),
                      SizedBox(
                        width: SizeConfig.blockSizeHorizontal! * 3,
                        height: SizeConfig.blockSizeHorizontal! * 10,
                      ),
                      Expanded(
                        child: TextField(
                          controller: textController,
                          decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(0),
                              hintText: "予定",
                              isCollapsed: true,
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: colorTheme),
                              )),
                        ),
                      )
                    ]),
                    SizedBox(
                      width: SizeConfig.blockSizeHorizontal! * 100,
                      height: SizeConfig.blockSizeHorizontal! * 3.5,
                      child: generateWeekThumbnail(),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Row(
                          children: [
                            generateCalendarCells("sunday"),
                            generateCalendarCells("monday"),
                            generateCalendarCells("tuesday"),
                            generateCalendarCells("wednesday"),
                            generateCalendarCells("thursday"),
                            generateCalendarCells("friday"),
                            generateCalendarCells("saturday"),
                          ],
                        ),
                      ),
                    ),
                  ]))))
    ]);
  }

  void increasePgNumber() {
    String increasedMonth = "";

    if (targetMonth.substring(5, 7) == "12") {
      int year = int.parse(targetMonth.substring(0, 4));
      year += 1;
      setState(() {
        increasedMonth = "$year/01";
      });
    } else {
      int month = int.parse(targetMonth.substring(5, 7));
      month += 1;
      setState(() {
        increasedMonth =
            targetMonth.substring(0, 5) + month.toString().padLeft(2, '0');
      });
    }

    targetMonth = increasedMonth;
    generateCalendarData();
  }

  void decreasePgNumber() {
    String decreasedMonth = "";

    if (targetMonth.substring(5, 7) == "01") {
      int year = int.parse(targetMonth.substring(0, 4));
      year -= 1;
      setState(() {
        decreasedMonth = "$year/12";
      });
    } else {
      int month = int.parse(targetMonth.substring(5, 7));
      month -= 1;
      setState(() {
        decreasedMonth =
            targetMonth.substring(0, 5) + month.toString().padLeft(2, '0');
      });
    }

    targetMonth = decreasedMonth;
    generateCalendarData();
  }

  Map<String, List<DateTime>> generateCalendarData() {
    DateTime firstDay = DateTime(int.parse(targetMonth.substring(0, 4)),
        int.parse(targetMonth.substring(5, 7)));
    List<DateTime> firstWeek = [];
    ref.read(calendarDataProvider).sortDataByDayForShare();

    List<DateTime> sunDay = [];
    List<DateTime> monDay = [];
    List<DateTime> tuesDay = [];
    List<DateTime> wednesDay = [];
    List<DateTime> thursDay = [];
    List<DateTime> friDay = [];
    List<DateTime> saturDay = [];

    switch (firstDay.weekday) {
      case 1:
        firstWeek = [
          firstDay.subtract(const Duration(days: 1)),
          firstDay,
          firstDay.add(const Duration(days: 1)),
          firstDay.add(const Duration(days: 2)),
          firstDay.add(const Duration(days: 3)),
          firstDay.add(const Duration(days: 4)),
          firstDay.add(const Duration(days: 5)),
        ];
      case 2:
        firstWeek = [
          firstDay.subtract(const Duration(days: 2)),
          firstDay.subtract(const Duration(days: 1)),
          firstDay,
          firstDay.add(const Duration(days: 1)),
          firstDay.add(const Duration(days: 2)),
          firstDay.add(const Duration(days: 3)),
          firstDay.add(const Duration(days: 4)),
        ];
      case 3:
        firstWeek = [
          firstDay.subtract(const Duration(days: 3)),
          firstDay.subtract(const Duration(days: 2)),
          firstDay.subtract(const Duration(days: 1)),
          firstDay,
          firstDay.add(const Duration(days: 1)),
          firstDay.add(const Duration(days: 2)),
          firstDay.add(const Duration(days: 3)),
        ];
      case 4:
        firstWeek = [
          firstDay.subtract(const Duration(days: 4)),
          firstDay.subtract(const Duration(days: 3)),
          firstDay.subtract(const Duration(days: 2)),
          firstDay.subtract(const Duration(days: 1)),
          firstDay,
          firstDay.add(const Duration(days: 1)),
          firstDay.add(const Duration(days: 2)),
        ];
      case 5:
        firstWeek = [
          firstDay.subtract(const Duration(days: 5)),
          firstDay.subtract(const Duration(days: 4)),
          firstDay.subtract(const Duration(days: 3)),
          firstDay.subtract(const Duration(days: 2)),
          firstDay.subtract(const Duration(days: 1)),
          firstDay,
          firstDay.add(const Duration(days: 1)),
        ];
      case 6:
        firstWeek = [
          firstDay.subtract(const Duration(days: 6)),
          firstDay.subtract(const Duration(days: 5)),
          firstDay.subtract(const Duration(days: 4)),
          firstDay.subtract(const Duration(days: 3)),
          firstDay.subtract(const Duration(days: 2)),
          firstDay.subtract(const Duration(days: 1)),
          firstDay,
        ];
      case 7:
        firstWeek = [
          firstDay,
          firstDay.add(const Duration(days: 1)),
          firstDay.add(const Duration(days: 2)),
          firstDay.add(const Duration(days: 3)),
          firstDay.add(const Duration(days: 4)),
          firstDay.add(const Duration(days: 5)),
          firstDay.add(const Duration(days: 6)),
        ];
      default:
        firstWeek = [
          firstDay,
          firstDay.add(const Duration(days: 1)),
          firstDay.add(const Duration(days: 2)),
          firstDay.add(const Duration(days: 3)),
          firstDay.add(const Duration(days: 4)),
          firstDay.add(const Duration(days: 5)),
          firstDay.add(const Duration(days: 6)),
        ];
    }
    sunDay = generateWeek(firstWeek.elementAt(0));
    monDay = generateWeek(firstWeek.elementAt(1));
    tuesDay = generateWeek(firstWeek.elementAt(2));
    wednesDay = generateWeek(firstWeek.elementAt(3));
    thursDay = generateWeek(firstWeek.elementAt(4));
    friDay = generateWeek(firstWeek.elementAt(5));
    saturDay = generateWeek(firstWeek.elementAt(6));

    Map<String, List<DateTime>> result = {
      "sunday": sunDay,
      "monday": monDay,
      "tuesday": tuesDay,
      "wednesday": wednesDay,
      "thursday": thursDay,
      "friday": friDay,
      "saturday": saturDay
    };

    return result;
  }

  Widget generateWeekThumbnail() {
    List<String> days = ["日", "月", "火", "水", "木", "金", "土"];
    return ListView.builder(
      itemBuilder: (context, index) {
        return SizedBox(
            width: SizeConfig.blockSizeHorizontal! * 12.857,
            child: Center(
                child: Text(
              days.elementAt(index),
              style: TextStyle(
                  color: colorTheme,
                  fontSize: SizeConfig.blockSizeHorizontal! * 2.5),
            )));
      },
      itemCount: 7,
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
    );
  }

  List<DateTime> generateWeek(DateTime firstDayOfDay) {
    List<DateTime> result = [
      firstDayOfDay,
      firstDayOfDay.add(const Duration(days: 7)),
      firstDayOfDay.add(const Duration(days: 14)),
      firstDayOfDay.add(const Duration(days: 21)),
      firstDayOfDay.add(const Duration(days: 28)),
      firstDayOfDay.add(const Duration(days: 35))
    ];
    return result;
  }

  Widget generateCalendarCells(String dayOfWeek) {
    return SizedBox(
        width: SizeConfig.blockSizeHorizontal! * 12.857,
        child: ListView.builder(
          itemBuilder: (context, index) {
            DateTime target =
                generateCalendarData()[dayOfWeek]!.elementAt(index);
            return Container(
              width: SizeConfig.blockSizeHorizontal! * 12.857,
              height: SizeConfig.blockSizeHorizontal! * 12.857,
              decoration: BoxDecoration(
                color: cellColour(target),
                border: Border.all(
                  color: colorTheme,
                  width: 0.5,
                ),
              ),
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                Row(children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      target.day.toString(),
                      style: TextStyle(
                        fontSize: SizeConfig.blockSizeHorizontal! * 2,
                      ),
                    ),
                  ),
                  const Spacer(),
                ]),
                Expanded(child: calendarCellsChild(target)),
              ]),
            );
          },
          itemCount: generateCalendarData()[dayOfWeek]!.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
        ));
  }

  Color cellColour(DateTime target) {
    DateTime targetmonthDT = DateTime(int.parse(targetMonth.substring(0, 4)),
        int.parse(targetMonth.substring(5, 7)));
    if (target.month != targetmonthDT.month) {
      return const Color.fromARGB(255, 242, 242, 242);
    } else {
      return Colors.white;
    }
  }

  Widget calendarCellsChild(DateTime target) {
    Widget dateTimeData = Container();
    final data = ref.watch(calendarDataProvider);
    String targetKey = "${target.year}-${target.month.toString().padLeft(2, "0")}-${target.day.toString().padLeft(2, "0")}";
    if (data.sortedDataByDayForShare.keys.contains(targetKey)) {
      List<dynamic> targetDayData = data.sortedDataByDayForShare[targetKey];
      return SizedBox(
          child: ListView.separated(
              itemBuilder: (context, index) {
                if (targetDayData.elementAt(index)["startTime"].trim() != "" &&
                    targetDayData.elementAt(index)["endTime"].trim() != "") {
                  dateTimeData = Text(
                    "${" " +
                        targetDayData.elementAt(index)["startTime"]}～" +
                        targetDayData.elementAt(index)["endTime"],
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: SizeConfig.blockSizeHorizontal! * 1.5,
                        fontWeight: FontWeight.bold),
                  );
                } else if (targetDayData.elementAt(index)["startTime"].trim() !=
                    "") {
                  dateTimeData = Text(
                    " " + targetDayData.elementAt(index)["startTime"],
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: SizeConfig.blockSizeHorizontal! * 1.5,
                        fontWeight: FontWeight.bold),
                  );
                } else {
                  dateTimeData = Container();
                }
                return SizedBox(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                            alignment: Alignment.centerLeft,
                            child: dateTimeData),
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Text(
                                  " " +
                                      targetDayData.elementAt(index)["subject"],
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize:
                                          SizeConfig.blockSizeHorizontal! * 1.5,
                                      fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            ])
                      ]),
                );
              },
              separatorBuilder: (context, index) {
                return const SizedBox();
              },
              itemCount: targetDayData.length,
              shrinkWrap: true,
              physics: const ClampingScrollPhysics()));
    } else {
      return const Center();
    }
  }

  Future<Color?> colorPickerDialogue(Color target) async {
    return showDialog<Color>(
      context: context,
      builder: (BuildContext context) {
        Color selectedColor = target;
        return AlertDialog(
          title: const Text('色を選択...'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: selectedColor,
              onColorChanged: (color) {
                selectedColor = color;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(selectedColor);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void changeColorTheme() async {
    Color? selectedColor = await colorPickerDialogue(colorTheme);
    if (selectedColor != null) {
      setState(() {
        colorTheme = selectedColor;
      });
    }
  }

  void changeBackgroundColorTheme() async {
    Color? selectedColor = await colorPickerDialogue(colorTheme);
    if (selectedColor != null) {
      setState(() {
        backgroundColorTheme = selectedColor;
      });
    }
  }
}
