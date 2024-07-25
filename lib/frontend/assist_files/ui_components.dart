import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';

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

BorderRadius boxRadius({int type = 0}){
  double endRadius = 30;
  double middleRadius = 3;

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

BoxDecoration roundedBoxdecorationWithShadow({int radiusType = 0,Color? backgroundColor}) {

  return BoxDecoration(
      color: backgroundColor ?? FORGROUND_COLOR,
      borderRadius: boxRadius(type: radiusType)
    );
}