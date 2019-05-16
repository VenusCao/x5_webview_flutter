import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:x5_webview/x5_sdk.dart';

import 'demo.dart';

void main() async {
  var isOK = await X5Sdk.init();
  print(isOK ? "X5内核成功加载" : "X5内核加载失败");
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
                  Navigator.of(context)
                      .push(CupertinoPageRoute(builder: (BuildContext context) {
                    return DemoWebViewPage();
                  }));
                },
                child: Text("flutter内嵌x5webview")),
            RaisedButton(
                onPressed: () async {
                  showInputDialog(
                      onConfirm: (url) async {
                        await X5Sdk.openWebActivity("https://www.baidu.com",
                            title: "web页面");
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
                    onConfirm(_controller.text);
                  },
                  child: Text("跳转"))
            ],
          );
        });
  }
}

typedef ConfirmCallBack = Function(String url);
