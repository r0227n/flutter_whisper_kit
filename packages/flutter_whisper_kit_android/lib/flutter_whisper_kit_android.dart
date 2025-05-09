
import 'flutter_whisper_kit_android_platform_interface.dart';

class FlutterWhisperKitAndroid {
  Future<String?> getPlatformVersion() {
    return FlutterWhisperKitAndroidPlatform.instance.getPlatformVersion();
  }
}
