import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/sharepreference.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/assist_files/ui_components.dart';
import 'package:flutter_calandar_app/static/constant.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:settings_ui/settings_ui.dart';

class TimetableSettingPage extends ConsumerStatefulWidget{
  const TimetableSettingPage({super.key});


  @override
  _TimetableSettingPageState createState() => _TimetableSettingPageState();
}

class _TimetableSettingPageState extends ConsumerState<TimetableSettingPage>{
  int tableColumnLength = 6;

  @override
  Widget build(BuildContext context) {
    bool isOndemandTableSide = SharepreferenceHandler().getValue(SharepreferenceKeys.isOndemandTableSide);
    
    return SettingsList(
        platform: DevicePlatform.iOS,
        sections: [
          SettingsSection(
              title: Text("所属学部"),
              tiles: <SettingsTile>[
                SettingsTile(
                  title: Text(userDepartmentSettingPreview(),
                                style:const TextStyle(color:Colors.blue)),
                  trailing: const Icon(CupertinoIcons.chevron_down),
                  onPressed: (context) {
                    showUserDepartmentSettingDialog(context);
                  },
                ),
              ]),
          SettingsSection(
              title: Text("時間割表示の設定"),
              tiles: <SettingsTile>[
                SettingsTile(
                  title: Text("土曜日の表示"),
                  trailing: showSaturdaySwitch(),
                ),
                SettingsTile(
                  title: Text("時間割の最小縦マス数"),
                  trailing: timetableColumnLengthSettings(),
                ),
              ]),
          SettingsSection(
            title: Text("OD科目の表示位置"),
            tiles: [
              SettingsTile(
                onPressed: (context) async{
                  bool newValue = isOndemandTableSide ? false : true;
                  SharepreferenceHandler().setValue(
                      SharepreferenceKeys.isOndemandTableSide,newValue);
                  setState(() {});
                },
                title: Text("時間割の下"),
                trailing: Icon(
                  Icons.check_rounded,color:isOndemandTableSide ? 
                     Colors.transparent : Colors.blue)
              ),
              SettingsTile(
                onPressed: (context) async{
                  bool newValue = isOndemandTableSide ? false : true;
                  SharepreferenceHandler().setValue(
                      SharepreferenceKeys.isOndemandTableSide,newValue);
                  setState(() {});
                },
                title: Text("時間割の横"),
                trailing: Icon(
                  Icons.check_rounded,color:isOndemandTableSide ? 
                    Colors.blue : Colors.transparent)
              ),
          ])
        ],
      );

  }

  String userDepartmentSettingPreview(){
    Department? userDepartment = 
      Department.byValue(SharepreferenceHandler().getValue(SharepreferenceKeys.userDepartment) ?? "設定なし");
    String departmentString ="設定なし";

    if(userDepartment != null){
      departmentString = userDepartment.text;}

    return  departmentString;
  }

  Widget attendDialogSettingSwitch() {
    return 
      CupertinoSwitch(
        activeColor: Colors.blue,
        value: SharepreferenceHandler()
            .getValue(SharepreferenceKeys.showAttendDialogAutomatically),
        onChanged: (value) async {
          SharepreferenceHandler().setValue(
              SharepreferenceKeys.showAttendDialogAutomatically, value);
          setState(() {});
        },
      );
  }

  Widget showSaturdaySwitch() {
    return
      CupertinoSwitch(
        activeColor: Colors.blue,
        value: SharepreferenceHandler()
            .getValue(SharepreferenceKeys.isShowSaturday),
        onChanged: (value) async {
          SharepreferenceHandler().setValue(
              SharepreferenceKeys.isShowSaturday, value);
          setState(() {});
        },
      );
  }

  Widget ondemandPlaceSwitch() {
    bool isOndemandTableSide = SharepreferenceHandler()
            .getValue(SharepreferenceKeys.isOndemandTableSide);
    
    return 
      GestureDetector(
        child: Container(
          padding:const EdgeInsets.symmetric(vertical: 3,horizontal: 3),
          child:
            Row(children:[
              Text(isOndemandTableSide ? "時間割の横" : "時間割の下",
                style:const TextStyle(
                  color: Colors.blue,
                  fontSize: 15
                )),
              const Icon(Icons.arrow_drop_down,size: 20)
            ])
        ),
        onTap: () async {
          bool newValue = isOndemandTableSide ? false : true;
          SharepreferenceHandler().setValue(
              SharepreferenceKeys.isOndemandTableSide,newValue);
          setState(() {});
        },
      );
  }

  Widget timetableColumnLengthSettings() {
    tableColumnLength = SharepreferenceHandler().getValue(SharepreferenceKeys.tableColumnLength);
    return 
      SizedBox(
        width: 50,
        child: cupertinoLikeDropDownListModel(
          const [
            DropdownMenuItem(value: 4, child: Text(" 4 ")),
            DropdownMenuItem(value: 5, child: Text(" 5 ")),
            DropdownMenuItem(value: 6, child: Text(" 6 ")),
            DropdownMenuItem(value: 7, child: Text(" 7 ")),
          ],
          tableColumnLength,
          (value) async {
            SharepreferenceHandler()
                .setValue(SharepreferenceKeys.tableColumnLength, value!);
            setState(() {
              tableColumnLength = value;
            });
          },
        ),
      );
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
