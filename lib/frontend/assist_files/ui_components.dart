import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

Widget buttonModel(Function() onTap, Color color, String text,
  {double verticalpadding = 7.5,double horizontalPadding = 5}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
        padding: EdgeInsets.symmetric(
          vertical: verticalpadding,horizontal: horizontalPadding),
        margin:const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: color,
          //border: Border.all(color: brighten(color, 0.6), width: 1),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          Text(text,
              style: const TextStyle(color: Colors.white)),
        ])),
  );
}

Widget buttonModelWithChild(
  Function() onTap, Color color, Widget child,
  {double verticalpadding = 7.5,double horizontalPadding = 5}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
        padding: EdgeInsets.symmetric(
          vertical: verticalpadding,horizontal: horizontalPadding),
        decoration: BoxDecoration(
          color: color,
          //border: Border.all(color: brighten(color, 0.5), width: 2),
          borderRadius: BorderRadius.circular(5),
        ),
        child: child),
  );
}

Widget okButton(context, width) {
  return buttonModelWithChild(
    () {
      Navigator.of(context).pop();
    },
    MAIN_COLOR,
    SizedBox(
        width: width,
        child: const Center(
            child: Text('OK', style: TextStyle(color: Colors.white)))),
  );
}

Color brighten(Color color, [double amount = .1]) {
  assert(amount >= 0 && amount <= 1);

  int r = color.red + ((255 - color.red) * amount).toInt();
  int g = color.green + ((255 - color.green) * amount).toInt();
  int b = color.blue + ((255 - color.blue) * amount).toInt();

  return Color.fromARGB(color.alpha, r, g, b);
}

Widget lengthBadge(int length, fontSize, bool hideZero) {
  if (length == 0 && hideZero) {
    return const SizedBox();
  } else {
    return Container(
        decoration: const BoxDecoration(
          color: Colors.redAccent,
          shape: BoxShape.circle,
          border: Border()
        ),
        padding: EdgeInsets.all(fontSize / 3),
        child: Text(
          length.toString(),
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: fontSize),
        ));
  }
}

LinearGradient gradationDecoration(
  {Color color1 = MAIN_COLOR,
   Color color2 = Colors.black}){
  return LinearGradient(
      begin: FractionalOffset.topLeft,
      end: FractionalOffset.bottomRight,
      colors: [
        color1,
        color2,
      ],
      stops: const [
        0.0,
        1.0,
      ]
  );
}

  double endRadius = 30;
  double middleRadius = 3;

BorderRadius boxRadius({int type = 0}){

  switch(type){
    case 1: 
      return BorderRadius.only(
        topLeft: Radius.circular(endRadius),
        topRight: Radius.circular(endRadius),
        bottomLeft: Radius.circular(middleRadius),
        bottomRight: Radius.circular(middleRadius),
      );
    case 2:
      return BorderRadius.only(
        topLeft: Radius.circular(middleRadius),
        topRight: Radius.circular(middleRadius),
        bottomLeft: Radius.circular(middleRadius),
        bottomRight: Radius.circular(middleRadius),
      );
    case 3:
      return BorderRadius.only(
        topLeft: Radius.circular(middleRadius),
        topRight: Radius.circular(middleRadius),
        bottomLeft: Radius.circular(endRadius),
        bottomRight: Radius.circular(endRadius),
      );

    default: 
      return BorderRadius.only(
        topLeft: Radius.circular(endRadius),
        topRight: Radius.circular(endRadius),
        bottomLeft: Radius.circular(endRadius),
        bottomRight: Radius.circular(endRadius),
      );
  }
  
}

BoxDecoration roundedBoxdecoration({int radiusType = 0,bool shadow = false, Color? backgroundColor}) {

  return BoxDecoration(
    boxShadow: [
      if(shadow) BoxShadow(
        color: Colors.black.withOpacity(0.2), // 影の色
        spreadRadius: 0, // 影の広がり
        blurRadius: 2, // ぼかしの強さ
        offset: const Offset(0, 3), // 影の位置 (x, y)
      )
    ], 
    color: backgroundColor ?? FORGROUND_COLOR,
    borderRadius: boxRadius(type: radiusType)
  );
}

BoxDecoration dialogHeader({Color? backgroundColor}) {

  return BoxDecoration(
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.5),
        spreadRadius: 1,
        blurRadius: 2, 
        offset: const Offset(0, 0.5),
      )
    ], 
    color: backgroundColor ?? FORGROUND_COLOR,
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(endRadius),
      topRight: Radius.circular(endRadius),
    ),
    border:const Border(
      bottom: BorderSide(
        color: Colors.grey, 
        width: 0.3,
      ),
    ),
  );
}

Widget cupertinoLikeDropDownListModel(
  List<DropdownMenuItem<dynamic>> items,
  dynamic value,
  Function(dynamic) onChanged,
  {double verticalPadding = 5.0}
){
  return  Material(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.withOpacity(0.2),
        child:DropdownButtonFormField(
          borderRadius: BorderRadius.circular(20),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: 0.0),
            isDense: true,
            border: InputBorder.none),
            style:const  TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.normal,
              fontSize:22
            ),
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down_rounded, color: Colors.grey),
          items:items,
          value: value,
          onChanged: onChanged,
        ),
      );
}

Future<void> showConfirmDeleteDialog(BuildContext context,String object,Function ondeleted)async{
  await showCupertinoDialog(
    context: context,
    builder: (context){
      return CupertinoAlertDialog(
        title:Text("$object を削除しますか？"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child:const Text("キャンセル")),
          TextButton(
            onPressed: () {
              ondeleted();
              Navigator.pop(context);
            },
            child:const Text("削除",style: TextStyle(color:Colors.red),)),
        ],);
    });
}


  String colorToHexString(Color color, {bool includeAlpha = false}) {
    // ColorのvalueプロパティからARGBの値を取得
    String hexColor = '';

    if (includeAlpha) {
      // Alpha（透明度）を含めたカラーコード（#AARRGGBB）
      hexColor = '#${color.value.toRadixString(16).padLeft(8, '0')}';
    } else {
      // Alphaを無視してRGBのみのカラーコード（#RRGGBB）
      hexColor = '#${color.value.toRadixString(16).padLeft(6, '0').substring(2)}';
    }

    return hexColor.toLowerCase(); // 大文字に変換
  }

Widget simpleSmallButton(String text,Function() onTap,{double horizontalMargin = 3}) {
  return GestureDetector(
      onTap:onTap,
      child: Container(
        decoration: roundedBoxdecoration(backgroundColor: Colors.grey[300]),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 1),
        margin: EdgeInsets.symmetric(vertical: 4,horizontal: horizontalMargin),
        child: Text(
          text,
          style: const TextStyle(
              color: Colors.blue,
              fontSize: 15,
              fontWeight: FontWeight.normal),
        ),
      )
    );
}

class DashedLinePainterWidget extends StatelessWidget {
  late double width;
  late double height;

  DashedLinePainterWidget({super.key, 
    required this.width,
    required this.height,
  });
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width,height), // 幅300、高さ1の破線を描画
      painter: DashedLinePainter(),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2;

    // 破線のパターン (線の長さとギャップの長さ)
    double dashWidth = 5;
    double dashSpace = 3;
    double startX = 0;

    while (startX < size.width) {
      // 破線の線を描画
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      // 次の破線の開始点を計算
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}