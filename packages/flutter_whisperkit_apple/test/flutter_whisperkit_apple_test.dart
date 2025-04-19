import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisperkit_apple/flutter_whisperkit_apple.dart';
import 'package:flutter_whisperkit_apple/flutter_whisperkit_apple_platform_interface.dart';
import 'package:flutter_whisperkit_apple/flutter_whisperkit_apple_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterWhisperkitApplePlatform
    with MockPlatformInterfaceMixin
    implements FlutterWhisperkitApplePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterWhisperkitApplePlatform initialPlatform = FlutterWhisperkitApplePlatform.instance;

  test('$MethodChannelFlutterWhisperkitApple is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterWhisperkitApple>());
  });

  test('getPlatformVersion', () async {
    FlutterWhisperkitApple flutterWhisperkitApplePlugin = FlutterWhisperkitApple();
    MockFlutterWhisperkitApplePlatform fakePlatform = MockFlutterWhisperkitApplePlatform();
    FlutterWhisperkitApplePlatform.instance = fakePlatform;

    expect(await flutterWhisperkitApplePlugin.getPlatformVersion(), '42');
  });
}
