import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/whisper_kit_message.g.dart',
    swiftOut:
        '../flutter_whisperkit_apple/ios/flutter_whisperkit_apple/Sources/flutter_whisperkit_apple/WhisperKitMessage.g.swift',
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
    int? storageLocation,
  );
  @async
  String? transcribeFromFile(String filePath, Map<String?, Object?>? options);
}
