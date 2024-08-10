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
  Map<String?,List<MyGrade>> majorClassificationGroupMap = {};
  late bool isGPview;

  @override 
  void initState(){
    super.initState();
    isGPview = false;
  }

  void sortDataByMajorClassification(List<MyGrade> data){
    majorClassificationGroupMap = {};
    for(int i = 0; i < data.length; i++){
      MyGrade target = data.elementAt(i);
      if(majorClassificationGroupMap.containsKey(
        target.majorClassification
      )){
        majorClassificationGroupMap[target.majorClassification]!.add(target);
      }else{
        majorClassificationGroupMap[target.majorClassification] = [target];
      }
    }
  }

  Map<String?,List<MyGrade>> sortDataByMiddleClassification(List<MyGrade> data){
    Map<String?,List<MyGrade>> result = {};
    for(int i = 0; i < data.length; i++){
      MyGrade target = data.elementAt(i);
      if(result.containsKey(
        target.middleClassification
      )){
        result[target.middleClassification]!.add(target);
      }else{
        result[target.middleClassification] = [target];
      }
    }
    return result;
  }

  Map<String?,List<MyGrade>> sortDataByMinorClassification(List<MyGrade> data){
    Map<String?,List<MyGrade>> result = {};
    for(int i = 0; i < data.length; i++){
      MyGrade target = data.elementAt(i);
      if(result.containsKey(
        target.minorClassification
      )){
        result[target.minorClassification]!.add(target);
      }else{
        result[target.minorClassification] = [target];
      }
    }
    return result;
  }

  int calculateCreditSum(List<MyGrade> data){
    int result = 0;
    for(int i = 0; i < data.length; i++){
      if(data.elementAt(i).gradePoint != null
        && data.elementAt(i).gradePoint != "0"
        && data.elementAt(i).gradePoint != "＊"){
        result += int.tryParse(data.elementAt(i).credit) ?? 0;
      }
    }
    return result;
  }

  double calculateGradeAverage(List<MyGrade> data){
    double result = 0;
    for(int i = 0; i < data.length; i++){
      if(data.elementAt(i).gradePoint != null){
        result += int.tryParse(data.elementAt(i).gradePoint!) ?? 0;
      }
    }

    double roundedNumber = double.parse(((result / data.length) * 100).round().toString()) / 100;
    return roundedNumber;
  }

  @override
  Widget build(BuildContext context){
    
    return Scaffold(
      backgroundColor: BACKGROUND_COLOR,
      body: Padding(
        padding:const EdgeInsets.symmetric(horizontal: 10),
        child:Column(children:[
          pageHeader(),
          const Divider(height: 1),
          Row(children:[changeGPviewButton()]),
          Expanded(
            child:ListView(children:[
              individualDataListBuilder(),
            ]))
        ])
    ));
  }

  Widget changeGPviewButton(){
    return GestureDetector(
      onTap:(){
        setState(() {
          if(isGPview){
            isGPview = false;
          }else{
            isGPview = true;
          }
        });
      },
      child: Container(
        decoration: roundedBoxdecoration(),
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 1
        ),
        margin: const EdgeInsets.symmetric(
          vertical: 4
        ),
        child:Text(
          isGPview ? "表示：GP" : "表示：成績",
          style:const  TextStyle(
            color: Colors.blue,
            fontSize: 15,
            fontWeight: FontWeight.normal
          ),
        ),
      )
    );
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
        if(snapshot.hasData && snapshot.data != []){
          sortDataByMajorClassification(snapshot.data!);
          return dataListByMajorClassification(snapshot.data!);
        }else{
          return noGradeDataScreen();
        }
      });
  }
  
  Widget noGradeDataScreen() {
    return const SizedBox(
      height: 500,
      child:Center(
        child: Text("成績のデータがありません。",
            style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.normal,
                overflow: TextOverflow.clip,
                fontSize: 20))));
  }

  Widget dataListByMajorClassification(List<MyGrade> data){
    return ListView.builder(
      itemBuilder: (context,index){
        return Column(children: [
          const SizedBox(height:10),
            Text(majorClassificationGroupMap.keys.elementAt(index) ?? "【大分類なし】",
              style:const TextStyle(fontSize:20,fontWeight: FontWeight.bold)),
          dataListByMiddleClassification(index)
        ]);
      },
      itemCount: majorClassificationGroupMap.length,
      shrinkWrap: true,
      physics:const NeverScrollableScrollPhysics(),);
  }


  Widget dataListByMiddleClassification(int index){

  Map<String?,List<MyGrade>> data = 
    sortDataByMiddleClassification(majorClassificationGroupMap.values.elementAt(index));

  TextStyle smallGreyFont = const TextStyle(fontSize:10,fontWeight: FontWeight.normal,color:Colors.grey);

    return ListView.builder(
      itemBuilder: (context,index){

        int creditSum = calculateCreditSum(data.values.elementAt(index));
        double gradeAverage = calculateGradeAverage(data.values.elementAt(index));

        return Column(children: [
          const SizedBox(height:10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children:[
            Text("単位",
              style:smallGreyFont),
            Expanded(
              child:Text(data.keys.elementAt(index) ?? "【中分類なし】",
                overflow: TextOverflow.clip,
                textAlign: TextAlign.center,
                style:const TextStyle(fontSize:17,fontWeight: FontWeight.normal,color:Colors.grey))),
            Text("単位計：$creditSum\nGP平均：$gradeAverage",
              style:smallGreyFont),
          ]),
          dataListByMinorClassification(data.values.elementAt(index))
        ]);
      },
      itemCount: data.keys.length,
      shrinkWrap: true,
      physics:const NeverScrollableScrollPhysics(),);
  }

  Widget dataListByMinorClassification(List<MyGrade> middleClassificationGroupList){
    Map<String?,List<MyGrade>> data = 
      sortDataByMinorClassification(middleClassificationGroupList);

    return ListView.builder(
      itemBuilder: (context,index){
        return Column(children: [
          if(data.keys.elementAt(index) != null)
            const SizedBox(height:10),
          Row(children:[
            if(data.keys.elementAt(index) != null)
              Text(data.keys.elementAt(index)!,
                style:const TextStyle(fontSize:12,fontWeight: FontWeight.normal,color:Colors.grey)),
          ]),
          gradeDataList(data.values.elementAt(index))
        ]);
      },
      itemCount: data.keys.length,
      shrinkWrap: true,
      physics:const NeverScrollableScrollPhysics(),);
  }

  Widget gradeDataList(List<MyGrade> minorClassificationGroupList){
    List<MyGrade> data = minorClassificationGroupList;

    return ListView.builder(
      itemBuilder: (context,index){
        return gradeDataListChild(data.elementAt(index));
      },
      itemCount: data.length,
      shrinkWrap: true,
      physics:const NeverScrollableScrollPhysics(),);
  }

  Widget gradeDataListChild(MyGrade data){
    return Row(children:[
      SizedBox(
        width: 20,
        child: Text(data.credit,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: 
               data.gradePoint == "0" || data.gradePoint == "＊"
                 ? Colors.grey : BLUEGREY
        )),
      ),
      Expanded(child:
        Container(
          decoration: roundedBoxdecoration(radiusType: 2),
          padding:const EdgeInsets.symmetric(horizontal: 7,vertical: 3),
          margin:const EdgeInsets.symmetric(vertical: 1,),
          child:Column(children:[
            Row(children:[
              gradeIcon(data),
              const SizedBox(width: 5),
              Expanded(
                child:Text(data.courseName,
                  style:TextStyle(
                    color: data.gradePoint == "0" ? Colors.grey : Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.bold))),
              Text("${data.year}/${data.term}",
                  style:const TextStyle(fontSize: 10,color:Colors.grey)
              )
            ])
          ])
        )
      )
    ]);
  }

  Widget gradeIcon(MyGrade myGrade){
    String grade = myGrade.grade;
    String gradePoint = myGrade.gradePoint ?? "?";
    Color iconColor;
    
    switch(grade){
      case "A+":{
        iconColor = Colors.red;
      }
      case "A":{
        iconColor = Colors.deepOrangeAccent;
      }
      case "B":{
        iconColor = Colors.blue;
      }
      case "C":{
        iconColor = Colors.green;
      }
      case "F":{
        iconColor = Colors.black;
      }
      case "G":{
        iconColor = Colors.black;
      }
      case "P": {
        iconColor = Colors.pink;
      }
      case "*": {
        iconColor = Colors.grey;
      }
      default:{
        iconColor = Colors.grey;
      }
    }

    return Container(
      margin: const EdgeInsets.all(2),
      padding:const EdgeInsets.symmetric(vertical: 1,horizontal: 4),
      decoration: BoxDecoration(
        color: iconColor,
        borderRadius: BorderRadius.circular(3)
      ),
      constraints:const BoxConstraints(
        minWidth: 25
      ),
      child: Text(isGPview ? gradePoint : grade,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 15,
          color: Colors.white,
          fontWeight: FontWeight.bold),
      ),
    );
  }

}