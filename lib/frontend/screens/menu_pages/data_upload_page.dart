import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/add_event_button.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/schedule_data_manager.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/tag_and_template_page.dart';
import 'package:flutter_calandar_app/frontend/screens/common/tutorials.dart';
import 'package:flutter_calandar_app/frontend/screens/menu_pages/arbeit_stats_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../assist_files/colors.dart';
import '../../assist_files/size_config.dart';
import 'package:toggle_switch/toggle_switch.dart';

class DataUploadPage extends ConsumerStatefulWidget {
  @override
  _DataUploadPageState createState() => _DataUploadPageState();
}

class _DataUploadPageState extends ConsumerState<DataUploadPage> {
  late int currentIndex;
  List<Map<String,dynamic>> shareScheduleList = [];

  @override
  void initState() {
  super.initState();
  currentIndex = 0;
  ref.read(scheduleFormProvider).clearContents();
 }

  @override
  Widget build(BuildContext context) {
  generateShereScheduleList(ref.watch(scheduleFormProvider).tagController.text);
  SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color:Colors.white),
        backgroundColor: MAIN_COLOR,
        elevation: 10,
        title: Column(
          children:<Widget>[
            Row(children:[
            const Icon(
              Icons.send_to_mobile_rounded,
              color:WIDGET_COLOR,
              ),
              SizedBox(width: SizeConfig.blockSizeHorizontal! *4,),
            Text(
              '予定のアップロード',
              style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal! *5,
                fontWeight: FontWeight.w800,
                color:Colors.white
              ),
            ),
            ]
            )
          ],
        ),
      ),
      body:SingleChildScrollView(
       child:Center(child:
          Column(children:[
          thumbnailImage(),
          Container(
            width:SizeConfig.blockSizeHorizontal! *100,
            decoration: roundedBoxdecorationWithShadow(),
            child:
            Column(children:[
              const SizedBox(height:15),
              toggleSwitch(),
              pageBody()
              ])
            )
          ])
        )
      ) 
    );
  }

  Image thumbnailImage(){
   if(currentIndex == 1){
    return Image.asset('lib/assets/schedule_share/schedule_backup_upload.png',
            height:SizeConfig.blockSizeHorizontal! *100,
            width:SizeConfig.blockSizeHorizontal! *100,);
   }else{
    return Image.asset('lib/assets/schedule_share/schedule_broadcast_upload.png',
            height:SizeConfig.blockSizeHorizontal! *100,
            width:SizeConfig.blockSizeHorizontal! *100,);
   }
  }
  
  Widget toggleSwitch(){
    return 
      ToggleSwitch(
        initialLabelIndex: currentIndex,
        totalSwitches: 2,
        activeBgColor:const[MAIN_COLOR],
        minWidth: SizeConfig.blockSizeHorizontal! *45,
        labels:const ['予定の配信','データバックアップ'],
        onToggle: (index) {
          setState((){
            currentIndex = index ?? 0;
          });
        },
      );
  }

  Widget pageBody(){
    if(currentIndex == 0){
      return scheduleBroadcastPage();
    }else{
      return dataBackupPage();
    }
  }

  Widget scheduleBroadcastPage(){
    return Padding(
      padding:const EdgeInsets.symmetric(horizontal: 20,vertical:20),
      child:Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("・共有コードを知っている人に向けて、予定を配信することができます。サークルやゼミなどで、スケジュールの共有にお使いください。",
                    style:TextStyle(fontSize: 17)),
          const SizedBox(height:10),
          const Text("・選択したタグが紐付いている予定のみが共有されます。"
                    ,style:TextStyle(color:Colors.red,fontSize: 17)),
          const SizedBox(height:10),
          chooseTagButton(),
          broadcastUploadButton(),
          tagThumbnail(),
          shereScheduleListView(),
      ])
    );
  }

Widget chooseTagButton() {
  return ElevatedButton(
    onPressed: () async {
      await showTagDialogue(ref, context, setState);
      setState(() {});
    },
    style: const ButtonStyle(
      backgroundColor: MaterialStatePropertyAll(ACCENT_COLOR),
    ),
    child: const Row(
      children: [
        Icon(Icons.more_vert_rounded, color: Colors.white),
        SizedBox(width: 20),
        Text("タグを選択", style: TextStyle(color: Colors.white)),
      ],
    ),
  );
}

  Widget tagThumbnail(){
    String tagID = ref.watch(scheduleFormProvider).tagController.text;
    if(tagID.isEmpty){
      return const SizedBox();
    }else{
      return Column(children:[
        const SizedBox(height:30),
          Row(children:[
            const Text("選択中："),
            tagChip(tagID, ref),
            const SizedBox(width:10),
            Text(shareScheduleList.length.toString() + "件",
            style:const TextStyle(color: Colors.grey)),
        ]),
        const SizedBox(height:5),
      ]);
    }
  }

  Future<void> generateShereScheduleList(String id) async{
    shareScheduleList = [];
    List<Map<String,dynamic>> result = [];
    List calendarList = ref.watch(calendarDataProvider).calendarData;
    if(id.isNotEmpty){
      for(int i = 0; i < calendarList.length; i++){
        if(calendarList.elementAt(i)["tag"] == id){
          result.add(calendarList.elementAt(i));
        }
      }
    }
    shareScheduleList = result.reversed.toList();
  }

  Widget shereScheduleListView(){
    return ListView.separated(
      itemBuilder: (context, index) {
       Map targetDayData = shareScheduleList.elementAt(index);
       Text dateTimeData = const Text("");
        if (targetDayData["startTime"].trim() != "" &&
          targetDayData["endTime"].trim() != "") {
        dateTimeData = Text(
            " " +
                targetDayData["startTime"] +
                "～" +
                targetDayData["endTime"],
            style: const TextStyle(color: Colors.grey),
          );
        } else if (targetDayData["startTime"].trim() !=
            "") {
          dateTimeData = Text(
            " " + targetDayData["startTime"],
            style: const TextStyle(color: Colors.grey),
          );
        } else {
          dateTimeData = const Text(
            " 終日",
            style: TextStyle(color: Colors.grey),
          );
        }

      return Container(
          child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children:[
            Row(children:[
             Text(shareScheduleList.elementAt(index)["startDate"],
             style:const TextStyle(color:Colors.grey),),
             const SizedBox(width:10),
             dateTimeData
            ]),
            Text(shareScheduleList.elementAt(index)["subject"]),
          ]) 
        );
      },
      separatorBuilder: (context,index){
        return const Divider(height:1);
      },
      itemCount:shareScheduleList.length,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
    );
  }

  Widget broadcastUploadButton(){
   if(shareScheduleList.isNotEmpty){
    return ElevatedButton(
      onPressed: (){
        String id = "2A8D24E9023F2DAC33";//仮のIDです。


        //ここにデータ配信の実行処理を書き込む（アップロード処理）


        //showBackupFailDialogue("エラーメッセージ"); //←処理の失敗時にお使いください。
        showBackUpDoneDialogue(id);
      },
      style:const ButtonStyle(
        backgroundColor:MaterialStatePropertyAll(MAIN_COLOR),
      ),
      child:const Row(children:[
        Icon(Icons.backup,color:Colors.white),
        SizedBox(width:20),
        Text("データをアップロード",style:TextStyle(color:Colors.white))
      ])
    );
    
    }else{

    return const SizedBox();

    }
  }




  Widget dataBackupPage(){
    return Padding(
      padding:const EdgeInsets.symmetric(horizontal: 20,vertical:20),
      child:Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("・今お使いの端末からサーバー上に「カレンダー」「課題」「学習記録」のすべてのデータをバックアップします。のちに他の端末などに復元していただけます。",
                    style:TextStyle(fontSize: 17)),
          const SizedBox(height:10),
          const Text("・バックアップに際して、発行されるIDが必要です。スクリーンショットなどで保管しておいてください。"
                    ,style:TextStyle(color:Colors.red,fontSize: 17)),
          const SizedBox(height:10),
          backUpUploadButton(),
      ])
    );
  }

  Widget backUpUploadButton(){
    return ElevatedButton(
      onPressed: (){
        String id = "2A8D24E9023F2DAC33";//仮のIDです。


        //ここにバックアップの実行処理を書き込む（アップロード処理）


        //showBackupFailDialogue("エラーメッセージ"); //←処理の失敗時にお使いください。
        showBackUpDoneDialogue(id);
      },
      style:const ButtonStyle(
        backgroundColor:MaterialStatePropertyAll(MAIN_COLOR),
      ),
      child:const Row(children:[
        Icon(Icons.backup,color:Colors.white),
        SizedBox(width:20),
        Text("データをバックアップ",style:TextStyle(color:Colors.white))
      ])
    );
  }

  void showBackUpDoneDialogue(String id){
    showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title:const Text('バックアップ完了'),
        actions: <Widget>[
          const Text("バックアップの復元に際して、こちらのIDが必要です。スクリーンショットなどで保管しておいてください。"
          ,style:TextStyle(color:Colors.red)),
          const SizedBox(height:10),
          const Align(alignment: Alignment.centerLeft, child:Text("ID:")),
          Text(id,style:const TextStyle(fontSize:25,fontWeight:FontWeight.bold)),
          okButton(context,500.0)
        ],
      );
    },
   );
  }

   void showBackupFailDialogue(String errorMessage){
    showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title:const Text('アップロード失敗'),
        actions: <Widget>[
          Align(alignment: Alignment.centerLeft, 
          child:Text(errorMessage)),
          const SizedBox(height:10),
          okButton(context,500.0)
        ],
      );
    },
   );
  }


}
