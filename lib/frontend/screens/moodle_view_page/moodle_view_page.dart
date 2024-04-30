import 'package:flutter/material.dart';
import 'package:flutter_calandar_app/frontend/assist_files/size_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class MoodleViewPage extends ConsumerStatefulWidget {
  @override
  _MoodleViewPageState createState() => _MoodleViewPageState();
}

class _MoodleViewPageState extends ConsumerState<MoodleViewPage> {
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;
  
  @override
  Widget build (BuildContext context){
    SizeConfig().init(context);
    return Scaffold(
      body: Column(children:[
       Expanded(
        child:InAppWebView(
            key: webViewKey,
            initialUrlRequest: URLRequest(
              url: WebUri("https://wsdmoodle.waseda.jp/")),
            onWebViewCreated: (controller) {
              webViewController = controller;
            },
            
          )),
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
                  webViewController?.goBack();
                },
                icon:Icon(Icons.arrow_back_ios,size:SizeConfig.blockSizeVertical! *2.5,),),
            const Spacer(),
            IconButton(
                onPressed: () {
                  final url = URLRequest(
                      url: WebUri("https://wsdmoodle.waseda.jp/"));
                  webViewController?.loadUrl(urlRequest: url);
                },
                icon:Icon(Icons.home,size:SizeConfig.blockSizeVertical! *3,),),
            const Spacer(),
            IconButton(
                onPressed: () {
                  webViewController?.goForward();
                },
                icon:Icon(Icons.arrow_forward_ios,size:SizeConfig.blockSizeVertical! *2.5,),),
    ]);
  }

}

