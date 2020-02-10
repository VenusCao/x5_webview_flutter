package com.cjx.x5_webview

import android.annotation.SuppressLint
import android.hardware.display.DisplayManager
import android.hardware.display.DisplayManager.DisplayListener
import android.os.Build
import android.util.Log
import java.lang.reflect.Field


class DisplayListenerProxy {
    lateinit var listenersBeforeWebView: ArrayList<DisplayListener>


    fun onPreWebViewInitialization(displayManager: DisplayManager) {
        listenersBeforeWebView = yoinkDisplayListeners(displayManager)
    }

    @SuppressLint("NewApi")
    fun onPostWebViewInitialization(displayManager: DisplayManager) {
        val webViewListeners = yoinkDisplayListeners(displayManager)
        // We recorded the list of listeners prior to initializing webview, any new listeners we see
        // after initializing the webview are listeners added by the webview.
        webViewListeners.removeAll(listenersBeforeWebView)

        if (webViewListeners.isEmpty()) {
            // The Android WebView registers a single display listener per process (even if there
            // are multiple WebView instances) so this list is expected to be non-empty only the
            // first time a webview is initialized.
            // Note that in an add2app scenario if the application had instantiated a non Flutter
            // WebView prior to instantiating the Flutter WebView we are not able to get a reference
            // to the WebView's display listener and can't work around the bug.
            //
            // This means that webview resizes in add2app Flutter apps with a non Flutter WebView
            // running on a system with a webview prior to 58.0.3029.125 may crash (the Android's
            // behavior seems to be racy so it doesn't always happen).
            return
        }

        for (webViewListener in webViewListeners) {
            // Note that while DisplayManager.unregisterDisplayListener throws when given an
            // unregistered listener, this isn't an issue as the WebView code never calls
            // unregisterDisplayListener.
            displayManager.unregisterDisplayListener(webViewListener)

            // We never explicitly unregister this listener as the webview's listener is never
            // unregistered (it's released when the process is terminated).
            displayManager.registerDisplayListener(
                    object : DisplayListener {
                        override fun onDisplayAdded(displayId: Int) {
                            for (webViewListener in webViewListeners) {
                                webViewListener.onDisplayAdded(displayId)
                            }
                        }

                        override fun onDisplayRemoved(displayId: Int) {
                            for (webViewListener in webViewListeners) {
                                webViewListener.onDisplayRemoved(displayId)
                            }
                        }

                        override fun onDisplayChanged(displayId: Int) {
                            if (displayManager.getDisplay(displayId) == null) {
                                return
                            }
                            for (webViewListener in webViewListeners) {
                                webViewListener.onDisplayChanged(displayId)
                            }
                        }
                    }, null)
        }
    }


    companion object {
        @SuppressLint("NewApi")
        private fun yoinkDisplayListeners(displayManager: DisplayManager): ArrayList<DisplayListener> {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                // We cannot use reflection on Android P, but it shouldn't matter as it shipped
                // with WebView 66.0.3359.158 and the WebView version the bug this code is working around was
                // fixed in 61.0.3116.0.
                return ArrayList()
            }
            try {
                val displayManagerGlobalField = DisplayManager::class.java.getDeclaredField("mGlobal")
                displayManagerGlobalField.isAccessible = true
                val displayManagerGlobal = displayManagerGlobalField.get(displayManager)
                val displayListenersField = displayManagerGlobal.javaClass.getDeclaredField("mDisplayListeners")
                displayListenersField.isAccessible = true
                val delegates = displayListenersField.get(displayManagerGlobal) as ArrayList<Any>

                var listenerField: Field? = null
                val listeners = ArrayList<DisplayListener>()
                for (delegate in delegates) {
                    if (listenerField == null) {
                        listenerField = delegate.javaClass.getField("mListener")
                        listenerField.isAccessible = true
                    }
                    val listener = listenerField?.get(delegate) as DisplayListener
                    listeners.add(listener)
                }
                return listeners
            } catch (e: NoSuchFieldException) {
                Log.w("", "Could not extract WebView's display listeners. $e")
                return ArrayList()
            } catch (e: IllegalAccessException) {
                Log.w("", "Could not extract WebView's display listeners. $e")
                return ArrayList()
            }

        }
    }

}