import 'package:flutter/material.dart';

import 'package:latlong2/latlong.dart';

Map<String, LatLng> campusLocations = const {
  "waseda": LatLng(35.70918661596566, 139.71979758630098),
  "toyama": LatLng(35.70562816868803, 139.7176382479536),
  "nishi_waseda": LatLng(35.70604328321409, 139.70671670575553),
  "tokorozawa": LatLng(35.78696579219986, 139.39954205621635),
  "higashi_fushimi" : LatLng(35.726727900743775, 139.56373149563657),
};

Map<String, double> initMapZoom = const {
  "waseda": 16.2,
  "toyama": 17.2,
  "nishi_waseda": 16.75,
  "tokorozawa": 16,
  "higashi_fushimi": 16.25,
};

Map<String, LatLng> buildingLocations = const {
  "3": LatLng(35.70924536312012, 139.72010069094065),
  "6": LatLng(35.71001460124641, 139.7191717115086),
  "7": LatLng(35.70920076884335, 139.7194839350231),
  "8": LatLng(35.70834887366013, 139.71985092673003),
  "10": LatLng(35.70847845517725, 139.71855810455077),
  "11": LatLng(35.70901405731995, 139.71892837146606),
  "14": LatLng(35.70982154825793, 139.7185954055238),
  "15": LatLng(35.71024833967154, 139.71849563827368),
  "16": LatLng(35.70995246877514, 139.7180193514461),
  "central_library": LatLng(35.7109364274621, 139.718125412829861),
  "ookuma_garden_food": LatLng(35.70894841097691, 139.72238604346498),
  "ground_slope_food": LatLng(35.70995133688496, 139.71713024030635),
  "31": LatLng(35.70541570674681, 139.7179363336403),
  "32": LatLng(35.70509109144369, 139.718370179258),
  "33": LatLng(35.70500553370184, 139.71779068546866),
  "34": LatLng(35.704792228628584, 139.71807583010226),
  "36": LatLng(35.70551452480278, 139.71708012198252),
  "38": LatLng(35.705410811083695, 139.71885914410385),
  "toyama_library": LatLng(35.70511867745611, 139.71871750748542),
  "toyama_food": LatLng(35.70542144323193, 139.71858283951815),
  "student_hall" : LatLng(35.70613012934406, 139.71671659730686),
  "training_gym" : LatLng(35.70589395907948, 139.71639545916818),
  "52": LatLng(35.705637188098656, 139.70709957841908),
  "53": LatLng(35.70563507207901, 139.70751912052745),
  "54": LatLng(35.70564142013665, 139.70788393977944),
  "56": LatLng(35.70649788798856, 139.7077277949618),
  "57": LatLng(35.70648095030999, 139.70723853939802),
  "60": LatLng(35.70604544935449, 139.7061200057127),
  "61": LatLng(35.706045288457254, 139.70576259562358),
  "63": LatLng(35.70584785402546, 139.7050880608981),
  "rikou_library": LatLng(35.70602782207398, 139.70674367727975),
  "rikou_food": LatLng(35.706287268366445, 139.70799168375845),
  "rikou_food_63": LatLng(35.70613476708157, 139.70544846698553),
  "79" : LatLng(35.727718026563025, 139.5643581585824),
  "100": LatLng(35.78526683441956, 139.39946516174751),
  "101": LatLng(35.78866719695889, 139.39950043751176),
  "tokorozawa_library": LatLng(35.78520285349271, 139.39840174340995),
  "tokorozawa_food": LatLng(35.78548026847353, 139.3985115677744),
};

Map<String, AssetImage> buildingImages = const {
  "3": AssetImage('lib/assets/map_images/waseda_building_3.png'),
  "6": AssetImage('lib/assets/map_images/waseda_building_6.jpg'),
  "7": AssetImage('lib/assets/map_images/waseda_building_7.jpg'),
  "8": AssetImage('lib/assets/map_images/waseda_building_8.png'),
  "10": AssetImage('lib/assets/map_images/waseda_building_10.jpg'),
  "11": AssetImage('lib/assets/map_images/waseda_building_11.png'),
  "14": AssetImage('lib/assets/map_images/waseda_building_14.png'),
  "15": AssetImage('lib/assets/map_images/waseda_building_15.png'),
  "16": AssetImage('lib/assets/map_images/waseda_building_16.png'),
  "central_library":
      AssetImage('lib/assets/map_images/waseda_central_library.jpg'),
  "31": AssetImage('lib/assets/map_images/waseda_building_38.jpg'),
  "32": AssetImage('lib/assets/map_images/waseda_building_38.jpg'),
  "33": AssetImage('lib/assets/map_images/waseda_building_38.jpg'),
  "34": AssetImage('lib/assets/map_images/waseda_building_38.jpg'),
  "36": AssetImage('lib/assets/map_images/waseda_building_38.jpg'),
  "38": AssetImage('lib/assets/map_images/waseda_building_38.jpg'),
  "toyama_library":
      AssetImage('lib/assets/map_images/waseda_toyama_library.jpg'),
  "52": AssetImage('lib/assets/map_images/waseda_building_53.jpg'),
  "53": AssetImage('lib/assets/map_images/waseda_building_53.jpg'),
  "54": AssetImage('lib/assets/map_images/waseda_building_53.jpg'),
  "56": AssetImage('lib/assets/map_images/waseda_building_56.jpg'),
  "57": AssetImage('lib/assets/map_images/waseda_building_57.jpg'),
  "60": AssetImage('lib/assets/map_images/waseda_building_60.jpg'),
  "61": AssetImage('lib/assets/map_images/waseda_building_61.jpg'),
  "63": AssetImage('lib/assets/map_images/waseda_building_63.jpg'),
  "rikou_library": AssetImage('lib/assets/map_images/waseda_rikou_library.jpg'),
  "79": AssetImage('lib/assets/map_images/waseda_building_21.png'),
  "100": AssetImage('lib/assets/map_images/waseda_building_21.png'),
  "101": AssetImage('lib/assets/map_images/waseda_building_21.png'),
  "tokorozawa_library":
      AssetImage('lib/assets/map_images/waseda_building_21.png'),
};

Map<int, List<String>> campusID2buildingsList() {
  return const {
    0: ["3", "6", "7", "8", "10", "11", "14", "15", "16"],
    1: ["31", "32", "33", "34", "36", "38"],
    2: ["52", "53", "54", "56", "57", "60", "61", "63"],
    3: ["100", "101"],
    4: ["79"]
  };
}

Map<String, String> webLinks = {
  "central_library": "https://www.waseda.jp/library/libraries/central/",
  "toyama_library": "https://www.waseda.jp/library/libraries/toyama/",
  "rikou_library": "https://www.waseda.jp/library/libraries/sci-eng/",
  "tokorozawa_library": "https://www.waseda.jp/library/libraries/tokorozawa/",
  "ookuma_garden_food": "https://www.wcoop.ne.jp/schedule/schedule_",
  "ground_slope_food": "https://www.wcoop.ne.jp/schedule/schedule_",
  "toyama_food": "https://www.wcoop.ne.jp/schedule/schedule_",
  "rikou_food": "https://www.wcoop.ne.jp/schedule/schedule_",
  "rikou_food_63": "https://www.wcoop.ne.jp/schedule/schedule_",
  "tokorozawa_food": "https://www.wcoop.ne.jp/schedule/schedule_",
  "student_hall" : "https://www.waseda.jp/inst/student/facility/studentcenter/about",
  "training_gym" : "https://www.waseda.jp/inst/student/facility/training",
  };
