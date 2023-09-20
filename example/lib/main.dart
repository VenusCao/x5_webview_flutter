import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:x5_webview/x5_sdk.dart';

import 'demo.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var crashInfo;
  bool isLoadOk = false;
  @override
  void initState() {
    super.initState();
    loadX5();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            ElevatedButton(
                onPressed: () async {
                  X5Sdk.openWebActivity("http://debugtbs.qq.com",
                      title: "X5内核信息");
                },
                child: Text("查看X5内核信息")),
            // ElevatedButton(
            //     onPressed: () async {
            //       showInputDialog(
            //           onConfirm: (url) async {
            //             await X5Sdk.openVideo(url, screenMode: 104);
            //           },
            //           defaultText: "https://vjs.zencdn.net/v/oceans.mp4");
            //
            //       // var canUseTbsPlayer = await X5Sdk.canUseTbsPlayer();
            //       // if (canUseTbsPlayer) {
            //       //   showInputDialog(
            //       //       onConfirm: (url) async {
            //       //         await X5Sdk.openVideo(url, screenMode: 104);
            //       //       },
            //       //       defaultText: "https://vjs.zencdn.net/v/oceans.mp4");
            //       // } else {
            //       //   print("x5Video不可用");
            //       // }
            //     },
            //     child: Text("x5video直接播放视频")),
            // ElevatedButton(
            //     onPressed: () async {
            //       showDialog(
            //           context: context,
            //           builder: (context) {
            //             return AlertDialog(
            //               title: Text("X5Sdk打开本地文件示例"),
            //               content: Text("请先下载再打开"),
            //               actions: <Widget>[
            //                 TextButton(
            //                   onPressed: () async {
            //                     Navigator.pop(context);
            //                   },
            //                   child: Text("取消"),
            //                 ),
            //                 TextButton(
            //                   onPressed: () async {
            //                     try {
            //                       showDialog(
            //                           context: context,
            //                           barrierDismissible: false,
            //                           builder: (context) {
            //                             return AlertDialog(
            //                               content: Column(
            //                                 mainAxisSize: MainAxisSize.min,
            //                                 children: <Widget>[
            //                                   CircularProgressIndicator(),
            //                                   Padding(
            //                                     padding:
            //                                         EdgeInsets.only(top: 20),
            //                                   ),
            //                                   Text("等待下载")
            //                                 ],
            //                               ),
            //                             );
            //                           });
            //                       var dir = await getExternalStorageDirectory();
            //                       print(await getExternalStorageDirectory());
            //                       print(await getApplicationSupportDirectory());
            //                       print(
            //                           await getApplicationDocumentsDirectory());
            //                       var response = await Dio().download(
            //                           "http://lc-QMTBhNKI.cn-n1.lcfile.com/fc441aa8ff4738cc3f85/FileList.xlsx",
            //                           "${dir?.path}/FileList.xlsx");
            //                       print(response.data);
            //                       Navigator.pop(context);
            //                     } on DioError catch (e) {
            //                       Navigator.pop(context);
            //                       print(e.message);
            //                     }
            //                   },
            //                   child: Text("下载"),
            //                 ),
            //                 TextButton(
            //                   onPressed: () async {
            //                     var dir = await getExternalStorageDirectory();
            //                     print(dir);
            //                     var msg = await X5Sdk.openFile(
            //                         "${dir?.path}/FileList.xlsx",
            //                         style: "1",
            //                         topBarBgColor: "#2196F3");
            //                     print(msg);
            //                   },
            //                   child: Text("打开"),
            //                 )
            //               ],
            //             );
            //           });
            //     },
            //     child: Text("x5sdk打开本地文件示例")),
            ElevatedButton(
                onPressed: () async {
//                                          Navigator.of(context).push(
//                            CupertinoPageRoute(builder: (BuildContext context) {
//                              return DemoWebViewPage("http://bin.amazeui.org/tizayo");
//                            }));

                  //网络url
                  // showInputDialog(
                  //     onConfirm: (url) {
                  //       Navigator.of(context).push(
                  //           CupertinoPageRoute(builder: (BuildContext context) {
                  //         return DemoWebViewPage(url);
                  //       }));
                  //     },
                  //     defaultText: "http://bin.amazeui.org/tizayo");

                  //本地html
                  var fileHtmlContents =
                      await rootBundle.loadString("assets/index.html");
                  var url = Uri.dataFromString(fileHtmlContents,
                          mimeType: 'text/html',
                          encoding: Encoding.getByName('utf-8'))
                      .toString();
                  Navigator.of(context)
                      .push(CupertinoPageRoute(builder: (BuildContext context) {
                    return DemoWebViewPage(url);
                  }));
                },
                child: Text("flutter内嵌x5webview")),
            ElevatedButton(
                onPressed: () async {
                  showInputDialog(
                      onConfirm: (url) {
                        openUrl(url);
                      },
                      defaultText:
                          "https://www.bilibili.com/video/BV1hD4y1X7Rm");
                },
                child: Text("x5webviewActivity")),
            ElevatedButton(
                onPressed: () async {
                  var fileHtmlContents =
                      await rootBundle.loadString("assets/index.html");
                  var url = Uri.dataFromString(fileHtmlContents,
                          mimeType: 'text/html',
                          encoding: Encoding.getByName('utf-8'))
                      .toString();

                  await X5Sdk.openWebActivity(url, title: "本地html示例");
                },
                child: Text("本地html")),
            ElevatedButton(
                onPressed: () async {
                  loadX5();
                },
                child: Text("重新加载内核")),
            Text(
                "内核状态：\n${crashInfo == null ? "未加载" : isLoadOk ? "加载成功---\n" + crashInfo.toString() : "加载失败---\n" + crashInfo.toString()}")
          ],
        ),
      ),
    );
  }

  void showInputDialog(
      {required ConfirmCallBack onConfirm, String defaultText = ""}) {
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
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("取消")),
              TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    onConfirm(_controller.text);
                  },
                  child: Text("跳转"))
            ],
          );
        });
  }

  var isLoad = false;

  void loadX5() async {
    if (isLoad) {
      showMsg("你已经加载过x5内核了,如果需要重新加载，请重启");
      return;
    }

    //请求动态权限，6.0安卓及以上必有
    Map<Permission, PermissionStatus> statuses = await [
      Permission.phone,
      Permission.storage,
    ].request();
    //判断权限
    if (!(statuses[Permission.phone]!.isGranted &&
        statuses[Permission.storage]!.isGranted)) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text("请同意所有权限后再尝试加载X5"),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("取消")),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      loadX5();
                    },
                    child: Text("再次加载")),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      openAppSettings();
                    },
                    child: Text("打开设置页面")),
              ],
            );
          });
      return;
    }

    //没有x5内核，是否在非wifi模式下载内核。默认false
    await X5Sdk.setDownloadWithoutWifi(true);

    //内核下载安装监听
    //int	DOWNLOAD_CANCEL_NOT_WIFI	111，非Wi-Fi，不发起下载 setDownloadWithoutWifi(boolean) 进行设置
    // int	DOWNLOAD_CANCEL_REQUESTING	133，下载请求中，不重复发起，取消下载
    // int	DOWNLOAD_FLOW_CANCEL	-134，带宽不允许，下载取消。Debug阶段可webview访问 debugtbs.qq.com 安装线上内核
    // int	DOWNLOAD_NO_NEED_REQUEST	-122，不发起下载请求，以下触发请求的条件均不符合：
    // 1、距离最后请求时间24小时后（可调整系统时间）
    // 2、请求成功超过时间间隔，网络原因重试小于11次
    // 3、App版本变更
    // int	DOWNLOAD_SUCCESS	100，内核下载成功
    // int	INSTALL_FOR_PREINIT_CALLBACK	243，预加载中间态，非异常，可忽略
    // int	INSTALL_SUCCESS	200，首次安装成功
    // int	NETWORK_UNAVAILABLE	101，网络不可用
    // int	STARTDOWNLOAD_OUT_OF_MAXTIME	127，发起下载次数超过1次（一次进程只允许发起一次下载）
    await X5Sdk.setX5SdkListener(X5SdkListener(onInstallFinish: (int code) {
      print("X5内核安装完成");
    }, onDownloadFinish: (int code) {
      print("X5内核下载完成");
    }, onDownloadProgress: (int progress) {
      print("X5内核下载中---$progress%");
    }));
    print("----开始加载内核----");
    var isOk = await X5Sdk.init();
    print(isOk ? "X5内核成功加载" : "X5内核加载失败");

    var x5CrashInfo = await X5Sdk.getCrashInfo();
    print(x5CrashInfo);
    if (isOk) {
      x5CrashInfo =
          "tbs_core_version" + x5CrashInfo.split("tbs_core_version")[1];
    }
    setState(() {
      isLoadOk = isOk;
      crashInfo = x5CrashInfo;
    });

    isLoad = true;
  }

  void showMsg(String msg) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(msg),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("我知道了"))
            ],
          );
        });
  }

  void openUrl(String url) {
    X5Sdk.openWebActivity(url, title: "web页面", callback: (url, headers) {
      print("拦截到url================$url");
      print("headers================$headers");
      //创建新的一个web页面,不创建callback传null
      openUrl(url);
    });
  }
}

typedef ConfirmCallBack = Function(String url);
