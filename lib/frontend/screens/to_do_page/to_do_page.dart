import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/screens/to_do_page/todo_assist_files/screen_manager.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaskPage extends ConsumerStatefulWidget {
  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends ConsumerState<TaskPage> {

  @override
  Widget build(BuildContext context) {
    return ScreenBuilder(
            context: context,
          );
  }
}
