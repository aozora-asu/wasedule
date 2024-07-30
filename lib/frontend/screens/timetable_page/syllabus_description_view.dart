

import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/assist_files/ui_components.dart';
import 'package:flutter_calandar_app/frontend/screens/moodle_view_page/syllabus_query_result.dart';
import 'package:flutter_calandar_app/frontend/screens/to_do_page/todo_assist_files/size_config.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

final GlobalKey wineWebViewKey = GlobalKey();
late InAppWebViewController wineWebViewController;

class SyllabusDescriptonView extends StatefulWidget{
  SyllabusQueryResult syllabusQuery;
  bool showHeader;

  SyllabusDescriptonView({
    required this.syllabusQuery,
    required this.showHeader
  });

  @override
  _SyllabusDescriptionViewState createState()=> _SyllabusDescriptionViewState();
}

class _SyllabusDescriptionViewState extends State<SyllabusDescriptonView>{
  late bool isWineView;
  
  @override
  void initState(){
    super.initState();
    isWineView = false;
  }

  @override
  Widget build(BuildContext context){
    SyllabusQueryResult syllabusQuery = widget.syllabusQuery;
    
    return  Column(
        children: [
        if(widget.showHeader) header(),
        const SizedBox(height:5),
        if(!isWineView) descriptionList() else webWineView(syllabusQuery.textbook ?? "")
      ],
    );
  }

  Widget header(){
    SyllabusQueryResult syllabusQuery = widget.syllabusQuery;
    return Padding(
      padding:const  EdgeInsets.symmetric(horizontal: 15,vertical:5),
      child:Row(children: [
        Expanded(
          child:Center(
            child:Text(syllabusQuery.courseName,
              style: const TextStyle(fontWeight: FontWeight.bold,fontSize:25),
              overflow: TextOverflow.clip,))),
        if (isWineView) returnFromWineButton() else addCourseToTimetableButton(),
      ],));
  }

  Widget descriptionList(){
    SyllabusQueryResult syllabusQuery = widget.syllabusQuery;
    return Expanded(
      child:SingleChildScrollView(
        child:Padding(
          padding:const  EdgeInsets.symmetric(horizontal: 15),
          child:Column(children:[
            descriptionElementTile("年度/学期/時限","${syllabusQuery.year.toString()}/${syllabusQuery.semesterAndWeekdayAndPeriod}",radiusType: 1),
            descriptionElementTile("学部",syllabusQuery.department ?? "なし"),
            descriptionElementTile("単位数",syllabusQuery.credit.toString()),
            descriptionElementTile("科目群",syllabusQuery.subjectClassification ?? "なし",fontWeight: FontWeight.normal),
            descriptionElementTile("教室",syllabusQuery.classRoom,fontWeight: FontWeight.normal),
            textBookTile(syllabusQuery.textbook ?? "なし",(){}),
            descriptionElementTile("評価方法",syllabusQuery.criteria.toString()),
            descriptionElementTile("教員",syllabusQuery.teacher ?? "なし",fontWeight: FontWeight.normal),
            descriptionElementTile("概要",syllabusQuery.abstract ?? "なし",fontWeight: FontWeight.normal),
            descriptionElementTile("備考",syllabusQuery.remark ?? "なし",fontWeight: FontWeight.normal),
            descriptionElementTile("授業計画",syllabusQuery.agenda ?? "なし",fontWeight: FontWeight.normal),
            descriptionElementTile("参考文献",syllabusQuery.reference ?? "なし",fontWeight: FontWeight.normal,radiusType: 3),
            const SizedBox(height:15)
        ])
      )
    ));
    
  }

  Widget descriptionElementTile(
   String titleText,String descriptionText,
   {int radiusType = 2,FontWeight fontWeight = FontWeight.bold}){
    return Container(
      decoration: roundedBoxdecorationWithShadow(
        radiusType: radiusType,backgroundColor: BACKGROUND_COLOR),
      margin: const EdgeInsets.symmetric(vertical: 1),
      padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 15),
      child:Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:[
        Text(titleText,style:const TextStyle(color:Colors.grey,fontSize: 15),),
        const SizedBox(width: 10),
        Expanded(
          child:Center(
            child:Text(
              descriptionText,
              style: TextStyle(fontWeight:fontWeight),
        )))
      ]),
    );
  }

  Widget textBookTile(String descriptionText,Function onTap){
    return GestureDetector(
      onTap:(){
        setState(() {
          isWineView = true;
        });
      },
      child:Container(
        decoration: roundedBoxdecorationWithShadow(
          radiusType: 2,backgroundColor: BACKGROUND_COLOR),
        margin: const EdgeInsets.symmetric(vertical: 1),
        padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 15),
        child:Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
          const Text("教科書",style: TextStyle(color:Colors.grey,fontSize: 15),),
          const SizedBox(width: 10),
          const Icon(Icons.search,color:Colors.blue),
          Expanded(
            child:Center(
              child:Text(
                descriptionText,
                style:const TextStyle(
                  color:Colors.blue,
                  fontWeight:FontWeight.bold),
          )))
        ]),
      )
    );
  }

  Widget addCourseToTimetableButton(){
    return buttonModel(
      (){

      },
      BLUEGREY,"追加",horizontalPadding: 30);
  }

  Widget returnFromWineButton(){
    return buttonModel(
      (){
        setState(() {
          isWineView = false;
        });
      },
      Colors.redAccent,"戻る",horizontalPadding: 30);
  }

  Widget webWineView(String searchText){
    num height = 0;
    return Expanded(
     child: Stack(children: [
      Container(
        color: FORGROUND_COLOR.withOpacity(0.6),
        child: Container(
          width: SizeConfig.blockSizeHorizontal! * 100,
          height: SizeConfig.blockSizeVertical! * 50,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey)),
          child: SizedBox(
              width: SizeConfig.blockSizeHorizontal! * 100,
              height: SizeConfig.blockSizeVertical! * height,                
      child: InAppWebView(
                key: wineWebViewKey,
                initialUrlRequest:
                    URLRequest(url: WebUri("https://waseda.primo.exlibrisgroup.com/discovery/search?vid=81SOKEI_WUNI:WINE")),
                onWebViewCreated: (controller) {
                  wineWebViewController = controller;
                },
                onLoadStop: (a, b) async {
                  height = await wineWebViewController
                          .getContentHeight() ??
                      100;
                  setState(() {});
                },
                onContentSizeChanged: (a, b, c) async {
                  height = await wineWebViewController
                          .getContentHeight() ??
                      100;
                  setState(() {});
                },
            )
          )
        )
      )
    ]));
  }

}