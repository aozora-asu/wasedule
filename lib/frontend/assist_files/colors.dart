import 'package:flutter/material.dart';

//ここで使う色を定義します。

const MAIN_COLOR = Color.fromARGB(255, 142, 23, 40);
const ACCENT_COLOR = Colors.orangeAccent;//Color.fromARGB(255,144,115,85);
const WIDGET_COLOR = Color.fromARGB(255, 255, 255, 255);
const WIDGET_OUTLINE_COLOR = Color.fromARGB(255, 227, 227, 227);
const PALE_MAIN_COLOR = Color.fromARGB(255, 184, 113, 113);


Color BACKGROUND_COLOR = const Color.fromRGBO(255, 255, 255, 1);
Color FORGROUND_COLOR = const Color(0xFFF2F2F7); //Color.fromRGBO(238, 238, 238, 1);


const BLACK = Color.fromRGBO(17,17,17,1); //(51,51,51,1);
const BLUEGREY = Color.fromRGBO(53,82,96,1);

const WASEDA_PSE_COLOR = Color.fromARGB(255, 255, 120, 9);
const WASEDA_LAW_COLOR = Color.fromARGB(255, 0, 142, 97);
const WASEDA_CMS_COLOR = Color.fromARGB(255, 0, 85, 100);
const WASEDA_HSS_COLOR = Color.fromARGB(255, 13, 0, 135);
const WASEDA_EDU_COLOR = Color.fromARGB(255, 184, 0, 129);
const WASEDA_SOC_COLOR = Color.fromARGB(255, 23, 0, 78);
const WASEDA_FSE_COLOR = Color.fromARGB(255, 174, 186, 0);
const WASEDA_CSE_COLOR = Color.fromARGB(255, 27, 136, 0);
const WASEDA_ASE_COLOR = Color.fromARGB(255, 0, 45, 142);
const WASEDA_SSS_COLOR = Color.fromARGB(255, 235, 211, 0);
const WASEDA_HUM_COLOR = Color.fromARGB(255, 0, 175, 239);
const WASEDA_SPS_COLOR = Color.fromARGB(255, 9, 109, 224);
const WASEDA_SILS_COLOR = Color.fromARGB(255, 87, 174, 190);


Color lighten(Color color, [double amount = 0.1]) {
  assert(amount >= 0 && amount <= 1);
  final hsl = HSLColor.fromColor(color);
  final hslLightened = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
  return hslLightened.toColor();
}

Color darken(Color color, [double amount = 0.1]) {
  assert(amount >= 0 && amount <= 1);
  final hsl = HSLColor.fromColor(color);
  final hslDarkened = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
  return hslDarkened.toColor();
}

void switchThemeColor(String theme){
  if(theme == "grey"){
    BACKGROUND_COLOR = const Color(0xFFF2F2F7);
    FORGROUND_COLOR = const Color.fromRGBO(255, 255, 255, 1);
  } else if (theme == "yellow"){
    BACKGROUND_COLOR = const Color.fromRGBO(238, 239, 151, 1);
    FORGROUND_COLOR = const Color.fromRGBO(253, 255, 230, 1);
  } else if (theme == "blue"){
    BACKGROUND_COLOR = const Color.fromRGBO(200, 212, 255, 1);
    FORGROUND_COLOR = const Color.fromRGBO(222, 232, 255, 1);
  }
}