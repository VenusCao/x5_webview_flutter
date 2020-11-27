import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

typedef void X5WebViewCreatedCallback(X5WebViewController controller);
typedef void PageFinishedCallback();
typedef void ShowCustomViewCallback();
typedef void HideCustomViewCallback();
typedef void ProgressChangedCallback(int progress);
typedef void MessageReceived(String name, String data);
typedef void UrlLoading(String url);

class X5WebView extends StatefulWidget {
  final url;
  final X5WebViewCreatedCallback onWebViewCreated;
  final PageFinishedCallback onPageFinished;
  final ShowCustomViewCallback onShowCustomView;
  final HideCustomViewCallback onHideCustomView;
  final ProgressChangedCallback onProgressChanged;
  final bool javaScriptEnabled;
  final JavascriptChannels javascriptChannels;
  final UrlLoading onUrlLoading;
  final Map<String, String> header;
  final String userAgentString;

  const X5WebView(
      {Key key,
      this.url,
      this.javaScriptEnabled = false,
      this.onWebViewCreated,
      this.onPageFinished,
      this.onShowCustomView,
      this.onHideCustomView,
      this.javascriptChannels,
      this.onProgressChanged,
      this.onUrlLoading,
      this.header,
      this.userAgentString})
      : super(key: key);

  @override
  _X5WebViewState createState() => _X5WebViewState();
}

class _X5WebViewState extends State<X5WebView> {
  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      //   return AndroidView(
      //     viewType: 'com.cjx/x5WebView',
      //     onPlatformViewCreated: _onPlatformViewCreated,
      //     creationParamsCodec: const StandardMessageCodec(),
      //     creationParams: _CreationParams.fromWidget(widget).toMap(),
      //     layoutDirection: TextDirection.rtl,
      //   );
      // } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      //   // 添加ios WebView
      //   return Container();
      // } else {
      //   return Container();
      return PlatformViewLink(
        viewType: "com.cjx/x5WebView",
        surfaceFactory: (_, controller) {
          return AndroidViewSurface(
            controller: controller,
            gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
            hitTestBehavior: PlatformViewHitTestBehavior.opaque,
          );
        },
        onCreatePlatformView: (params) {
          return PlatformViewsService.initSurfaceAndroidView(
            id: params.id,
            viewType: 'com.cjx/x5WebView',
            // WebView content is not affected by the Android view's layout direction,
            // we explicitly set it here so that the widget doesn't require an ambient
            // directionality.
            layoutDirection: TextDirection.rtl,
            creationParams: _CreationParams.fromWidget(widget).toMap(),
            creationParamsCodec: const StandardMessageCodec(),
          )
            ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
            ..addOnPlatformViewCreatedListener((int id) {
              _onPlatformViewCreated(id);
              // if (onWebViewPlatformCreated == null) {
              //   return;
              // }
              // onWebViewPlatformCreated(
              //   MethodChannelWebViewPlatform(id, webViewPlatformCallbacksHandler),
              // );
            })
            ..create();
        },
      );
    } else {
      return Container();
    }
  }

  void _onPlatformViewCreated(int id) {
    if (widget.onWebViewCreated == null) {
      return;
    }
    final X5WebViewController controller = X5WebViewController._(id, widget);
    widget.onWebViewCreated(controller);
  }
}

class X5WebViewController {
  X5WebView _widget;

  X5WebViewController._(
    int id,
    this._widget,
  ) : _channel = MethodChannel('com.cjx/x5WebView_$id') {
    _channel.setMethodCallHandler(_onMethodCall);
  }

  final MethodChannel _channel;

  Future<void> loadUrl(String url, {Map<String, String> headers}) async {
    assert(url != null);
    return _channel.invokeMethod('loadUrl', {
      'url': url,
      'headers': headers,
    });
  }

  Future<bool> isX5WebViewLoadSuccess() async {
    return _channel.invokeMethod('isX5WebViewLoadSuccess');
  }

  Future<String> evaluateJavascript(String js) async {
    assert(js != null);
    return _channel.invokeMethod('evaluateJavascript', {
      'js': js,
    });
  }

  ///  直接使用X5WebView(javascriptChannels:JavascriptChannels(names, (name, data) { }))
  @deprecated
  Future<void> addJavascriptChannels(
      List<String> names, MessageReceived callback) async {
    assert(names != null);
    await _channel.invokeMethod("addJavascriptChannels", {'names': names});
    _channel.setMethodCallHandler((call) {
      if (call.method == "onJavascriptChannelCallBack") {
        Map arg = call.arguments;
        callback(arg["name"], arg["msg"]);
      }
      return;
    });
  }

  Future<void> goBackOrForward(int i) async {
    assert(i != null);
    return _channel.invokeMethod('goBackOrForward', {
      'i': i,
    });
  }

  Future<bool> canGoBack() async {
    return _channel.invokeMethod('canGoBack');
  }

  Future<bool> canGoForward() async {
    return _channel.invokeMethod('canGoForward');
  }

  Future<void> goBack() async {
    return _channel.invokeMethod('goBack');
  }

  Future<void> goForward() async {
    return _channel.invokeMethod('goForward');
  }

  Future<void> reload() async {
    return _channel.invokeMethod('reload');
  }

  Future<String> currentUrl() async {
    return _channel.invokeMethod('currentUrl');
  }

  Future _onMethodCall(MethodCall call) async {
    switch (call.method) {
      case "onPageFinished":
        if (_widget.onPageFinished != null) {
          _widget.onPageFinished();
        }
        break;
      case "onJavascriptChannelCallBack":
        if (_widget.javascriptChannels.callback != null) {
          Map arg = call.arguments;
          _widget.javascriptChannels.callback(arg["name"], arg["msg"]);
        }
        break;
      case "onShowCustomView":
        if (_widget.onShowCustomView != null) {
          _widget.onShowCustomView();
        }
        break;
      case "onHideCustomView":
        if (_widget.onHideCustomView != null) {
          _widget.onHideCustomView();
        }
        break;
      case "onProgressChanged":
        if (_widget.onProgressChanged != null) {
          Map arg = call.arguments;
          _widget.onProgressChanged(arg["progress"]);
        }
        break;
      case "onUrlLoading":
        if (_widget.onUrlLoading != null) {
          Map arg = call.arguments;
          _widget.onUrlLoading(arg["url"]);
        }
        break;

      default:
        throw MissingPluginException(
            '${call.method} was invoked but has no handler');
        break;
    }
  }
}

class _CreationParams {
  _CreationParams(
      {this.url,
      this.javaScriptEnabled,
      this.javascriptChannels,
      this.urlInterceptEnabled,
      this.header,
      this.userAgentString});

  static _CreationParams fromWidget(X5WebView widget) {
    return _CreationParams(
        url: widget.url,
        javaScriptEnabled: widget.javaScriptEnabled,
        javascriptChannels: widget.javascriptChannels.names,
        urlInterceptEnabled: widget.onUrlLoading != null,
        userAgentString: widget.userAgentString,
        header: widget.header);
  }

  final String url;
  final bool javaScriptEnabled;
  final List<String> javascriptChannels;
  final Map<String, String> header;
  final bool urlInterceptEnabled;
  final String userAgentString;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'url': url,
      'javaScriptEnabled': javaScriptEnabled,
      "javascriptChannels": javascriptChannels,
      "urlInterceptEnabled": urlInterceptEnabled,
      "header": header,
      "userAgentString": userAgentString
    };
  }
}

class JavascriptChannels {
  List<String> names;
  MessageReceived callback;

  JavascriptChannels(this.names, this.callback);
}
