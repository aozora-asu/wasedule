
import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/colors.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_calandar_app/frontend/screens/common/app_bar.dart';
import 'package:flutter_calandar_app/frontend/screens/common/logo_and_title.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class CodeSharePage extends StatelessWidget{
  final ScreenshotController _screenShotController = ScreenshotController();
  late String id;
  
  CodeSharePage({
    required this.id
  });
  
  @override
  Widget build(BuildContext context){
    SizeConfig().init(context);
    return Scaffold(
      appBar: CustomAppBar(backButton:true),
      body: pageBody(),
      floatingActionButton: shareButton(context),
    );

  }

  Widget pageBody(){
    return 
      Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
           image: AssetImage('lib/assets/page_background/sky_wallpaper.png'),
           fit: BoxFit.cover,
        )),
        child: Center(
          child: Screenshot(
            controller: _screenShotController, 
            child:  mainContents()
          )
        )
    );

  }

  Widget mainContents(){
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('lib/assets/calendar_background/ookuma_day.png'),
          fit: BoxFit.cover,
        )
      ),
      child:Container(
        width: SizeConfig.blockSizeHorizontal! *95,
        height: SizeConfig.blockSizeHorizontal! *95,
        color: Colors.white.withOpacity(0.8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child:Column(children:[
            Row(children:[
              Text("わせジュールで",
                style:TextStyle(
                  fontSize: SizeConfig.blockSizeHorizontal! *5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
            ]),
            Row(children:[
            const Expanded(
                child:TextField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(0),
                    hintText: "予定",
                    isCollapsed: true,
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color:MAIN_COLOR),)
                  ),
                ),
              ),
              Text("を共有中！",
                style:TextStyle(
                  fontSize: SizeConfig.blockSizeHorizontal! *5,
                  fontWeight: FontWeight.bold
                ),
              ),
            ]),
            const Spacer(),
            QrImageView(
              data: id,
              version: QrVersions.auto,
              size: SizeConfig.blockSizeHorizontal! *55,
              backgroundColor: Colors.white,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color:MAIN_COLOR),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: MAIN_COLOR
              ),
            ),
            const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children:[
                  Text("共有コード:",
                      style:TextStyle(
                        fontSize: SizeConfig.blockSizeHorizontal! *4
                      )
                    ),
                  Text(id,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize:  SizeConfig.blockSizeHorizontal! *4,
                    overflow: TextOverflow.clip
                    )
                  ),
                Row(
                  children: [
                    const Spacer(),
                    LogoAndTitle(size:SizeConfig.blockSizeHorizontal! *1.5),
                  ]
                )
              ])
          ])
        )
      )
    );
  }

  Widget shareButton(BuildContext context) {
    return FloatingActionButton(
        heroTag: "share",
        backgroundColor: MAIN_COLOR,
        child: const Icon(Icons.ios_share, color: Colors.white),
        onPressed: () async {
          final screenshot = await _screenShotController.capture(
            delay: const Duration(milliseconds: 0),
          );
          if (screenshot != null) {
            final shareFile = XFile.fromData(screenshot, mimeType: "image/png");

            await Share.shareXFiles([
              shareFile,
            ],
                sharePositionOrigin: Rect.fromLTWH(
                    0,
                    0,
                    MediaQuery.of(context).size.width,
                    MediaQuery.of(context).size.height / 2));
          }
        });
  }
}