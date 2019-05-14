# x5_webview

基于腾讯x5引擎的webview，暂时只支持android使用

## x5内核介绍

[x5内核](https://x5.tencent.com/tbs/product/tbs.html)，腾讯为改善移动端web体验的一种内核架构。

## 快速集成

在启动时，初始化x5
```
void main() async {
  var isOK=await X5Sdk.init();
  print(isOK?"X5内核成功加载":"X5内核加载失败");
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
* 该插件暂时只支持Android手机，IOS会使用无效。ios可使用[webview_flutter](https://pub.flutter-io.cn/packages/webview_flutter)
* 一般手机安装了QQ，微信，QQ浏览器等软件，手机里自动会有X5内核。详细配置可用手机打开以下链接查看X5内核的详情
    ```
    http://debugtbs.qq.com
    ```

* 请使用真机测试，模拟器可能不能正常显示

* 如果运行闪退的话，请添加运行配置
    ```
    --target-platform android-arm
    ```
