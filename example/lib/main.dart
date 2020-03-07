import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:x5_webview/x5_sdk.dart';
import 'package:path_provider/path_provider.dart';

import 'demo.dart';

import 'package:dio/dio.dart';

void main() {
  X5Sdk.setDownloadWithoutWifi(true); //没有x5内核，是否在非wifi模式下载内核。默认false
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
                          await X5Sdk.openVideo(url, screenMode: 102);
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
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("X5Sdk打开本地文件示例"),
                          content: Text("请先下载再打开"),
                          actions: <Widget>[
                            FlatButton(
                              onPressed: () async {
                                Navigator.pop(context);
                              },
                              child: Text("取消"),
                            ),
                            FlatButton(
                              onPressed: () async {
                                try {
                                  showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) {
                                        return AlertDialog(
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              CircularProgressIndicator(),
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(top: 20),
                                              ),
                                              Text("等待下载")
                                            ],
                                          ),
                                        );
                                      });
                                  var dir=await getExternalStorageDirectory();
                                  print(await getExternalStorageDirectory());
                                  print(await getApplicationSupportDirectory());
                                  print(await getApplicationDocumentsDirectory());
                                  var response = await Dio().download(
                                      "http://lc-QMTBhNKI.cn-n1.lcfile.com/aa1b149fab1fd3c7d88b/%E6%96%87%E4%BB%B6%E6%A0%BC%E5%BC%8F%E6%94%AF%E6%8C%81%E5%88%97%E8%A1%A8.xlsx",
                                      "${dir.path}/FileList.xlsx");
                                  print(response.data);
                                  Navigator.pop(context);
                                } catch (e) {
                                  print(e);
                                  Navigator.pop(context);
                                }
                              },
                              child: Text("下载"),
                            ),
                            FlatButton(
                              onPressed: () async {
                                var dir= await getExternalStorageDirectory();
                                print(dir);
                                var msg = await X5Sdk.openFile(
                                    "${dir.path}/FileList.xlsx");
                                print(msg);
                              },
                              child: Text("打开"),
                            )
                          ],
                        );
                      });
                },
                child: Text("x5sdk打开本地文件示例")),
            RaisedButton(
                onPressed: () async {
//                                          Navigator.of(context).push(
//                            CupertinoPageRoute(builder: (BuildContext context) {
//                              return DemoWebViewPage("http://bin.amazeui.org/tizayo");
//                            }));

                  showInputDialog(
                      onConfirm: (url) {
                        Navigator.of(context).push(
                            CupertinoPageRoute(builder: (BuildContext context) {
                          return DemoWebViewPage(url);
                        }));
                      },
                      defaultText: "http://bin.amazeui.org/tizayo");
                },
                child: Text("flutter内嵌x5webview")),
            RaisedButton(
                onPressed: () async {
                  showInputDialog(
                      onConfirm: (url) async {
                        await X5Sdk.openWebActivity(url, title: "web页面");
                      },
                      defaultText: "https://baidu.com");
                },
                child: Text("x5webviewActivity")),
            RaisedButton(
                onPressed: () async {
                  var fileHtmlContents =
                      await rootBundle.loadString("assets/index.html");
                  var url = Uri.dataFromString(fileHtmlContents,
                          mimeType: 'text/html',
                          encoding: Encoding.getByName('utf-8'))
                      .toString();

                  await X5Sdk.openWebActivity(url, title: "本地html示例");

//                  showInputDialog(
//                      onConfirm: (url) async {
//
//
//                        await X5Sdk.openWebActivity(url, title: "web页面");
//                      },
//                      defaultText: "https://baidu.com");
                },
                child: Text("本地html")),
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
