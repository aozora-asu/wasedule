import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_calandar_app/backend/firebase_handler.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/add_event_button.dart';
import 'package:flutter_calandar_app/frontend/screens/common/tutorials.dart';
import 'package:flutter_calandar_app/frontend/screens/menu_pages/arbeit_stats_page.dart';
import 'package:flutter_calandar_app/frontend/screens/menu_pages/sns_link_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../assist_files/colors.dart';
import '../../assist_files/size_config.dart';

class UnivSchedulePage extends ConsumerStatefulWidget {
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
        appBar: AppBar(
          leading: const BackButton(color: Colors.white),
          backgroundColor: MAIN_COLOR,
          elevation: 10,
          title: Column(
            children: <Widget>[
              Row(children: [
                const Icon(
                  Icons.school,
                  color: WIDGET_COLOR,
                ),
                SizedBox(
                  width: SizeConfig.blockSizeHorizontal! * 4,
                ),
                Text(
                  '年間行事予定',
                  style: TextStyle(
                      fontSize: SizeConfig.blockSizeHorizontal! * 5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white),
                ),
              ])
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
           child: Column(children: [
            SizedBox(height:SizeConfig.blockSizeHorizontal! * 80,
              child:thumbnailImage(),
            ),
            Container(
                width: SizeConfig.blockSizeHorizontal! * 100,
                decoration: roundedBoxdecorationWithShadow(),
                child: Column(children: [
                  pageBody()
                ]))
          ])
        )
      )
    );
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
          const Divider(thickness: 2,),
          const SizedBox(height: 10),
          const Text("【免責事項】",
              style: TextStyle(fontSize: 17)),
          const Text("大学の予定は変更される場合があります。最新情報は以下のリンクから公式サイトにてお確かめください。",
              style: TextStyle(fontSize: 17)),
          const SizedBox(height: 20),
          urlList()
        ],
      ),
    );
  }

  Widget downloadUniversityScheduleButton(){
    return SizedBox(
      width:90000,
      child:ElevatedButton(
        onPressed: ()async{
          showDownloadConfirmDialogue("大学全体","all_depertment");
        },
        style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(MAIN_COLOR)),
        child:const Text(
          "大学年間行事予定",
          style: TextStyle(color:Colors.white),  
        )
      )
    );
  }

  Widget chooseDepartmentButton(){
    return SizedBox(
      width:90000,
      child:ElevatedButton(
        onPressed: (){
          showChooseDepartmentDialogue();
        },
        style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(ACCENT_COLOR)),
        child:const Text(
          "各学部年間行事予定",
          style: TextStyle(color:Colors.white),  
        )
      )
    );
  }

  void showChooseDepartmentDialogue(){
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title:const Text("学部を選択"),
          children: <Widget>[

            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                showDownloadConfirmDialogue("政治経済学部", "PSE");
              },
              child: departmentPanel(
                WASEDA_PSE_COLOR,
                "PSE",
                "政治経済学部")
            ),
              
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                showDownloadConfirmDialogue("法学部", "LAW");
              },
              child: departmentPanel(
                WASEDA_LAW_COLOR,
                "LAW",
                "法学部")
            ),
              
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                showDownloadConfirmDialogue("商学部", "SOC");
              },
              child: departmentPanel(
                WASEDA_SOC_COLOR,
                "SOC",
                "商学部")
            ),

            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                showDownloadConfirmDialogue("国際教養学部", "");
              },
              child: departmentPanel(
                WASEDA_SILS_COLOR,
                "SILS",
                "国際教養学部")
            ),

            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                showDownloadConfirmDialogue("社会科学部", "SSS");
              },
              child: departmentPanel(
                WASEDA_SSS_COLOR,
                "SSS",
                "社会科学部")
            ),
            
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                showDownloadConfirmDialogue("教育学部", "EDU");
              },
              child: departmentPanel(
                WASEDA_EDU_COLOR,
                "EDU",
                "教育学部")
            ),

            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                showDownloadConfirmDialogue("文学部", "HSS");
              },
              child: departmentPanel(
                WASEDA_HSS_COLOR,
                "HSS",
                "文学部")
            ),
            
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                showDownloadConfirmDialogue("文化構想学部", "CMS");
              },
              child: departmentPanel(
                WASEDA_CMS_COLOR,
                "CMS",
                "文化構想学部")
            ),
            
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                showDownloadConfirmDialogue("先進理工学部", "ASE");
              },
              child: departmentPanel(
                WASEDA_ASE_COLOR,
                "ASE",
                "先進理工学部")
            ),
            
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                showDownloadConfirmDialogue("創造理工学部", "CSE");
              },
              child: departmentPanel(
                WASEDA_CSE_COLOR,
                "CSE",
                "創造理工学部")
            ),

            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                showDownloadConfirmDialogue("基幹理工学部", "FSE");
              },
              child: departmentPanel(
                WASEDA_FSE_COLOR,
                "FSE",
                "基幹理工学部")
            ),

            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                showDownloadConfirmDialogue("人間科学部", "HUM");
              },
              child: departmentPanel(
                WASEDA_HUM_COLOR,
                "HUM",
                "人間科学部")
            ),
            
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                showDownloadConfirmDialogue("スポーツ科学部", "SPS");
              },
              child: departmentPanel(
                WASEDA_SPS_COLOR,
                "SPS",
                "スポーツ科学部")
            ),
            
          ],
        );
      },
    );
  }


  Widget departmentPanel (Color color, String alphabet, String departmentName){
    return

     Container(
      child:Row(children:[
      Transform.rotate(
        angle: 45 * pi / 180,
        child:
        Container(
            height:SizeConfig.blockSizeHorizontal! *7,
            width:SizeConfig.blockSizeHorizontal! *7,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.all(Radius.circular(double.infinity),
            ), 
          ),
          child:Center(
            child:Transform.rotate(
              angle: 315 * pi / 180,
                child:Text(
                  alphabet,
                  style: TextStyle(
                    fontSize:SizeConfig.blockSizeHorizontal! *3,
                    color:Colors.white,
                    fontWeight: FontWeight.bold
                  ),
              ),
            ),
          )
        ),
        ),
        const SizedBox(width:20),
        Text(departmentName)
      ])
    );
  }

  void showDownloadConfirmDialogue(String depName, String alphabet) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(depName + '  の年間行事予定をカレンダーに追加しますか？'),
          actions: <Widget>[
            const Align(
                alignment: Alignment.centerLeft,
                child: Text("ダウンロードを行うと、カレンダーにデータが追加されます。")),
            const SizedBox(height: 10),
            ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  String year = DateFormat("yyyy").format(DateTime.now());

                  bool isScheduleDownloadSuccess
                    = await receiveSchedule(alphabet + "_" + year);

                  if (isScheduleDownloadSuccess) {
                    showDownloadDoneDialogue("データがダウンロードされました！");
                  } else {
                    showDownloadFailDialogue("ダウンロードに失敗しました");
                  }
                },
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color?>(MAIN_COLOR)),
                child: const Row(children: [
                  Icon(Icons.downloading_outlined, color: Colors.white),
                  SizedBox(width: 20),
                  Text("ダウンロード実行", style: TextStyle(color: Colors.white))
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

  Widget urlList(){
    return ListView(     
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: <Widget>[

        SimpleDialogOption(
          onPressed: () {
            final _urlLaunchWithStringButton = UrlLaunchWithStringButton();
            _urlLaunchWithStringButton.launchUriWithString(
              context,
              "https://www.waseda.jp/top/about/work/organizations/academic-affairs-division/academic-calendar",
            );
          },
          child: departmentPanel(
            MAIN_COLOR,
            "大學",
            "大学全体")
        ),

        const SizedBox(height:15),

        SimpleDialogOption(
          onPressed: () {
            final _urlLaunchWithStringButton = UrlLaunchWithStringButton();
            _urlLaunchWithStringButton.launchUriWithString(
              context,
              "https://www.waseda.jp/fpse/pse/students/calendar/",
            );
          },
          child: departmentPanel(
            WASEDA_PSE_COLOR,
            "PSE",
            "政治経済学部")
        ),
          
        SimpleDialogOption(
          onPressed: () {
            final _urlLaunchWithStringButton = UrlLaunchWithStringButton();
            _urlLaunchWithStringButton.launchUriWithString(
              context,
              "https://www.waseda.jp/folaw/law/students/schedule/",
            );
          },
          child: departmentPanel(
            WASEDA_LAW_COLOR,
            "LAW",
            "法学部")
        ),
          
        SimpleDialogOption(
          onPressed: () {
            final _urlLaunchWithStringButton = UrlLaunchWithStringButton();
            _urlLaunchWithStringButton.launchUriWithString(
              context,
              "https://www.waseda.jp/fcom/soc/students/calendar",
            );
          },
          child: departmentPanel(
            WASEDA_SOC_COLOR,
            "SOC",
            "商学部")
        ),

        SimpleDialogOption(
          onPressed: () {
            final _urlLaunchWithStringButton = UrlLaunchWithStringButton();
            _urlLaunchWithStringButton.launchUriWithString(
              context,
              "https://www.waseda.jp/fire/sils/students/calendar/",
            );
          },
          child: departmentPanel(
            WASEDA_SILS_COLOR,
            "SILS",
            "国際教養学部")
        ),

        SimpleDialogOption(
          onPressed: () {
            final _urlLaunchWithStringButton = UrlLaunchWithStringButton();
            _urlLaunchWithStringButton.launchUriWithString(
              context,
              "https://www.waseda.jp/fsss/sss/students/schedule/",
            );
          },
          child: departmentPanel(
            WASEDA_SSS_COLOR,
            "SSS",
            "社会科学部")
        ),
        
        SimpleDialogOption(
          onPressed: () {
            final _urlLaunchWithStringButton = UrlLaunchWithStringButton();
            _urlLaunchWithStringButton.launchUriWithString(
              context,
              "https://www.waseda.jp/fedu/edu/students/schedule/",
            );
          },
          child: departmentPanel(
            WASEDA_EDU_COLOR,
            "EDU",
            "教育学部")
        ),

        SimpleDialogOption(
          onPressed: () {
            final _urlLaunchWithStringButton = UrlLaunchWithStringButton();
            _urlLaunchWithStringButton.launchUriWithString(
              context,
              "https://www.waseda.jp/flas/hss/students/calendar/",
            );
          },
          child: departmentPanel(
            WASEDA_HSS_COLOR,
            "HSS",
            "文学部")
        ),
        
        SimpleDialogOption(
          onPressed: () {
            final _urlLaunchWithStringButton = UrlLaunchWithStringButton();
            _urlLaunchWithStringButton.launchUriWithString(
              context,
              "https://www.waseda.jp/flas/cms/students/calendar/",
            );
          },
          child: departmentPanel(
            WASEDA_CMS_COLOR,
            "CMS",
            "文化構想学部")
        ),
        
        SimpleDialogOption(
          onPressed: () {
            final _urlLaunchWithStringButton = UrlLaunchWithStringButton();
            _urlLaunchWithStringButton.launchUriWithString(
              context,
              "https://www.waseda.jp/fsci/students/calendar/",
            );
          },
          child: departmentPanel(
            WASEDA_ASE_COLOR,
            "ASE",
            "先進理工学部")
        ),
        
        SimpleDialogOption(
          onPressed: () {
            final _urlLaunchWithStringButton = UrlLaunchWithStringButton();
            _urlLaunchWithStringButton.launchUriWithString(
              context,
              "https://www.waseda.jp/fsci/students/calendar/",
            );
          },
          child: departmentPanel(
            WASEDA_CSE_COLOR,
            "CSE",
            "創造理工学部")
        ),

        SimpleDialogOption(
          onPressed: () {
            final _urlLaunchWithStringButton = UrlLaunchWithStringButton();
            _urlLaunchWithStringButton.launchUriWithString(
              context,
              "https://www.waseda.jp/fsci/students/calendar/",
            );
          },
          child: departmentPanel(
            WASEDA_FSE_COLOR,
            "FSE",
            "基幹理工学部")
        ),

        SimpleDialogOption(
          onPressed: () {
            final _urlLaunchWithStringButton = UrlLaunchWithStringButton();
            _urlLaunchWithStringButton.launchUriWithString(
              context,
              "https://www.waseda.jp/tokorozawa/kg/human-school/schedule_h.html",
            );
          },
          child: departmentPanel(
            WASEDA_HUM_COLOR,
            "HUM",
            "人間科学部")
        ),
        
        SimpleDialogOption(
          onPressed: () {
            final _urlLaunchWithStringButton = UrlLaunchWithStringButton();
            _urlLaunchWithStringButton.launchUriWithString(
              context,
              "https://www.waseda.jp/tokorozawa/kg/sports-school/schedule_s.html",
            );
          },
          child: departmentPanel(
            WASEDA_SPS_COLOR,
            "SPS",
            "スポーツ科学部")
        ),
        
      ],

    );
  }

}
