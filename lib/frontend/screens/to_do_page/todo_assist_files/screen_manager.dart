import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_calandar_app/backend/DB/handler/todo_db_handler.dart';
import 'package:flutter_calandar_app/frontend/screens/to_do_page/todo_daily_view_page/todo_daily_view_page.dart';
import 'package:flutter_calandar_app/frontend/screens/to_do_page/todo_assist_files/data_receiver.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScreenBuilder extends ConsumerStatefulWidget{
  Future<List<Map<String, dynamic>>>? events;
  AsyncSnapshot<List<Map<String, dynamic>>> snapshot;
  BuildContext context;

  ScreenBuilder ({
    this.events,
    required this.snapshot,
    required this.context
  });
  @override
  ScreenBuilderState createState() =>  ScreenBuilderState();
}

class  ScreenBuilderState extends ConsumerState<ScreenBuilder> {
   Future<List<Map<String, dynamic>>>? events;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

    Future<void> _initializeData() async {
    if (await DataBaseHelper().hasData() == true) {
      await displayDB();
    } else {
      noneTaskText();
    }
  }

  Widget noneTaskText() {
    return const Text("出ねぇよぉ！！");
  }


  Future<void> displayDB() async {
    final addData = await DataBaseHelper().getFixedData();
    await TemplateDataBaseHelper().initializeDB();
    final data = ref.read(dataProvider);
    data.getTemplateData();
    if (mounted) {
      setState(() {
        events = Future.value(addData);
      });
    }
  }
  
  @override
  Widget build (BuildContext context){
    ref.watch(dataProvider);
    final data = ref.watch(dataProvider);
    ref.watch(dataProvider).targetMonth;
    return  FutureBuilder(
      future: events,
      builder: (BuildContext context,snapshot){
        if (snapshot.connectionState == ConnectionState.waiting) {
          return DaylyViewPage(
            snapshot: widget.snapshot,
            context: widget.context,
            events: widget.events,
            );
        }else if(snapshot.hasError){
          final error  = snapshot.error;
          return Text('$error', style: const TextStyle(fontSize: 60,),);
        }else if (snapshot.hasData) {

          if(ref.watch(dataProvider).isInit){
            ref.read(dataProvider).isInit = false;            
          }

          if(ref.read(dataProvider).isRenewed){
            displayDB();
          }
          data.getData(snapshot.data!);
          return DaylyViewPage(
            snapshot: widget.snapshot,
            context: widget.context,
            events: widget.events,
            );
        } else {
          
          if(ref.read(dataProvider).isRenewed){
            displayDB();
          }
          return DaylyViewPage(
            snapshot: widget.snapshot,
            context: widget.context,
            events: widget.events,
            );
     }
    }
  );
}
  
}