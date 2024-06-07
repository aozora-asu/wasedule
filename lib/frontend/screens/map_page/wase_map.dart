import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_calandar_app/converter.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/frontend/assist_files/ui_components.dart';
import 'package:flutter_calandar_app/frontend/screens/moodle_view_page/syllabus.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toggle_switch/toggle_switch.dart';
import "../../../backend/DB/isar_collection/isar_handler.dart";
import "../../../backend/DB/isar_collection/isar_handler.dart";

final GlobalKey mapWebViewKey = GlobalKey();
late InAppWebViewController mapWebViewController;

class WasedaMapPage extends ConsumerStatefulWidget {
  @override
  _WasedaMapPageState createState() => _WasedaMapPageState();
}

class _WasedaMapPageState extends ConsumerState<WasedaMapPage>
    with TickerProviderStateMixin {
  final MapController mapController = MapController();
  late final _animatedMapController = AnimatedMapController(vsync: this);
  String yearAndMonth = DateFormat("yyyyMM").format(DateTime.now());
  late int initCampusNum;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    initPrefarence();
  }

  Future<void> initPrefarence() async {
    final pref = await SharedPreferences.getInstance();
    if (pref.getInt('initCampusNum') == null) {
      initCampusNum = 0;
      await pref.setInt('initCampusNum', 0);
    } else {
      initCampusNum = pref.getInt('initCampusNum')!;
    }

    for (int i = 0; i < campusID2buildingsList().length; i++) {
      await initCampusMapPrefarences(i.toString(), pref);
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> initCampusMapPrefarences(
      String campusID, SharedPreferences pref) async {
    if (pref.getBool('isMapDBEmpty_' + campusID) == null) {
      await pref.setBool('isMapDBEmpty_' + campusID, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    SizeConfig().init(context);
    return Scaffold(body: mapView());
  }

  Map<String, LatLng> campusLocations = const {
    "waseda": LatLng(35.70918661596566, 139.71979758630098),
    "toyama": LatLng(35.70562816868803, 139.7176382479536),
    "nishi_waseda": LatLng(35.70604328321409, 139.70671670575553),
    "tokorozawa": LatLng(35.78696579219986, 139.39954205621635),
  };

  Map<String, double> initMapZoom = const {
    "waseda": 16.2,
    "toyama": 17.2,
    "nishi_waseda": 16.75,
    "tokorozawa": 16,
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
    "rikou_library":
        AssetImage('lib/assets/map_images/waseda_rikou_library.jpg'),
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
      3: ["100", "101"]
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
  };

  Widget mapView() {
    return Stack(children: [
      Container(
          height: SizeConfig.blockSizeVertical! * 80,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 1.5), color: WHITE),
          child: FlutterMap(
            mapController: _animatedMapController.mapController,
            options: MapOptions(
                initialCenter: campusLocations.values.elementAt(initCampusNum),
                initialZoom: initMapZoom.values.elementAt(initCampusNum),
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                )),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(
            " わせまっぷ",
            style: TextStyle(
                color: BLUEGREY,
                fontSize: SizeConfig.blockSizeHorizontal! * 10,
                fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          //＠ブックマーク
          // IconButton(
          //     onPressed: () {},
          //     icon: Icon(Icons.bookmark,
          //         color: BLUEGREY, size: SizeConfig.blockSizeHorizontal! * 12))
        ]),
        Divider(
          color: Colors.blueGrey,
          endIndent: SizeConfig.blockSizeHorizontal! * 30,
          thickness: 3,
          height: 3,
        ),
        const SizedBox(height: 5),
        Row(children: [
          buttonModel(() async {
            final pref = await SharedPreferences.getInstance();
            pref.setInt("initCampusNum", 0);
            await _animatedMapController.animateTo(
                dest: campusLocations["waseda"]);
            await _animatedMapController.animatedZoomTo(initMapZoom["waseda"]!);
            setState(() {});
          }, buttonColor(0), "  早稲田  "),
          buttonModel(() async {
            final pref = await SharedPreferences.getInstance();
            pref.setInt("initCampusNum", 1);
            await _animatedMapController.animateTo(
                dest: campusLocations["toyama"]);
            await _animatedMapController.animatedZoomTo(initMapZoom["toyama"]!);
            setState(() {});
          }, buttonColor(1), "   戸山   "),
          buttonModel(() async {
            final pref = await SharedPreferences.getInstance();
            pref.setInt("initCampusNum", 2);
            await _animatedMapController.animateTo(
                dest: campusLocations["nishi_waseda"]);
            await _animatedMapController
                .animatedZoomTo(initMapZoom["nishi_waseda"]!);
            setState(() {});
          }, buttonColor(2), " 西早稲田 "),
          buttonModel(() async {
            final pref = await SharedPreferences.getInstance();
            pref.setInt("initCampusNum", 3);
            await _animatedMapController.animateTo(
                dest: campusLocations["tokorozawa"]);
            await _animatedMapController
                .animatedZoomTo(initMapZoom["tokorozawa"]!);
            setState(() {});
          }, buttonColor(3), "   所沢   "),
        ]),
      ]))
    ]);
  }

  Color buttonColor(int campusID) {
    if (campusID == initCampusNum) {
      return Colors.blue;
    } else {
      return Colors.blue;
    }
  }

  Marker markerPin(String location) {
    return Marker(
      width: 45.0,
      height: 45.0,
      point: buildingLocations[location]!,
      child: GestureDetector(
          onTap: () {
            showDetailButtomSheet(location);
          },
          child: FutureBuilder(
            future: IsarHandler().getNowVacantRoomList(isar!, location),
            builder: (context, snapShot) {
              if (snapShot.connectionState == ConnectionState.done) {
                bool hasVacantRoom = snapShot.data!.isNotEmpty;
                Image pinImage =
                    Image.asset('lib/assets/map_images/location_pin.png');
                if (!hasVacantRoom) {
                  pinImage = Image.asset(
                      'lib/assets/map_images/location_pin_notempty.png');
                }
                return Stack(children: [
                  pinImage,
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                    ),
                    child: Text(
                      location,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: WHITE),
                    ),
                  )
                ]);
              } else {
                return Stack(children: [
                  Image.asset('lib/assets/map_images/location_pin.png'),
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                    ),
                    child: Text(
                      location,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: WHITE),
                    ),
                  )
                ]);
              }
            },
          )),
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
                color: WHITE,
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
                    decoration: BoxDecoration(
                      gradient: gradationDecoration(color2: Colors.black),
                      color: WHITE,
                      borderRadius: const BorderRadius.only(
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
                              fontWeight: FontWeight.bold,
                              color: WHITE))
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
                  Container(
                    height: SizeConfig.blockSizeVertical! * 60,
                    color: WHITE.withOpacity(0.6),
                    padding: const EdgeInsets.all(10),
                    child: emptyClassRooms(location),
                  )
                ]))
              ]));
        }).then((_) {
      onModalBottomSheetClosed(); // コールバックを呼び出す
    });
  }

  void onModalBottomSheetClosed() {
    if (!stopDownload) {
      showSnackBar(context);
    }
    stopDownload = true;
  }

  void showSnackBar(BuildContext context) {
    SnackBar snackBar = const SnackBar(
      content: Text('データのダウンロードが中止されました。'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  bool stopDownload = true;
  Future<List<String>> initVacantRoomList(String location) async {
    int campusID = 0;
    for (int i = 0; i < campusID2buildingsList().length; i++) {
      if (campusID2buildingsList().values.elementAt(i).contains(location)) {
        campusID = campusID2buildingsList().keys.elementAt(i);
      }
    }

    SharedPreferences pref = await SharedPreferences.getInstance();
    bool isDataEmpty = pref.getBool('isMapDBEmpty_' + campusID.toString())!;
    if (isDataEmpty) {
      await downLoadCampusData(campusID);
      await pref.setBool('isMapDBEmpty_' + campusID.toString(), false);
    }

    List<String> result =
        await IsarHandler().getNowVacantRoomList(isar!, location);
    return result;
  }

  String currentLoadState = "";
  Future<void> downLoadCampusData(int campusID) async {
    stopDownload = false;
    List targetList = campusID2buildingsList()[campusID]!;
    for (int i = 0; i < targetList.length; i++) {
      if (stopDownload) {
        break;
      } else {
        print(targetList.elementAt(i) + "号館  ダウンロード実行中...");
        currentLoadState = targetList.elementAt(i) + "号館  ダウンロード実行中...";
        await resisterVacantRoomList(targetList.elementAt(i));
      }
    }
  }

  Widget emptyClassRooms(String location) {
    DateTime now = DateTime.now();
    int current_period = datetime2Period(now) ?? 0;

    return FutureBuilder(
        future: initVacantRoomList(location),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
              const CircularProgressIndicator(color: MAIN_COLOR),
              const Text("空き教室データ取得中…",
                  style: TextStyle(
                      color: MAIN_COLOR, fontWeight: FontWeight.bold)),
              streamProgressText(context, renewText())
            ]));
          } else if (snapshot.hasData) {
            countupLoaderStop();
            String searchResult = "授業期間外です。";

            // Map<String, Map<String, dynamic>> quarterMap = snapshot.data!;

            // dynamic weekDayMap = quarterMap[now.weekday.toString()] ?? {};

            // dynamic periodList = weekDayMap[current_period.toString()] ?? [];

            if (current_period == 0) {
              searchResult = "授業時間外です。";
            } else if (snapshot.data!.isEmpty) {
              searchResult = "空き教室はありません。";
            } else {
              searchResult = snapshot.data!.join('\n');
            }

            return SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text("現在の空き教室",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: SizeConfig.blockSizeHorizontal! * 6,
                          color: BLUEGREY)),
                  Container(
                      width: SizeConfig.blockSizeHorizontal! * 100,
                      padding: const EdgeInsets.all(7.5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7.0),
                          gradient: gradationDecoration()),
                      child: Text(searchResult,
                          style: TextStyle(
                            color: WHITE,
                            fontWeight: FontWeight.bold,
                            fontSize: SizeConfig.blockSizeHorizontal! * 5,
                          ))),
                  const SizedBox(height: 20),
                  SearchEmptyClassrooms(location: location),
                  const SizedBox(height: 30),
                  buttonModel(() async {
                    int campusID = 0;
                    for (int i = 0; i < campusID2buildingsList().length; i++) {
                      if (campusID2buildingsList()
                          .values
                          .elementAt(i)
                          .contains(location)) {
                        campusID = campusID2buildingsList().keys.elementAt(i);
                      }
                    }
                    SharedPreferences pref =
                        await SharedPreferences.getInstance();
                    await pref.setBool(
                        'isMapDBEmpty_' + campusID.toString(), true);
                    Navigator.pop(context);
                    showDetailButtomSheet(location);
                  }, MAIN_COLOR, "空き教室データの再取得", verticalpadding: 10)
                ]));
          } else {
            print("エラー：" + snapshot.error.toString());
            return const Center(
                child: CircularProgressIndicator(color: Colors.red));
          }
        });
  }

  Widget streamProgressText(BuildContext context, Stream<String> stream,
      [void Function()? stop]) {
    return StreamBuilder<String>(
        stream: stream,
        builder: (context, snapshot) {
          String data = "";
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              break;
            case ConnectionState.waiting:
              data = snapshot.data ?? data;
              break;
            case ConnectionState.active:
              data = snapshot.data ?? data;
              break;
            case ConnectionState.done:
              data = snapshot.data ?? data;
              break;
          }
          return Text(data,
              style: const TextStyle(
                  color: MAIN_COLOR, fontWeight: FontWeight.bold));
        });
  }

  //ロード処理を中止するフラグ
  bool _stop = false;

  //進捗状況を表示するためのロード処理部分
  Stream<String> renewText() async* {
    _stop = false;
    while (!_stop) {
      yield currentLoadState;
      await Future.delayed(const Duration(milliseconds: 10));
    }
  }

  //ロード処理を中止するための関数
  void countupLoaderStop() {
    _stop = true;
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
                color: WHITE,
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
                    decoration: BoxDecoration(
                      color: WHITE,
                      gradient: gradationDecoration(
                          color1: Colors.orange, color2: Colors.brown),
                      borderRadius: const BorderRadius.only(
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
                              fontWeight: FontWeight.bold,
                              color: WHITE))
                    ])),
                SizedBox(height: SizeConfig.blockSizeVertical! * 1),
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
                      color: WHITE.withOpacity(0.6),
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
                color: WHITE,
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
                    decoration: BoxDecoration(
                      gradient: gradationDecoration(
                          color1: Colors.red, color2: Colors.brown),
                      color: WHITE,
                      borderRadius: const BorderRadius.only(
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
                              fontWeight: FontWeight.bold,
                              color: WHITE))
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
                      color: WHITE.withOpacity(0.6),
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

class SearchEmptyClassrooms extends StatefulWidget {
  final String location;

  SearchEmptyClassrooms({
    required this.location,
  });

  @override
  _SearchEmptyClassroomsState createState() => _SearchEmptyClassroomsState();
}

class _SearchEmptyClassroomsState extends State<SearchEmptyClassrooms> {
  late int weekday;
  late int period;
  late Future<List<String>> futureVacantRooms;

  @override
  void initState() {
    super.initState();
    weekday = 0;
    period = 0;
    futureVacantRooms = fetchVacantRooms(widget.location, weekday, period);
  }

  Future<List<String>> fetchVacantRooms(
      String location, int weekday, int period) {
    return IsarHandler()
        .getVacantRoomList(isar!, location, weekday + 1, period + 1);
  }

  void updateVacantRooms() {
    setState(() {
      futureVacantRooms = fetchVacantRooms(widget.location, weekday, period);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "空き教室検索",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: SizeConfig.blockSizeHorizontal! * 6,
            color: BLUEGREY,
          ),
        ),
        ToggleSwitch(
          animate: true,
          animationDuration: 300,
          initialLabelIndex: weekday,
          totalSwitches: 6,
          activeBgColor: [PALE_MAIN_COLOR],
          inactiveFgColor: BLUEGREY,
          inactiveBgColor: Colors.grey.withOpacity(0.7),
          minHeight: 35,
          labels: const ['月', '火', '水', '木', '金', '土'],
          onToggle: (index) {
            setState(() {
              weekday = index!;
              updateVacantRooms();
            });
          },
        ),
        const SizedBox(height: 10),
        ToggleSwitch(
          animate: true,
          animationDuration: 300,
          initialLabelIndex: period,
          activeBgColor: const [PALE_MAIN_COLOR],
          inactiveFgColor: BLUEGREY,
          inactiveBgColor: Colors.grey.withOpacity(0.7),
          totalSwitches: 6,
          minHeight: 35,
          labels: ['1限', '2限', '3限', '4限', '5限', '6限'],
          onToggle: (index) {
            setState(() {
              period = index!;
              updateVacantRooms();
            });
          },
        ),
        const SizedBox(height: 10),
        FutureBuilder<List<String>>(
          future: futureVacantRooms,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: MAIN_COLOR),
                    Text(
                      "空き教室検索中…",
                      style: TextStyle(
                          color: MAIN_COLOR, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasData) {
              String searchResult = "この時間帯の空き教室はありません。";
              if (snapshot.data!.isNotEmpty) {
                searchResult = snapshot.data!.join('\n');
              }

              return Container(
                width: SizeConfig.blockSizeHorizontal! * 100,
                padding: const EdgeInsets.all(7.5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7.0),
                  gradient: gradationDecoration(),
                ),
                child: Text(
                  searchResult,
                  style: TextStyle(
                    color: WHITE,
                    fontWeight: FontWeight.bold,
                    fontSize: SizeConfig.blockSizeHorizontal! * 5,
                  ),
                ),
              );
            } else {
              print("エラー：" + snapshot.error.toString());
              return const Center(
                child: CircularProgressIndicator(color: Colors.red),
              );
            }
          },
        ),
      ],
    );
  }
}
