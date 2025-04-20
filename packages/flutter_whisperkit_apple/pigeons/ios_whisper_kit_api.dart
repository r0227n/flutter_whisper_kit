import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/whisper_kit_message.g.dart',
    swiftOut:
        'ios/flutter_whisperkit_apple/Sources/flutter_whisperkit_apple/WhisperKitMessage.g.swift',
    dartPackageName: 'flutter_whisperkit_apple',
  ),
)
@HostApi()
abstract class WhisperKitMessage {
  @async
  String? getPlatformVersion();
  @async
  String? createWhisperKit(String? model, String? modelRepo);
}
