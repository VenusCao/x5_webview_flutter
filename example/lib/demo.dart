import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:x5_webview/x5_webview.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DemoWebViewPage extends StatefulWidget {
  @override
  _DemoWebViewPageState createState() => _DemoWebViewPageState();
}

class _DemoWebViewPageState extends State<DemoWebViewPage> {
  X5WebViewController _controller;
  WebViewController _otherController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("X5WebView示例"),
      ),
      body: defaultTargetPlatform == TargetPlatform.android
          ? X5WebView(
              url: "http://debugtbs.qq.com",
              javaScriptEnabled: true,
              onWebViewCreated: (control) {
                _controller = control;
              },
              onPageFinished: () async {
                var url = await _controller.currentUrl();
                print(url);
                var body = await _controller
                    .evaluateJavascript('document.body.innerHTML');
                print(body);
              },
            )
          :
          //可替换为其他已实现ios webview,此处使用webview_flutter
          WebView(
              initialUrl: "https://www.baidu.com",
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (control) {
                _otherController = control;
                var body = _otherController
                    .evaluateJavascript('document.body.innerHTML');
                print(body);
              },
            ),
    );
  }
}
