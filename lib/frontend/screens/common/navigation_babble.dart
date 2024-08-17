import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/ui_components.dart';

class NavigationBabble{


  Widget _babble(){
   return  Container(
      margin:const EdgeInsets.symmetric(horizontal:5),
      height: 50,
      decoration: roundedBoxdecoration(
        backgroundColor: Colors.greenAccent,
        shadow: true),
    );
  }
  
}