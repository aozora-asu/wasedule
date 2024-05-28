import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/frontend/assist_files/ui_components.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

final GlobalKey mapWebViewKey = GlobalKey();
late InAppWebViewController mapWebViewController;

class EmptyClassRoomView extends ConsumerStatefulWidget {
  @override
  _EmptyClassRoomViewState createState() => _EmptyClassRoomViewState();
}

class _EmptyClassRoomViewState extends ConsumerState<EmptyClassRoomView> with TickerProviderStateMixin{
  final MapController mapController = MapController();
  late final _animatedMapController = AnimatedMapController(vsync: this);
  @override
  Widget build(BuildContext context){
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
      child:Column(
        children:[
          Container(
            alignment: Alignment.center,
            height:SizeConfig.blockSizeVertical! *6,
            child:Text(
              "わせまっぷ(仮)",
              style: TextStyle(
                fontSize: SizeConfig.blockSizeVertical! *3,
                fontWeight: FontWeight.bold
              ))
          ),
          const Divider(height:1),
          SizedBox(
            height:SizeConfig.blockSizeVertical! *3,
            child:Text(
              "Map",
              style: TextStyle(
                fontSize: SizeConfig.blockSizeVertical! *2,
              ))
          ),
           mapView(),
          SizedBox(height:SizeConfig.blockSizeVertical! *4)
      ])
    );
  }

  Map<String,LatLng> campusLocations = const {
    "waseda" : LatLng(35.70943486485431, 139.71912124551386),
    "toyama" : LatLng(35.70562816868803, 139.7176382479536),
    "nishi_waseda" : LatLng(35.706086144049856, 139.7069180022201),
    "tokorozawa" : LatLng(35.78696579219986, 139.39954205621635),
  };

  Map<String,double> initMapZoom =  const {
    "waseda" : 16.5,
    "toyama" : 16.5,
    "nishi_waseda" : 16.5,
    "tokorozawa" : 16.5,
  };

  Map<String,LatLng> buildingLocations = const {
    "3" : LatLng(35.70924536312012, 139.72010069094065),
    "8" : LatLng(35.70834887366013, 139.71985092673003),
    "11" : LatLng(35.70901405731995, 139.71892837146606),
    "14" : LatLng(35.70982154825793, 139.7185954055238),
    "15" : LatLng(35.71024833967154, 139.71849563827368),
    "16" : LatLng(35.70995246877514, 139.7180193514461),
    "central_library" : LatLng(35.7109364274621, 139.718125412829861),

    "31" : LatLng(35.70541570674681, 139.7179363336403),
    "32" : LatLng(35.70509109144369, 139.718370179258),
    "33" : LatLng(35.70500553370184, 139.71779068546866),
    "toyama_library" : LatLng(35.70511867745611, 139.71871750748542),

    "52" : LatLng(35.705637188098656, 139.70709957841908),
    "53" : LatLng(35.70563507207901, 139.70751912052745),
    "54" : LatLng(35.70564142013665, 139.70788393977944),
    "61" : LatLng(35.706045288457254, 139.70576259562358),
    "rikou_library" : LatLng(35.70602782207398, 139.70674367727975),

    "tokorozawa_library" : LatLng(35.78520285349271, 139.39840174340995),
  };


  Map<String,AssetImage> buildingImages = const {
    "3" : AssetImage('lib/assets/map_images/waseda_building_3.png'),
    "8" : AssetImage('lib/assets/map_images/waseda_building_8.png'),
    "11" : AssetImage('lib/assets/map_images/waseda_building_11.png'),
    "14" : AssetImage('lib/assets/map_images/waseda_building_14.png'),
    "15" : AssetImage('lib/assets/map_images/waseda_building_15.png'),
    "16" : AssetImage('lib/assets/map_images/waseda_building_16.png'),
    "central_library" : AssetImage('lib/assets/map_images/waseda_central_library.jpg'),

    "31" : AssetImage('lib/assets/map_images/waseda_building_38.jpg'),
    "32" : AssetImage('lib/assets/map_images/waseda_building_38.jpg'),
    "33" : AssetImage('lib/assets/map_images/waseda_building_38.jpg'),
    "toyama_library" : AssetImage('lib/assets/map_images/waseda_toyama_library.jpg'),

    "52" : AssetImage('lib/assets/map_images/waseda_building_53.jpg'),
    "53" : AssetImage('lib/assets/map_images/waseda_building_53.jpg'),
    "54" : AssetImage('lib/assets/map_images/waseda_building_53.jpg'),
    "61" : AssetImage('lib/assets/map_images/waseda_building_61.jpg'),
    "rikou_library" : AssetImage('lib/assets/map_images/waseda_rikou_library.jpg'),

    "tokorozawa_library" : AssetImage('lib/assets/map_images/waseda_building_21.png'),
  };

  Map<String,String> webLinks = {
    "central_library" : "https://www.waseda.jp/library/libraries/central/",
    "toyama_library" : "https://www.waseda.jp/library/libraries/toyama/",
    "rikou_library" : "https://www.waseda.jp/library/libraries/sci-eng/",
    "tokorozawa_library" : "https://www.waseda.jp/library/libraries/tokorozawa/",
  };

  Widget mapView(){
    return Column(children:[
      Container(
        decoration: BoxDecoration(
          border: Border.all(color:Colors.grey,width: 1.5)
        ),
        height:SizeConfig.blockSizeVertical! *50,
        child: FlutterMap(
          mapController: _animatedMapController.mapController,
          options: MapOptions(
            initialCenter: campusLocations["waseda"]!,
            initialZoom: initMapZoom["waseda"]!,
          ),
          children: [
            TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains:const ['a', 'b', 'c'],
            ),
             MarkerLayer(
                markers: [
                  markerPin("3"),
                  markerPin("8"),
                  markerPin("11"),
                  markerPin("14"),
                  markerPin("15"),
                  markerPin("16"),
                  libraryPin("central_library"),

                  markerPin("31"),
                  markerPin("32"),
                  markerPin("33"),
                  libraryPin("toyama_library"),

                  markerPin("52"),
                  markerPin("53"),
                  markerPin("54"),
                  markerPin("61"),
                  libraryPin("rikou_library"),

                  libraryPin("tokorozawa_library"),
                ],
            ),
          ],
        )
      ),
      SizedBox(
        height: SizeConfig.blockSizeVertical! *5,
          child:Row(
            children:[
            buttonModel(
              (){
                _animatedMapController.animateTo(dest:campusLocations["waseda"]);
              },
              Colors.blue,
              "  早稲田  "),
              buttonModel(
              (){
                _animatedMapController.animateTo(dest:campusLocations["toyama"]);
              },
              Colors.blue,
              "   戸山   "),
              buttonModel(
              (){
                _animatedMapController.animateTo(dest:campusLocations["nishi_waseda"]);
              },
              Colors.blue,
              " 西早稲田 "),
              buttonModel(
              (){
                _animatedMapController.animateTo(dest:campusLocations["tokorozawa"]);
              },
              Colors.blue,
              "   所沢   "),
          ]),
        )
    ]);
  }

  Marker markerPin(String location){
    return Marker(
        width: 45.0,
        height: 45.0,
        point: buildingLocations[location]!, 
        child: GestureDetector(
          onTap: (){
            showDetailButtomSheet(location);
          },
          child:Image.asset('lib/assets/map_images/location_pin.png')),  
        rotate: true,
      );
    }

  Marker libraryPin(String location){
    return Marker(
        width: 45.0,
        height: 45.0,
        point: buildingLocations[location]!, 
        child: GestureDetector(
          onTap: (){
            showLibraryButtomSheet(location);
          },
          child:Image.asset('lib/assets/map_images/library_pin.png')),  
        rotate: true,
      );
    }

  void showDetailButtomSheet(String location){
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) {
        return Container(
          height: SizeConfig.blockSizeVertical! *60,
          decoration:const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
          ),
          margin:const EdgeInsets.only(top: 20),
          child: Column(
            children:[
              Container(
                height: SizeConfig.blockSizeVertical! *6,
                width: SizeConfig.blockSizeHorizontal! *100,
                decoration:const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                child: Row(children:[
                  SizedBox(width: SizeConfig.safeBlockHorizontal! *3),
                  Image.asset('lib/assets/map_images/location_pin.png'), 
                  Text(
                    " "+location+'号館',
                    style: TextStyle(
                      fontSize: SizeConfig.blockSizeVertical! *4,
                      fontWeight: FontWeight.bold))
                  ])
                ),
              const Divider(height: 2,thickness: 2,),
              Expanded(
                child:Stack(
                children:[
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image:buildingImages[location]!,
                        fit: BoxFit.cover),
                  ),
                ),
                Container(color:Colors.white.withOpacity(0.6))
              ])
            )
          ])
        );
      });
    }

    void showLibraryButtomSheet(String location){
    int scrollDistance = 0;
    String buildingName = "";
    switch(location) {
      case "central_library":
        buildingName = "中央図書館";
        scrollDistance = 4500;
        break;
      case "toyama_library": 
        buildingName = "戸山図書館";
        scrollDistance = 7000;
        break;
      case "rikou_library":
        buildingName = "理工図書館";
        scrollDistance = 4250;
        break;
      case "tokorozawa_library":
        buildingName = "所沢図書館";
        scrollDistance = 5000;
        break;
      default:
        buildingName = "不明な図書館";
        scrollDistance = 0;
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
          height: SizeConfig.blockSizeVertical! *60,
          decoration:const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
          ),
          margin:const EdgeInsets.only(top: 20),
          child: Column(
            children:[
              Container(
                height: SizeConfig.blockSizeVertical! *6,
                width: SizeConfig.blockSizeHorizontal! *100,
                decoration:const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                child: Row(children:[
                  SizedBox(width: SizeConfig.safeBlockHorizontal! *3),
                  Image.asset('lib/assets/map_images/library_pin.png'), 
                  Text(
                    " "+ buildingName,
                    style: TextStyle(
                      fontSize: SizeConfig.blockSizeVertical! *4,
                      fontWeight: FontWeight.bold))
                  ])
                ),
              const Divider(height: 2,thickness: 2,),
              Expanded(
                child:Stack(
                children:[
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image:buildingImages[location]!,
                        fit: BoxFit.cover),
                  ),
                ),
                Container(
                  color:Colors.white.withOpacity(0.6),
                  child:         Container(
            width: SizeConfig.blockSizeHorizontal! * 100,
            height: SizeConfig.blockSizeVertical! * 75,
            decoration:
                BoxDecoration(border: Border.all()),
              child: Container(
                  width: SizeConfig.blockSizeHorizontal! *
                      100,
                  height: SizeConfig.blockSizeVertical! *
                      _height,
                  child: InAppWebView(
                    key: mapWebViewKey,
                    initialUrlRequest: URLRequest(
                        url: WebUri(
                          webLinks[location]!)),
                    onWebViewCreated: (controller) {
                     mapWebViewController =
                          controller;
                    },
                    onLoadStop: (a, b) async {
                      _height =
                          await mapWebViewController
                                  ?.getContentHeight() ??
                              100;
                      mapWebViewController.scrollBy(x:0,y:scrollDistance,animated: true);
                      setState(() {});
                    },
                    onContentSizeChanged:
                        (a, b, c) async {
                      _height =
                          await mapWebViewController
                                  ?.getContentHeight() ??
                              100;
                      setState(() {});
                    },
                  )),
                )),
              ])
            )
          ])
        );
      });
    }

}