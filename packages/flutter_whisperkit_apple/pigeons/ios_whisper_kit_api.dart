import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/whisper_kit_message.g.dart',
    swiftOut:
        'ios/flutter_whisperkit_apple/Sources/flutter_whisperkit_apple/WhisperKitMessage.g.swift',
    dartPackageName: 'flutter_whisperkit_apple',
  ),
)
enum DecodingTask { transcribe, translate }

enum ChunkingStrategy { none, vad }

class DecodingOptionsMessage {
  const DecodingOptionsMessage(
    this.verbose,
    this.task,
    this.language,
    this.temperature,
    this.temperatureIncrementOnFallback,
    this.temperatureFallbackCount,
    this.sampleLength,
    this.topK,
    this.usePrefillPrompt,
    this.usePrefillCache,
    this.detectLanguage,
    this.skipSpecialTokens,
    this.withoutTimestamps,
    this.wordTimestamps,
    this.maxInitialTimestamp,
    this.clipTimestamps,
    this.promptTokens,
    this.prefixTokens,
    this.suppressBlank,
    this.supressTokens,
    this.compressionRatioThreshold,
    this.logProbThreshold,
    this.firstTokenLogProbThreshold,
    this.noSpeechThreshold,
    this.concurrentWorkerCount,
    this.chunkingStrategy,
  );

  final bool verbose;
  final DecodingTask task;
  final String? language;
  final double temperature;
  final double temperatureIncrementOnFallback;
  final int temperatureFallbackCount;
  final int sampleLength;
  final int topK;
  final bool usePrefillPrompt;
  final bool usePrefillCache;
  final bool detectLanguage;
  final bool skipSpecialTokens;
  final bool withoutTimestamps;
  final bool wordTimestamps;
  final double? maxInitialTimestamp;
  final List<double>? clipTimestamps;
  final List<int>? promptTokens;
  final List<int>? prefixTokens;
  final bool suppressBlank;
  final List<int> supressTokens;
  final double? compressionRatioThreshold;
  final double? logProbThreshold;
  final double? firstTokenLogProbThreshold;
  final double? noSpeechThreshold;
  final int concurrentWorkerCount;
  final ChunkingStrategy? chunkingStrategy;

  Map<String, dynamic> toJson() {
    return {
      'verbose': verbose,
      'task': task,
      'language': language,
      'temperature': temperature,
      'temperatureIncrementOnFallback': temperatureIncrementOnFallback,
      'temperatureFallbackCount': temperatureFallbackCount,
      'sampleLength': sampleLength,
      'topK': topK,
      'usePrefillPrompt': usePrefillPrompt,
      'usePrefillCache': usePrefillCache,
      'detectLanguage': detectLanguage,
      'skipSpecialTokens': skipSpecialTokens,
      'withoutTimestamps': withoutTimestamps,
      'wordTimestamps': wordTimestamps,
      'maxInitialTimestamp': maxInitialTimestamp,
      'clipTimestamps': clipTimestamps,
      'promptTokens': promptTokens,
      'prefixTokens': prefixTokens,
      'suppressBlank': suppressBlank,
      'supressTokens': supressTokens,
      'compressionRatioThreshold': compressionRatioThreshold,
      'logProbThreshold': logProbThreshold,
      'firstTokenLogProbThreshold': firstTokenLogProbThreshold,
      'noSpeechThreshold': noSpeechThreshold,
      'concurrentWorkerCount': concurrentWorkerCount,
      'chunkingStrategy': chunkingStrategy,
    };
  }
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
  String? transcribeFromFile(String filePath, Map<String?, Object?>? options);
}
