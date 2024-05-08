import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/frontend/screens/menu_pages/arbeit_stats_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OndemandPreview extends ConsumerStatefulWidget {
  late Map target;
 OndemandPreview({
    required this.target
  });
  @override
  _OndemandPreviewState createState() => _OndemandPreviewState();
}

class _OndemandPreviewState extends ConsumerState<OndemandPreview> {
    TextEditingController memoController = TextEditingController();
    TextEditingController classNameController = TextEditingController();


  @override
  void initState() {
    super.initState();
    Map target = widget.target; 
    memoController.text = target["memo"] ?? "";
    classNameController.text = target["courseName"] ?? "";
  }

  @override
  Widget build(BuildContext context){
    final bottomSpace= MediaQuery.of(context).viewInsets.bottom;
    
    return GestureDetector(
      onTap: (){
        Navigator.pop(context);
      },
      child:LayoutBuilder(builder:
         (BuildContext context, BoxConstraints viewportConstraints) { 
          return SingleChildScrollView(
          reverse: true,
          child:  Padding(
          padding: EdgeInsets.only(bottom: bottomSpace /2),
            child: ConstrainedBox(
                  constraints: BoxConstraints(
                      minHeight: viewportConstraints.maxHeight,
                      maxHeight: viewportConstraints.maxHeight),
                  child:Center(child:
                  SingleChildScrollView(
                    child:Padding(
                      padding:const EdgeInsets.symmetric(horizontal: 5),
                      child:
                      Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:[
                        const SizedBox(height:20),
                        courseInfo(),
                        const SizedBox(height:20),
      ])))))));}));
  }

  Widget courseInfo(){
    Map target = widget.target;
    Widget dividerModel = const Divider(
      height: 2,
    );


    return GestureDetector(
      onTap:(){},
      child:Container(
      decoration:roundedBoxdecorationWithShadow(),
      width: SizeConfig.blockSizeHorizontal! *100,
      child: Padding(
          padding: const EdgeInsets.all(12.5),
          child:Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children:[

            Row(children:[
              textFieldModel("授業名を入力…",classNameController,FontWeight.bold,30.0,
              (value){
                int id = target["id"];
                //＠ここに授業名のアップデート関数！！！
                         
              })
            ]),

            dividerModel, 

            Row(children:[
              SizedBox(width: SizeConfig.blockSizeHorizontal! *1),
              const Icon(Icons.info,color:MAIN_COLOR),
              SizedBox(width: SizeConfig.blockSizeHorizontal! *3),
              Text("オンデマンド/その他",
              style: TextStyle(fontSize: SizeConfig.blockSizeHorizontal! *5,
              fontWeight: FontWeight.bold)),
              SizedBox(width: SizeConfig.blockSizeHorizontal! *3),
              Text(target["year"].toString() + " "+ targetSemester(target["semester"]),
              style: TextStyle(fontSize: SizeConfig.blockSizeHorizontal! *4,
              color:Colors.grey)),
              const Spacer(),
            ]),
            
            dividerModel,

            Row(children:[
              SizedBox(width: SizeConfig.blockSizeHorizontal! *1),
              const Icon(Icons.sticky_note_2,color:MAIN_COLOR),
              SizedBox(width: SizeConfig.blockSizeHorizontal! *3),
              textFieldModel("授業メモを入力…",memoController,
                FontWeight.normal,20.0,
                (value){
                  int id = target["id"];
                  //＠ここにメモのアップデート関数！！！
                  
                }),
            ]),
           
            dividerModel,

            Row(children:[
              const Spacer(),
              
              GestureDetector(child:Icon(Icons.delete,color:Colors.grey),
              onTap:() {
                int id = target["id"];
                //＠ここに削除実行関数！！！ 
              }),
              SizedBox(width: SizeConfig.blockSizeHorizontal! *1),
            ])

          ])
        )
      )
    );
  }

  Widget textFieldModel(
    String hintText,
    TextEditingController controller,
    FontWeight weight,
    double fontSize,
    Function(String) onSubmitted
    ){
      return Expanded(
      child: Material(
        child:TextField(
          controller: controller,
          maxLines:null,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration.collapsed(
            border: InputBorder.none,
            hintText: hintText),
          style: TextStyle(
              color: Colors.black,fontWeight: weight,
              fontSize:fontSize),
          onSubmitted: onSubmitted
          ),
        )
      );
  }

  
  String targetSemester(String semesterID){
    String result = "年間科目";
    if(semesterID == "spring_quarter"){
      result = "春学期 -春クォーター";
    }else if(semesterID == "summer_quarter"){
      result = "春学期 -夏クォーター";
    }else if(semesterID == "spring_semester"){
      result = "春学期";
    }else if(semesterID == "fall_quarter"){
      result = "秋学期 -秋クォーター";
    }else if(semesterID == "winter_quarter"){
      result = "秋学期 -冬クォーター";
    }else if(semesterID == "fall_semester"){
      result = "秋学期";
    }
    return result;
  }


}