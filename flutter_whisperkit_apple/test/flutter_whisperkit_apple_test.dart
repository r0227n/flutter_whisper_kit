import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisperkit/flutter_whisperkit_platform_interface.dart';
import 'package:flutter_whisperkit_apple/flutter_whisperkit_apple.dart';
import 'package:flutter_whisperkit_apple/flutter_whisperkit_apple_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterWhisperkitPlatform
    with MockPlatformInterfaceMixin
    implements FlutterWhisperkitPlatform {
  // No methods to override since the platform interface is empty
}

void main() {
  // Register the implementation before running tests
  setUpAll(() {
    FlutterWhisperkitApple.registerWith();
  });

  test('$MethodChannelFlutterWhisperkitApple is the default instance', () {
    final platform = FlutterWhisperkitPlatform.instance;
    expect(platform, isInstanceOf<MethodChannelFlutterWhisperkitApple>());
  });
}
