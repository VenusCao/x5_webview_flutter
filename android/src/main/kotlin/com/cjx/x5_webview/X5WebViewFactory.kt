package com.cjx.x5_webview

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class X5WebViewFactory(private val msg: BinaryMessenger,private val activity: Context) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, id: Int, args: Any?): PlatformView {
        return X5WebView(activity,id, args as Map<String, Any>,msg)
    }

}