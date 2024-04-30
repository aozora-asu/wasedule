import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_calandar_app/backend/DB/handler/calendarpage_config_db_handler.dart';
import 'package:flutter_calandar_app/frontend/assist_files/data_loader.dart';
import 'package:flutter_calandar_app/frontend/screens/common/tutorials.dart';
import 'package:flutter_calandar_app/frontend/screens/calendar_page/calendar_data_manager.dart';
import 'package:flutter_calandar_app/frontend/screens/menu_pages/arbeit_stats_page.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import '../../assist_files/colors.dart';
import '../../assist_files/size_config.dart';

class SettingsPage extends StatelessWidget {
  int? initIndex;
  SettingsPage({
    this.initIndex
  });
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        backgroundColor: MAIN_COLOR,
        elevation: 10,
        title: const Column(
          children: <Widget>[
            Row(children: [
              Icon(
                Icons.settings,
                color: WIDGET_COLOR,
              ),
              Text(
                '  設定',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white),
              ),
            ])
          ],
        ),
      ),
      body: MyWidget(initIndex: initIndex ?? 0),
    );
  }
}

//サイドメニュー//////////////////////////////////////////////////////
class MyWidget extends ConsumerStatefulWidget {
  int initIndex = 0;
  
  MyWidget({
    required this.initIndex,
    super.key});

  @override
  ConsumerState<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends ConsumerState<MyWidget> {
  int _selectedIndex = 0;

    @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initIndex;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            labelType: NavigationRailLabelType.selected,
            selectedIconTheme: const IconThemeData(color: MAIN_COLOR),
            selectedLabelTextStyle: const TextStyle(color: MAIN_COLOR),
            elevation: 20,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.calendar_today),
                label: Text('カレンダー'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.notifications_active),
                label: Text('通知'),
              ),
            ],
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          MainContents(index: _selectedIndex)
        ],
      ),
    );
  }
}

class MainContents extends ConsumerStatefulWidget {
  final int index;
  const MainContents({super.key, required this.index});
  @override
  ConsumerState<MainContents> createState() => _MainContentsState();
}

class _MainContentsState extends ConsumerState<MainContents> {
  final FocusNode _nodeText1 = FocusNode();
  TextEditingController controller = TextEditingController();

  KeyboardActionsConfig _buildConfig(TextEditingController controller) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor: Colors.white,
      nextFocus: false,
      actions: [
        KeyboardActionsItem(
          focusNode: _nodeText1,
          toolbarAlignment: MainAxisAlignment.start,
          displayArrows: false,
          toolbarButtons: [
            (node) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Stack(
                  children: [
                    Container(
                        margin: const EdgeInsets.only(left: 0),
                        child: Row(children: [
                          SizedBox(width: SizeConfig.blockSizeHorizontal! * 80),
                          GestureDetector(
                            onTap: () {
                              updateConfigInfo("taskList", controller.text);
                              node.unfocus();
                            },
                            child: const Text(
                              "完了",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ])),
                  ],
                ),
              );
            }
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    switch (widget.index) {

      case 0:
        return Expanded(
            child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: calendarBody(),
        ));

       default:
        return Expanded(
          child: SingleChildScrollView(
            child:Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: notificationBody(),
        )));

    }
  }

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  Widget calendarBody() {
    Widget borderModel =
      const Column(children:[
        SizedBox(height: 2.5),
        Divider(height:1),
        SizedBox(height: 2.5),
      ]);

    return KeyboardActions(
        config: _buildConfig(controller),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            'カレンダー設定…',
            style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal! * 7,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
              decoration: roundedBoxdecorationWithShadow(),
              padding: const EdgeInsets.symmetric(horizontal:5,vertical:10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '画面表示のカスタマイズ',
                      style: TextStyle(
                          fontSize: SizeConfig.blockSizeHorizontal!*5),
                    ),
                    const Divider(height:2,thickness:2,color:ACCENT_COLOR,),
                    const SizedBox(height:2),
                    configSwitch("Tipsとお知らせ", "tips"),
                    borderModel,
                    configSwitch("きょうの予定", "todaysSchedule"),
                    borderModel,
                    configSwitch("近日締切のタスク", "taskList"),
                    const SizedBox(height: 5),
                    configTextField("表示日数：", "taskList", controller),
                    borderModel,
                    configSwitch("Waseda Moodle リンク", "moodleLink"),
                    borderModel,
                    configSwitch("アルバイト推計収入", "arbeitPreview"),
                    borderModel,
                  ])),
                
                const SizedBox(height:10),

          Container(
              decoration: roundedBoxdecorationWithShadow(),
              padding: const EdgeInsets.symmetric(horizontal:5,vertical:10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'カレンダーの設定',
                      style: TextStyle(
                          fontSize: SizeConfig.blockSizeHorizontal! *5),
                    ),
                    const Divider(height:2,thickness:2,color:ACCENT_COLOR,),
                    const SizedBox(height:2),
                    configSwitch("土日祝日の着色", "holidayPaint"),
                    borderModel,
                    configSwitch("祝日名の表示", "holidayName"),
                    borderModel,
                  ]))

        ]));
  }

  Widget configSwitch(String configText, String widgetName) {
    return Row(children: [
      const SizedBox(width:5),
      Text(
        configText,
        style: TextStyle(
          fontSize: SizeConfig.blockSizeHorizontal! * 4,
        ),
      ),
      const Spacer(),
      CupertinoSwitch(
          value: searchConfigData(widgetName),
          activeColor: ACCENT_COLOR,
          onChanged: (value) {
            updateConfigData(widgetName, value);
          }),
    ]);
  }

  Widget configTextField(
      String configText, String widgetName, TextEditingController controller) {
    controller.selection = TextSelection.fromPosition(
      //入力文字のカーソルの位置を管理
      TextPosition(offset: controller.text.length),
    ); //入力されている文字数を取得し、その位置にカーソルを移動することで末尾にカーソルを当てる
    controller.text = searchConfigInfo(widgetName);
    return Row(children: [
      const Spacer(),
      Text(
        configText,
        style: TextStyle(
          fontSize: SizeConfig.blockSizeHorizontal! * 4,
        ),
      ),
      Expanded(
        child: CupertinoTextField(
            controller: controller,
            focusNode: _nodeText1,
            onSubmitted: (value) {
              updateConfigInfo(widgetName, value);
            },
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
            ]),
      )
    ]);
  }

  bool searchConfigData(String widgetName) {
    final calendarData = ref.watch(calendarDataProvider);
    int result = 0;
    for (var data in calendarData.configData) {
      String targetWidgetName = data["widgetName"];

      if (targetWidgetName == widgetName) {
        result = data["isVisible"];
      }
    }

    if (result == 1) {
      return true;
    } else {
      return false;
    }
  }

  String searchConfigInfo(String widgetName) {
    final calendarData = ref.watch(calendarDataProvider);
    String result = "";
    for (var data in calendarData.configData) {
      String targetWidgetName = data["widgetName"];
      if (targetWidgetName == widgetName) {
        result = data["info"];
      }
    }

    return result;
  }

  Future<void> updateConfigData(String widgetName, bool value) async {
    final calendarData = ref.watch(calendarDataProvider);
    int result = 0;

    if (value) {
      result = 1;
    }

    for (var data in calendarData.configData) {
      String targetWidgetName = data["widgetName"];

      if (targetWidgetName == widgetName) {
        await CalendarConfigDatabaseHelper().updateCalendarConfig({
          "id": data["id"],
          "widgetName": data["widgetName"],
          "isVisible": result,
          "info": "0"
        });
        ref.read(calendarDataProvider.notifier).state = CalendarData();
        ref.read(calendarDataProvider).getTagData(TagDataLoader().getTagDataSource());
        await ConfigDataLoader().initConfig(ref);
        await CalendarDataLoader().insertDataToProvider(ref);
        
        setState(() {});
      }
    }
  }

  Future<void> updateConfigInfo(String widgetName, String info) async {
    final calendarData = ref.watch(calendarDataProvider);
    if (info == "") {
      info = "0";
    }
    if (int.parse(info) > 100) {
      info = "100";
    }
    for (var data in calendarData.configData) {
      String targetWidgetName = data["widgetName"];

      if (targetWidgetName == widgetName) {
        await CalendarConfigDatabaseHelper().updateCalendarConfig({
          "id": data["id"],
          "widgetName": data["widgetName"],
          "isVisible": data["isVisible"],
          "info": info
        });
        ref.read(calendarDataProvider.notifier).state = CalendarData();
        ref.read(calendarDataProvider).getTagData(TagDataLoader().getTagDataSource());
        await ConfigDataLoader().initConfig(ref);
        await CalendarDataLoader().insertDataToProvider(ref);

        setState(() {});
      }
    }
  }

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


  Widget notificationBody() {
    
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        '通知設定…',
        style: TextStyle(
            fontSize: SizeConfig.blockSizeHorizontal! * 7,
            fontWeight: FontWeight.bold),
      ),
      const SizedBox(height:5),
      Container(
        decoration: roundedBoxdecorationWithShadow(),
        padding: const EdgeInsets.all(7.5),
        child:Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
          Text(
            '通知頻度の設定',
            style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal! * 5),
          ),
          const Divider(height:2,thickness:2,color:ACCENT_COLOR,),
          const SizedBox(height:2),
          notificationFrequencySetting(),
          const SizedBox(height:1),
          const Text(" ■ 設定済み通知",style:TextStyle(color:Colors.grey),),
          //const Divider(height:1),
          showNotificationList([{
            "id":1,
            "notyfyType":"weekly",
            "weekDay":3,
            "time":"08:00",
            "days":3,
            "isValidNotify":1
          }])
        ])
      ),
      const SizedBox(height: 10),
      Container(
          decoration: roundedBoxdecorationWithShadow(),
          padding: const EdgeInsets.all(7.5),
          child:Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children:[
            Text(
              '通知フォーマットの設定',
              style: TextStyle(
                  fontSize: SizeConfig.blockSizeHorizontal! * 5),
            ),
            const Divider(height:2,thickness:2,color:ACCENT_COLOR,),
            const SizedBox(height:2),
            notificarionFormatSetting(),
          ])
      ),
      const SizedBox(height:20)
    ])
    ;
  }

  String? notifyType;
  int? weekDay;
  String time = "08:00";
  String timeForPreview = "08時間00分";
  int days = 1;

  Widget notificationFrequencySetting(){

    Widget borderModel =
      const Column(children:[
        SizedBox(height: 2.5),
        Divider(height:1),
        SizedBox(height: 2.5),
    ]);

  return Column(
    children: [

      IntrinsicHeight(
        child:Row(children: [
          SizedBox(
            width: SizeConfig.blockSizeHorizontal! * 32,
            child: DropdownButtonFormField(
              decoration:const InputDecoration.collapsed(
                hintText: "通知する日",
                border: OutlineInputBorder()
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text(" 毎日")),
                DropdownMenuItem(value: 1, child: Text(" 毎週月曜日")),
                DropdownMenuItem(value: 2, child: Text(" 毎週火曜日")),
                DropdownMenuItem(value: 3, child: Text(" 毎週水曜日")),
                DropdownMenuItem(value: 4, child: Text(" 毎週木曜日")),
                DropdownMenuItem(value: 5, child: Text(" 毎週金曜日")),
                DropdownMenuItem(value: 6, child: Text(" 毎週土曜日")),
                DropdownMenuItem(value: 7, child: Text(" 毎週日曜日")),
              ],
              onChanged: (value){
                setState(() {
                  weekDay = value;
                });
              },
            ),
          ),
          SizedBox(width:SizeConfig.blockSizeHorizontal! *2),
          GestureDetector(
            onTap: () async{
              DateTime now = DateTime.now();
              await DatePicker.showTimePicker(context,
                showTitleActions: true,
                showSecondsColumn: false,
                onConfirm: (date) {
                  setState((){
                    time=DateFormat("HH:mm").format(date);
                  });
                },
                currentTime: DateTime(now.year,now.month,now.day,12,00),
                locale: LocaleType.jp
              );
            },
            child:Container(
              padding:const EdgeInsets.symmetric(horizontal: 2.5),
              decoration: BoxDecoration(
                border: Border.all(color: const Color.fromARGB(255, 100, 100, 100),width:1),
                borderRadius:BorderRadius.circular(5),
              ),
              child:Row(children:[
                Text(time,style:const TextStyle(fontWeight:FontWeight.bold)),
                const Icon(Icons.arrow_drop_down, color:Color.fromARGB(255, 100, 100, 100))
              ])
            ),
          ),
          const Text(" に"),
        ]),
      ),
      IntrinsicHeight(
        child:Row(children: [
          SizedBox(
            width: SizeConfig.blockSizeHorizontal! * 15,
            child: DropdownButtonFormField(
              decoration:const InputDecoration.collapsed(
                hintText: "日数",
                border: OutlineInputBorder()
              ),
              items: const [
                DropdownMenuItem(value: 1, child: Text(" １")),
                DropdownMenuItem(value: 2, child: Text(" ２")),
                DropdownMenuItem(value: 3, child: Text(" ３")),
                DropdownMenuItem(value: 4, child: Text(" ４")),
                DropdownMenuItem(value: 5, child: Text(" ５")),
                DropdownMenuItem(value: 6, child: Text(" ６")),
                DropdownMenuItem(value: 7, child: Text(" ７")),
                DropdownMenuItem(value: 8, child: Text(" ８")),
              ],
              onChanged: (value){
                setState(() {
                  days = value!;
                });
              },
            ),
          ),
          const Text(" 日分を通知"),
          const Spacer(),
          GestureDetector(
            onTap: () {
              if(weekDay == null){
                notifyType = "dayly";
              }else{
                notifyType = "weekly";
              }
              setState(() {});
              //ここでDB登録！！
              print(notifyType);
              print(weekDay);
              print(time);
              print(days);

            },
            child:Container(
              padding:const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color:ACCENT_COLOR,
                border: Border.all(color:const Color.fromARGB(255, 255, 216, 130),width:1),
                borderRadius:BorderRadius.circular(5),
              ),
              child:const Row(children:[
                Text("   追加   ",
                  style:TextStyle(
                    fontWeight:FontWeight.bold,
                    color:Colors.white
                  )
                ),
              ])
            ),
          ),
          const SizedBox(width:5)
        ]),
      ),

      borderModel,
      
      const SizedBox(height:7),
      IntrinsicHeight(
        child:Row(children: [
          const Text("期限/予定の  "),
          GestureDetector(
            onTap: () async{
              DateTime now = DateTime.now();
              await DatePicker.showTimePicker(context,
                showTitleActions: true,
                showSecondsColumn: false,
                onConfirm: (date) {
                  setState((){
                    timeForPreview=DateFormat("HH時間mm分").format(date);
                    time=DateFormat("HH:mm").format(date);
                  });
                },
                currentTime: DateTime(now.year,now.month,now.day,12,00),
                locale: LocaleType.jp
              );
            },
            child:Container(
              padding:const EdgeInsets.symmetric(horizontal: 2.5),
              decoration: BoxDecoration(
                border: Border.all(color: const Color.fromARGB(255, 100, 100, 100),width:1),
                borderRadius:BorderRadius.circular(5),
              ),
              child:Row(children:[
                Text(timeForPreview,style:const TextStyle(fontWeight:FontWeight.bold)),
                const Icon(Icons.arrow_drop_down, color:Color.fromARGB(255, 100, 100, 100))
              ])
            ),
          ),
          const Text(" 前"),
        ]),
      ),
      const SizedBox(height:14),
      IntrinsicHeight(
        child:Row(children: [
          const Text("に通知"),
          const Spacer(),
          GestureDetector(
            onTap: () {
              notifyType = "beforeHour";
              setState(() {

              });
              //ここでDB登録！！
              print(notifyType);
              print(weekDay);
              print(time);

            },
            child:Container(
              padding:const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color:ACCENT_COLOR,
                border: Border.all(color:const Color.fromARGB(255, 255, 216, 130),width:1),
                borderRadius:BorderRadius.circular(5),
              ),
              child:const Row(children:[
                Text("   追加   ",
                  style:TextStyle(
                    fontWeight:FontWeight.bold,
                    color:Colors.white
                  )
                ),
              ])
            ),
          ),
          const SizedBox(width:5)
        ]),
      ),
      const SizedBox(height:7),
    
    borderModel
    ]);
  }

  Widget showNotificationList(List<Map>? map){
    if(map == null){
      return noneSettingWidget();
    }else{
      return notificationSettingList(map);
    }
  }

  Widget notificationSettingList(List<Map> map){
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder:((context, index) {
        Map target = map.elementAt(index);
        int id = target["id"];
        int? weekDay = target["weekDay"];
        String time = target["time"];
        int? days = target["days"];
        int isValidNotify = target["isValidNotify"];
        Color buttonColor = Colors.grey;
        String buttonText = "通知OFF";
        
        if(isValidNotify == 1){
          buttonColor = ACCENT_COLOR;
          buttonText = "通知ON";
        }

        return Card(
          child:Padding(
           padding:const EdgeInsets.all(5),
           child:Row(
            children:[
            InkWell(
              onTap:(){
                //ここに削除の処理
                id;

                setState(() {
                  
                });
              },
              child:const Icon(Icons.delete)),
            const Spacer(),
            Column(children:[
              Row(children:[
                const Text(" "),
                Text(getDayOfWeek(weekDay)),
                const Text(" "),
                Text(time)
              ]),
              Row(children:[
                const Text(" "),
                Text(days.toString()+" 日分",
                  style:const TextStyle(color:Colors.grey)),
              ]),
            ]),
            const Spacer(),
            GestureDetector(
            onTap: () {
              //通知のON　OFFの切り替え処理をします
              id;
              setState(() {
                
              });
            },
            child:Container(
              padding:const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color:buttonColor,
                border: Border.all(color:const Color.fromARGB(255, 255, 216, 130),width:1),
                borderRadius:BorderRadius.circular(5),
              ),
              child:Row(children:[
                Text(buttonText,
                  style:const TextStyle(
                    fontWeight:FontWeight.bold,
                    color:Colors.white
                  )
                ),
              ])
            ),
          ),
          ]))
          
        );
      }),
      separatorBuilder: ((context, index) {
        return const SizedBox(height:2);
      }),
      itemCount: map.length);
  }

  Widget noneSettingWidget(){
    return SizedBox(
      height: SizeConfig.blockSizeVertical! *10,
      child:const Center(
        child:Text(
          "登録されている通知はありません。",
          style:TextStyle(color:Colors.grey))
      ),
    );
  }

  String? notificationFormat;
  bool isContainWeekDay = true;
  Widget notificarionFormatSetting(){

    String weekDayText = "";
    if(isContainWeekDay 
      && notificationFormat != null){
      weekDayText = DateFormat("(E)","ja_JP").format(DateTime.now());
    }

    String thumbnailText = "";
    if(notificationFormat != null){
      thumbnailText = DateFormat(notificationFormat).format(DateTime.now());
    }else{
      thumbnailText = "今日    明日";
    }

    return Column(
     children: [

      IntrinsicHeight(
        child:Row(children: [
          const Text("日付の形式  "),
          SizedBox(
            width: SizeConfig.blockSizeHorizontal! * 45,
            child: DropdownButtonFormField(
              decoration:const InputDecoration.collapsed(
                hintText: "日付の形式",
                border: OutlineInputBorder()
              ),
              items: const [
                DropdownMenuItem(value: "MM月dd日", child: Text(" MM月dd日")),
                DropdownMenuItem(value: "MM/dd", child: Text(" MM/dd")),
                DropdownMenuItem(value: "dd/MM", child: Text(" dd/MM")),
                DropdownMenuItem(value: null, child: Text(" 相対")),
              ],
              onChanged: (value){
                setState(() {
                  notificationFormat = value;
                });
              },
            ),
          ),
        ]),
      ),
      IntrinsicHeight(
        child:Row(children: [
          const Text("曜日を含む："),
          CupertinoCheckbox(
            activeColor: ACCENT_COLOR,
            value: isContainWeekDay,
            onChanged:(value){
              setState(() {
                isContainWeekDay = value!;
              });
            }),
          const Spacer(),
          GestureDetector(
            onTap: () {
              setState(() {});

              //ここでDB登録！！
              print(notificationFormat);
              print(isContainWeekDay);

            },
            child:Container(
              padding:const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color:Colors.orange,
                border: Border.all(color:const Color.fromARGB(255, 255, 216, 130),width:1),
                borderRadius:BorderRadius.circular(5),
              ),
              child:const Row(children:[
                Text("   変更   ",
                  style:TextStyle(
                    fontWeight:FontWeight.bold,
                    color:Colors.white
                  )
                ),
              ])
            ),
          ),
          const SizedBox(width:5)
        ]),
      ),
      const Divider(height:1),
      const SizedBox(height:5),
      Text(thumbnailText + weekDayText,
        style:const TextStyle(fontWeight: FontWeight.bold,fontSize:20)),
    ]);
  }

  String getDayOfWeek(int? dayIndex) {
    switch (dayIndex) {
      case DateTime.monday:
        return "毎週月曜日";
      case DateTime.tuesday:
        return "毎週火曜日";
      case DateTime.wednesday:
        return "毎週水曜日";
      case DateTime.thursday:
        return "毎週木曜日";
      case DateTime.friday:
        return "毎週金曜日";
      case DateTime.saturday:
        return "毎週土曜日";
      case DateTime.sunday:
        return "毎週日曜日";
      default:
        return "毎日";
    }
  }


}
