import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/frontend/assist_files/ui_components.dart';
import 'package:flutter_calandar_app/frontend/screens/menu_pages/university_schedule.dart';
import 'package:flutter_calandar_app/frontend/screens/moodle_view_page/syllabus_query_request.dart';
import 'package:flutter_calandar_app/frontend/screens/moodle_view_page/syllabus_query_result.dart';
import 'package:flutter_calandar_app/static/constant.dart';


class SyllabusSearchDialog extends StatefulWidget{
  Term? gakki;
  DayOfWeek? youbi;
  Lesson? jigen;
  Department? gakubu;

  SyllabusSearchDialog({
    this.gakki,
    this.youbi,
    this.jigen,
    this.gakubu,
  });

  @override
  _SyllabusSearchDialogState createState() => _SyllabusSearchDialogState();
}

class _SyllabusSearchDialogState extends State<SyllabusSearchDialog> {
  late SyllabusRequestQuery requestQuery;

  @override
  void initState() {
    super.initState();
    requestQuery = SyllabusRequestQuery(
      keyword: "",
      kamoku: "",
      p_gakki: widget.gakki,
      p_youbi: widget.youbi,
      p_jigen: widget.jigen,
      p_gakubu: widget.gakubu,
      p_gengo: null,
      p_open: false,
      subjectClassification: null,
    );
  }



  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:(){},
      child:searchWindow());
  }

  Widget searchWindow() {
    String courseTimeText;
    String year = returnFiscalYear(DateTime.now()).toString();

    if (widget.youbi != null && widget.jigen != null) {
      courseTimeText =
          "$year年 / ${widget.gakki?.text} / ${widget.youbi?.text}曜日 / ${widget.jigen!.period}限";
    } else {
      courseTimeText = "$year年 / ${widget.gakki?.text} / オンデマンド / 時限なし";
    }

    TextStyle searchConditionTextStyle = const TextStyle(
      fontSize: 15,
      color: Colors.grey,
    );

    return Container(
      decoration: roundedBoxdecorationWithShadow(radiusType: 3),
      width: SizeConfig.blockSizeHorizontal! * 100,
      padding: const EdgeInsets.symmetric(horizontal: 12.5,vertical: 5),
      child: Column(
        children: [
          
          Row(children:[
            const SizedBox(
              width:80,
              child: Text(
                "候補",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
              ),
            )),
            const Spacer(),
            Text(courseTimeText,style: searchConditionTextStyle,),
            const Spacer(),
          ]),
          const Divider(),
          Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  "学部",
                  style: searchConditionTextStyle,
                  textAlign: TextAlign.center,
                ),
              ),
              departmentPicker(widget.gakubu),
            ],
          ),
          const SizedBox(height:5),
          subjectClassificationPicker(searchConditionTextStyle),
          const SizedBox(height:5),
          Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  "キーワード",
                  style: searchConditionTextStyle,
                  textAlign: TextAlign.center,
                ),
              ),
              searchTextField(
                TextEditingController(text:requestQuery.keyword),
                (value){requestQuery.keyword = value;}),
            ],
          ),
          const SizedBox(height:5),
          Row(
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  "オープン科目",
                  style: searchConditionTextStyle,
                  textAlign: TextAlign.center,
                ),
              ),
              CupertinoCheckbox(
                value: requestQuery.p_open,
                onChanged: (value){
                  setState(() {
                    requestQuery.p_open = value!;
                  });
                })
            ],
          ),
          const Divider(),
          searchResult()
        ],
      ),
    );
  }

  Widget searchTextField(TextEditingController controller, Function(String) onSubmitted){

    return Expanded(
      child:CupertinoTextField(
        controller: controller,
        onSubmitted: (value) {
          setState(() {
            onSubmitted(value);
          });
        },
      ));
  }

  Widget departmentPicker(Department? gakubu) {
    List<Department?> items = Department.departments;
    items.insert(0,gakubu);

    return Expanded(
      child: CupertinoPicker(
        useMagnifier: true,
        itemExtent: 32.0,
        onSelectedItemChanged: (int index) {
          setState(() {
            requestQuery.p_gakubu = items.elementAt(index);
          });
        },
        children: List<Widget>.generate(items.length, (int index) {
          return Center(
            child: Text(items[index]?.text ?? "学部なし"),
          );
        }),
      ),
    );
  }

  Widget subjectClassificationPicker(TextStyle searchConditionTextStyle) {
    Widget value;
    Department? gakubu = requestQuery.p_gakubu;

    if(gakubu == null || gakubu.subjectClassifications == null){
      value = const SizedBox(); 
    }else{     
    List<SubjectClassification> items =
      gakubu.subjectClassifications!;

      value = Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  "科目区分",
                  style: searchConditionTextStyle,
                  textAlign: TextAlign.center,
                ),
              ), 
        Expanded(
        child: CupertinoPicker(
          useMagnifier: true,
          itemExtent: 32.0,
          onSelectedItemChanged: (int index) {
            setState(() {
              requestQuery.subjectClassification;
            });
          },
          children: List<Widget>.generate(items.length, (int index) {
            return Center(
              child: Text(items[index].text),
            );
          }),
        ),
      )
    ]);
  }

    return  value;
  }

  Widget searchResult(){
    print(requestQuery.p_gakubu!.text);
    print(requestQuery.p_gakki!.text);
    print(requestQuery.p_youbi!.text);
    print(requestQuery.p_jigen!.text);
    print(requestQuery.keyword);
    print(requestQuery.p_open);
    return StreamBuilder(
      stream: requestQuery.fetchAllSyllabusInfo(),
      builder: (context,snapShot){
        if(snapShot.connectionState == ConnectionState.waiting){
          return const SizedBox(
            height:70,
            child:Center(
              child:CircularProgressIndicator(color:PALE_MAIN_COLOR)));
        }else if(snapShot.hasData){
          return ListView.separated(
            itemBuilder:(context,index){
              return Text(snapShot.data!.courseName);
            },
            separatorBuilder:(context,index){
              return const SizedBox(height:5);
            },
            itemCount: 3,//snapShot.data!.length,
            shrinkWrap: true,
            );
        }else if(snapShot.hasError){
          return Text(snapShot.error.toString());
        }else{
          return const SizedBox(
            height:70,
            child:Center(
              child:Text("検索結果なし",
                style:TextStyle(color:Colors.grey))));
        }
      },);
  }

}
