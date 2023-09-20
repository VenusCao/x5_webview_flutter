package com.cjx.x5_webview

import android.app.Activity
import android.content.Intent
import android.graphics.PixelFormat
import android.net.Uri
import android.os.Bundle
import android.util.Log
import android.view.MenuItem
import android.view.View
import android.view.Window
import android.view.WindowManager
import android.widget.FrameLayout
import com.tencent.smtt.export.external.interfaces.IX5WebChromeClient
import com.tencent.smtt.export.external.interfaces.WebResourceRequest
import com.tencent.smtt.sdk.ValueCallback
import com.tencent.smtt.sdk.WebChromeClient
import com.tencent.smtt.sdk.WebView
import com.tencent.smtt.sdk.WebViewClient
import io.flutter.plugin.common.MethodChannel
import kotlin.collections.HashMap

class X5WebViewActivity : Activity() {
    var chooserCallback: ValueCallback<Uri>? = null
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
            settings.javaScriptEnabled = true
            settings.domStorageEnabled = true
            settings.allowFileAccess=true
            settings.databaseEnabled=true

            loadUrl(intent.getStringExtra("url"), headers)
            val isUrlIntercept=intent.getBooleanExtra("isUrlIntercept",false)
            webViewClient = object : WebViewClient() {
                override fun shouldOverrideUrlLoading(view: WebView, url: String?): Boolean {
                    Log.e("X5WebViewActivity", "openurl:$url")
                    if(isUrlIntercept){
                        val map=HashMap<String,Any>()
                        map["url"] = url?:""
                        map["headers"] = HashMap<String,String>()
                        Log.e("X5WebViewActivity", "X5WebViewPlugin.methodChannel:${X5WebViewPlugin.methodChannel==null}")
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
                        Log.e("X5WebViewActivity", "X5WebViewPlugin.methodChannel:${X5WebViewPlugin.methodChannel==null}")
                        X5WebViewPlugin.methodChannel?.invokeMethod("onUrlLoad",map)
                        return isUrlIntercept
                    }
                    view.loadUrl(request?.url.toString())
                    return super.shouldOverrideUrlLoading(view, request)
                }



            }

            var fullView:View?=null
            webChromeClient = object : WebChromeClient() {

                override fun onShowCustomView(view: View?, call: IX5WebChromeClient.CustomViewCallback?) {
                    super.onShowCustomView(view, call)
                    // view 为内核生成的全屏视图，需要添加到相应的布局位置（如：全屏幕）
                    // customViewCallback 用于主动控制全屏退出
                    if(view!=null){
                        windowManager.addView(view, WindowManager.LayoutParams(
                            WindowManager.LayoutParams.TYPE_APPLICATION
                        ))

                        view.systemUiVisibility = (View.SYSTEM_UI_FLAG_LOW_PROFILE
                                or View.SYSTEM_UI_FLAG_FULLSCREEN
                                or View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                                or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                                or View.SYSTEM_UI_FLAG_HIDE_NAVIGATION)
                        fullView=view
                    }
                }

                override fun onHideCustomView() {
                    super.onHideCustomView()
                    //退出全屏
                    if(fullView!=null){
                        windowManager.removeView(fullView)
                        fullView=null
                    }
                }

                override fun openFileChooser(p0: ValueCallback<Uri>?, p1: String?, p2: String?) {
                    chooserCallback=p0
                    Log.e("--cjx","p1:$p1 --- p2:$p2")
                    startActivityForResult(Intent(Intent.ACTION_PICK).apply {
                        type=p1
                    }
                        ,21212)

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

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if(data!=null&&requestCode==21212&&chooserCallback!=null){
            chooserCallback?.onReceiveValue(data.data)
        }else{
            chooserCallback?.onReceiveValue(null)
        }
        chooserCallback=null

        super.onActivityResult(requestCode, resultCode, data)
    }
}