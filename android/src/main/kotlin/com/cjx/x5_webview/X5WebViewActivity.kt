package com.cjx.x5_webview

import android.app.Activity
import android.graphics.PixelFormat
import android.os.Bundle
import android.util.Log
import android.view.MenuItem
import android.view.Window
import android.widget.FrameLayout
import com.tencent.smtt.export.external.interfaces.WebResourceRequest
import com.tencent.smtt.sdk.WebView
import com.tencent.smtt.sdk.WebViewClient
import io.flutter.plugin.common.MethodChannel
import kotlin.collections.HashMap

class X5WebViewActivity : Activity() {

    var webView: WebView? = null
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        requestWindowFeature(Window.FEATURE_ACTION_BAR)
        window.setFormat(PixelFormat.TRANSLUCENT)
        webView = WebView(this)
        setContentView(webView)

        initView()
    }

    private fun initView() {
        actionBar?.show()
        actionBar?.setDisplayHomeAsUpEnabled(true)
        title = intent.getStringExtra("title") ?: ""
        webView?.apply {
            layoutParams = FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT)
            val headers = intent.getSerializableExtra("headers") as HashMap<String,String>
            loadUrl(intent.getStringExtra("url"), headers)
            settings.javaScriptEnabled = true

            val isUrlIntercept=intent.getBooleanExtra("isUrlIntercept",false)
            webViewClient = object : WebViewClient() {
                override fun shouldOverrideUrlLoading(view: WebView, url: String?): Boolean {
                    Log.e("X5WebViewActivity", "openurl:$url")
                    if(isUrlIntercept){
                        val map=HashMap<String,Any>()
                        map["url"] = url?:""
                        map["headers"] = HashMap<String,String>()
                        X5WebViewPlugin.methodChannel?.invokeMethod("onUrlLoad",map)
                        return isUrlIntercept
                    }
                    view.loadUrl(url)

                    return super.shouldOverrideUrlLoading(view, url)
                }

                override fun shouldOverrideUrlLoading(view: WebView, request: WebResourceRequest?): Boolean {
                    Log.e("X5WebViewActivity", "openurl2:" + request?.url.toString())
                    if(isUrlIntercept){
                        val map=HashMap<String,Any>()
                        map["url"] = request?.url.toString()
                        map["headers"] = request?.requestHeaders?:HashMap<String,String>()
                        X5WebViewPlugin.methodChannel?.invokeMethod("onUrlLoad",map)
                        return isUrlIntercept
                    }
                    view.loadUrl(request?.url.toString())
                    return super.shouldOverrideUrlLoading(view, request)
                }
            }
        }
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        when (item.itemId) {
            android.R.id.home -> {
                finish()
            }
        }

        return super.onOptionsItemSelected(item)
    }


    override fun onDestroy() {
        super.onDestroy()
        webView?.destroy()
    }

    override fun onPause() {
        super.onPause()
        webView?.onPause()
    }

    override fun onResume() {
        super.onResume()
        webView?.onResume()
    }

}