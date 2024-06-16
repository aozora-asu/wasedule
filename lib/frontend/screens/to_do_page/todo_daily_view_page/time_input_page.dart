import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/frontend/screens/common/app_bar.dart';
import 'package:flutter_calandar_app/backend/DB/handler/todo_db_handler.dart';
import 'package:flutter_calandar_app/frontend/screens/to_do_page/todo_assist_files/data_receiver.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class TimeInputPage extends ConsumerStatefulWidget{
  late Map<String,dynamic> targetDayData;

  TimeInputPage({super.key, 
    required this.targetDayData,
  });

  @override
  TimeInputPageState createState() =>  TimeInputPageState();
}

class  TimeInputPageState extends ConsumerState<TimeInputPage> {
  Map<String,int> userImput = {};
    @override
  void initState() {
    super.initState();
    userImput = {"hourDigit10":0,"hourDigit1":0,"minuteDigit10":0,"minuteDigit1":0};
  }

  @override
  Widget build(BuildContext context){
  SizeConfig().init(context);
   return Scaffold(
    appBar:CustomAppBar(backButton: true,),
    floatingActionButton: backButton(),
    body: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children:[
    Text(
      "${" " + widget.targetDayData["date"]}の勉強時間",
      style: const TextStyle(fontSize: 30,fontWeight: FontWeight.bold,color:Colors.white),
    ),
    const SizedBox(height: 15),
    Row(children:[numPanel(1,"時間"),numPanel(2,"時間"),numPanel(3,"時間"),numPanel(4,"時間"),numPanel(5,"時間")]),
    Row(children:[numPanel(6,"時間"),numPanel(7,"時間"),numPanel(8,"時間"),numPanel(9,"時間"),numPanel(0,"時間")]),
    imputButton("時間"),
    const SizedBox(height: 15),
    Row(children:[numPanel(1,"分"),numPanel(2,"分"),numPanel(3,"分"),numPanel(4,"分"),numPanel(5,"分")]),
    Row(children:[numPanel(6,"分"),numPanel(7,"分"),numPanel(8,"分"),numPanel(9,"分"),numPanel(0,"分")]),
    imputButton("分"),
    const SizedBox(height: 15),
    const Divider(indent: 7,endIndent: 7,thickness: 4),
    submitButton()
    ])
   );
  }

  Widget numPanel(int num,String category){
     return InkWell(
      child:Container(
      width: SizeConfig.blockSizeHorizontal! *20,
      height: SizeConfig.blockSizeHorizontal! *20,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0), // 角丸の半径を指定
        border: Border.all(
          color: Colors.grey, // ボーダーの色
          width: 2.0, // ボーダーの幅
        ),
      ),
      child: Center(
        child: Text(
          num.toString(),
          style: const TextStyle(fontSize: 20),
        ),
      ),
    ),
    onTap:(){
      if(category == "時間"){

       if(userImput["hourDigit10"]! > 2){

        setState((){
        userImput["hourDigit10"] = 2;
        userImput["hourDigit1"] = 4;
        });

       }else{

        if(userImput["hourDigit10"] == 0 && userImput["hourDigit1"] == 0){
          
        setState((){
           userImput["hourDigit1"] = num;
        });

        }else{
          
        setState((){
           userImput["hourDigit10"] = userImput["hourDigit1"]!;
           userImput["hourDigit1"] = num;
        });

        if(userImput["hourDigit10"]!*10 + userImput["hourDigit1"]! > 24){
         setState((){
          userImput["hourDigit10"] = 2;
          userImput["hourDigit1"] = 4;
          });
        }
        }
       }

      }else{

       if(userImput["minuteDigit10"]! > 6){

        setState((){
        userImput["minuteDigit10"] = 0;
        userImput["minuteDigit1"] = 0;
        });

       }else{

        if(userImput["minuteDigit10"] == 0 && userImput["minuteDigit1"] == 0){
          
        setState((){
           userImput["minuteDigit1"] = num;
        });

        }else{
          
        setState((){
           userImput["minuteDigit10"] = userImput["minuteDigit1"]!;
           userImput["minuteDigit1"] = num;
        });

        if(userImput["minuteDigit10"]!*10 + userImput["minuteDigit10"]! > 60){
         setState((){
          userImput["minuteDigit10"] = 0;
          userImput["minuteDigit1"] = 0;
        });
        }
      }
      }
    }
    }
  );
}

  Widget backButton(){
    return FloatingActionButton.extended(
      backgroundColor:MAIN_COLOR,
      onPressed: (){Navigator.pop(context);},
      label:const Text("戻る",style:TextStyle(color:Colors.white)),
      );
  }

Widget imputButton(String category){
  return ElevatedButton(
            onPressed: () {
              if(category == "時間"){
                setState(() {
                userImput["hourDigit10"] = 0;
                userImput["hourDigit1"] = 0;                  
                });
              }else{
                setState(() {
                userImput["minuteDigit10"] = 0;
                userImput["minuteDigit1"] = 0;                  
                });
              }
            },
            style: ElevatedButton.styleFrom(
              fixedSize: Size(SizeConfig.blockSizeHorizontal! *100, SizeConfig.blockSizeVertical! *5,),
              backgroundColor: Colors.blueAccent, // ボタンの背景色
              textStyle: const TextStyle(color:Colors.white), // テキストの色
            ),
            child: Row(
              children:[
              const Spacer(),
              Text(preview(category) + category,style:const TextStyle(color:Colors.white)),
              const SizedBox(width:20),
              const Icon(Icons.delete,color: Colors.white,),
              const Spacer(),
              ]), // ボタンのテキスト
          );
}

String preview(category){
  if(category == "時間"){
    return userImput["hourDigit10"].toString() + userImput["hourDigit1"].toString();
  }else{
    return userImput["minuteDigit10"].toString() + userImput["minuteDigit1"].toString();
  }
}

Widget submitButton(){

    return ElevatedButton(
            onPressed: () async{
             Duration inputResult;
             int hour = 0;
             int minute = 0;
              hour = int.parse(userImput["hourDigit10"].toString() + userImput["hourDigit1"].toString());
              minute = int.parse(userImput["minuteDigit10"].toString() + userImput["minuteDigit1"].toString());
              inputResult = Duration(hours: hour,minutes:minute);

                 await DataBaseHelper().upDateDB(
                  widget.targetDayData["date"],
                  inputResult,
                  widget.targetDayData["schedule"], 
                  widget.targetDayData["plan"], 
                  widget.targetDayData["record"],
                  widget.targetDayData["timeStamp"]
                 );
                 ref.read(dataProvider.notifier).state = Data();
                 ref.read(dataProvider).isRenewed = true;
             Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              fixedSize: Size(SizeConfig.blockSizeHorizontal! *100, SizeConfig.blockSizeVertical! *5,),
              backgroundColor: MAIN_COLOR, // ボタンの背景色
              textStyle: const TextStyle(color:Colors.white), // テキストの色
            ),
            child:
              Text(
                "${userImput["hourDigit10"]}${userImput["hourDigit1"]}時間${userImput["minuteDigit10"]}${userImput["minuteDigit1"]}分で登録",
                style: const TextStyle(color:Colors.white)
                ),
          );
}

}