# x5_webview   [![pub package](https://img.shields.io/pub/v/x5_webview.svg)](https://pub.flutter-io.cn/packages/x5_webview)

一个基于腾讯x5引擎的webview的flutter插件，暂时只支持android使用
提示：之前内嵌webview出现的一系列问题得到解决，请更新到最新版试用，谢谢支持。

## x5内核介绍

[x5内核](https://x5.tencent.com/tbs/product/tbs.html)，腾讯为改善移动端web体验的一种内核架构。加载更快，更省流量，视频播放优化，文件助手等等

## 快速集成
[![pub package](https://img.shields.io/pub/v/x5_webview.svg)](https://pub.flutter-io.cn/packages/x5_webview)

[pub地址](https://pub.flutter-io.cn/packages/x5_webview)

pubspec.yaml文件添加
```
dependencies:
  x5_webview: ^x.x.x //最新版本见上方
```

初始化x5。(安卓6.0+需在init之前请求动态权限，可以使用[permission_handler](https://pub.flutter-io.cn/packages/permission_handler)，详情见example/lib/main.dart)
```
//请求权限
Map<Permission, PermissionStatus> statuses = await [
      Permission.phone,
      Permission.storage,
    ].request();
//判断权限
if (!(statuses[Permission.phone].isGranted &&
statuses[Permission.storage].isGranted)) {
    print("权限被拒绝");
    return;
}

var isOk = await X5Sdk.init();
print(isOk ? "X5内核成功加载" : "X5内核加载失败");
```

如果你只是想要简单的展示web页面，可使用以下代码直接打开一个webActivity，
性能更佳(推荐使用，视频播放也可以这个api)
```
X5Sdk.openWebActivity("https://www.baidu.com",title: "web页面");
```

使用TBSPlayer直接全屏播放视频(screenMode自行测试，103横屏 104竖屏，官方默认使用102第一次点击全屏无反应)
```
    var isOk = await X5Sdk.openVideo(
    "https://ifeng.com-l-ifeng.com/20180528/7391_46b6cf3b/index.m3u8",screenMode: 102);
```

打开本地文件
接入TBS可支持打开文件格式：doc、docx、ppt、pptx、xls、xlsx、pdf、txt、epub
调用QQ浏览器可打开：rar（包含加密格式）、zip（包含加密格式）、tar、bz2、gz、7z（包含加密格式）、
doc、docx、ppt、pptx、xls、xlsx、txt、pdf、epub、chm、html/htm、xml、mht、url、ini、log、
bat、php、js、lrc、jpg、jpeg、png、gif、bmp、tiff 、webp、mp3、m4a、aac、amr、wav、ogg、mid、
ra、wma、mpga、ape、flac
```
var errorMsg = await X5Sdk.openFile("/sdcard/download/FileList.xlsx");
print(errorMsg);
```

## 使用内嵌webview

```
return Scaffold(
      appBar: AppBar(
        title: Text("X5WebView示例"),
      ),
      body: defaultTargetPlatform == TargetPlatform.android
          ? X5WebView(
              url: "http://debugtbs.qq.com",
              javaScriptEnabled: true,
              header: {"TestHeader": "测试"},
              userAgentString: "my_ua",
              //Url拦截，传null不会拦截会自动跳转
              onUrlLoading: (willLoadUrl) {
                _controller.loadUrl(willLoadUrl);
              }
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
##内嵌webview js与flutter互调
## flutter调用js
```
var body = await _controller.evaluateJavascript("document.body.innerHTML");
```
## js调用flutter
* flutter代码
```
     X5WebView(
        ...
        javascriptChannels: JavascriptChannels(
            ["X5Web", "Toast"], (name, data) {
          switch (name) {
            ...
          }
        }))
```
* js代码
```
X5Web.postMessage("XXX")
Toast.postMessage("YYY")
```

## 打开本地html文件(使用assets文件，内嵌webview同理)
```
var fileS = await rootBundle.loadString("assets/index.html");
var url = Uri.dataFromString(fileS,
                          mimeType: 'text/html',
                          encoding: Encoding.getByName('utf-8'))
                      .toString();
X5Sdk.openWebActivity(url, title: "本地html示例");
```

## 注意事项
* 该插件暂时只支持Android手机，IOS会使用无效。ios可使用[webview_flutter](https://pub.flutter-io.cn/packages/webview_flutter)或其他已实现IOS WXWebView插件
* 一般手机安装了QQ，微信，QQ浏览器等软件，手机里自动会有X5内核，如果没有X5内核会在wifi下自动下载，X5内核没有加载成功会自动使用系统内核[官网说明](https://x5.tencent.com/tbs/technical.html#/list/sdk/916172a5-f14e-40ed-9915-eaf74e9acba8/%E5%8A%A0%E8%BD%BD%E7%B1%BB)。详细配置可用手机打开以下链接查看X5内核的详情
    ```
    http://debugtbs.qq.com
    ```
* 请使用真机测试，模拟器可能不能正常显示

* 如果测试正常，打包后不能加载，可以尝试使用android studio打开android目录直接打包apk。或者使用以下命令行打包
```
flutter build apk --target-platform android-arm --no-shrink
```

* android9.0版本webview联不了网在manifest添加
    ```
    <application
        ...
        android:usesCleartextTraffic="true">
    </application>
    ```
* android7.0版本打开文件需要在manifest的application内添加(xml文件已在插件内，无需自己创建)
    ```
          <!--        不使用androidx 请用android:name="android.support.v4.content.FileProvider"-->    
        <provider
            android:name="androidx.core.content.FileProvider"
            android:authorities="${applicationId}"
            android:exported="false"
            android:grantUriPermissions="true">
            <meta-data
                android:name="android.support.FILE_PROVIDER_PATHS"
                android:resource="@xml/x5webview_file_paths" />
        </provider>  
    ```

* X5Sdk.openWebActivity actionbar颜色自定义
  ```
  //1.
  implementation "androidx.appcompat:appcompat:1.1.0"

  //2.
    <style name="AppTheme" parent="ThemeOverlay.AppCompat.Dark">
        <!-- Customize your theme here. -->
        <item name="colorPrimary">#2196F3</item>
        <item name="colorPrimaryDark">#1976D2</item>
        <item name="colorAccent">#FF4081</item>
        <item name="windowNoTitle">false</item>
        <item name="windowActionBar">true</item>
    </style>

  //3.
  <application
        ...
        android:theme="@style/AppTheme">

  ```

* 有比较急的问题可以加我QQ：793710663

## 示例程序下载(密码：123456)

[apk下载](https://www.pgyer.com/x5_webview)

![二维码](https://www.pgyer.com/app/qrcode/x5_webview)