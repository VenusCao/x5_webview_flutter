package com.cjx.x5_webview

import android.content.Context
import android.content.Context.INPUT_METHOD_SERVICE
import android.util.Log
import android.view.View
import android.view.inputmethod.InputMethodManager
import com.tencent.smtt.sdk.WebView


class InputAwareWebView(context: Context?, private var containerView: View) : WebView(context) {
    var threadedInputConnectionProxyView: View? = null
    var proxyAdapterView: ThreadedInputConnectionProxyAdapterView? = null

    fun isLockInputConnection(locked: Boolean) {
        if (proxyAdapterView == null) {
            return
        }
        proxyAdapterView?.isLocked = locked
    }


    fun setContainerView(containerView: View?) {
        this.containerView = containerView!!

        if (proxyAdapterView == null) {
            return
        }

        Log.w("", "The containerView has changed while the proxyAdapterView exists.")
        if (containerView != null) {
            setInputConnectionTarget(proxyAdapterView!!)
        }
    }


    fun dispose() {
        resetInputConnection()
    }

    private fun resetInputConnection() {
        if (proxyAdapterView == null) {
            // No need to reset the InputConnection to the default thread if we've never changed it.
            return
        }
        if (containerView == null) {
            Log.e("InputAwareWebView", "Can't reset the input connection to the container view because there is none.")
            return
        }

        setInputConnectionTarget(containerView)
    }

    private fun setInputConnectionTarget(targetView: View) {
        if (containerView == null) {
            Log.e(
                    "InputAwareWebView",
                    "Can't set the input connection target because there is no containerView to use as a handler.")
            return
        }
        targetView.requestFocus()
        containerView.post {
            var imm: InputMethodManager = containerView.context.getSystemService(INPUT_METHOD_SERVICE) as InputMethodManager
            targetView.onWindowFocusChanged(true)
            imm.isActive(containerView)
        }
    }


    override fun checkInputConnectionProxy(view: View): Boolean {

        var previousProxy = threadedInputConnectionProxyView
        threadedInputConnectionProxyView = view

        if (previousProxy == view) {
            return super.checkInputConnectionProxy(view)
        }
        if (containerView == null) {
            Log.e(
                    "InputAwareWebView",
                    "Can't create a proxy view because there's no container view. Text input may not work.")
            return super.checkInputConnectionProxy(view)
        }
        proxyAdapterView = ThreadedInputConnectionProxyAdapterView(containerView, view, view.handler)
        setInputConnectionTarget(proxyAdapterView!!)
        return super.checkInputConnectionProxy(view)

    }

    override fun clearFocus() {
        super.clearFocus()
        resetInputConnection()
    }

}