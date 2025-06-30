/// Represents the task to perform (transcribe or translate).
enum DecodingTask { transcribe, translate }

/// Represents the chunking strategy.
enum ChunkingStrategy { none, vad }

/// Represents options for the transcription process.
class DecodingOptions {
  const DecodingOptions({
    this.verbose = false,
    this.task = DecodingTask.transcribe,
    this.language,
    this.temperature = 0.0,
    this.temperatureIncrementOnFallback = 0.2,
    this.temperatureFallbackCount = 5,
    this.sampleLength = 224,
    this.topK = 5,
    this.usePrefillPrompt = false,
    this.usePrefillCache = false,
    this.detectLanguage = false,
    this.skipSpecialTokens = false,
    this.withoutTimestamps = false,
    this.wordTimestamps = false,
    this.maxInitialTimestamp = 1.0,
    this.clipTimestamps = const [],
    this.promptTokens = const [],
    this.prefixTokens = const [],
    this.suppressBlank = false,
    this.supressTokens = const [],
    this.compressionRatioThreshold,
    this.logProbThreshold = -1.0,
    this.firstTokenLogProbThreshold = -1.5,
    this.noSpeechThreshold = 0.6,
    this.concurrentWorkerCount = 4,
    this.chunkingStrategy = ChunkingStrategy.vad,
  });

  /// Creates a [DecodingOptions] from a JSON map.
  factory DecodingOptions.fromJson(Map<String, dynamic> json) {
    return DecodingOptions(
      verbose: json['verbose'] as bool? ?? false,
      task: json['task'] == 'translate'
          ? DecodingTask.translate
          : DecodingTask.transcribe,
      language: json['language'] as String?,
      temperature: json['temperature'] != null
          ? (json['temperature'] as num).toDouble()
          : 0.0,
      temperatureIncrementOnFallback:
          json['temperatureIncrementOnFallback'] != null
              ? (json['temperatureIncrementOnFallback'] as num).toDouble()
              : 0.2,
      temperatureFallbackCount: json['temperatureFallbackCount'] as int? ?? 5,
      sampleLength: json['sampleLength'] as int? ?? 224,
      topK: json['topK'] as int? ?? 5,
      usePrefillPrompt: json['usePrefillPrompt'] as bool? ?? false,
      usePrefillCache: json['usePrefillCache'] as bool? ?? false,
      detectLanguage: json['detectLanguage'] as bool? ?? false,
      skipSpecialTokens: json['skipSpecialTokens'] as bool? ?? false,
      withoutTimestamps: json['withoutTimestamps'] as bool? ?? false,
      wordTimestamps: json['wordTimestamps'] as bool? ?? false,
      maxInitialTimestamp: json['maxInitialTimestamp'] != null
          ? (json['maxInitialTimestamp'] as num).toDouble()
          : 1.0,
      clipTimestamps:
          (json['clipTimestamps'] as List<dynamic>?)?.cast<double>() ?? [],
      promptTokens: (json['promptTokens'] as List<dynamic>?)?.cast<int>() ?? [],
      prefixTokens: (json['prefixTokens'] as List<dynamic>?)?.cast<int>() ?? [],
      suppressBlank: json['suppressBlank'] as bool? ?? false,
      supressTokens:
          (json['supressTokens'] as List<dynamic>?)?.cast<int>() ?? [],
      compressionRatioThreshold: json['compressionRatioThreshold'] != null
          ? (json['compressionRatioThreshold'] as num).toDouble()
          : null,
      logProbThreshold: json['logProbThreshold'] != null
          ? (json['logProbThreshold'] as num).toDouble()
          : null,
      firstTokenLogProbThreshold: json['firstTokenLogProbThreshold'] != null
          ? (json['firstTokenLogProbThreshold'] as num).toDouble()
          : null,
      noSpeechThreshold: json['noSpeechThreshold'] != null
          ? (json['noSpeechThreshold'] as num).toDouble()
          : null,
      concurrentWorkerCount: json['concurrentWorkerCount'] as int? ?? 4,
      chunkingStrategy: json['chunkingStrategy'] == 'vad'
          ? ChunkingStrategy.vad
          : ChunkingStrategy.none,
    );
  }

  /// Whether to print verbose output.
  final bool verbose;

  /// The task to perform (transcribe or translate).
  final DecodingTask task;

  /// The language to use for transcription.
  final String? language;

  /// The temperature to use for sampling.
  final double temperature;

  /// The temperature increment on fallback.
  final double temperatureIncrementOnFallback;

  /// The number of temperature fallback count.
  final int temperatureFallbackCount;

  /// The number of samples to consider for each token.
  final int sampleLength;

  /// The top k samples to consider.
  final int topK;

  /// Whether to use prefill prompt.
  final bool usePrefillPrompt;

  /// Whether to use prefill cache.
  final bool usePrefillCache;

  /// Whether to detect language.
  final bool detectLanguage;

  /// Whether to skip special tokens.
  final bool skipSpecialTokens;

  /// Whether to add initial prompt.
  final bool withoutTimestamps;

  /// The word timestamps flag.
  final bool wordTimestamps;

  /// The maximum initial timestamp.
  final double maxInitialTimestamp;

  /// The clip timestamps.
  final List<double> clipTimestamps;

  /// The prompt tokens.
  final List<int> promptTokens;

  /// The prefix tokens.
  final List<int> prefixTokens;

  /// Whether to suppress blank tokens.
  final bool suppressBlank;

  /// The suppress tokens.
  final List<int> supressTokens;

  /// The compression ratio threshold.
  final double? compressionRatioThreshold;

  /// The log probability threshold.
  final double? logProbThreshold;

  /// The first token log probability threshold.
  final double? firstTokenLogProbThreshold;

  /// The no speech threshold.
  final double? noSpeechThreshold;

  /// The concurrent worker count.
  final int concurrentWorkerCount;

  /// The chunking strategy.
  final ChunkingStrategy? chunkingStrategy;

  /// Converts this [DecodingOptions] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'verbose': verbose,
      'task': task == DecodingTask.translate ? 'translate' : 'transcribe',
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
      'chunkingStrategy':
          chunkingStrategy == ChunkingStrategy.vad ? 'vad' : 'none',
    };
  }
}
