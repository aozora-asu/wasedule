import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';

Widget buttonModel(Function() onTap,Color color,String text){
  return  GestureDetector(
    onTap: onTap,
    child:Container(
      padding:const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color:color,
        border: Border.all(color:brighten(color,0.6),width:1),
        borderRadius:BorderRadius.circular(5),
      ),
      child: Row(children:[
        Text(text,
          style:const TextStyle(
            fontWeight:FontWeight.bold,
            color:Colors.white
          )
        ),
      ])
    ),
  );
}

Widget buttonModelWithChild(Function() onTap,Color color,Widget child){
  return  GestureDetector(
    onTap: onTap,
    child:Container(
      padding:const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color:color,
        border: Border.all(color:brighten(color,0.6),width:1),
        borderRadius:BorderRadius.circular(5),
      ),
      child: child
    ),
  );
}

Widget okButton(context,width){
    return buttonModelWithChild(
    () {
      Navigator.of(context).pop();
    },
    MAIN_COLOR,
    SizedBox(
      width: width,
      child: const Center(
        child:Text(
        'OK',
        style:TextStyle(color: Colors.white)
      )) 
    ),
  );
}

Color brighten(Color color, [double amount = .1]) {
  assert(amount >= 0 && amount <= 1);

  int r = color.red + ((255 - color.red) * amount).toInt();
  int g = color.green + ((255 - color.green) * amount).toInt();
  int b = color.blue + ((255 - color.blue) * amount).toInt();

  return Color.fromARGB(color.alpha, r, g, b);
}