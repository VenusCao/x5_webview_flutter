import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class X5Sdk {
  static const MethodChannel _channel = const MethodChannel('com.cjx/x5Video');

  ///是否能直接使用x5内核播放视频
  static Future<bool> canUseTbsPlayer() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      bool res = await _channel.invokeMethod("canUseTbsPlayer");
      return res;
    } else {
      return false;
    }
  }

  ///加载内核，没有内核会自动下载,加载失败会自动调用系统内核。
  ///不要重复请求。如需要重新加载可重启应用
  ///android 6.0+调用之前需动态请求权限（电话和存储权限）
  static Future<bool> init() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      bool res = await _channel.invokeMethod("init");
      return res;
    } else {
      return false;
    }
  }

  ///获取x5的日志
  static Future<String> getCrashInfo() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      var res = await _channel.invokeMethod("getCarshInfo");
      return res;
    } else {
      return "";
    }
  }

  ///设置是否在非wifi环境下载内核，默认false
  static Future<bool> setDownloadWithoutWifi(bool isDownloadWithoutWifi) async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final Map<String, dynamic> params = <String, dynamic>{
        'isDownloadWithoutWifi': isDownloadWithoutWifi ?? false,
      };

      bool res = await _channel.invokeMethod("setDownloadWithoutWifi", params);
      return res;
    } else {
      return false;
    }
  }

  ///screenMode 播放参数，103横屏全屏，104竖屏全屏。默认102
  static Future<void> openVideo(String url, {int screenMode}) async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final Map<String, dynamic> params = <String, dynamic>{
        'screenMode': screenMode ?? 102,
        'url': url
      };
      return await _channel.invokeMethod("openVideo", params);
    } else {
      return;
    }
  }

  // ignore: slash_for_doc_comments
  /**
      打开本地文件，暂不支持在线文件，可下载后再打开

      filePath:文件路径。格式为 android 本地存储路径格式，例如:/sdcard/Download/xxx.doc. 不支持 file:///格式。暂不支持在线文件。


      extraParams:miniqb 的扩展功能。为非必填项，可传入 null 使用默认设置。
      其格式是一个 key 对应一个 value。在文件查看器的产品形态中，当前支持 的 key 包括:


      local: “true”表示是进入文件查看器，如果不设置或设置为“false”，则进入 miniqb 浏览器模式。不是必
      须设置项。


      style: “0”表示文件查看器使用默认的 UI 样式。“1”表示文件查看器使用微信的 UI 样式。不设置此 key
      或设置错误值，则为默认 UI 样式。


      topBarBgColor: 定制文件查看器的顶部栏背景色。格式为“#xxxxxx”，例“#2CFC47”;不设置此 key 或设置
      错误值，则为默认 UI 样式。


      menuData: 该参数用来定制文件右上角弹出菜单，可传入菜单项的 icon 的文本，用户点击菜单项后，sdk
      会通过 startActivity+intent 的方式回调。menuData 是 jsonObject 类型，结构格式如下:
      public static final String jsondata =
      "{
      pkgName:\"com.example.thirdfile\", "
      + "className:\"com.example.thirdfile.IntentActivity\","
      + "thirdCtx: {pp:123},"
      + "menuItems:"
      + "["
      + "{id:0,iconResId:"+ R.drawable.ic_launcher +",text:\"menu0\"},
      {id:1,iconResId:" + R.drawable.bookmark_edit_icon + ",text:\"menu1\"}, {id:2,iconResId:"+ R.drawable.bookmark_folder_icon +",text:\"菜单2\"}" + "]"
      +"
      }";
      pkgName 和 className 是回调时的包名和类名。

      thirdCtx 是三方参数，需要是 jsonObject 类型，sdk 不会处理该参数，只是在菜单点击事件发生的时候原样 回传给调用方。

      menuItems 是 json 数组，表示菜单中的每一项。
   */
  static Future<String> openFile(String filePath,
      {String local,
      String style,
      String topBarBgColor,
      String menuData}) async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final Map<String, String> params = <String, String>{
        'filePath': filePath,
        'local': local,
        'style': style,
        'topBarBgColor': topBarBgColor,
        'menuData': menuData
      };
      return await _channel.invokeMethod("openFile", params);
    } else {
      return "$defaultTargetPlatform暂不支持";
    }
  }

  ///打开简单的x5webview
  static Future<void> openWebActivity(String url,
      {String title,
      Map<String, String> headers,
      InterceptUrlCallBack callback}) async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final Map<String, dynamic> params = <String, dynamic>{
        'title': title,
        'url': url,
        'headers': headers,
        'isUrlIntercept': callback != null
      };
      if (callback != null) {
        _channel.setMethodCallHandler((call) {
          try {
            if (call.method == "onUrlLoad") {
              print("onUrlLoad----${call.arguments}");
              Map arg = call.arguments;
              callback(arg["url"], Map<String, String>.from(arg["headers"]));
            }
          } catch (e) {
            print(e);
          }
          return;
        });
      }

      return await _channel.invokeMethod("openWebActivity", params);
    } else {
      return;
    }
  }

  ///设置内核下载安装事件
  static Future<void> setX5SdkListener(X5SdkListener listener) async {
    _channel.setMethodCallHandler((call) {
      switch (call.method) {
        case "onInstallFinish":
          listener.onInstallFinish();
          break;
        case "onDownloadFinish":
          listener.onDownloadFinish();
          break;
        case "onDownloadProgress":
          listener.onDownloadProgress(call.arguments);
          break;
        default:
          throw MissingPluginException(
              '${call.method} was invoked but has no handler');
          break;
      }
      return;
    });
  }
}

typedef void InstallFinish();
typedef void DownloadFinish();
typedef void DownloadProgress(int progress);

typedef void InterceptUrlCallBack(String url, Map<String, String> headers);

///X5内核的下载和安装监听
class X5SdkListener {
  ///安装完成监听
  InstallFinish onInstallFinish;

  ///下载完成监听
  DownloadFinish onDownloadFinish;

  ///下载进度监听
  DownloadProgress onDownloadProgress;

  X5SdkListener(
      {@required this.onInstallFinish,
      @required this.onDownloadFinish,
      @required this.onDownloadProgress});
}
