package com.cjx.x5_webview

import android.app.Activity
import android.os.Bundle
import android.widget.LinearLayout
import com.tencent.smtt.export.external.interfaces.WebResourceRequest
import com.tencent.smtt.sdk.WebView
import com.tencent.smtt.sdk.WebViewClient

class X5WebViewActivity:Activity() {
    var webView:WebView?=null
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        webView=WebView(this)
        setContentView(webView)

        initView()
    }

    private fun initView() {
        webView?.apply {
            layoutParams=LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT,LinearLayout.LayoutParams.MATCH_PARENT)
            loadUrl(intent.getStringExtra("url"))
            settings.javaScriptEnabled=true
            webViewClient= object : WebViewClient() {
                override fun shouldOverrideUrlLoading(view: WebView, url: String?): Boolean {
                    view.loadUrl(url)
                    return super.shouldOverrideUrlLoading(view, url)
                }

                override fun shouldOverrideUrlLoading(view: WebView, request: WebResourceRequest?): Boolean {
                    view.loadUrl(request?.url.toString())
                    return super.shouldOverrideUrlLoading(view, request)
                }
            }
        }
    }
}