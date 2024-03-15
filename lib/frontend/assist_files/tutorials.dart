import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';

Widget okButton(context,width){
    return ElevatedButton(
    onPressed: () {
      Navigator.of(context).pop();
    },
    style: const ButtonStyle(
      backgroundColor: MaterialStatePropertyAll(MAIN_COLOR),
      visualDensity: VisualDensity.standard
    ),
    child: SizedBox(
      width: width,
      child: const Center(
        child:Text(
        'OK',
        style:TextStyle(color: Colors.white)
      )) 
    ),
  );
}

Future<void> showTagAndTemplateGuide(context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title : const Text("最初の予定を登録！"), 
          actions: <Widget>[
          Column(children:[
            SizedBox(
                  width: 200,
                  child: Image.asset('lib/assets/tutorial_images/tag_and_template_button.png')),
            const Text("\n「タグ」機能、「テンプレート」機能が使えるようになりました！「タグとテンプレート」から追加してみましょう。\n"),
            okButton(context, 500.0)
          ]) ,
          ],
        );
      },
    );
  }

  Future<void> showTagGuide(context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title : const Text("最初のタグを登録！1/2"), 
          actions: <Widget>[
          Column(children:[
            SizedBox(
                  width: 200,
                  child: Image.asset('lib/assets/tutorial_images/tag_button.png')),
            const Text("\n最初のタグが登録されました！予定登録時に、「 + タグ」ボタンを押して紐づけてみましょう。\n"),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                showArbeitGuide(context);
              },
              style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(MAIN_COLOR),
                visualDensity: VisualDensity.standard
              ),
              child:const SizedBox(
                width: 500.0,
                child:  Center(
                  child:Text(
                  'つぎへ',
                  style:TextStyle(color: Colors.white)
                )) 
              ),
            )
          ]) ,
          ],
        );
      },
    );
  }

  Future<void> showArbeitGuide(context) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title : const Text("最初のタグを登録！2/2"), 
        actions: <Widget>[
        Column(children:[
          SizedBox(
                width: 200,
                child: Image.asset('lib/assets/tutorial_images/arbeit_button.png')),
          const Text("\nアルバイトタグを予定に紐付けると、自動で給料の見込みが計算！「アルバイト」ページで閲覧してください。\n"),
          okButton(context, 500.0)
        ]) ,
        ],
      );
    },
  );
}

  Future<void> showTemplateGuide(context) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title : const Text("最初のテンプレートを登録！"), 
        actions: <Widget>[
        Column(children:[
          SizedBox(
                width: 200,
                child: Image.asset('lib/assets/tutorial_images/template_button.png')),
          const Text("\n最初のテンプレートが登録されました！予定登録時、「 + テンプレート」ボタンから選択しましょう。\n"),
          okButton(context, 500.0)
        ]) ,
        ],
      );
    },
  );
}