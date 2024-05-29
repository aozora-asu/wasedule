import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/frontend/assist_files/ui_components.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/services.dart' show rootBundle;

final GlobalKey mapWebViewKey = GlobalKey();
late InAppWebViewController mapWebViewController;

class EmptyClassRoomView extends ConsumerStatefulWidget {
  @override
  _EmptyClassRoomViewState createState() => _EmptyClassRoomViewState();
}

class _EmptyClassRoomViewState extends ConsumerState<EmptyClassRoomView>
    with TickerProviderStateMixin {
  final MapController mapController = MapController();
  late final _animatedMapController = AnimatedMapController(vsync: this);
  String yearAndMonth = DateFormat("yyyyMM").format(DateTime.now());
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0), // 角丸の半径を指定
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5), // 影の色と透明度
              spreadRadius: 2, // 影の広がり
              blurRadius: 3, // ぼかしの強さ
              offset: const Offset(0, 3), // 影の方向（横、縦）
            ),
          ],
        ),
        padding: EdgeInsets.only(
          left: SizeConfig.blockSizeHorizontal! * 2.5,
          right: SizeConfig.blockSizeHorizontal! * 2.5,
        ),
        child: Column(children: [
          Container(

            alignment: Alignment.center,
            height:SizeConfig.blockSizeVertical! *6,
            child:Row(children:[
              const Spacer(),
              SizedBox(
                height:SizeConfig.blockSizeVertical! *4,
                child:Image.asset('lib/assets/eye_catch/wase_map_logo.png')),
              SizedBox(width:SizeConfig.blockSizeHorizontal! *2),
              Text(
                "わせまっぷ(Beta版)",
                style: TextStyle(
                  fontSize: SizeConfig.blockSizeVertical! *3,
                  fontWeight: FontWeight.bold
              )),
              const Spacer()
            ])
              
          ),
          const Divider(height:1),

          SizedBox(
              height: SizeConfig.blockSizeVertical! * 3,
              child: Text("Find your Waseda.",
                  style: TextStyle(
                      fontSize: SizeConfig.blockSizeVertical! * 2,
                      color: Colors.blueGrey))),
          mapView(),
          SizedBox(height: SizeConfig.blockSizeVertical! * 4)
        ]));
  }

  Map<String, LatLng> campusLocations = const {
    "waseda": LatLng(35.70943486485431, 139.71912124551386),
    "toyama": LatLng(35.70562816868803, 139.7176382479536),
    "nishi_waseda": LatLng(35.70604328321409, 139.70671670575553),
    "tokorozawa": LatLng(35.78696579219986, 139.39954205621635),
  };

  Map<String,double> initMapZoom =  const {
    "waseda" : 16.5,
    "toyama" : 17.2,
    "nishi_waseda" : 16.75,
    "tokorozawa" : 16,

  };

  Map<String, LatLng> buildingLocations = const {
    "3": LatLng(35.70924536312012, 139.72010069094065),
    "6" : LatLng(35.71001460124641, 139.7191717115086),
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
    
    "52": LatLng(35.705637188098656, 139.70709957841908),
    "53": LatLng(35.70563507207901, 139.70751912052745),
    "54": LatLng(35.70564142013665, 139.70788393977944),
    "56": LatLng(35.70649788798856, 139.7077277949618),
    "57": LatLng(35.70648095030999, 139.70723853939802),
    "60": LatLng(35.70604544935449, 139.7061200057127),
    "61": LatLng(35.706045288457254, 139.70576259562358),
    "63" : LatLng(35.70584785402546, 139.7050880608981),
    "rikou_library": LatLng(35.70602782207398, 139.70674367727975),
    "rikou_food": LatLng(35.706287268366445, 139.70799168375845),
    "rikou_food_63": LatLng(35.70613476708157, 139.70544846698553),
    
    "100" : LatLng(35.78526683441956, 139.39946516174751),
    "101" : LatLng(35.78866719695889, 139.39950043751176),
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
    "rikou_library":
        AssetImage('lib/assets/map_images/waseda_rikou_library.jpg'),
    
    "100": AssetImage('lib/assets/map_images/waseda_building_21.png'),
    "101": AssetImage('lib/assets/map_images/waseda_building_21.png'),
    "tokorozawa_library":
        AssetImage('lib/assets/map_images/waseda_building_21.png'),
  };

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
  };

  Widget mapView() {
    return Column(children: [
      Container(
          decoration:
              BoxDecoration(border: Border.all(color: Colors.grey, width: 1.5)),
          height: SizeConfig.blockSizeVertical! * 50,
          child: FlutterMap(
            mapController: _animatedMapController.mapController,
            options: MapOptions(
              initialCenter: campusLocations["waseda"]!,
              initialZoom: initMapZoom["waseda"]!,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  libraryPin("central_library"),
                  foodPin("ground_slope_food"),
                  foodPin("ookuma_garden_food"),
                  markerPin("8"),
                  markerPin("10"),
                  markerPin("11"),
                  markerPin("6"),
                  markerPin("7"),
                  markerPin("3"),
                  markerPin("16"),
                  markerPin("15"),
                  markerPin("14"),

                  libraryPin("toyama_library"),
                  foodPin("toyama_food"),
                  markerPin("31"),
                  markerPin("32"),
                  markerPin("33"),
                  markerPin("34"),
                  markerPin("36"),
                  markerPin("38"),

                  foodPin("rikou_food"),
                  foodPin("rikou_food_63"),
                  libraryPin("rikou_library"),
                  markerPin("52"),
                  markerPin("53"),
                  markerPin("54"),
                  markerPin("56"),
                  markerPin("57"),
                  markerPin("61"),
                  markerPin("60"),
                  markerPin("63"),

                  foodPin("tokorozawa_food"),
                  libraryPin("tokorozawa_library"),
                  markerPin("100"),
                  markerPin("101"),
                ],
              ),
            ],
          )),
      SizedBox(
        height: SizeConfig.blockSizeVertical! *5,
          child:Row(
            children:[
            buttonModel(
              ()async{
                await _animatedMapController.animateTo(dest:campusLocations["waseda"]);
                await _animatedMapController.animatedZoomTo(initMapZoom["waseda"]!);
              },
              Colors.blue,
              "  早稲田  "),
              buttonModel(
              ()async{
                await _animatedMapController.animateTo(dest:campusLocations["toyama"]);
                await _animatedMapController.animatedZoomTo(initMapZoom["toyama"]!);
              },
              Colors.blue,
              "   戸山   "),
              buttonModel(
              ()async{
                await _animatedMapController.animateTo(dest:campusLocations["nishi_waseda"]);
                await _animatedMapController.animatedZoomTo(initMapZoom["nishi_waseda"]!);
              },
              Colors.blue,
              " 西早稲田 "),
              buttonModel(
              ()async{
                await _animatedMapController.animateTo(dest:campusLocations["tokorozawa"]);
                await _animatedMapController.animatedZoomTo(initMapZoom["tokorozawa"]!);
              },
              Colors.blue,
              "   所沢   "),
          ]),
        )
    ]);
  }

  Marker markerPin(String location){
    Image.asset('lib/assets/map_images/location_pin_notempty.png');
    return Marker(
      width: 45.0,
      height: 45.0,
      point: buildingLocations[location]!,
      child: GestureDetector(
          onTap: () {
            showDetailButtomSheet(location);
          },
          child: Stack(children: [
            Image.asset('lib/assets/map_images/location_pin.png'),
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
              ),
              child: Text(
                location,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
            )
          ])),
      rotate: true,
    );
  }

  Marker libraryPin(String location) {
    return Marker(
      width: 45.0,
      height: 45.0,
      point: buildingLocations[location]!,
      child: GestureDetector(
          onTap: () {
            showLibraryButtomSheet(location);
          },
          child: Image.asset('lib/assets/map_images/library_pin.png')),
      rotate: true,
    );
  }

  Marker foodPin(String location) {
    return Marker(
      width: 45.0,
      height: 45.0,
      point: buildingLocations[location]!,
      child: GestureDetector(
          onTap: () {
            showFoodButtomSheet(location);
          },
          child: Image.asset('lib/assets/map_images/food_pin.png')),
      rotate: true,
    );
  }

  void showDetailButtomSheet(String location) {
    showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        enableDrag: true,
        barrierColor: Colors.black.withOpacity(0.5),
        builder: (context) {
          return Container(
              height: SizeConfig.blockSizeVertical! * 60,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              margin: const EdgeInsets.only(top: 20),
              child: Column(children: [
                Container(
                    height: SizeConfig.blockSizeVertical! * 6,
                    width: SizeConfig.blockSizeHorizontal! * 100,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                    ),
                    child: Row(children: [
                      SizedBox(width: SizeConfig.safeBlockHorizontal! * 3),
                      Image.asset('lib/assets/map_images/location_pin.png'),
                      Text(" " + location + '号館',
                          style: TextStyle(
                              fontSize: SizeConfig.blockSizeVertical! * 3,
                              fontWeight: FontWeight.bold))
                    ])),
                const Divider(
                  height: 2,
                  thickness: 2,
                ),
                Expanded(
                    child: Stack(children: [
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: buildingImages[location]!, fit: BoxFit.cover),
                    ),
                  ),
                  Container(color: Colors.white.withOpacity(0.6))
                ]))
              ]));
        });
  }

  void showLibraryButtomSheet(String location) {
    String buildingName = "";
    bool isMenu = false;
    Image pinImage = Image.asset('lib/assets/map_images/library_pin.png');
    String anc = "";
    switch (location) {
      case "central_library":
        buildingName = "中央図書館";
        anc = "#anc_5";
        break;
      case "toyama_library":
        buildingName = "戸山図書館";
        anc = "#anc_8";

        break;
      case "rikou_library":
        buildingName = "理工図書館";
        anc = "#anc_4";
        break;
      case "tokorozawa_library":
        buildingName = "所沢図書館";
        anc = "#anc_4";

        break;
      default:
        buildingName = "不明な施設";

        break;
    }
    int _height = (SizeConfig.blockSizeVertical! * 100).round();
    showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        enableDrag: false,
        barrierColor: Colors.black.withOpacity(0.5),
        builder: (context) {
          return Container(
              height: SizeConfig.blockSizeVertical! * 70,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              margin: const EdgeInsets.only(top: 20),
              child: Column(children: [
                Container(
                    height: SizeConfig.blockSizeVertical! * 6,
                    width: SizeConfig.blockSizeHorizontal! * 100,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                    ),
                    child: Row(children: [
                      SizedBox(width: SizeConfig.safeBlockHorizontal! * 3),
                      pinImage,
                      Text(" " + buildingName,
                          style: TextStyle(
                              fontSize: SizeConfig.blockSizeVertical! * 3,
                              fontWeight: FontWeight.bold))
                    ])),
                SizedBox(height: SizeConfig.blockSizeVertical! * 1),
                //const Divider(height: 2,thickness: 2,),
                Row(children: [
                  SizedBox(width: SizeConfig.safeBlockHorizontal! * 3),
                  buttonModel(() {
                    isMenu = false;
                    mapWebViewController.loadUrl(
                        urlRequest: URLRequest(
                            url: WebUri(webLinks[location]! + yearAndMonth)));
                  }, Colors.greenAccent, " 開館時間 "),
                  buttonModel(() async {
                    isMenu = true;
                    await mapWebViewController.loadUrl(
                        urlRequest: URLRequest(
                            url: WebUri(
                                "https://waseda.primo.exlibrisgroup.com/discovery/search?vid=81SOKEI_WUNI:WINE")));
                  }, MAIN_COLOR, " WINE(蔵書検索) ")
                ]),
                SizedBox(height: SizeConfig.blockSizeVertical! * 1),
                Expanded(
                    child: Stack(children: [
                  Container(
                      color: Colors.white.withOpacity(0.6),
                      child: Container(
                        width: SizeConfig.blockSizeHorizontal! * 100,
                        height: SizeConfig.blockSizeVertical! * 75,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey)),
                        child: Container(
                            width: SizeConfig.blockSizeHorizontal! * 100,
                            height: SizeConfig.blockSizeVertical! * _height,
                            child: InAppWebView(
                              key: mapWebViewKey,
                              initialUrlRequest:
                                  URLRequest(url: WebUri(webLinks[location]!)),
                              onWebViewCreated: (controller) {
                                mapWebViewController = controller;
                              },
                              onLoadStop: (a, b) async {
                                _height = await mapWebViewController
                                        ?.getContentHeight() ??
                                    100;
                                if (!isMenu) {
                                  String javascriptCode = """
                                                     const element = document.querySelector('a[href="$anc"]');
                                                      if (element) {
                                                        element.click();
                                                      }
                                                        """;
                                  await mapWebViewController.evaluateJavascript(
                                      source: javascriptCode);
                                }
                                setState(() {});
                              },
                              onContentSizeChanged: (a, b, c) async {
                                _height = await mapWebViewController
                                        ?.getContentHeight() ??
                                    100;
                                setState(() {});
                              },
                            )),
                      )),
                ]))
              ]));
        });
  }

  void showFoodButtomSheet(String location) {
    String scrollElementID = "";
    int sectionChildNum = 0;
    String buildingName = "";
    Image pinImage = Image.asset('lib/assets/map_images/food_pin.png');
    bool isMenu = false;
    switch (location) {
      case "ookuma_garden_food":
        buildingName = "大隈ガーデンハウス";
        scrollElementID = "s01";
        sectionChildNum = 3;
        break;
      case "ground_slope_food":
        buildingName = "グランド坂食堂";
        scrollElementID = "s01";
        sectionChildNum = 5;
        break;
      case "toyama_food":
        buildingName = "戸山カフェテリア";
        scrollElementID = "s02";
        sectionChildNum = 1;
        break;
      case "rikou_food":
        buildingName = " 理工カフェテリア";
        scrollElementID = "s03";
        sectionChildNum = 2;
        break;
      case "rikou_food_63":
        buildingName = " 63号館カフェテリア";
        scrollElementID = "s03";
        sectionChildNum = 3;
        break;
      case "tokorozawa_food":
        buildingName = " 所沢食堂 ";
        scrollElementID = "s04";
        sectionChildNum = 1;
        break;
      default:
        buildingName = "不明な施設";
        scrollElementID = "";
        sectionChildNum = 0;
        break;
    }
    int _height = (SizeConfig.blockSizeVertical! * 100).round();
    showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        enableDrag: false,
        barrierColor: Colors.black.withOpacity(0.5),
        builder: (context) {
          return Container(
              height: SizeConfig.blockSizeVertical! * 75,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              margin: const EdgeInsets.only(top: 20),
              child: Column(children: [
                Container(
                    height: SizeConfig.blockSizeVertical! * 6,
                    width: SizeConfig.blockSizeHorizontal! * 100,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                    ),
                    child: Row(children: [
                      SizedBox(width: SizeConfig.safeBlockHorizontal! * 3),
                      pinImage,
                      Text(" " + buildingName,
                          style: TextStyle(
                              fontSize: SizeConfig.blockSizeVertical! * 3,
                              fontWeight: FontWeight.bold))
                    ])),
                SizedBox(height: SizeConfig.blockSizeVertical! * 1),
                //const Divider(height: 2,thickness: 2,),
                Row(children: [
                  SizedBox(width: SizeConfig.safeBlockHorizontal! * 3),
                  buttonModel(() {
                    isMenu = false;
                    mapWebViewController.loadUrl(
                        urlRequest: URLRequest(
                            url: WebUri(webLinks[location]! + yearAndMonth)));
                  }, Colors.orange, " 営業時間 "),
                  buttonModel(() async {
                    isMenu = true;
                    await mapWebViewController.loadUrl(
                        urlRequest: URLRequest(
                            url: WebUri("https://gakushoku.coop/search")));
                  }, Colors.yellow, " メニュー "),
                ]),
                SizedBox(height: SizeConfig.blockSizeVertical! * 1),
                Expanded(
                    child: Stack(children: [
                  Container(
                      color: Colors.white.withOpacity(0.6),
                      child: Container(
                        width: SizeConfig.blockSizeHorizontal! * 100,
                        height: SizeConfig.blockSizeVertical! * 75,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey)),
                        child: Container(
                            width: SizeConfig.blockSizeHorizontal! * 100,
                            height: SizeConfig.blockSizeVertical! * _height,
                            child: InAppWebView(
                              key: mapWebViewKey,
                              onConsoleMessage:
                                  (controller, consoleMessage) async {
                                print(consoleMessage.message);
                              },
                              initialUrlRequest: URLRequest(
                                  url: WebUri(
                                      webLinks[location]! + yearAndMonth)),
                              onWebViewCreated: (controller) {
                                mapWebViewController = controller;
                              },
                              onLoadStop: (a, b) async {
                                _height = await mapWebViewController
                                        ?.getContentHeight() ??
                                    100;

                                if (!isMenu) {
                                  String javascriptCode = """
                                                     const element = document.querySelector('a[href="#$scrollElementID"]');
                                                      if (element) {
                                                        element.click();
                                                      }
                                                        """;
                                  await mapWebViewController.evaluateJavascript(
                                      source: javascriptCode);
                                }
                                setState(() {});
                              },
                              onContentSizeChanged: (a, b, c) async {
                                _height = await mapWebViewController
                                        ?.getContentHeight() ??
                                    100;
                                setState(() {});
                              },
                            )),
                      )),
                ]))
              ]));
        });
  }
}
