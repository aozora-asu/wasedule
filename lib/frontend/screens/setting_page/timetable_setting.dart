import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/sharepreference.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/assist_files/ui_components.dart';
import 'package:flutter_calandar_app/static/constant.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TimetableSettingPage extends ConsumerStatefulWidget{

  @override
  _TimetableSettingPageState createState() => _TimetableSettingPageState();
}

class _TimetableSettingPageState extends ConsumerState<TimetableSettingPage>{

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Text(
            '  時間割設定…',
            style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Container(
              decoration: roundedBoxdecoration(),
              padding:
                  const EdgeInsets.symmetric(vertical: 7.5, horizontal: 15),
              margin: const EdgeInsets.symmetric(vertical: 7.5, horizontal: 10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '所属学部',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: BLUEGREY),
                    ),
                    const Divider(
                      height: 2,
                      thickness: 2,
                      color: BLUEGREY,
                    ),
                    const SizedBox(height: 2),
                    userDepartmentSettingPreview(),
                    const SizedBox(height: 4),
                    buttonModel(
                      ()async{
                        await showUserDepartmentSettingDialog(context);
                        setState(() {});
                      },
                      BLUEGREY,
                      "変更"),
                    const SizedBox(height: 4),
                  ])),

          const SizedBox(height: 5),
          Container(
              decoration: roundedBoxdecoration(),
              padding:
                  const EdgeInsets.symmetric(vertical: 7.5, horizontal: 15),
              margin: const EdgeInsets.symmetric(vertical: 7.5, horizontal: 10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '出欠記録の設定',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: BLUEGREY),
                    ),
                    const Divider(
                      height: 2,
                      thickness: 2,
                      color: BLUEGREY,
                    ),
                    const SizedBox(height: 2),
                    attendDialogSettingSwitch(),
                    const SizedBox(height: 2),
                  ])),

        ]);
  }

  Widget userDepartmentSettingPreview(){
    Department? userDepartment = 
      Department.byValue(SharepreferenceHandler().getValue(SharepreferenceKeys.userDepartment) ?? "設定なし");
    String departmentString ="設定なし";

    if(userDepartment != null){
      departmentString = userDepartment.text;}

    return Text(
      departmentString,
      textAlign: TextAlign.center,
      style:const TextStyle(fontSize:25,fontWeight: FontWeight.bold));
  }

  Widget attendDialogSettingSwitch() {
    return Row(children: [
      const Text("出欠記録画面の自動表示"),
      const Spacer(),
      CupertinoSwitch(
        activeColor: PALE_MAIN_COLOR,
        value: SharepreferenceHandler()
            .getValue(SharepreferenceKeys.showAttendDialogAutomatically),
        onChanged: (value) async {
          SharepreferenceHandler().setValue(
              SharepreferenceKeys.showAttendDialogAutomatically, value);
          setState(() {});
        },
      )
    ]);
  }

}

Future<void> showUserDepartmentSettingDialog(BuildContext context)async{
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: const Text(
          '所属学部の設定'),
        content:Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _departmentPicker(),
            ]
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); 
            },
            child:const Text('閉じる'),
          ),
        ],
      );
    },
  );
}

  Widget _departmentPicker() {
    List<Department?> departments = [];
    departments.addAll(Department.departments);
    
    List<DropdownMenuItem<Department>> items = [];
    for(int i = 0; i < departments.length; i++){
      String menuText = "学部を選択";
      if(departments.elementAt(i) != null){
        menuText = departments.elementAt(i)!.text;
      }

      items.add(DropdownMenuItem(
        value: departments.elementAt(i),
        child: Center(
         child:Text(menuText,
          style: const TextStyle(
            fontSize:20,
            fontWeight: FontWeight.normal),))));
    }
    String? userDepartmentString = 
      SharepreferenceHandler().getValue(SharepreferenceKeys.userDepartment);
    Department? userDepartment;
    if(userDepartmentString != null){
      userDepartment = Department.byValue(userDepartmentString);
    }
  
    return cupertinoLikeDropDownListModel(
        items,userDepartment,
        (value) {
          SharepreferenceHandler().setValue(
            SharepreferenceKeys.userDepartment,
            value.value);
        },
    );
  }
