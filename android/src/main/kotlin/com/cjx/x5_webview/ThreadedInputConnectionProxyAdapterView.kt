package com.cjx.x5_webview

import android.os.Handler
import android.os.IBinder
import android.view.View
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputConnection

class ThreadedInputConnectionProxyAdapterView(val containerView: View, private val targetView: View, private val imeHandler: Handler) : View(containerView.context) {
    var mWindowToken:IBinder?=null
    var mRootView:View?=null
    var triggerDelayed=true
    var isLocked=false
    var cachedConnection:InputConnection?=null
    init {
        mWindowToken=containerView.windowToken
        mRootView=containerView.rootView
        isFocusable=true
        isFocusableInTouchMode=true
        visibility= VISIBLE
    }

    override fun onCreateInputConnection(outAttrs: EditorInfo?): InputConnection? {
        triggerDelayed=false
        val inputConnection=if (isLocked) cachedConnection else targetView.onCreateInputConnection(outAttrs)
        triggerDelayed = true
        cachedConnection = inputConnection
        return inputConnection

    }

    override fun checkInputConnectionProxy(view: View?): Boolean {
        return true
    }

    override fun hasWindowFocus(): Boolean {
        return true
    }

    override fun getRootView(): View {
        return mRootView?:containerView.rootView
    }

    override fun onCheckIsTextEditor(): Boolean {
        return true
    }

    override fun isFocused(): Boolean {
        return true
    }

    override fun getWindowToken(): IBinder {
        return mWindowToken?:containerView.windowToken
    }

    override fun getHandler(): Handler {
        return imeHandler
    }

}