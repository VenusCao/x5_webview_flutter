package com.cjx.x5_webview

import android.content.Context
import android.view.View
import com.tencent.smtt.export.external.interfaces.IX5WebChromeClient
import com.tencent.smtt.export.external.interfaces.WebResourceRequest
import com.tencent.smtt.sdk.WebChromeClient
import com.tencent.smtt.sdk.WebView
import com.tencent.smtt.sdk.WebViewClient
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

class X5WebView(private val context: Context, val id: Int, val params: Map<String, Any>, val messenger: BinaryMessenger? = null) : PlatformView, MethodChannel.MethodCallHandler {
    private val webView: WebView
    private val channel: MethodChannel = MethodChannel(messenger, "com.cjx/x5WebView_$id")

    init {
        channel.setMethodCallHandler(this)
        webView = WebView(context)
        webView.apply {
            settings.javaScriptEnabled = params["javaScriptEnabled"] as Boolean
            loadUrl(params["url"].toString())
            webViewClient= object : WebViewClient() {
                override fun shouldOverrideUrlLoading(view: WebView, url: String?): Boolean {
                    view.loadUrl(url)
                    return super.shouldOverrideUrlLoading(view, url)
                }

                override fun shouldOverrideUrlLoading(view: WebView, requset: WebResourceRequest?): Boolean {
                    view.loadUrl(requset?.url.toString())
                    return super.shouldOverrideUrlLoading(view, requset)
                }

                override fun onPageFinished(p0: WebView?, url: String) {
                    super.onPageFinished(p0, url)
                    //向flutter通信
                    val arg=hashMapOf<String,Any>()
                    arg["url"]=url
                    channel.invokeMethod("onPageFinished",arg)
                }

            }
            webChromeClient= object : WebChromeClient() {
                override fun onShowCustomView(view: View?, call: IX5WebChromeClient.CustomViewCallback?) {
                    super.onShowCustomView(view, call)
                    channel.invokeMethod("onShowCustomView",null)
                }

                override fun onHideCustomView() {
                    super.onHideCustomView()
                    channel.invokeMethod("onHideCustomView",null)
                }

                override fun onProgressChanged(p0: WebView?, p1: Int) {
                    super.onProgressChanged(p0, p1)
                    //加载进度
                    val arg=hashMapOf<String,Any>()
                    arg["progress"]=p1
                    channel.invokeMethod("onProgressChanged",arg)
                }
            }

//            val data= Bundle()
            //true表示标准全屏，false表示X5全屏；不设置默认false，
//            data.putBoolean("standardFullScreen",true)
            //false：关闭小窗；true：开启小窗；不设置默认true，
//            data.putBoolean("supportLiteWnd",false)
            //1：以页面内开始播放，2：以全屏开始播放；不设置默认：1
//            data.putInt("DefaultVideoScreen",2)
//            x5WebViewExtension.invokeMiscMethod("setVideoParams",data)
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "loadUrl" -> {
                val arg = call.arguments as Map<String, Any>
                val url = arg["url"].toString()
                val headers = arg["headers"] as? Map<String, String>
                webView.loadUrl(url,headers)
                result.success(null)
            }
            "canGoBack" -> {
                result.success(webView.canGoBack())
            }
            "canGoForward" -> {
                result.success(webView.canGoForward())
            }
            "goBack" -> {
                webView.goBack()
                result.success(null)
            }
            "goForward" -> {
                webView.goForward()
                result.success(null)
            }
            "goBackOrForward" -> {
                val arg = call.arguments as Map<String, Any>
                val point=arg["i"] as Int
                webView.goBackOrForward(point)
                result.success(null)
            }
            "reload" -> {
                webView.reload()
                result.success(null)
            }
            "currentUrl" -> {
                result.success(webView.url)
            }
            "evaluateJavascript" -> {
                val arg = call.arguments as Map<String, Any>
                val js=arg["js"].toString()
                webView.evaluateJavascript(js) { value -> result.success(value) }
            }
            else->{
                result.notImplemented()
            }
        }
    }

    override fun getView(): View {
        return webView
    }

    override fun dispose() {
        channel.setMethodCallHandler(null)
        webView.destroy()
    }
}