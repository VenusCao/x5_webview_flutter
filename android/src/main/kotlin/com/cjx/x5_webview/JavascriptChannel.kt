package com.cjx.x5_webview

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.webkit.JavascriptInterface
import io.flutter.plugin.common.MethodChannel

class JavascriptChannel(private val name: String, private val channel: MethodChannel, private val context: Context?) {

    @JavascriptInterface
    fun postMessage(msg: String) {
        val postRunnable = Runnable {
            val arg = hashMapOf<String, Any>()
            arg["name"] = name
            arg["msg"] = msg
            channel.invokeMethod("onJavascriptChannelCallBack", arg)
        }
        val handler = Handler(context?.mainLooper!!)

        if (handler.looper == Looper.myLooper()) {
            postRunnable.run()
        } else {
            handler.post(postRunnable)
        }
    }
}