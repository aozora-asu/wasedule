import 'dart:math';

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/firebase/firebase_handler.dart';
import 'package:flutter_calandar_app/frontend/assist_files/ui_components.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/add_event_button.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/calendar_data_manager.dart';
import 'package:flutter_calandar_app/frontend/screens/setting_page/support_page.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/task_data_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../assist_files/colors.dart';
import '../../assist_files/size_config.dart';

class UnivSchedulePage extends ConsumerStatefulWidget {
  const UnivSchedulePage({super.key});

  @override
  _UnivSchedulePageState createState() => _UnivSchedulePageState();
}

class _UnivSchedulePageState extends ConsumerState<UnivSchedulePage> {
  late int currentIndex;
  List<Map<String, dynamic>> shareScheduleList = [];

  @override
  void initState() {
    super.initState();
    currentIndex = 0;
    ref.read(scheduleFormProvider).clearContents();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        backgroundColor: BACKGROUND_COLOR,
        // appBar: AppBar(
        //   leading: const BackButton(color: WHITE),
        //   backgroundColor: MAIN_COLOR,
        //   elevation: 10,
        //   title: Column(
        //     children: <Widget>[
        //       Row(children: [
        //         const Icon(
        //           Icons.school,
        //           color: WIDGET_COLOR,
        //         ),
        //         SizedBox(
        //           width: SizeConfig.blockSizeHorizontal! * 4,
        //         ),
        //         Text(
        //           '年間行事予定',
        //           style: TextStyle(
        //               fontSize: SizeConfig.blockSizeHorizontal! * 5,
        //               fontWeight: FontWeight.w800,
        //               color: WHITE),
        //         ),
        //       ])
        //     ],
        //   ),
        // ),
        body: SingleChildScrollView(
            child: Center(
                child: Column(children: [
          SizedBox(
            height: SizeConfig.blockSizeHorizontal! * 80,
            child: thumbnailImage(),
          ),
          Container(
              width: SizeConfig.blockSizeHorizontal! * 100,
              decoration: roundedBoxdecorationWithShadow(radiusType: 1),
              child: Column(children: [pageBody()]))
        ]))));
  }

  Image thumbnailImage() {
    return Image.asset(
      'lib/assets/eye_catch/eyecatch.png',
      height: SizeConfig.blockSizeHorizontal! * 60,
      width: SizeConfig.blockSizeHorizontal! * 60,
    );
  }

  Widget pageBody() {
    return scheduleBroadcastPage();
  }

  TextEditingController idController = TextEditingController();
  Widget scheduleBroadcastPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("・早稲田大学の年間行事予定をダウンロードし、カレンダーに追加できます。",
              style: TextStyle(fontSize: 17)),
          const SizedBox(height: 20),
          downloadUniversityScheduleButton(),
          const SizedBox(height: 5),
          chooseDepartmentButton(),
          const SizedBox(height: 10),
          const Divider(
            thickness: 2,
          ),
          const SizedBox(height: 10),
          const Text("【免責事項】", style: TextStyle(fontSize: 17)),
          const Text("大学の予定は予期せず変更される場合があります。最新情報は以下のリンクから公式サイトにてお確かめください。",
              style: TextStyle(fontSize: 17)),
          const SizedBox(height: 20),
          ExpandablePanel(
              header: const Row(children: [
                Icon(Icons.link, color: Colors.blue),
                Text("リンク集")
              ]),
              collapsed: Container(),
              expanded: urlList())
        ],
      ),
    );
  }

  Widget downloadUniversityScheduleButton() {
    return SizedBox(
        width: 90000,
        child: buttonModelWithChild(() async {
          showDownloadConfirmDialogue("大学全体", "all_depertment");
        },
            MAIN_COLOR,
            Row(children: [
              const Spacer(),
              Icon(Icons.downloading_outlined, color: FORGROUND_COLOR),
              const SizedBox(width: 30),
              Text(
                "大学年間行事予定",
                style: TextStyle(color: FORGROUND_COLOR),
              ),
              const Spacer()
            ]),
            verticalpadding: 10));
  }

  Widget chooseDepartmentButton() {
    return SizedBox(
        width: 90000,
        child: buttonModelWithChild(() {
          showChooseDepartmentDialogue();
        },
            PALE_MAIN_COLOR,
            Row(children: [
              const Spacer(),
              Icon(Icons.downloading_outlined, color: FORGROUND_COLOR),
              const SizedBox(width: 30),
              Text(
                "各学部年間行事予定",
                style: TextStyle(color: FORGROUND_COLOR),
              ),
              const Spacer()
            ]),
            verticalpadding: 10));
  }

  void showChooseDepartmentDialogue() {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text("学部を選択"),
          children: <Widget>[
            SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  showDownloadConfirmDialogue("政治経済学部  ", "PSE");
                },
                child: departmentPanel(WASEDA_PSE_COLOR, "PSE", "政治経済学部")),
            SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  showDownloadConfirmDialogue("法学部  ", "LAW");
                },
                child: departmentPanel(WASEDA_LAW_COLOR, "LAW", "法学部")),
            SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  showDownloadConfirmDialogue("商学部  ", "SOC");
                },
                child: departmentPanel(WASEDA_SOC_COLOR, "SOC", "商学部")),
            SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  showDownloadConfirmDialogue("国際教養学部  ", "SILS");
                },
                child: departmentPanel(WASEDA_SILS_COLOR, "SILS", "国際教養学部")),
            SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  showDownloadConfirmDialogue("社会科学部  ", "SSS");
                },
                child: departmentPanel(WASEDA_SSS_COLOR, "SSS", "社会科学部")),
            SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  showDownloadConfirmDialogue("教育学部  ", "EDU");
                },
                child: departmentPanel(WASEDA_EDU_COLOR, "EDU", "教育学部")),
            SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  showDownloadConfirmDialogue("文学部  ", "HSS");
                },
                child: departmentPanel(WASEDA_HSS_COLOR, "HSS", "文学部")),
            SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  showDownloadConfirmDialogue("文化構想学部  ", "CMS");
                },
                child: departmentPanel(WASEDA_CMS_COLOR, "CMS", "文化構想学部")),
            SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  showDownloadConfirmDialogue("先進理工学部  ", "ASE");
                },
                child: departmentPanel(WASEDA_ASE_COLOR, "ASE", "先進理工学部")),
            SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  showDownloadConfirmDialogue("創造理工学部  ", "CSE");
                },
                child: departmentPanel(WASEDA_CSE_COLOR, "CSE", "創造理工学部")),
            SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  showDownloadConfirmDialogue("基幹理工学部  ", "FSE");
                },
                child: departmentPanel(WASEDA_FSE_COLOR, "FSE", "基幹理工学部")),
            SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  showDownloadConfirmDialogue("人間科学部  ", "HUM");
                },
                child: departmentPanel(WASEDA_HUM_COLOR, "HUM", "人間科学部")),
            SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  showDownloadConfirmDialogue("スポーツ科学部  ", "SPS");
                },
                child: departmentPanel(WASEDA_SPS_COLOR, "SPS", "スポーツ科学部")),
          ],
        );
      },
    );
  }

  Widget departmentPanel(Color color, String alphabet, String departmentName) {
    return Container(
        child: Row(children: [
      Transform.rotate(
        angle: 45 * pi / 180,
        child: Container(
            height: SizeConfig.blockSizeHorizontal! * 7,
            width: SizeConfig.blockSizeHorizontal! * 7,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.all(
                Radius.circular(double.infinity),
              ),
            ),
            child: Center(
              child: Transform.rotate(
                angle: 315 * pi / 180,
                child: Text(
                  alphabet,
                  style: TextStyle(
                      fontSize: SizeConfig.blockSizeHorizontal! * 2.75,
                      color: FORGROUND_COLOR,
                      fontWeight: FontWeight.bold),
                ),
              ),
            )),
      ),
      const SizedBox(width: 20),
      Text(departmentName)
    ]));
  }

  void showDownloadConfirmDialogue(String depName, String alphabet) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$depNameの年間行事予定をカレンダーに追加しますか？'),
          actions: <Widget>[
            const Align(
                alignment: Alignment.centerLeft,
                child: Text("ダウンロードを行うと、カレンダーにデータが追加されます。")),
            const SizedBox(height: 10),
            buttonModelWithChild(() async {
              Navigator.pop(context);
              String currentYear = returnFiscalYear(DateTime.now()).toString();
              String nextYear =
                  (returnFiscalYear(DateTime.now()) + 1).toString();

              bool isScheduleDownloadSuccess = await importAcademicCalendar(
                  "${alphabet}_${currentYear}_$nextYear");

              if (isScheduleDownloadSuccess) {
                showDownloadDoneDialogue("データがダウンロードされました！");
                ref.read(taskDataProvider).isRenewed = true;
                ref.read(calendarDataProvider.notifier).state = CalendarData();
                while (ref.read(taskDataProvider).isRenewed != false) {
                  await Future.delayed(const Duration(microseconds: 1));
                }
              } else {
                showDownloadFailDialogue("ダウンロードに失敗しました");
              }
            },
                MAIN_COLOR,
                Row(children: [
                  const SizedBox(width: 20),
                  Icon(Icons.downloading_outlined, color: FORGROUND_COLOR),
                  const SizedBox(width: 20),
                  Text("ダウンロード実行", style: TextStyle(color: FORGROUND_COLOR))
                ]))
          ],
        );
      },
    );
  }

  void showDownloadDoneDialogue(String text) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ダウンロード完了'),
          actions: <Widget>[
            Align(alignment: Alignment.centerLeft, child: Text(text)),
            const SizedBox(height: 10),
            okButton(context, 500.0)
          ],
        );
      },
    );
  }

  void showDownloadFailDialogue(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ダウンロード失敗'),
          actions: <Widget>[
            Align(alignment: Alignment.centerLeft, child: Text(errorMessage)),
            const SizedBox(height: 10),
            okButton(context, 500.0)
          ],
        );
      },
    );
  }

  Widget urlList() {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: <Widget>[
        SimpleDialogOption(
            onPressed: () {
              final urlLaunchWithStringButton = UrlLaunchWithStringButton();
              urlLaunchWithStringButton.launchUriWithString(
                context,
                "https://www.waseda.jp/top/about/work/organizations/academic-affairs-division/academic-calendar",
              );
            },
            child: departmentPanel(MAIN_COLOR, "", "大学全体")),
        const SizedBox(height: 15),
        SimpleDialogOption(
            onPressed: () {
              final urlLaunchWithStringButton = UrlLaunchWithStringButton();
              urlLaunchWithStringButton.launchUriWithString(
                context,
                "https://www.waseda.jp/fpse/pse/students/calendar/",
              );
            },
            child: departmentPanel(WASEDA_PSE_COLOR, "PSE", "政治経済学部")),
        SimpleDialogOption(
            onPressed: () {
              final urlLaunchWithStringButton = UrlLaunchWithStringButton();
              urlLaunchWithStringButton.launchUriWithString(
                context,
                "https://www.waseda.jp/folaw/law/students/schedule/",
              );
            },
            child: departmentPanel(WASEDA_LAW_COLOR, "LAW", "法学部")),
        SimpleDialogOption(
            onPressed: () {
              final urlLaunchWithStringButton = UrlLaunchWithStringButton();
              urlLaunchWithStringButton.launchUriWithString(
                context,
                "https://www.waseda.jp/fcom/soc/students/calendar",
              );
            },
            child: departmentPanel(WASEDA_SOC_COLOR, "SOC", "商学部")),
        SimpleDialogOption(
            onPressed: () {
              final urlLaunchWithStringButton = UrlLaunchWithStringButton();
              urlLaunchWithStringButton.launchUriWithString(
                context,
                "https://www.waseda.jp/fire/sils/students/calendar/",
              );
            },
            child: departmentPanel(WASEDA_SILS_COLOR, "SILS", "国際教養学部")),
        SimpleDialogOption(
            onPressed: () {
              final urlLaunchWithStringButton = UrlLaunchWithStringButton();
              urlLaunchWithStringButton.launchUriWithString(
                context,
                "https://www.waseda.jp/fsss/sss/students/schedule/",
              );
            },
            child: departmentPanel(WASEDA_SSS_COLOR, "SSS", "社会科学部")),
        SimpleDialogOption(
            onPressed: () {
              final urlLaunchWithStringButton = UrlLaunchWithStringButton();
              urlLaunchWithStringButton.launchUriWithString(
                context,
                "https://www.waseda.jp/fedu/edu/students/schedule/",
              );
            },
            child: departmentPanel(WASEDA_EDU_COLOR, "EDU", "教育学部")),
        SimpleDialogOption(
            onPressed: () {
              final urlLaunchWithStringButton = UrlLaunchWithStringButton();
              urlLaunchWithStringButton.launchUriWithString(
                context,
                "https://www.waseda.jp/flas/hss/students/calendar/",
              );
            },
            child: departmentPanel(WASEDA_HSS_COLOR, "HSS", "文学部")),
        SimpleDialogOption(
            onPressed: () {
              final urlLaunchWithStringButton = UrlLaunchWithStringButton();
              urlLaunchWithStringButton.launchUriWithString(
                context,
                "https://www.waseda.jp/flas/cms/students/calendar/",
              );
            },
            child: departmentPanel(WASEDA_CMS_COLOR, "CMS", "文化構想学部")),
        SimpleDialogOption(
            onPressed: () {
              final urlLaunchWithStringButton = UrlLaunchWithStringButton();
              urlLaunchWithStringButton.launchUriWithString(
                context,
                "https://www.waseda.jp/fsci/students/calendar/",
              );
            },
            child: departmentPanel(WASEDA_ASE_COLOR, "ASE", "先進理工学部")),
        SimpleDialogOption(
            onPressed: () {
              final urlLaunchWithStringButton = UrlLaunchWithStringButton();
              urlLaunchWithStringButton.launchUriWithString(
                context,
                "https://www.waseda.jp/fsci/students/calendar/",
              );
            },
            child: departmentPanel(WASEDA_CSE_COLOR, "CSE", "創造理工学部")),
        SimpleDialogOption(
            onPressed: () {
              final urlLaunchWithStringButton = UrlLaunchWithStringButton();
              urlLaunchWithStringButton.launchUriWithString(
                context,
                "https://www.waseda.jp/fsci/students/calendar/",
              );
            },
            child: departmentPanel(WASEDA_FSE_COLOR, "FSE", "基幹理工学部")),
        SimpleDialogOption(
            onPressed: () {
              final urlLaunchWithStringButton = UrlLaunchWithStringButton();
              urlLaunchWithStringButton.launchUriWithString(
                context,
                "https://www.waseda.jp/fhum/hum/campus-life/schedule/",
              );
            },
            child: departmentPanel(WASEDA_HUM_COLOR, "HUM", "人間科学部")),
        SimpleDialogOption(
            onPressed: () {
              final urlLaunchWithStringButton = UrlLaunchWithStringButton();
              urlLaunchWithStringButton.launchUriWithString(
                context,
                "https://www.waseda.jp/fsps/sps/students-2/registration/",
              );
            },
            child: departmentPanel(WASEDA_SPS_COLOR, "SPS", "スポーツ科学部")),
      ],
    );
  }
}

int returnFiscalYear(DateTime dt) {
  int month = dt.month;
  if (month <= 3) {
    return dt.year - 1;
  } else {
    return dt.year;
  }
}
