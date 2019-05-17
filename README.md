# x5_webview   [![pub package](https://img.shields.io/pub/v/x5_webview.svg)](https://pub.flutter-io.cn/packages/x5_webview)

一个基于腾讯x5引擎的webview的flutter插件，暂时只支持android使用

## x5内核介绍

[x5内核](https://x5.tencent.com/tbs/product/tbs.html)，腾讯为改善移动端web体验的一种内核架构。加载更快，更省流量，视频播放优化，文件助手等等

## 快速集成
[![pub package](https://img.shields.io/pub/v/x5_webview.svg)](https://pub.flutter-io.cn/packages/x5_webview)

pubspec.yaml文件添加
```
dependencies:
  x5_webview: ^0.0.1 //最新版本见上方
```


在启动时，初始化x5
```
void main() {
  X5Sdk.init().then((isOK) {
    print(isOK ? "X5内核成功加载" : "X5内核加载失败");
  });
  runApp(MyApp());
}
```
使用内嵌webview

```
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
```

使用TBSPlayer直接播放视频
```
 var canUseTbsPlayer = await X5Sdk.canUseTbsPlayer();
 if (canUseTbsPlayer) {
    var isOk = await X5Sdk.openVideo(
    "https://ifeng.com-l-ifeng.com/20180528/7391_46b6cf3b/index.m3u8");
 } else {
     print("x5Video不可用");
 }
```

如果你只是想要简单的展示web页面，可使用以下代码直接打开一个webActivity，
性能更佳
```
X5Sdk.openWebActivity("https://www.baidu.com",title: "web页面");
```


## 注意事项
* 该插件暂时只支持Android手机，IOS会使用无效。ios可使用[webview_flutter](https://pub.flutter-io.cn/packages/webview_flutter)或其他已实现IOS WXWebView插件
* 一般手机安装了QQ，微信，QQ浏览器等软件，手机里自动会有X5内核，如果没有X5内核会在wifi下自动下载，X5内核没有加载成功会自动使用系统内核[官网说明](https://x5.tencent.com/tbs/technical.html#/list/sdk/916172a5-f14e-40ed-9915-eaf74e9acba8/%E5%8A%A0%E8%BD%BD%E7%B1%BB)。详细配置可用手机打开以下链接查看X5内核的详情
    ```
    http://debugtbs.qq.com
    ```

* 请使用真机测试，模拟器可能不能正常显示

* 如果运行闪退的话，请添加运行配置
    ```
    --target-platform android-arm
    ```
## 示例程序下载

[apk下载](https://www.pgyer.com/x5_webview)

![二维码](https://www.pgyer.com/app/qrcode/x5_webview)