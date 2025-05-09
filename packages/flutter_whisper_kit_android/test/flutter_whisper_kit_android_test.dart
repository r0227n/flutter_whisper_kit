import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisper_kit_android/flutter_whisper_kit_android.dart';
import 'package:flutter_whisper_kit_android/flutter_whisper_kit_android_platform_interface.dart';
import 'package:flutter_whisper_kit_android/flutter_whisper_kit_android_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterWhisperKitAndroidPlatform
    with MockPlatformInterfaceMixin
    implements FlutterWhisperKitAndroidPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterWhisperKitAndroidPlatform initialPlatform = FlutterWhisperKitAndroidPlatform.instance;

  test('$MethodChannelFlutterWhisperKitAndroid is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterWhisperKitAndroid>());
  });

  test('getPlatformVersion', () async {
    FlutterWhisperKitAndroid flutterWhisperKitAndroidPlugin = FlutterWhisperKitAndroid();
    MockFlutterWhisperKitAndroidPlatform fakePlatform = MockFlutterWhisperKitAndroidPlatform();
    FlutterWhisperKitAndroidPlatform.instance = fakePlatform;

    expect(await flutterWhisperKitAndroidPlugin.getPlatformVersion(), '42');
  });
}
