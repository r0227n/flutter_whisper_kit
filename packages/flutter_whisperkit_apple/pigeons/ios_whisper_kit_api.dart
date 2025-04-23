import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/whisper_kit_message.g.dart',
    swiftOut:
        'ios/flutter_whisperkit_apple/Sources/flutter_whisperkit_apple/WhisperKitMessage.g.swift',
    dartPackageName: 'flutter_whisperkit_apple',
  ),
)

class DecodingOptionsMessage {
  String? task;
  String? language;
  double? temperature;
  int? sampleLen;
  int? bestOf;
  int? beamSize;
  double? patience;
  double? lengthPenalty;
  bool? suppressBlank;
  bool? suppressTokens;
  bool? withoutTimestamps;
  double? maxInitialTimestamp;
  bool? wordTimestamps;
  String? prependPunctuations;
  String? appendPunctuations;
  double? logProbThreshold;
  double? noSpeechThreshold;
  double? compressionRatioThreshold;
  String? conditionOnPreviousText;
  String? prompt;
  String? chunkingStrategy;

  DecodingOptionsMessage({
    this.task,
    this.language,
    this.temperature,
    this.sampleLen,
    this.bestOf,
    this.beamSize,
    this.patience,
    this.lengthPenalty,
    this.suppressBlank,
    this.suppressTokens,
    this.withoutTimestamps,
    this.maxInitialTimestamp,
    this.wordTimestamps,
    this.prependPunctuations,
    this.appendPunctuations,
    this.logProbThreshold,
    this.noSpeechThreshold,
    this.compressionRatioThreshold,
    this.conditionOnPreviousText,
    this.prompt,
    this.chunkingStrategy,
  });
}

@HostApi()
abstract class WhisperKitMessage {
  @async
  String? getPlatformVersion();
  @async
  String? createWhisperKit(String? model, String? modelRepo);
  @async
  String? loadModel(
    String? variant,
    String? modelRepo,
    bool? redownload,
    int? storageLocation,
  );
  @async
  String? transcribeFromFile(String filePath, DecodingOptionsMessage? options);
}
