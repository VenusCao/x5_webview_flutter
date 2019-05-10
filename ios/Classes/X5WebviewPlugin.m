#import "X5WebviewPlugin.h"
#import <x5_webview/x5_webview-Swift.h>

@implementation X5WebviewPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftX5WebviewPlugin registerWithRegistrar:registrar];
}
@end
