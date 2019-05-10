package com.cjx.x5_webview

import android.content.Context
import android.os.Bundle
import com.tencent.smtt.sdk.QbSdk
import com.tencent.smtt.sdk.TbsVideo
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

class X5WebViewPlugin(var context: Context): MethodCallHandler {
  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "com.cjx/x5Video")
      channel.setMethodCallHandler(X5WebViewPlugin(registrar.context()))

      registrar.platformViewRegistry().registerViewFactory("com.cjx/x5WebView",X5WebViewFactory(registrar.messenger(),registrar.activeContext()))

    }
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when(call.method){
      "init"->{
        QbSdk.initX5Environment(context.applicationContext, object : QbSdk.PreInitCallback {
          override fun onCoreInitFinished() {

          }

          override fun onViewInitFinished(p0: Boolean) {
            //x5內核初始化完成的回调，为true表示x5内核加载成功，否则表示x5内核加载失败，会自动切换到系统内核。
            result.success(p0)
          }

        })
      }
      "canUseTbsPlayer"->{
        //返回是否可以使用tbsPlayer
       result.success(TbsVideo.canUseTbsPlayer(context))
      }
      "openVideo"->{
        val url=call.argument<String>("url")
        val screenMode=call.argument<Int>("screenMode")?:103
        val bundle=Bundle()
        bundle.putInt("screenMode",screenMode)
        TbsVideo.openVideo(context,url,bundle)
      }
      else->{
        result.notImplemented()
      }
    }

//    if (call.method == "getPlatformVersion") {
//      result.success("Android ${android.os.Build.VERSION.RELEASE}")
//    } else {
//      result.notImplemented()
//    }
  }
}
