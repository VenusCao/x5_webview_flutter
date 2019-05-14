import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class X5Sdk {
  static const MethodChannel _channel =
      const MethodChannel('com.cjx/x5Video');

  static Future<bool> canUseTbsPlayer()async{
    if (defaultTargetPlatform == TargetPlatform.android) {
      bool res = await _channel.invokeMethod("canUseTbsPlayer");
      return res;
    }else{
      return false;
    }

  }
  static Future<bool> init()async{
    if (defaultTargetPlatform == TargetPlatform.android) {
      bool res = await _channel.invokeMethod("init");
      return res;
    }else{
      return false;
    }

  }

  static Future<void> openVideo(String url,{int screenMode})async{
    if (defaultTargetPlatform == TargetPlatform.android) {
      final Map<String, dynamic> params = <String, dynamic>{
        'screenMode': screenMode??103,
        'url':url
      };
      return await _channel.invokeMethod("openVideo",params);
    }else{
      return;
    }

  }

  static Future<void> openWebActivity(String url,{String title})async{
    if (defaultTargetPlatform == TargetPlatform.android) {
      final Map<String, dynamic> params = <String, dynamic>{
        'title': title,
        'url':url
      };
      return await _channel.invokeMethod("openWebActivity",params);
    }else{
      return;
    }

  }
}
