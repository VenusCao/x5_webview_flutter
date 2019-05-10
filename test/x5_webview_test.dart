import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:x5_webview/x5_sdk.dart';

void main() {
  const MethodChannel channel = MethodChannel('x5_webview');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

}
