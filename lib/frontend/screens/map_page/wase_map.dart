import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/backend/DB/sharepreference.dart';
import 'package:flutter_calandar_app/static/converter.dart';
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
import 'package:toggle_switch/toggle_switch.dart';
import "../../../backend/DB/isar_collection/isar_handler.dart";
import "../../../static/constant.dart";
import "./const_map_info.dart";

final GlobalKey mapWebViewKey = GlobalKey();
late InAppWebViewController mapWebViewController;

class WasedaMapPage extends ConsumerStatefulWidget {
  const WasedaMapPage({super.key});

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

  void initPrefarence() {
    initCampusNum =
        SharepreferenceHandler().getValue(SharepreferenceKeys.initCampusNum);
    for (int i = 0; i < campusID2buildingsList().length; i++) {
      initCampusMapPrefarences(i);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void initCampusMapPrefarences(int campusID) {
    SharepreferenceKeys mapDBEmptyKey =
        SharepreferenceKeys.isMapDBEmpty(campusID);
    SharepreferenceHandler sharepreferenceHandler = SharepreferenceHandler();
    if (sharepreferenceHandler.getValue(mapDBEmptyKey) == null) {
      sharepreferenceHandler.setValue(mapDBEmptyKey, true);
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

  Map<int, List<String>> campusID2buildingsList() {
    return const {
      0: ["3", "6", "7", "8", "10", "11", "14", "15", "16"],
      1: ["31", "32", "33", "34", "36", "38"],
      2: ["52", "53", "54", "56", "57", "60", "61", "63"],
      3: ["100", "101"]
    };
  }

  Widget mapView() {
    SharepreferenceHandler sharepreferenceHandler = SharepreferenceHandler();
    return Stack(children: [
      Container(
          height: SizeConfig.blockSizeVertical! * 80,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 1.5),
              color: FORGROUND_COLOR),
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
          const SizedBox(width:10),
          SizedBox(
              width: 40,
              height: 40,
              child: Image.asset(
                  "lib/assets/eye_catch/wase_map_logo_transparent.png")),
          const Text(
            " わせまっぷ",
            style: TextStyle(
                color: BLUEGREY,
                fontSize: 40,
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
          color: BLUEGREY,
          endIndent: SizeConfig.blockSizeHorizontal! * 30,
          thickness: 3,
          height: 3,
        ),
        const SizedBox(height: 5),
        Row(children: [
          buttonModel(() async {
            sharepreferenceHandler.setValue(
                SharepreferenceKeys.initCampusNum, 0);
            await _animatedMapController.animateTo(
                dest: campusLocations["waseda"]);
            await _animatedMapController.animatedZoomTo(initMapZoom["waseda"]!);
            setState(() {});
          }, buttonColor(0), "  早稲田  "),
          buttonModel(() async {
            sharepreferenceHandler.setValue(
                SharepreferenceKeys.initCampusNum, 1);
            await _animatedMapController.animateTo(
                dest: campusLocations["toyama"]);
            await _animatedMapController.animatedZoomTo(initMapZoom["toyama"]!);
            setState(() {});
          }, buttonColor(1), "   戸山   "),
          buttonModel(() async {
            sharepreferenceHandler.setValue(
                SharepreferenceKeys.initCampusNum, 2);
            await _animatedMapController.animateTo(
                dest: campusLocations["nishi_waseda"]);
            await _animatedMapController
                .animatedZoomTo(initMapZoom["nishi_waseda"]!);
            setState(() {});
          }, buttonColor(2), " 西早稲田 "),
          buttonModel(() async {
            sharepreferenceHandler.setValue(
                SharepreferenceKeys.initCampusNum, 3);
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
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: FORGROUND_COLOR),
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
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: FORGROUND_COLOR),
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
        enableDrag: false,
        barrierColor: Colors.black.withOpacity(0.5),
        builder: (context) {
          return Container(
              height: SizeConfig.blockSizeVertical! * 60,
              decoration: BoxDecoration(
                color: FORGROUND_COLOR,
                borderRadius: const BorderRadius.only(
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
                      color: FORGROUND_COLOR,
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
                              color: FORGROUND_COLOR))
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
                    color: FORGROUND_COLOR.withOpacity(0.6),
                    padding: const EdgeInsets.all(10),
                    child: emptyClassRooms(location),
                  )
                ]))
              ]));
        }).then((_) {
      onModalBottomSheetClosed();
    });
  }

  void onModalBottomSheetClosed() {
    if (!stopDownload && !showDownloadButton) {
      //showSnackBar(context);
    }
    showDownloadButton = true;
    stopDownload = true;
  }

  void showSnackBar(BuildContext context) {
    SnackBar snackBar = const SnackBar(
      content: Text('データのダウンロードが中止されました。'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  bool stopDownload = false;
  bool showDownloadButton = true;
  Future<List<String>> initVacantRoomList(String location) async {
    int campusID = 0;
    for (int i = 0; i < campusID2buildingsList().length; i++) {
      if (campusID2buildingsList().values.elementAt(i).contains(location)) {
        campusID = campusID2buildingsList().keys.elementAt(i);
      }
    }

    SharepreferenceKeys mapDBEmptyKey =
        SharepreferenceKeys.isMapDBEmpty(campusID);
    bool isDataEmpty = SharepreferenceHandler().getValue(mapDBEmptyKey);
    if (isDataEmpty && !isDownloadInit) {
      isDownloadInit = true;
      SharepreferenceHandler().setValue(mapDBEmptyKey, false);
      await downLoadCampusData(campusID);
      showDownloadButton = false;
      stopDownload = true;
    } else if (!isDataEmpty) {
      showDownloadButton = false;
    } else {
      showDownloadButton = true;
    }

    List<String> result =
        await IsarHandler().getNowVacantRoomList(isar!, location);
    return result;
  }

  int numOfDoneLoadings = 0;
  String currentLoadState = "";
  Future<void> downLoadCampusData(int campusID) async {
    SharepreferenceKeys mapDBEmptyKey =
        SharepreferenceKeys.isMapDBEmpty(campusID);
    currentLoadState = "";
    numOfDoneLoadings = 0;
    stopDownload = false;
    List targetList = campusID2buildingsList()[campusID]!;
    for (int i = 0; i < targetList.length; i++) {
      if (stopDownload) {
        SharepreferenceHandler().setValue(mapDBEmptyKey, true);
        showDownloadButton = true;
        break;
      } else {
        print(targetList.elementAt(i) + "号館  ダウンロード実行中...");
        currentLoadState = targetList.elementAt(i) + "号館  ダウンロード実行中...";
        await resisterVacantRoomList(targetList.elementAt(i));
        numOfDoneLoadings += 1;
      }
    }
  }

  bool isDownloadInit = true;
  Widget emptyClassRooms(String location) {
    DateTime now = DateTime.now();
    int currentPeriod =
        Lesson.whenPeriod(now) != null ? Lesson.whenPeriod(now)!.period : 0;
    SharepreferenceKeys mapDBEmptyKey;
    int campusID = 0;
    for (int i = 0; i < campusID2buildingsList().length; i++) {
      if (campusID2buildingsList().values.elementAt(i).contains(location)) {
        campusID = campusID2buildingsList().keys.elementAt(i);
      }
    }

    return FutureBuilder(
        future: initVacantRoomList(location),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
              showStreamLoader(context,
                  renewProgressBar(campusID2buildingsList()[campusID]!.length)),
              const Text("空き教室データ取得中(所要時間:1分程度)",
                  style: TextStyle(
                      color: MAIN_COLOR, fontWeight: FontWeight.bold)),
              streamProgressText(context, renewText())
            ]));
          } else if (snapshot.hasData) {
            isDownloadInit = true;
            countupLoaderStop();
            String searchResult = "授業期間外です。";

            // Map<String, Map<String, dynamic>> quarterMap = snapshot.data!;

            // dynamic weekDayMap = quarterMap[now.weekday.toString()] ?? {};

            // dynamic periodList = weekDayMap[current_period.toString()] ?? [];

            if (currentPeriod == 0) {
              searchResult = "授業時間外です。";
            } else if (snapshot.data!.isEmpty) {
              searchResult = "空き教室はありません。";
            } else {
              searchResult = snapshot.data!.join('\n');
            }
            if (showDownloadButton) {
              return Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text("このキャンパスの空き教室データはありません",
                    style: TextStyle(
                        color: MAIN_COLOR, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                buttonModel(() {
                  setState(() {
                    isDownloadInit = false;
                  });
                  Navigator.pop(context);
                  showDetailButtomSheet(location);
                }, MAIN_COLOR, "ダウンロード", verticalpadding: 10)
              ]));
            } else {
              return SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    const Text("現在の空き教室",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                            color: BLUEGREY)),
                    Container(
                        width: SizeConfig.blockSizeHorizontal! * 100,
                        padding: const EdgeInsets.all(7.5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7.0),
                            gradient: gradationDecoration()),
                        child: Text(searchResult,
                            style: TextStyle(
                              color: FORGROUND_COLOR,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ))),
                    const SizedBox(height: 20),
                    SearchEmptyClassrooms(location: location),
                    const SizedBox(height: 30),
                    buttonModel(() async {
                      int campusID = 0;
                      for (int i = 0;
                          i < campusID2buildingsList().length;
                          i++) {
                        if (campusID2buildingsList()
                            .values
                            .elementAt(i)
                            .contains(location)) {
                          campusID = campusID2buildingsList().keys.elementAt(i);
                        }
                      }

                      mapDBEmptyKey =
                          SharepreferenceKeys.isMapDBEmpty(campusID);
                      SharepreferenceHandler().setValue(mapDBEmptyKey, true);
                      isDownloadInit = false;
                      Navigator.pop(context);
                      showDetailButtomSheet(location);
                    }, MAIN_COLOR, "空き教室データの再取得", verticalpadding: 10)
                  ]));
            }
          } else {
            print("エラー：${snapshot.error}");
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

  Widget showStreamLoader(BuildContext context, Stream<double> stream,
      [void Function()? stop]) {
    return StreamBuilder<double>(
        stream: stream,
        builder: (context, snapshot) {
          double data = 0.0;
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
              Navigator.pop(context);
              break;
          }
          return LinearProgressIndicator(
            color: MAIN_COLOR,
            value: data,
            minHeight: 5,
          );
        });
  }

  Stream<double> renewProgressBar(int numOfBuildings) async* {
    _stop = false;
    if (numOfBuildings == 0) {
      numOfBuildings = 1;
    }
    while (!_stop) {
      yield numOfDoneLoadings / numOfBuildings;
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
    int height = (SizeConfig.blockSizeVertical! * 100).round();
    showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        enableDrag: false,
        barrierColor: Colors.black.withOpacity(0.5),
        builder: (context) {
          return Container(
              height: SizeConfig.blockSizeVertical! * 70,
              decoration: BoxDecoration(
                color: FORGROUND_COLOR,
                borderRadius: const BorderRadius.only(
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
                      color: FORGROUND_COLOR,
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
                      Text(" $buildingName",
                          style: TextStyle(
                              fontSize: SizeConfig.blockSizeVertical! * 3,
                              fontWeight: FontWeight.bold,
                              color: FORGROUND_COLOR))
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
                      color: FORGROUND_COLOR.withOpacity(0.6),
                      child: Container(
                        width: SizeConfig.blockSizeHorizontal! * 100,
                        height: SizeConfig.blockSizeVertical! * 75,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey)),
                        child: SizedBox(
                            width: SizeConfig.blockSizeHorizontal! * 100,
                            height: SizeConfig.blockSizeVertical! * height,
                            child: InAppWebView(
                              key: mapWebViewKey,
                              initialUrlRequest:
                                  URLRequest(url: WebUri(webLinks[location]!)),
                              onWebViewCreated: (controller) {
                                mapWebViewController = controller;
                              },
                              onLoadStop: (a, b) async {
                                height = await mapWebViewController
                                        .getContentHeight() ??
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
                                height = await mapWebViewController
                                        .getContentHeight() ??
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
    int height = (SizeConfig.blockSizeVertical! * 100).round();
    showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        enableDrag: false,
        barrierColor: Colors.black.withOpacity(0.5),
        builder: (context) {
          return Container(
              height: SizeConfig.blockSizeVertical! * 75,
              decoration: BoxDecoration(
                color: FORGROUND_COLOR,
                borderRadius: const BorderRadius.only(
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
                      color: FORGROUND_COLOR,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                    ),
                    child: Row(children: [
                      SizedBox(width: SizeConfig.safeBlockHorizontal! * 3),
                      pinImage,
                      Text(" $buildingName",
                          style: TextStyle(
                              fontSize: SizeConfig.blockSizeVertical! * 3,
                              fontWeight: FontWeight.bold,
                              color: FORGROUND_COLOR))
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
                      color: FORGROUND_COLOR.withOpacity(0.6),
                      child: Container(
                        width: SizeConfig.blockSizeHorizontal! * 100,
                        height: SizeConfig.blockSizeVertical! * 75,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey)),
                        child: SizedBox(
                            width: SizeConfig.blockSizeHorizontal! * 100,
                            height: SizeConfig.blockSizeVertical! * height,
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
                                height = await mapWebViewController
                                        .getContentHeight() ??
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
                                height = await mapWebViewController
                                        .getContentHeight() ??
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

  const SearchEmptyClassrooms({
    super.key,
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
        const Text(
          "空き教室検索",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 23,
            color: BLUEGREY,
          ),
        ),
        ToggleSwitch(
          animate: true,
          animationDuration: 300,
          initialLabelIndex: weekday,
          totalSwitches: 6,
          activeBgColor: const [PALE_MAIN_COLOR],
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
          labels: const ['1限', '2限', '3限', '4限', '5限', '6限'],
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
                    color: FORGROUND_COLOR,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              );
            } else {
              print("エラー：${snapshot.error}");
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
