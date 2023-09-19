import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class X5Sdk {
  static const MethodChannel _channel = const MethodChannel('com.cjx/x5Video');

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
        'isDownloadWithoutWifi': isDownloadWithoutWifi,
      };

      await _channel.invokeMethod("setDownloadWithoutWifi", params);
      return true;
    } else {
      return false;
    }
  }

  ///打开简单的x5webview
  static Future<void> openWebActivity(String url,
      {String? title,
      Map<String, String>? headers,
      InterceptUrlCallBack? callback}) async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final Map<String, dynamic> params = <String, dynamic>{
        'title': title ?? "",
        'url': url,
        'headers': headers ?? {},
        'isUrlIntercept': callback != null
      };
      if (callback != null) {
        _channel.setMethodCallHandler((call) async {
          try {
            if (call.method == "onUrlLoad") {
              print("onUrlLoad----${call.arguments}");
              Map arg = call.arguments;
              callback(arg["url"], Map<String, String>.from(arg["headers"]));
            }
          } catch (e) {
            print(e);
          }
        });
      }

      return await _channel.invokeMethod("openWebActivity", params);
    } else {
      return;
    }
  }

  ///设置内核下载安装事件
  static Future<void> setX5SdkListener(X5SdkListener listener) async {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case "onInstallFinish":
          listener.onInstallFinish(call.arguments);
          break;
        case "onDownloadFinish":
          listener.onDownloadFinish(call.arguments);
          break;
        case "onDownloadProgress":
          listener.onDownloadProgress(call.arguments);
          break;
        default:
          throw MissingPluginException(
              '${call.method} was invoked but has no handler');
      }
    });
  }
}

typedef void InstallFinish(int code);
typedef void DownloadFinish(int code);
typedef void DownloadProgress(int progress);

typedef void InterceptUrlCallBack(String url, Map<String, String> headers);

///X5内核的下载和安装监听
///
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
class X5SdkListener {
  ///安装完成监听
  InstallFinish onInstallFinish;

  ///下载完成监听
  DownloadFinish onDownloadFinish;

  ///下载进度监听
  DownloadProgress onDownloadProgress;

  X5SdkListener(
      {required this.onInstallFinish,
      required this.onDownloadFinish,
      required this.onDownloadProgress});
}
