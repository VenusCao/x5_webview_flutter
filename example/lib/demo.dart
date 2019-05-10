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
        title: Text("webview示例"),
      ),
      body: X5WebView(
        url:
//            "https://www.baidu.com",
            "https://ifeng.com-l-ifeng.com/20180528/7391_46b6cf3b/index.m3u8",
        javaScriptEnabled: true,
        onWebViewCreated: (control) {
          _controller = control;
        },
        onPageFinished: () async{
          print("页面加载完成");
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
