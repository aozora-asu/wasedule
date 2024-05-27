import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/frontend/assist_files/ui_components.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

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
              "空き教室検索",
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

    "31" : LatLng(35.70541570674681, 139.7179363336403),
    "32" : LatLng(35.70509109144369, 139.718370179258),
    "33" : LatLng(35.70500553370184, 139.71779068546866),

    "52" : LatLng(35.705637188098656, 139.70709957841908),
    "53" : LatLng(35.70563507207901, 139.70751912052745),
    "54" : LatLng(35.70564142013665, 139.70788393977944),
    "61" : LatLng(35.706045288457254, 139.70576259562358),
  };


  Map<String,AssetImage> buildingImages = const {
    "3" : AssetImage('lib/assets/map_images/waseda_building_3.png'),
    "8" : AssetImage('lib/assets/map_images/waseda_building_8.png'),
    "11" : AssetImage('lib/assets/map_images/waseda_building_11.png'),
    "14" : AssetImage('lib/assets/map_images/waseda_building_14.png'),
    "15" : AssetImage('lib/assets/map_images/waseda_building_15.png'),
    "16" : AssetImage('lib/assets/map_images/waseda_building_16.png'),

    "31" : AssetImage('lib/assets/map_images/waseda_building_38.jpg'),
    "32" : AssetImage('lib/assets/map_images/waseda_building_38.jpg'),
    "33" : AssetImage('lib/assets/map_images/waseda_building_38.jpg'),

    "52" : AssetImage('lib/assets/map_images/waseda_building_53.jpg'),
    "53" : AssetImage('lib/assets/map_images/waseda_building_53.jpg'),
    "54" : AssetImage('lib/assets/map_images/waseda_building_53.jpg'),
    "61" : AssetImage('lib/assets/map_images/waseda_building_61.jpg'),
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

                  markerPin("31"),
                  markerPin("32"),
                  markerPin("33"),

                  markerPin("52"),
                  markerPin("53"),
                  markerPin("54"),
                  markerPin("61"),
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
}