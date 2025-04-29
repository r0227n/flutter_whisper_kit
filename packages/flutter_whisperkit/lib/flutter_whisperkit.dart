
import 'flutter_whisperkit_platform_interface.dart';

class FlutterWhisperkit {
  Future<String?> getPlatformVersion() {
    return FlutterWhisperkitPlatform.instance.getPlatformVersion();
  }
}
