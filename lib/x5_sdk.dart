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

  ///加载内核，没有内核会自动下载,加载失败会自动调用系统内核
  static Future<bool> init() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      bool res = await _channel.invokeMethod("init");
      return res;
    } else {
      return false;
    }
  }

  ///设置是否在非wifi环境下载内核，默认false
  static Future<bool> setDownloadWithoutWifi(bool isDownloadWithoutWifi) async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final Map<String, dynamic> params = <String, dynamic>{
        'isDownloadWithoutWifi': isDownloadWithoutWifi,
      };

      bool res = await _channel.invokeMethod("setDownloadWithoutWifi", params);
      return res;
    } else {
      return false;
    }
  }

  ///screenMode 播放参数，103横屏全屏，104竖屏全屏。默认103
  static Future<void> openVideo(String url, {int screenMode}) async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final Map<String, dynamic> params = <String, dynamic>{
        'screenMode': screenMode ?? 103,
        'url': url
      };
      return await _channel.invokeMethod("openVideo", params);
    } else {
      return;
    }
  }

  ///打开简单的x5webview
  static Future<void> openWebActivity(String url, {String title}) async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final Map<String, dynamic> params = <String, dynamic>{
        'title': title,
        'url': url
      };
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

class X5SdkListener {
  InstallFinish onInstallFinish;
  DownloadFinish onDownloadFinish;
  DownloadProgress onDownloadProgress;

  X5SdkListener(this.onInstallFinish, this.onDownloadFinish,
      this.onDownloadProgress);
}
