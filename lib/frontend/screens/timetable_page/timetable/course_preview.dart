import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/sharepreference.dart';
import 'package:flutter_calandar_app/backend/service/syllabus_query_request.dart';
import 'package:flutter_calandar_app/frontend/screens/common/bottom_bar.dart';
import 'package:flutter_calandar_app/frontend/screens/common/plain_appbar.dart';
import 'package:flutter_calandar_app/frontend/screens/timetable_page/attend_record/attend_menu_panel.dart';
import 'package:flutter_calandar_app/frontend/screens/timetable_page/syllabus/syllabus_description_view.dart';
import 'package:flutter_calandar_app/frontend/screens/timetable_page/syllabus/syllabus_search_dialog.dart';
import 'package:flutter_calandar_app/static/constant.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/frontend/screens/common/ui_components.dart';
import 'package:flutter_calandar_app/backend/DB/handler/my_course_db.dart';
import 'package:flutter_calandar_app/frontend/screens/task_page/task_modal_sheet.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:intl/intl.dart';

enum CoursePreviewType{
  page,
  modal,
}

class CoursePreview extends ConsumerStatefulWidget {
  late MyCourse target;
  late StateSetter setTimetableState;
  late List<Map<String, dynamic>> taskList;
  late bool isOndemand;
  late CoursePreviewType? type;

  CoursePreview(
      {super.key,
      required this.target,
      required this.setTimetableState,
      required this.taskList,
      required this.isOndemand,
      this.type
      });

  Future<void> showModal(BuildContext context)async{
    final bottomSpace = MediaQuery.of(context).viewInsets.bottom;
    type = CoursePreviewType.modal;

    await showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      backgroundColor: FORGROUND_COLOR,
      builder: (BuildContext context) {
        return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
      return SingleChildScrollView(
          // physics: viewMode == 1
          //     ? const NeverScrollableScrollPhysics()
          //     : const ScrollPhysics(),
          reverse: true,
          child: Padding(
              padding: EdgeInsets.only(bottom: bottomSpace),
              child: ConstrainedBox(
                  constraints: BoxConstraints(
                      minHeight: SizeConfig.blockSizeVertical! *30,
                      maxHeight:  SizeConfig.blockSizeVertical! *70),
                  child:this)
                )
              );
            }
          );
        }
      );
  }

  Future<void> showPage(BuildContext context) async{
    type = CoursePreviewType.page;

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
          this,
        transitionDuration: Duration.zero, // アニメーションの時間を0秒に設定
        reverseTransitionDuration: Duration.zero, // 戻る際も0秒
      ),
    );

  }

  @override
  _CoursePreviewState createState() => _CoursePreviewState();
}

class _CoursePreviewState extends ConsumerState<CoursePreview> {
  TextEditingController memoController = TextEditingController();
  TextEditingController classNameController = TextEditingController();
  TextEditingController classRoomController = TextEditingController();
  TextEditingController classificationController = TextEditingController();
  late int viewMode;
  late bool searchMode;
  late List<Map<String,dynamic>> taskList = [];
  late int pageIndex;

  Widget dividerModel = const Divider(height: 2);
  TextStyle titleStyle = const TextStyle(color:Colors.grey, fontSize: 20,fontWeight: FontWeight.normal);
  late Color colorButtonColor;

  @override
  void initState() {
    super.initState();
    MyCourse target = widget.target;
    taskList = widget.taskList;
    memoController.text = target.memo ?? "";
    classRoomController.text = target.classRoom;
    classNameController.text = target.courseName;
    classificationController.text = target.subjectClassification ?? "";
    viewMode = 0;
    pageIndex = 0;
    searchMode = false;
    colorButtonColor = widget.target.color.toColor() ?? Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    if(widget.type == CoursePreviewType.page){
      return Scaffold(
        backgroundColor: FORGROUND_COLOR,
        appBar: CustomAppBar(
          backButton: true,
          title: appbarHeader(),
        ),
        body: contentBody(),
        bottomNavigationBar: customBottomBar(
          context,
          1, 
          (index){
            if(index == 1){
              Navigator.pop(context);
            }
          },
          setState,
          Colors.transparent),
      );
    }else{
      return contentBody();
    }
  }

  Widget appbarHeader() {
    MyCourse target = widget.target;
    return
     Row(crossAxisAlignment: CrossAxisAlignment.center, children: [

        if(widget.isOndemand)
          const Text("OD/その他",
             style: TextStyle(
              fontSize: 20,
              color:Colors.white,
              fontWeight: FontWeight.bold))
        else
          Text("${target.weekday!.text}曜 ${target.period!.period}限",
            style: const TextStyle(
              fontSize: 20,
              color:Colors.white,
              fontWeight: FontWeight.bold)),

        const SizedBox(width: 10),


        Text(
          "${target.year} ${target.semester?.fullText ?? Term.fullYear.fullText}",
          style: const TextStyle(fontSize: 15, color: Colors.grey),
          overflow: TextOverflow.clip,
        ),

      ]);
  }

  Widget pageModeSwitch(){
    return Container(
      padding:const EdgeInsets.only(top: 7),
      child:FlutterToggleTab
        (height: 30,
          width: SizeConfig.blockSizeHorizontal! *24,
          borderRadius: 5,
          selectedIndex: pageIndex,
          selectedTextStyle:const TextStyle(
            color: Colors.white,
            fontSize: 15
          ),
          unSelectedTextStyle:const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
          labels: const ["概要","出欠","詳細情報"],
          selectedBackgroundColors: const [BLUEGREY,BLUEGREY,BLUEGREY],
          selectedLabelIndex: (index) {
            setState(() {
              pageIndex = index;
            });
          },
          marginSelected:const EdgeInsets.symmetric(horizontal: 2,vertical:3),
          isScroll: true,
          isShadowEnable: false,
        )
    );
  }

  Widget contentBody(){
    return SingleChildScrollView(
        physics: pageIndex == 2
            ? const NeverScrollableScrollPhysics()
            : const ScrollPhysics(),
            child: Container(
              
              decoration: roundedBoxdecoration(
                backgroundColor: FORGROUND_COLOR,
              ),
              child:Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if(widget.type == CoursePreviewType.modal)
                    ModalSheetHeader(),
                  pageModeSwitch(),

                  if(pageIndex == 0)
                    courseInfo(),
                  if(pageIndex == 0)
                    relatedTasks(),
                  if(pageIndex == 1)
                    attendanceRecord(),
                  if(pageIndex == 2)
                    syllabusPageViewBuilder(widget.target)
                ])
              )
          );
  }


  Widget searchPage() {

      return 
        Column(children: [
          if(!widget.isOndemand)
            SyllabusSearchDialog(
                radiusType: 2,
                gakki: widget.target.semester,
                youbi: widget.target.weekday,
                jigen: widget.target.period,
                gakubu: Department.byValue(SharepreferenceHandler()
                    .getValue(SharepreferenceKeys.userDepartment)),
                setTimetableState: widget.setTimetableState)
          else
            SyllabusSearchDialog(
                radiusType: 2,
                gakki: widget.target.semester,
                youbi: DayOfWeek.anotherday,
                jigen: Lesson.ondemand,
                gakubu: Department.byValue(SharepreferenceHandler()
                    .getValue(SharepreferenceKeys.userDepartment)),
                setTimetableState: widget.setTimetableState)
        ]);

  }

  Widget courseInfo() {
    MyCourse target = widget.target;
    Widget header = Container(
      margin: const EdgeInsets.only(top:5),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [

        const SizedBox(width: 10),

        if(widget.isOndemand)
          const Text("OD/その他",
             style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold))
        else
          Text("${target.weekday!.text}曜日 ${target.period!.period}限",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold)),

        const SizedBox(width: 10),

        Expanded(
            child: Text(
          "${target.year} ${target.semester?.fullText ?? Term.fullYear.fullText}",
          style: const TextStyle(fontSize: null, color: Colors.grey),
          overflow: TextOverflow.clip,
        )),

        const SizedBox(width: 5)
      ]),
    );


    return GestureDetector(
        onTap: () {},
        child: 
          Column(children: [
            if(widget.type == CoursePreviewType.modal)
              header,
            Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                child: Padding(
                    padding: const EdgeInsets.only(
                        left: 0, right: 0, top: 5, bottom: 10),
                    child: summaryContent(dividerModel, target),          
              )
            )
          ])
        );
  }


  Widget syllabusPageViewBuilder(MyCourse target){
    if(target.syllabusID != null){
    return FutureBuilder(
      future: SyllabusRequestQuery.getSingleSyllabusInfo(target.syllabusID!),
      builder: (conetext,snapshot){
        if(snapshot.connectionState == ConnectionState.waiting){
          return const Center(
            child:CircularProgressIndicator(
              color:Colors.blueAccent)
            );
        }else if(snapshot.hasData){
          return Container(
              decoration: BoxDecoration(
                color:FORGROUND_COLOR,
                border: const Border(bottom: BorderSide(color: Colors.grey))
              ),
              height: SizeConfig.blockSizeVertical! * 72.5,
              width: SizeConfig.blockSizeHorizontal! * 100,
              child: SyllabusDescriptonView(
                  showHeader: false,
                  syllabusQuery: snapshot.data!));
        }else{
          return const Center(
            child:CircularProgressIndicator(
              color:Colors.blueAccent)
            );
        }
        
      });
    }else{
      return const SizedBox(
        height: 200,
        child:Center(
          child:Text("シラバス情報がありません。",
            style: TextStyle(color:Colors.grey,fontSize: 20),
      )));
    }
  }




  Widget summaryContent(dividerModel, MyCourse target) {
    int? credit = target.credit;
    String creditString = 
      credit != null ? credit.toString() : "？";
    String criteria = 
      target.criteria ?? "？";
    Color iconColor = BLUEGREY;
    Widget vertDivider = const VerticalDivider();

    return Column(children: [
      
      const SizedBox(height: 10),
    
      containerModel(
        Row(children: [
          SizedBox(width: MediaQuery.of(context).size.width * 0.01),
          textFieldModel("授業名を入力…", classNameController, FontWeight.bold, 23.0,
          (value) async {
            int id = target.id!;
            //＠ここに授業名変更関数を登録！！！
            await MyCourse.updateCourseName(id, value);
            widget.setTimetableState(() {});
          }),
        ]),
      ),

      if(!widget.isOndemand)
        containerModel(
          Row(children: [
            SizedBox(width: SizeConfig.blockSizeHorizontal! * 1),
            Icon(CupertinoIcons.map_pin, color: iconColor),
            SizedBox(width: SizeConfig.blockSizeHorizontal! * 3),
            classRoomSelector(context, target)
          ])
        ),

      containerModel(
        Row(children: [
          SizedBox(width: MediaQuery.of(context).size.width * 0.01),
          Icon(CupertinoIcons.doc_text, color: iconColor),
          SizedBox(width: MediaQuery.of(context).size.width * 0.03),
          textFieldModel("メモを入力…", memoController, FontWeight.normal, null,
              (value) async {
            int id = target.id!;
            //＠ここにメモのアップデート関数！！！
            await MyCourse.updateMemo(id, value);
            widget.setTimetableState(() {});
          })
        ])
      ),
      
      containerModel(
        Row(children: [
          SizedBox(width: MediaQuery.of(context).size.width * 0.01),
          Icon(CupertinoIcons.info, color: iconColor),
          SizedBox(width: MediaQuery.of(context).size.width * 0.03),
          textFieldModel("科目の分類を入力…", classificationController, FontWeight.normal, null,
            (value) async {
              int id = target.id!;
              MyCourse newMyCourse = widget.target;
              newMyCourse.subjectClassification = classificationController.text;
              await MyCourse.updateMyCourse(id,newMyCourse);
              widget.setTimetableState(() {});
            }
          )
        ])
      ),

      const SizedBox(height: 10),

      containerModel(
        Container(
          height: 30,
          child:Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            SizedBox(width: MediaQuery.of(context).size.width * 0.01),
            const Text("単位数",style: TextStyle(color:Colors.grey,fontSize: null),),
            SizedBox(width: MediaQuery.of(context).size.width * 0.03),
            Text(creditString,style:const TextStyle(fontWeight: FontWeight.bold,fontSize:20)),
            const Spacer(),
            vertDivider,
            const Spacer(),
            const Text("色",style: TextStyle(color:Colors.grey,fontSize: null)),
            SizedBox(width: MediaQuery.of(context).size.width * 0.03),
            colorSettingButton(
              context,
              setState,
              colorButtonColor,
              (newColor) async{
                int id = widget.target.id!;
                await MyCourse.updateColor(id,newColor);
                widget.setTimetableState(() {});
                colorButtonColor = newColor.toColor()!;
                setState(() {});
            }),
            const Spacer(),
            vertDivider,
            const Spacer(),
            const Text("削除",style: TextStyle(color:Colors.grey,fontSize: null)),
            SizedBox(width: MediaQuery.of(context).size.width * 0.03),
            GestureDetector(
              child: const Icon(CupertinoIcons.delete_solid,
                  color: Colors.grey),
              onTap: () async {
                int id = target.id!;
                await showConfirmDeleteDialog(
                  context,
                  target.courseName,
                  ()async{
                    //＠ここに削除実行関数！！！
                    await MyCourse.deleteMyCourse(id);
                    widget.setTimetableState(() {});
                    Navigator.pop(context);
                  });
            }),
          ])
        )
      ),

      const SizedBox(height: 10),

    ]);
  }

  Widget classRoomSelector(BuildContext context, MyCourse target) {
    List<String> classRooms = target.classRoom.toString().split("\n");
    Map<String, bool> selectedRooms = {};
    int id;
    for (var classroom in classRooms) {
      selectedRooms[classroom] = true;
    }

    if (classRooms.length <= 2) {
      return textFieldModel(
          "教室を入力…", classRoomController, FontWeight.normal, null, (value) async {
        id = target.id!;
        //＠ここに教室のアップデート関数！！！
        await MyCourse.updateClassRoom(id, value);
        widget.setTimetableState(() {});
      });
    } else {
      return IntrinsicHeight(
        child: Row(children: [
          GestureDetector(
            onTap: () async {
              showModalBottomSheet(
                context: context,
                backgroundColor: BACKGROUND_COLOR,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(20.0), // Set corner radius
                ),
                builder: (BuildContext context) {
                  return StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return ListView(
                          physics: const NeverScrollableScrollPhysics(),
                          children: classRooms.map((classRoom) {
                            return CheckboxListTile(
                              title: Text(classRoom),
                              value: selectedRooms[classRoom] ?? true,
                              onChanged: (bool? value) {
                                setState(() {
                                  selectedRooms[classRoom] = value!;
                                });
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    20.0), // Set corner radius
                              ),
                              activeColor: ACCENT_COLOR,
                              controlAffinity: ListTileControlAffinity.leading,
                              tileColor: Colors.white,
                              selectedTileColor: Colors.white,
                            );
                          }).toList());
                    },
                  );
                },
              ).whenComplete(() async {
                id = target.id!;
                String selectedRoomValue = selectedRooms.entries
                    .where((entry) => entry.value)
                    .map((entry) => entry.key)
                    .join("\n")
                    .trimRight();

                await MyCourse.updateClassRoom(id, selectedRoomValue);
                setState(() {});
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 2.5),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: const Color.fromARGB(255, 100, 100, 100),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(children: [
                Text(classRooms.join(" ")),
                const Icon(
                  Icons.arrow_drop_down,
                  color: Color.fromARGB(255, 100, 100, 100),
                )
              ]),
            ),
          ),
        ]),
      );
    }
  }

  Widget textFieldModel(String hintText, TextEditingController controller,
      FontWeight weight, double? fontSize, Function(String) onChanged) {
    return Expanded(
        child: Material(
        color: Colors.transparent,
      child: CupertinoTextField(
          controller: controller,
          maxLines: null,
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.multiline,
          placeholder: hintText,
          style: TextStyle(
              fontSize: fontSize, color: Colors.black, fontWeight: weight),
          onChanged: onChanged),
    ));
  }

  Widget relatedTasks() {
    if (taskList.isNotEmpty) {
      return Column(children: [
        const Divider(),
        Row(
          children: [
            const SizedBox(width: 15),
            Text("課題",
                style: titleStyle),
            const Spacer(),
            lengthBadge(taskList.length, 17.5, false),
            const SizedBox(width: 15),
          ],
        ),
        Container(
            decoration: roundedBoxdecoration(radiusType: 2),
            padding: const EdgeInsets.all(5),
            margin: const EdgeInsets.symmetric(horizontal: 5),
            child: Column(children: [
              const SizedBox(height: 2),
              ListView.separated(
                itemBuilder: (context, index) {
                  return taskListChild(taskList.elementAt(index));
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 2);
                },
                itemCount: taskList.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
              ),
            ])
          ),
      ]);
    } else {
      return const SizedBox();
    }
  }

  Widget taskListChild(Map<String, dynamic> target) {
    DateTime dtEnd = DateTime.fromMillisecondsSinceEpoch(
      target["dtEnd"],
    );
    String endDate = DateFormat("MM/dd").format(dtEnd);
    String endTime = DateFormat("HH:mm").format(dtEnd);

    Duration remainingTime = dtEnd.difference(DateTime.now());
    String formatDuration(Duration duration) {
      int days = duration.inDays;
      int hours = duration.inHours % 24;
      if (days == 0) {
        return 'あと$hours時間';
      } else {
        return 'あと$days日$hours時間';
      }
    }

    String remainingTimeInString = formatDuration(remainingTime);
    return GestureDetector(
        onTap: () async {
          await bottomSheet(
            context,
            target,
            widget.setTimetableState,
            onChanged: (newData){
              int index = targetTaskIndex(newData);
              setState(() {
                taskList = 
                  List.from(
                    List.from(taskList)..removeAt(index)
                  )..insert(index,newData);
              });
            },
            onDeleted: (targetData){
              setState(() {
                taskList = List.from(taskList)..removeAt(targetTaskIndex(targetData));
              });
            }
          );
        },
        child: Row(children: [
          Column(children: [
            Text(
              endDate,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Text(endTime,
                style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey)),
          ]),
          const SizedBox(width: 5),
          Expanded(
              child: Container(
                  decoration: roundedBoxdecoration(
                      radiusType: 2, backgroundColor: BACKGROUND_COLOR),
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(remainingTimeInString,
                            style: const TextStyle(color: Colors.redAccent)),
                        Text(
                          target["summary"],
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ])
                    )
                  )
        ])
      );
  }

  Widget attendanceRecord(){
    if(widget.isOndemand){
      return const SizedBox(
        height: 200,
        child:Center(
          child:Text("オンデマンド授業:\n出欠情報はありません。",
            style: TextStyle(color:Colors.grey,fontSize: 20),
      )));
    }else{
      return MediaQuery.removePadding(
        context: context,
        removeBottom: true,
        child: Column(children:[
            const SizedBox(height:7),
            Padding(
              padding:const EdgeInsets.symmetric(horizontal: 10),
              child:AttendMenuPanel(
                courseData: widget.target,
                setTimetableState:
                    widget.setTimetableState,
                backgroundColor: FORGROUND_COLOR
              )
            ),
            const SizedBox(height:15)
          ])
      );
    }
  }

  int targetTaskIndex(Map<String,dynamic> target){
    int result = 0;
    for(int i = 0; i < taskList.length; i++){
      if(target["id"] == taskList.elementAt(i)["id"]){
        result = i;
      }
    }
    return result;
  }

}

  Widget colorSettingButton(BuildContext context,StateSetter setState,Color currentColor,Function(String) onChanged){
    Color buttonColor = currentColor;
    return GestureDetector(
      onTap:()async{
        String? newColor = await colorPickerDialogue(context, setState);
        if(newColor != null){
          setState((){
            buttonColor = newColor.toColor()!;
          });
          onChanged(newColor);
        }
      },
      child:Container(
        width: 24,
        height: 24,
        margin: const EdgeInsets.symmetric(vertical: 0,horizontal: 5),
        decoration:BoxDecoration(
          color:Colors.white,
          border: Border.all(
            color: buttonColor,
            width: 6
          ),
          shape: BoxShape.circle,
        )
      )
    );
  }

  Future<String?> colorPickerDialogue(BuildContext context,StateSetter setState) async{
    Color? result;
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('授業の色を選択...'),
            content: SingleChildScrollView(
              child: BlockPicker(
                  pickerColor: Colors.redAccent,
                  onColorChanged: (color) {
                    setState(() {
                      result = color;
                    });
                  }),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('選択'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
    if(result != null){
      return colorToHexString(result!);
    }else{
      return null;
    }

  }

  Widget containerModel(Widget child){
    return Container(
      decoration: roundedBoxdecoration(radiusType: 2,backgroundColor: Colors.transparent),
      margin:const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(vertical: 2,horizontal: 5),
      child: child,
    );

  }