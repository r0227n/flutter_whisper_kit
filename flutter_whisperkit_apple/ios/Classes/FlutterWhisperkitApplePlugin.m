#import "FlutterWhisperkitApplePlugin.h"
#if __has_include(<flutter_whisperkit_apple/flutter_whisperkit_apple-Swift.h>)
#import <flutter_whisperkit_apple/flutter_whisperkit_apple-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_whisperkit_apple-Swift.h"
#endif

@implementation FlutterWhisperkitApplePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterWhisperkitApplePlugin registerWithRegistrar:registrar];
}
@end 