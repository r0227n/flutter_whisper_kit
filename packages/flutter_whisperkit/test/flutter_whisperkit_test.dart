import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisperkit/flutter_whisperkit.dart';
import 'package:flutter_whisperkit/flutter_whisperkit_platform_interface.dart';
import 'package:flutter_whisperkit/flutter_whisperkit_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterWhisperkitPlatform
    with MockPlatformInterfaceMixin
    implements FlutterWhisperkitPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterWhisperkitPlatform initialPlatform = FlutterWhisperkitPlatform.instance;

  test('$MethodChannelFlutterWhisperkit is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterWhisperkit>());
  });

  test('getPlatformVersion', () async {
    FlutterWhisperkit flutterWhisperkitPlugin = FlutterWhisperkit();
    MockFlutterWhisperkitPlatform fakePlatform = MockFlutterWhisperkitPlatform();
    FlutterWhisperkitPlatform.instance = fakePlatform;

    expect(await flutterWhisperkitPlugin.getPlatformVersion(), '42');
  });
}
