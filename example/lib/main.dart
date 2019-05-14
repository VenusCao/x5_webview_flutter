import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:x5_webview/x5_sdk.dart';
import 'package:x5_webview_example/demo.dart';

void main() async {
  var isOK=await X5Sdk.init();
  print(isOK?"X5内核成功加载":"X5内核加载失败");
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
                    var isOk = await X5Sdk.openVideo(
                        "https://ifeng.com-l-ifeng.com/20180528/7391_46b6cf3b/index.m3u8");
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
                  X5Sdk.openWebActivity(
                      "https://ifeng.com-l-ifeng.com/20180528/7391_46b6cf3b/index.m3u8",
                      title: "web页面");
                },
                child: Text("x5webviewActivity")),
          ],
        ),
      ),
    );
  }
}
