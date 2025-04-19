
import 'flutter_whisperkit_apple_platform_interface.dart';

class FlutterWhisperkitApple {
  Future<String?> getPlatformVersion() {
    return FlutterWhisperkitApplePlatform.instance.getPlatformVersion();
  }
}
