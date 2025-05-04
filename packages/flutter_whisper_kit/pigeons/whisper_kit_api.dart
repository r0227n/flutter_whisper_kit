import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/platform_specifics/whisper_kit_message.g.dart',
    swiftOut:
        '../flutter_whisper_kit_apple/darwin/flutter_whisper_kit_apple/Sources/flutter_whisper_kit_apple/WhisperKitMessage.g.swift',
    dartPackageName: 'flutter_whisper_kit',
  ),
)
@HostApi()
abstract class WhisperKitMessage {
  @async
  String? loadModel(
    String? variant,
    String? modelRepo,
    bool redownload,
    String? modelDownloadPath,
    bool hasProgressCallback,
  );
  @async
  String? transcribeFromFile(String filePath, Map<String, Object?> options);
  @async
  String? startRecording(Map<String, Object?> options, bool loop);
  @async
  String? stopRecording(bool loop);
}
