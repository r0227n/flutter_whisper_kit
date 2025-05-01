import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/whisper_kit_message.g.dart',
    swiftOut:
        '../flutter_whisperkit_apple/darwin/flutter_whisperkit_apple/Sources/flutter_whisperkit_apple/WhisperKitMessage.g.swift',
    dartPackageName: 'flutter_whisperkit',
  ),
)
@HostApi()
abstract class WhisperKitMessage {
  @async
  String? loadModel(
    String? variant,
    String? modelRepo,
    bool? redownload,
    String? modelPath,
    bool? prewarmMode,
  );
  @async
  String? transcribeFromFile(String filePath, Map<String, Object?> options);
  @async
  String? startRecording(Map<String, Object?> options, bool loop);
  @async
  String? stopRecording(bool loop);
}
