import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/handler/my_grade_db.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';

class RequiredCreditsStats extends StatefulWidget{

@override   
_RequiredCreditsStatsState createState()=> _RequiredCreditsStatsState();
}

class _RequiredCreditsStatsState extends State<RequiredCreditsStats>{
  TextStyle categoryStyle = const TextStyle(fontSize: 14, color: Colors.grey);
  TextStyle blackBoldStyle = const TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
  TextStyle numberStyle = const TextStyle(
      fontSize: 18, fontWeight: FontWeight.bold, color: BLUEGREY);
  late List<bool> isExpandedList;
  late bool isExpandedListGenerated;
  
  @override  
  void initState(){
    super.initState();
    isExpandedList = [];
    isExpandedListGenerated = false;
  }

  @override  
  Widget build(BuildContext context){
    return Padding(
      padding:const EdgeInsets.symmetric(horizontal: 10,vertical: 0),
      child:FutureBuilder(
        future: MyGradeDB.getMyCredit(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.majorClass != []) {
            return majorClassificationList(snapshot.data!);
          } else {
            return const SizedBox();
          }
      })
    );
  }

  Widget majorClassificationList(MyCredit creditData){

    if(!isExpandedListGenerated){
      for(int i = 0; i < creditData.majorClass.length; i++){
        isExpandedList.add(false);
      }
      isExpandedListGenerated = true;
    }

    return Column(children:[
      Row(children:[
        Text(creditData.text,style: blackBoldStyle)]),
        requiredCreditsIndicator(creditData.countedCredit,creditData.requiredCredit),
        const Divider(height: 10),
        ListView.separated(
          itemBuilder: (context,index){
            MajorClass item = creditData.majorClass[index];
            return Column(children: [
              Row(children:[
                Expanded(child:
                  Text("${(index+1).toString()}. ${item.text}",style: blackBoldStyle)),
                GestureDetector(
                  onTap:(){
                    setState(() {
                      if(isExpandedList[index]){
                        isExpandedList[index] = false;
                      }else{
                        isExpandedList[index] = true;
                      }
                    });
                  },
                  child: Icon(
                    isExpandedList[index] ? Icons.minimize_rounded : Icons.add_rounded,
                    color:Colors.grey,
                    size:25
                  ),)
                ]),
                requiredCreditsIndicator(item.countedCredit, item.requiredCredit),
                if(isExpandedList[index])
                  const Divider(height:10,indent:15),
                if(isExpandedList[index])
                  middleClassificationList(item.middleClass)
            ]);
          },
          separatorBuilder: (context,index){
            return const Divider(height: 7);
          },
          itemCount: creditData.majorClass.length,
          shrinkWrap: true,
          physics:const NeverScrollableScrollPhysics(),)
    ]);
  }

  Widget middleClassificationList(List<MiddleClass> middleClassList){
    return Row(children:[
      const SizedBox(width: 15),
      Expanded(
        child:ListView.builder(
          itemBuilder: (context,index){
            MiddleClass item = middleClassList[index];
            return Column(children:[
              Row(children:[Text((index + 1).toString() + ". " + item.text,style: categoryStyle)]),
              requiredCreditsIndicator(item.countedCredit, item.requiredCredit,barColor: PALE_MAIN_COLOR)
            ]);
          },
          shrinkWrap: true,
          itemCount: middleClassList.length,
          physics: const NeverScrollableScrollPhysics(),
        )
      )
    ]);
  }

  Widget requiredCreditsIndicator(int countedcredit,int? requiredCredit,{Color barColor = BLUEGREY}){
    String requiredCreditString = requiredCredit!= null ? requiredCredit.toString() : "？";
    int modifiedRequiredCredit = requiredCredit ?? 0;
    if(modifiedRequiredCredit == 0 || countedcredit > modifiedRequiredCredit){
      modifiedRequiredCredit = countedcredit;
    }
    if(countedcredit == 0 && modifiedRequiredCredit == 0){
      modifiedRequiredCredit = 1;
    }
    double indictorValue = countedcredit / modifiedRequiredCredit;

    return Row(children: [
      SizedBox(
        width: 100,
        child:Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children:[
          Text(countedcredit.toString(),style: numberStyle),
          Text(" / ",style: categoryStyle),
          Text(requiredCreditString,style: numberStyle),
          Text(" 単位",style: categoryStyle),
        ]),
      ),
      const SizedBox(width: 5),
      Expanded(
        child:LinearProgressIndicator(
          borderRadius: BorderRadius.circular(3),
          value: indictorValue,
          minHeight: 10,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(barColor)
      )),
    ],);
  }
}