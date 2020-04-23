package com.cjx.x5_webview

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.widget.Toast
import com.tencent.smtt.export.external.TbsCoreSettings
import com.tencent.smtt.sdk.QbSdk
import com.tencent.smtt.sdk.TbsListener
import com.tencent.smtt.sdk.TbsVideo
import com.tencent.smtt.sdk.WebView
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.io.File

class X5WebViewPlugin : MethodCallHandler, FlutterPlugin, ActivityAware {
    constructor(mContext: Context,mActivity: Activity){
        this.mActivity=mActivity
        this.mContext=mContext
    }
    constructor()

    var mContext: Context? = null
    var mActivity: Activity? = null
    var mFlutterPluginBinding: FlutterPlugin.FlutterPluginBinding? = null

    //兼容旧方式集成插件
    companion object {
        var methodChannel: MethodChannel? = null
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "com.cjx/x5Video")
            channel.setMethodCallHandler(X5WebViewPlugin(registrar.context(),registrar.activity()))
            setCallBack(channel, registrar.activity())
            registrar.platformViewRegistry().registerViewFactory("com.cjx/x5WebView", X5WebViewFactory(registrar.messenger(), registrar.activity(), registrar.view()))
        }

        private fun setCallBack(channel: MethodChannel, activity: Activity) {
            QbSdk.setTbsListener(object : TbsListener {
                override fun onInstallFinish(p0: Int) {
                    activity.runOnUiThread {
                        channel.invokeMethod("onInstallFinish", null)
                    }
                }

                override fun onDownloadFinish(p0: Int) {
                    activity.runOnUiThread {
                        channel.invokeMethod("onDownloadFinish", null)
                    }
                }

                override fun onDownloadProgress(p0: Int) {
                    activity.runOnUiThread {
                        channel.invokeMethod("onDownloadProgress", p0)
                    }
                }
            })
        }
    }


    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "init" -> {
                val map = hashMapOf<String, Any>()
                map[TbsCoreSettings.TBS_SETTINGS_USE_SPEEDY_CLASSLOADER] = true
                map[TbsCoreSettings.TBS_SETTINGS_USE_DEXLOADER_SERVICE] = true
                QbSdk.initTbsSettings(map)
                QbSdk.initX5Environment(mContext?.applicationContext, object : QbSdk.PreInitCallback {
                    override fun onCoreInitFinished() {
                        Log.e("X5Sdk","onCoreInitFinished")
                    }

                    override fun onViewInitFinished(p0: Boolean) {
                        //x5內核初始化完成的回调，为true表示x5内核加载成功，否则表示x5内核加载失败，会自动切换到系统内核。
                        result.success(p0)
                    }

                })
            }
            "canUseTbsPlayer" -> {
                //返回是否可以使用tbsPlayer
                result.success(TbsVideo.canUseTbsPlayer(mContext))
            }
            "openVideo" -> {
                val url = call.argument<String>("url")
                val screenMode = call.argument<Int>("screenMode") ?: 103
                val bundle = Bundle()
                bundle.putInt("screenMode", screenMode)
                TbsVideo.openVideo(mContext, url, bundle)
                result.success(null)
            }
            "openFile" -> {
                //context:调起 miniqb 的 Activity 的 context。此参数只能是 activity 类型的 context，不能设置为 Application
                //的 context。
                //filePath:文件路径。格式为 android 本地存储路径格式，例如:/sdcard/Download/xxx.doc. 不支持 file:///
                //格式。暂不支持在线文件。
                //extraParams:miniqb 的扩展功能。为非必填项，可传入 null 使用默认设置。
                //其格式是一个 key 对应一个 value。在文件查看器的产品形态中，当前支持 的 key 包括:
                //local: “true”表示是进入文件查看器，如果不设置或设置为“false”，则进入 miniqb 浏览器模式。不是必
                //须设置项。
                //style: “0”表示文件查看器使用默认的 UI 样式。“1”表示文件查看器使用微信的 UI 样式。不设置此 key
                //或设置错误值，则为默认 UI 样式。
                //topBarBgColor: 定制文件查看器的顶部栏背景色。格式为“#xxxxxx”，例“#2CFC47”;不设置此 key 或设置
                //错误值，则为默认 UI 样式。
                //menuData: 该参数用来定制文件右上角弹出菜单，可传入菜单项的 icon 的文本，用户点击菜单项后，sdk
                //会通过 startActivity+intent 的方式回调。menuData 是 jsonObject 类型，结构格式如下: public static final String jsondata =
                //"{
                //pkgName:\"com.example.thirdfile\", "
                //+ "className:\"com.example.thirdfile.IntentActivity\","
                //+ "thirdCtx: {pp:123},"
                //+ "menuItems:"
                //+ "["
                //+ "{id:0,iconResId:"+ R.drawable.ic_launcher +",text:\"menu0\"},
                //{id:1,iconResId:" + R.drawable.bookmark_edit_icon + ",text:\"menu1\"}, {id:2,iconResId:"+ R.drawable.bookmark_folder_icon +",text:\"菜单2\"}" + "]"
                //+"
                //}";
                //pkgName 和 className 是回调时的包名和类名。
                //thirdCtx 是三方参数，需要是 jsonObject 类型，sdk 不会处理该参数，只是在菜单点击事件发生的时候原样 回传给调用方。
                //menuItems 是 json 数组，表示菜单中的每一项。
                //ValueCallback:提供 miniqb 打开/关闭时给调用方回调通知,以便应用层做相应处理。 在单独进程打开文件的场景中，回调参数出现如下字符时，表示可以关闭当前进程，避免内存占用。 openFileReader open in QB
                //filepath error
                //TbsReaderDialogClosed
                //default browser:
                //filepath error
                //fileReaderClosed


                val filePath = call.argument<String>("filePath")
                val params = hashMapOf<String, String>()
                params["local"] = call.argument<String>("local") ?: "false"
                params["style"] = call.argument<String>("style") ?: "0"
                params["topBarBgColor"] = call.argument<String>("topBarBgColor") ?: "#2CFC47"
                var menuData = call.argument<String>("menuData")
                if (menuData != null) {
                    params["menuData"] = menuData
                }
                if (!File(filePath).exists()) {
                    Toast.makeText(mContext, "文件不存在,请确认$filePath 是否正确", Toast.LENGTH_LONG).show()
                    result.success("文件不存在,请确认$filePath 是否正确")
                    return
                }
                QbSdk.canOpenFile(mActivity, filePath) { canOpenFile ->
                    if (canOpenFile) {
                        QbSdk.openFileReader(mActivity, filePath, params) { msg ->
                            Log.d("QbSdk", msg)
                        }
                    } else {
                        Toast.makeText(mContext, "X5Sdk无法打开此文件", Toast.LENGTH_LONG).show()
                        result.success("X5Sdk无法打开此文件")
                    }
                }
            }

            "openWebActivity" -> {
                val url = call.argument<String>("url")
                val title = call.argument<String>("title")
                val headers = call.argument<HashMap<String,String>>("headers")?:HashMap()
                val isUrlIntercept=call.argument<Boolean>("isUrlIntercept")
                val intent = Intent(mActivity, X5WebViewActivity::class.java)
                intent.putExtra("url", url)
                intent.putExtra("title", title)
                intent.putExtra("headers", headers)
                intent.putExtra("isUrlIntercept", isUrlIntercept)
                mActivity?.startActivity(intent)
                result.success(null)
            }
            "getCarshInfo" -> {
                val info = WebView.getCrashExtraMessage(mContext)
                result.success(info)
            }
            "setDownloadWithoutWifi" -> {
                val isWithoutWifi = call.argument<Boolean>("isWithoutWifi")
                QbSdk.setDownloadWithoutWifi(isWithoutWifi ?: false)
                result.success(null)
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    //新方式集成插件
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.e("onAttachedToEngine", "onAttachedToEngine")
        if (mActivity == null) {
            Log.e("onAttachedToEngine", "mActivity==null")
            mFlutterPluginBinding = binding
            return
        }
        mFlutterPluginBinding = binding
        mContext = binding.applicationContext

        methodChannel = MethodChannel(binding.binaryMessenger, "com.cjx/x5Video")
        methodChannel?.setMethodCallHandler(X5WebViewPlugin(mContext!!,mActivity!!))
        setCallBack(methodChannel!!, mActivity!!)
        binding.platformViewRegistry.registerViewFactory("com.cjx/x5WebView", X5WebViewFactory(binding.binaryMessenger, mActivity!!, null))
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.e("onDetachedFromEngine", "onDetachedFromEngine")
        QbSdk.setTbsListener(null)
        mFlutterPluginBinding = null
        methodChannel?.setMethodCallHandler(null)
        methodChannel = null
    }

    override fun onDetachedFromActivity() {
        Log.e("onDetachedFromActivity", "onDetachedFromActivity")
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        Log.e("onAttachedToActivity", "onAttachedToActivity")
        if (mFlutterPluginBinding == null) {
            Log.e("onAttachedToActivity", "mFlutterPluginBinding==null")
            this.mActivity = binding.activity
            return
        }
        this.mActivity = binding.activity
        this.mContext = binding.activity.applicationContext
        methodChannel = MethodChannel(mFlutterPluginBinding?.binaryMessenger, "com.cjx/x5Video")
        methodChannel?.setMethodCallHandler(X5WebViewPlugin(mContext!!,mActivity!!))
        setCallBack(methodChannel!!, mActivity!!)
        mFlutterPluginBinding?.platformViewRegistry?.registerViewFactory("com.cjx/x5WebView", X5WebViewFactory(mFlutterPluginBinding?.binaryMessenger!!, mActivity!!, null))

    }

    override fun onDetachedFromActivityForConfigChanges() {
    }
}
