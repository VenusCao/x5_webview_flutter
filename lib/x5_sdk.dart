import 'dart:async';

import 'package:flutter/services.dart';

class X5Sdk {
  static const MethodChannel _channel =
      const MethodChannel('com.cjx/x5Video');

  static Future<bool> canUseTbsPlayer()async{
    bool res = await _channel.invokeMethod("canUseTbsPlayer");
    return res;
  }
  static Future<bool> init()async{
    bool res = await _channel.invokeMethod("init");
    return res;
  }

  static Future<void> openVideo(String url,int screenMode)async{
    final Map<String, dynamic> params = <String, dynamic>{
      'screenMode': screenMode,
      'url':url
    };
    return await _channel.invokeMethod("openVideo",params);
  }

  static Future<void> openWebActivity(String url,{String title})async{
    final Map<String, dynamic> params = <String, dynamic>{
      'title': title,
      'url':url
    };
    return await _channel.invokeMethod("openWebActivity",params);
  }
}
