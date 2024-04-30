import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class MoodleViewPage extends ConsumerStatefulWidget {
  @override
  _MoodleViewPageState createState() => _MoodleViewPageState();
}

final GlobalKey webMoodleViewKey = GlobalKey();
InAppWebViewController? webMoodleViewController;

class _MoodleViewPageState extends ConsumerState<MoodleViewPage> {

  
  @override
  Widget build (BuildContext context){
    SizeConfig().init(context);
    return Scaffold(
      body: Column(children:[
       Expanded(
        child:
          ListView(
           shrinkWrap: true,
           scrollDirection: Axis.horizontal,
           physics: const NeverScrollableScrollPhysics(),
           children:[
            SizedBox(
              width:SizeConfig.blockSizeHorizontal! *100,
              child:InAppWebView(
                key: webMoodleViewKey,
                initialUrlRequest: URLRequest(
                  url: WebUri("https://wsdmoodle.waseda.jp/")),
                onWebViewCreated: (controller) {
                  webMoodleViewController = controller;
                },
              )
          )
            
          ])
          ),
      const Divider(height:0.5,thickness: 0.5, color: Colors.grey),
      Container(
        color: Colors.white,
        height:SizeConfig.blockSizeVertical! *5.5,
        child:menuBar()
      ),
      ])
        
    );
  }

  Widget menuBar(){
    return Row(children:[
            IconButton(
                onPressed: () {
                  webMoodleViewController?.goBack();
                },
                icon:Icon(Icons.arrow_back_ios,size:SizeConfig.blockSizeVertical! *2.5,),),
            const Spacer(),
            IconButton(
                onPressed: () {
                  final url = URLRequest(
                      url: WebUri("https://wsdmoodle.waseda.jp/"));
                  webMoodleViewController?.loadUrl(urlRequest: url);
                },
                icon:Icon(Icons.home,size:SizeConfig.blockSizeVertical! *3,),),
            const Spacer(),
            IconButton(
                onPressed: () {
                  webMoodleViewController?.goForward();
                },
                icon:Icon(Icons.arrow_forward_ios,size:SizeConfig.blockSizeVertical! *2.5,),),
    ]);
  }

}

