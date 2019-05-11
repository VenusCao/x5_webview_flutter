import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:x5_webview/x5_webview.dart';

class DemoWebViewPage extends StatefulWidget {
  @override
  _DemoWebViewPageState createState() => _DemoWebViewPageState();
}

class _DemoWebViewPageState extends State<DemoWebViewPage> {
  WebViewController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("X5WebView示例"),
      ),
      body: X5WebView(

        url:
//            "https://ifeng.com-l-ifeng.com/20180528/7391_46b6cf3b/index.m3u8",
            "http://debugtbs.qq.com",
        javaScriptEnabled: true,
        onWebViewCreated: (control) {
          _controller = control;
        },
        onPageFinished: () async{
          var url=await _controller.currentUrl();
          print(url);
          var body =
              await _controller.evaluateJavascript('document.body.innerHTML');
          print(body);
        },
      ),
    );
  }

}
