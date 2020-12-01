import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:x5_webview/x5_webview.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DemoWebViewPage extends StatefulWidget {
  final url;

  DemoWebViewPage(this.url);

  @override
  _DemoWebViewPageState createState() => _DemoWebViewPageState(url);
}

class _DemoWebViewPageState extends State<DemoWebViewPage> {
  X5WebViewController _controller;
  final url;

  _DemoWebViewPageState(this.url);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            title: Text("X5WebView示例"),
            actions: <Widget>[
              IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.pop(context);
                  })
            ],
          ),
          body: Column(children: <Widget>[
            Expanded(
                child: defaultTargetPlatform == TargetPlatform.android
                    ? X5WebView(
                        url: url,
                        javaScriptEnabled: true,
                        header: {"TestHeader": "测试", "MSG": "在？在干嘛？吃饭了没？"},
                        userAgentString: "aaaa",
                        javascriptChannels: JavascriptChannels(
                            ["X5Web", "Toast"], (name, data) {
                          switch (name) {
                            case "X5Web":
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text("获取到的字符串为："),
                                      content: Text(data),
                                    );
                                  });
                              break;
                            case "Toast":
                              print(data);
                              break;
                          }
                        }),
                        onWebViewCreated: (control) {
                          _controller = control;
//                          var listName = ["X5Web", "Toast"];
//                          _controller.addJavascriptChannels(listName,
//                                  (name, data) {
//                                switch (name) {
//                                  case "X5Web":
//                                    showDialog(
//                                        context: context,
//                                        builder: (context) {
//                                          return AlertDialog(
//                                            title: Text("获取到的字符串为："),
//                                            content: Text(data),
//                                          );
//                                        });
//                                    break;
//                                  case "Toast":
//                                    print(data);
//                                    break;
//                                }
//                              });
                        },
                        onPageFinished: () async {
                          var url = await _controller.currentUrl();
                          print(url);
                        },
                        onProgressChanged: (progress) {
                          print("webview加载进度------$progress%");
                        },
                        onUrlLoading: (_url) {
                          print(_url);
                          showDialog(
                              context: context,
                              builder: (_) {
                                return AlertDialog(
                                  content: Text("url==$_url"),
                                  actions: [
                                    FlatButton(
                                      child: Text("我知道了"),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    )
                                  ],
                                );
                              });
                        },
                      )
                    :
                    //可替换为其他已实现ios webview,此处使用webview_flutter
                    WebView(
                        initialUrl: url,
                        javascriptMode: JavascriptMode.unrestricted,
                        javascriptChannels: [
                          JavascriptChannel(
                              name: "X5Web",
                              onMessageReceived: (msg) {
                                print(msg);
                              })
                        ].toSet(),
                        onWebViewCreated: (control) {
//                _otherController = control;
//                var body = _otherController
//                    .evaluateJavascript('document.body.innerHTML');
//                print(body);
                        },
                      )),
            RaisedButton(
              onPressed: () {
                _controller.evaluateJavascript(
                    'document.getElementById("input").value="flutter调用js成功！"');
              },
              child: Text("flutter调用js(更改文字)"),
            )
          ]),
        ),
        onWillPop: () async {
          var canGoBack = await _controller.canGoBack();
          if (canGoBack) {
            _controller.goBack();
            return false;
          } else {
            return true;
          }
        });
  }
}
