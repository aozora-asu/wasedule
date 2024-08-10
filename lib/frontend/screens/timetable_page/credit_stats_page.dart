import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/handler/my_grade_db.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/assist_files/ui_components.dart';
import 'package:flutter_calandar_app/frontend/screens/common/tutorials.dart';

class CreditStatsPage extends StatefulWidget{
  Function() moveToMyWaseda;

  CreditStatsPage({
    required this.moveToMyWaseda
  });
  @override
  _CreditStatsPageState createState() => _CreditStatsPageState();
}

class _CreditStatsPageState extends State<CreditStatsPage>{
  @override
  Widget build(BuildContext context){
    
    // MyGrade(
    //   courseName: courseName,
    //   credit: credit,
    //    grade: grade,
    //    term: term,
    //    majorClassification: majorClassification,
    //    middleClassification: middleClassification,
    //    minorClassification: minorClassification,
    //    year: year,
    //    gradePoint: gradePoint);

    return Scaffold(
      backgroundColor: BACKGROUND_COLOR,
      body: Padding(
        padding:const EdgeInsets.symmetric(horizontal: 10),
        child:Column(children:[
          pageHeader(),
          const Divider(height: 1),
          Expanded(
            child:ListView(children:[
              individualDataListBuilder(),
            ]))
        ])
    ));
  }

  Widget pageHeader() {
    return Padding(
      padding:const EdgeInsets.symmetric(horizontal: 5,vertical: 5),
      child:Row(children: [
        const Icon(Icons.abc, color: BLUEGREY, size: 30),
        const SizedBox(
          width: 5,
        ),
        const Text(
          "単位情報",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 25,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
          buttonModel(
            () async {
              await showMoodleRegisterGuide(
                  context, false, MoodleRegisterGuideType.credit);
              widget.moveToMyWaseda();
            },
            PALE_MAIN_COLOR,
            "データ取得",
            verticalpadding: 10,
            horizontalPadding: 30),
      ])
    );
  }

  Widget individualDataListBuilder(){
    return FutureBuilder(
      future: MyGrade.getMyGrade(),
      builder: (context,snapshot){
        if(snapshot.hasData){
          return individualDataList(snapshot.data!);
        }else{
          return const SizedBox();
        }
      });
  }

  Widget individualDataList(List<MyGrade> data){
    return ListView.builder(
      itemBuilder: (context,index){
        return Text(data.elementAt(index).courseName);
      },
      itemCount: data.length,
      shrinkWrap: true,
      physics:const NeverScrollableScrollPhysics(),);
  }

}