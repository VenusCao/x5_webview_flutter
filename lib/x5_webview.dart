import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

typedef void X5WebViewCreatedCallback(X5WebViewController controller);
typedef void PageFinishedCallback();
typedef void ShowCustomViewCallback();
typedef void HideCustomViewCallback();
typedef void ProgressChangedCallback(int progress);
class X5WebView extends StatefulWidget {
  final url;
  final X5WebViewCreatedCallback onWebViewCreated;
  final PageFinishedCallback onPageFinished;
  final ShowCustomViewCallback onShowCustomView;
  final HideCustomViewCallback onHideCustomView;
  final ProgressChangedCallback onProgressChanged;
  final bool javaScriptEnabled;
  const X5WebView({
    Key key,
    this.url,
    this.javaScriptEnabled=false,
    this.onWebViewCreated,
    this.onPageFinished,
    this.onShowCustomView,
    this.onHideCustomView,
    this.onProgressChanged,
  }) :super(key: key);



  @override
  _X5WebViewState createState() => _X5WebViewState();
}

class _X5WebViewState extends State<X5WebView> {
  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'com.cjx/x5WebView',
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParamsCodec: const StandardMessageCodec(),
        creationParams: _CreationParams.fromWidget(widget).toMap(),
        layoutDirection: TextDirection.rtl,
      );
    }else if(defaultTargetPlatform == TargetPlatform.iOS){
      //TODO 添加ios WebView
      return Container();
    }else{
      return Container();
    }

  }

  void _onPlatformViewCreated(int id) {
    if(widget.onWebViewCreated==null){
      return;
    }
    final X5WebViewController controller = X5WebViewController._(id,widget);
    widget.onWebViewCreated(controller);
  }

}



class X5WebViewController {
  X5WebView _widget;

  X5WebViewController._(int id,this._widget,)
      : _channel = MethodChannel('com.cjx/x5WebView_$id'){
    _channel.setMethodCallHandler(_onMethodCall);
  }

  final MethodChannel _channel;

  Future<void> loadUrl(String url,{Map<String, String> headers}) async {
    assert(url != null);
    return _channel.invokeMethod('loadUrl', {
      'url': url,
      'headers': headers,
    });
  }

  Future<String> evaluateJavascript(String js) async {
    assert(js != null);
    return _channel.invokeMethod('evaluateJavascript', {
      'js': js,
    });
  }
  Future<void> goBackOrForward(int i) async {
    assert(i != null);
    return _channel.invokeMethod('evaluateJavascript', {
      'i': i,
    });
  }

  Future<bool> canGoBack()async{
    return _channel.invokeMethod('canGoBack');
  }
  Future<bool> canGoForward()async{
    return _channel.invokeMethod('canGoForward');
  }
  Future<void> goBack()async{
    return _channel.invokeMethod('goBack');
  }
  Future<void> goForward()async{
    return _channel.invokeMethod('goForward');
  }
  Future<void> reload()async{
    return _channel.invokeMethod('reload');
  }
  Future<String> currentUrl()async{
    return _channel.invokeMethod('currentUrl');
  }

  Future _onMethodCall(MethodCall call) async{
    switch(call.method){
      case "onPageFinished":
        if(_widget.onPageFinished!=null){
          _widget.onPageFinished();
        }
        break;
      case "onShowCustomView":
        if(_widget.onShowCustomView!=null){
          _widget.onShowCustomView();
        }
        break;
      case "onHideCustomView":
        if(_widget.onHideCustomView!=null){
          _widget.onHideCustomView();
        }
        break;
      case "onProgressChanged":
        if (_widget.onProgressChanged != null) {
          Map arg = call.arguments;
          _widget.onProgressChanged(arg["progress"]);
        }
        break;
      default :
        throw MissingPluginException(
            '${call.method} was invoked but has no handler');
        break;
    }
  }
}


class _CreationParams {
  _CreationParams(
      {this.url, this.javaScriptEnabled});

  static _CreationParams fromWidget(X5WebView widget) {
    return _CreationParams(
      url: widget.url,
        javaScriptEnabled:widget.javaScriptEnabled
    );
  }

  final String url;
  final bool javaScriptEnabled;
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'url': url,
      'javaScriptEnabled': javaScriptEnabled,
    };
  }
}