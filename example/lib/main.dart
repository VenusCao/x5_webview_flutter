import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:x5_webview/x5_sdk.dart';

import 'demo.dart';

void main() {
  X5Sdk.init().then((isOK) {
    print(isOK ? "X5内核成功加载" : "X5内核加载失败");
  });
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            RaisedButton(
                onPressed: () async {
                  X5Sdk.openWebActivity("http://debugtbs.qq.com",
                      title: "X5内核信息");
                },
                child: Text("查看X5内核信息")),
            RaisedButton(
                onPressed: () async {
                  var canUseTbsPlayer = await X5Sdk.canUseTbsPlayer();
                  if (canUseTbsPlayer) {
                    showInputDialog(
                        onConfirm: (url) async {
                          await X5Sdk.openVideo(url);
                        },
                        defaultText:
                            "https://youku.com-l-youku.com/20181221/5625_d9733a43/index.m3u8");
                  } else {
                    print("x5Video不可用");
                  }
                },
                child: Text("x5video直接播放视频")),
            RaisedButton(
                onPressed: () async {
                  showInputDialog(
                      onConfirm: (url) {
                        Navigator.of(context).push(
                            CupertinoPageRoute(builder: (BuildContext context) {
                              return DemoWebViewPage(url);
                            }));
                      },
                      defaultText: "https://www.baidu.com");
                },
                child: Text("flutter内嵌x5webview")),
            RaisedButton(
                onPressed: () async {
                  showInputDialog(
                      onConfirm: (url) async {
                        await X5Sdk.openWebActivity(url, title: "web页面");
                      },
                      defaultText: "https://www.baidu.com");
                },
                child: Text("x5webviewActivity")),
          ],
        ),
      ),
    );
  }

  void showInputDialog(
      {@required ConfirmCallBack onConfirm, String defaultText = ""}) {
    final _controller = TextEditingController(text: defaultText);
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("输入链接测试"),
            content: TextField(
              controller: _controller,
            ),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("取消")),
              FlatButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    onConfirm(_controller.text);
                  },
                  child: Text("跳转"))
            ],
          );
        });
  }
}

typedef ConfirmCallBack = Function(String url);
