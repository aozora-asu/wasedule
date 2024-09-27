import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/screen_manager.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/frontend/assist_files/ui_components.dart';
import 'package:flutter_calandar_app/frontend/screens/common/menu_appbar.dart';
import 'package:flutter_calandar_app/frontend/screens/common/plain_appbar.dart';
import 'package:flutter_calandar_app/frontend/screens/setting_page/data_backup_page.dart';
import 'package:flutter_calandar_app/frontend/screens/moodle_view_page/moodle_view_page.dart';
import 'package:introduction_screen/introduction_screen.dart';
import "../../../backend/DB/sharepreference.dart";

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  PageDecoration decoration =const PageDecoration(
      titleTextStyle: TextStyle(
          height: 1,
          fontSize: 35,
          fontWeight: FontWeight.bold,
          color: BLUEGREY),
      bodyTextStyle: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
      pageColor: Colors.white,
      imagePadding:  EdgeInsets.only(top: 10,bottom: 0),
      imageFlex: 8,
      contentMargin : EdgeInsets.all(0),
      pageMargin : EdgeInsets.only(bottom: 0),
      titlePadding : EdgeInsets.only(bottom: 10),
      bodyPadding : EdgeInsets.zero, 
      footerPadding : EdgeInsets.symmetric(vertical: 0),
      bodyFlex: 2,
      footerFlex: 5);

  List<PageViewModel> getPages() {
    dismissTimelinePop = true;
    return [
      PageViewModel(
          title: "わせジュールへようこそ",
          image: Center(
            child: Image.asset(
              "lib/assets/eye_catch/eyecatch.png",
              scale: 2,
            ),
          ),
          bodyWidget: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child:Column(children: [
              Text(
                "あなたの生活に、\nわせジュールがやってきました。",
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 20),
              Text(
                "このアプリではこんなことができます：\n・課題を自動取得して通知\n・成績データのダウンロード\n・時間割の自動生成",
                style: TextStyle(fontSize: 17,color:Colors.grey),
              ),
            ])
          ),

          decoration: const PageDecoration(
              titleTextStyle:
                  TextStyle(fontSize: 25.0, fontWeight: FontWeight.w700),
              bodyTextStyle: TextStyle(fontSize: 17.0),
              pageColor: Colors.white,
              imagePadding: EdgeInsets.only(top: 100),
              imageFlex: 3,
              pageMargin : EdgeInsets.only(bottom: 0),
              bodyFlex: 2)),
      
      PageViewModel(
          title: "課題",
          body: "Moodleから毎日自動でデータ取得。\n思いのままに通知設定。",
          image: Center(
            child: Image.asset(
              "lib/assets/tutorial_images/task_introduction.png",
            ),
          ),
          decoration: decoration),
      PageViewModel(
          title: "単位と成績",
          body: "卒業まであと何単位？\n成績照会画面からインポート。",
          image: Center(
            child: Image.asset(
              "lib/assets/tutorial_images/credits_introduction.png",
            ),
          ),
          decoration: decoration),
      PageViewModel(
          title: "予定",
          body: "大学学部の行事予定をインポート。\nアルバイト年収も推計して管理！",
          image: Center(
            child: Image.asset(
              "lib/assets/tutorial_images/calendar_introduction.png",
            ),
          ),
          decoration: decoration),
      PageViewModel(
          title: "授業",
          body: "Moodleからインポート。\n授業の入力候補も出してくれます",
          image: Center(
            child: Image.asset(
              "lib/assets/tutorial_images/timetable_introduction.png",
            ),
          ),
          decoration: decoration),
      PageViewModel(
          title: "Moodle\nMyWaseda・成績照会",
          body: "主要Webページのブックマーク搭載。",
          image: Center(
            child: Image.asset(
              "lib/assets/tutorial_images/moodle_introduction.png",
            ),
          ),
          decoration: decoration),
      PageViewModel(
          title: "空き教室\n図書館・食堂情報",
          body: "地図 × (ブックマーク + 教室検索)\n=便利！",
          image: Center(
            child: Image.asset(
              "lib/assets/tutorial_images/map_introduction.png",
            ),
          ),
          decoration: decoration),
      PageViewModel(
          title: "And More...",
          body: "ここでご紹介したのは、ほんの少し。\nあなただけの学生生活を、\nわせジュールで見つけてください。",
          image: Center(
            child: Image.asset(
              "lib/assets/tutorial_images/more_introduction.png",
            ),
          ),
          decoration: decoration),
      PageViewModel(
        title: "使ってみましょう！",
        useScrollView: false,
        bodyWidget: Column(children: [
          const Text("あなたは早稲田大学の学生ですか？", style: TextStyle(fontSize: 20)),
          const SizedBox(height: 20),
          SizedBox(
            width: 500,
            child: ElevatedButton(
              onPressed: () {
                showMoodleRegisterGuide(context,true,MoodleRegisterGuideType.task);
              },
              style: const ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(MAIN_COLOR)),
              child: const Text(
                "はい",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 500,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const IntroLastPage(),
                  ),
                );
              },
              style: const ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(PALE_MAIN_COLOR)),
              child: const Text(
                "いいえ",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ]),
        image: Center(
          child: Image.asset(
            "lib/assets/eye_catch/eyecatch.png",
            height: 200.0,
          ),
        ),
        decoration: const PageDecoration(
          titleTextStyle:
              TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
          bodyTextStyle: TextStyle(fontSize: 20.0),
          imagePadding: EdgeInsets.only(top: 200),
          pageColor: Colors.white,
        ),
      ),
    ];
  }

  final introKey = GlobalKey<IntroductionScreenState>();

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return IntroductionScreen(
      key: introKey,
      controlsPadding: const EdgeInsets.all(0),
      pages: getPages(),
      showSkipButton: false,
      showDoneButton: false,
      next: const Icon(Icons.keyboard_arrow_right),
      dotsDecorator: DotsDecorator(
        size: const Size.square(10.0),
        activeSize: const Size(10.0, 10.0),
        activeColor: Theme.of(context).primaryColor,
        color: Colors.black26,
        spacing: const EdgeInsets.symmetric(horizontal: 1.5, vertical: 20),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
    );
  }

}

  enum MoodleRegisterGuideType {
    notAvailableAndroid,
    task,
    timetable,
    credit,
  }

  Future<void> showMoodleRegisterGuide(
   BuildContext context,bool istutorial,MoodleRegisterGuideType dialogType) {
    String guideText = "";
    String titleText = "";
    Widget button = okButton(context,1500.0);

    if(dialogType == MoodleRegisterGuideType.task){
      titleText = "課題の自動取得を設定しましょう。";
      guideText = "'Moodle'ページから、課題の自動取得を設定しましょう！\n\n■手順\n１.Moodleにログイン\n２.「わせジュール 拡張機能」\n３.「課題の自動取得を設定する」\n\n登録すると、以降はアプリに課題が自動で取得されます。\n";
    }else if(dialogType == MoodleRegisterGuideType.timetable){
      titleText = "時間割をアプリに取得しましょう。";
      guideText = "'Moodle'ページから、時間割をアプリに取得しましょう！\n\n■手順\n１.Moodleにログイン\n２.「わせジュール 拡張機能」\n３.「時間割を自動登録する」\n\nこれだけで、あなたの授業がアプリに登録されます！\n";
    }else if(dialogType == MoodleRegisterGuideType.credit){
      titleText = "単位取得状況をアプリに取得しましょう。";
      guideText = "'成績照会'ページから、単位取得状況をアプリに取得しましょう！\n\n■手順\n１.成績照会画面でログイン\n２.「わせジュールにダウンロード」\n\nこれであなたの単位取得情報ががアプリに登録され、以後はアプリ内から確認できます！\n";
    }else if(dialogType == MoodleRegisterGuideType.notAvailableAndroid){
      titleText = "この機能は準備中です。";
      guideText = "大変申し訳ございません。現在Android版ではこの機能はご利用いただけません。近日中の完成を予定して開発中ですので今しばらくお待ちください。\n";
    }


    if(istutorial){
      button = SizedBox(
        width: 5000,
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => const IntroLastPage(),
              ),
            );
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => Scaffold(
                    appBar: CustomAppBar(backButton: true),
                    body: const MoodleViewPage()),
              ),
            );
          },
          style: const ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(MAIN_COLOR)),
          child: const Text(
            "登録画面へ",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );

    }

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titleText),
          actions: <Widget>[
            Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
                Text(guideText),
              button
            ]),
          ],
        );
      },
    );
  }

class IntroLastPage extends StatefulWidget {
  const IntroLastPage({super.key});
  @override
  State<IntroLastPage> createState() => _IntroLastPageState();
}

class _IntroLastPageState extends State<IntroLastPage> {
  List<PageViewModel> lastPage() {
    return [
      PageViewModel(
          title: "早速課題を登録してみましょう！",
          bodyWidget: Column(children: [
            const Text(
              "課題ページ「+」ボタンから課題を入力してみましょう。\n先ほどURLを登録した方は、自動取得された課題がこの画面に表示されます。",
            ),
            const SizedBox(height: 20),
            Row(children: [
              const Spacer(),
              InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DataBackupPage(),
                        ));
                  },
                  child: const Text("バックアップの復元",
                      style: TextStyle(
                        color: Colors.blue,
                      )))
            ])
          ]),
          image: Center(
            child: Image.asset(
              "lib/assets/tutorial_images/task_add_button.png",
            ),
          ),
          decoration: const PageDecoration(
              titleTextStyle:
                  TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
              bodyTextStyle: TextStyle(fontSize: 17.0),
              pageColor: Colors.white,
              imagePadding: EdgeInsets.only(top: 100),
              imageFlex: 3,
              bodyFlex: 2))
    ];
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return IntroductionScreen(
      controlsPadding: const EdgeInsets.all(0),
      pages: lastPage(),
      done: const Text("使ってみる"),
      onDone: () async {
        SharepreferenceHandler()
            .setValue(SharepreferenceKeys.hasCompletedIntro, true);

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => AppPage(initIndex: 3),
          ),
        );
      },
      showSkipButton: false,
      showDoneButton: true,
      next: const Icon(Icons.keyboard_arrow_right),
    );
  }
}

Future<void> showScheduleGuide(context) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("予定を登録してみましょう！"),
        actions: <Widget>[
          Column(children: [
            SizedBox(
                width: 200,
                child: Image.asset(
                    'lib/assets/tutorial_images/schedule_add_button.png')),
            const Text("\nカレンダーに予定を登録してみましょう！画面右下の[+]ボタン、または各日付のマスから追加できます。\n"),
            okButton(context, 500.0)
          ]),
        ],
      );
    },
  );
}

Future<void> showTagAndTemplateGuide(context) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("最初の予定を登録！"),
        actions: <Widget>[
          Column(children: [
            SizedBox(
                width: 200,
                child: Image.asset(
                    'lib/assets/tutorial_images/tag_and_template_button.png')),
            const Text(
                "\n「タグ」機能、「テンプレート」機能が使えるようになりました！「タグとテンプレート」から追加してみましょう。\n"),
            okButton(context, 500.0)
          ]),
        ],
      );
    },
  );
}

Future<void> showTagGuide(context) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("最初のタグを登録！1/2"),
        actions: <Widget>[
          Column(children: [
            SizedBox(
                width: 200,
                child:
                    Image.asset('lib/assets/tutorial_images/tag_button.png')),
            const Text("\n最初のタグが登録されました！予定登録時に、「 + タグ」ボタンを押して紐づけてみましょう。\n"),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                showArbeitGuide(context);
              },
              style: const ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(MAIN_COLOR),
                  visualDensity: VisualDensity.standard),
              child: const SizedBox(
                  width: 500.0,
                  child: Center(
                      child:
                          Text('つぎへ', style: TextStyle(color: Colors.white)))),
            )
          ]),
        ],
      );
    },
  );
}

Future<void> showArbeitGuide(context) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("最初のタグを登録！2/2"),
        actions: <Widget>[
          Column(children: [
            SizedBox(
                width: 200,
                child: Image.asset(
                    'lib/assets/tutorial_images/arbeit_button.png')),
            const Text(
                "\nアルバイトタグを予定に紐付けると、自動で給料の見込みが計算！「アルバイト」ページで閲覧してください。\n"),
            okButton(context, 500.0)
          ]),
        ],
      );
    },
  );
}

Future<void> showTemplateGuide(context) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("最初のテンプレートを登録！"),
        actions: <Widget>[
          Column(children: [
            SizedBox(
                width: 200,
                child: Image.asset(
                    'lib/assets/tutorial_images/template_button.png')),
            const Text("\n最初のテンプレートが登録されました！予定登録時、「 + テンプレート」ボタンから選択しましょう。\n"),
            okButton(context, 500.0)
          ]),
        ],
      );
    },
  );
}
