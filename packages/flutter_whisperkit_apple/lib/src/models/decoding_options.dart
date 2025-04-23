/// Represents the task to perform (transcribe or translate).
enum DecodingTask {
  transcribe,
  translate,
}

/// Represents options for the transcription process.
class DecodingOptions {
  /// The task to perform (transcribe or translate).
  final DecodingTask task;
  
  /// The language to use for transcription.
  final String? language;
  
  /// The temperature to use for sampling.
  final double temperature;
  
  /// The number of samples to consider for each token.
  final int sampleLen;
  
  /// The best of n samples to consider.
  final int bestOf;
  
  /// The beam size for beam search.
  final int beamSize;
  
  /// The patience value for beam search.
  final double patience;
  
  /// The length penalty for beam search.
  final double lengthPenalty;
  
  /// Whether to suppress blank tokens.
  final bool suppressBlank;
  
  /// Whether to suppress tokens that are not in the prompt.
  final bool suppressTokens;
  
  /// Whether to add initial prompt.
  final bool withoutTimestamps;
  
  /// The maximum initial timestamp.
  final double maxInitialTimestamp;
  
  /// The word timestamps flag.
  final bool wordTimestamps;
  
  /// The prepend punctuations.
  final String prependPunctuations;
  
  /// The append punctuations.
  final String appendPunctuations;
  
  /// The log probability threshold.
  final double? logProbThreshold;
  
  /// The no speech threshold.
  final double? noSpeechThreshold;
  
  /// The compression ratio threshold.
  final double? compressionRatioThreshold;
  
  /// The condition on previous text.
  final String? conditionOnPreviousText;
  
  /// The prompt text.
  final String? prompt;
  
  /// The chunking strategy.
  final String? chunkingStrategy;
  
  DecodingOptions({
    this.task = DecodingTask.transcribe,
    this.language,
    this.temperature = 0.0,
    this.sampleLen = 224,
    this.bestOf = 1,
    this.beamSize = 1,
    this.patience = 1.0,
    this.lengthPenalty = 1.0,
    this.suppressBlank = false,
    this.suppressTokens = false,
    this.withoutTimestamps = false,
    this.maxInitialTimestamp = 1.0,
    this.wordTimestamps = false,
    this.prependPunctuations = '"\'"¿([{-',
    this.appendPunctuations = '"\'.。,，!！?？:：")]}、',
    this.logProbThreshold,
    this.noSpeechThreshold,
    this.compressionRatioThreshold,
    this.conditionOnPreviousText,
    this.prompt,
    this.chunkingStrategy,
  });
  
  /// Creates a [DecodingOptions] from a JSON map.
  factory DecodingOptions.fromJson(Map<String, dynamic> json) {
    return DecodingOptions(
      task: json['task'] == 'translate' ? DecodingTask.translate : DecodingTask.transcribe,
      language: json['language'] as String?,
      temperature: json['temperature'] != null ? (json['temperature'] as num).toDouble() : 0.0,
      sampleLen: json['sampleLen'] as int? ?? 224,
      bestOf: json['bestOf'] as int? ?? 1,
      beamSize: json['beamSize'] as int? ?? 1,
      patience: json['patience'] != null ? (json['patience'] as num).toDouble() : 1.0,
      lengthPenalty: json['lengthPenalty'] != null ? (json['lengthPenalty'] as num).toDouble() : 1.0,
      suppressBlank: json['suppressBlank'] as bool? ?? false,
      suppressTokens: json['suppressTokens'] as bool? ?? false,
      withoutTimestamps: json['withoutTimestamps'] as bool? ?? false,
      maxInitialTimestamp: json['maxInitialTimestamp'] != null ? (json['maxInitialTimestamp'] as num).toDouble() : 1.0,
      wordTimestamps: json['wordTimestamps'] as bool? ?? false,
      prependPunctuations: json['prependPunctuations'] as String? ?? '"\'"¿([{-',
      appendPunctuations: json['appendPunctuations'] as String? ?? '"\'.。,，!！?？:：")]}、',
      logProbThreshold: json['logProbThreshold'] != null ? (json['logProbThreshold'] as num).toDouble() : null,
      noSpeechThreshold: json['noSpeechThreshold'] != null ? (json['noSpeechThreshold'] as num).toDouble() : null,
      compressionRatioThreshold: json['compressionRatioThreshold'] != null ? (json['compressionRatioThreshold'] as num).toDouble() : null,
      conditionOnPreviousText: json['conditionOnPreviousText'] as String?,
      prompt: json['prompt'] as String?,
      chunkingStrategy: json['chunkingStrategy'] as String?,
    );
  }
  
  /// Converts this [DecodingOptions] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'task': task == DecodingTask.translate ? 'translate' : 'transcribe',
      if (language != null) 'language': language,
      'temperature': temperature,
      'sampleLen': sampleLen,
      'bestOf': bestOf,
      'beamSize': beamSize,
      'patience': patience,
      'lengthPenalty': lengthPenalty,
      'suppressBlank': suppressBlank,
      'suppressTokens': suppressTokens,
      'withoutTimestamps': withoutTimestamps,
      'maxInitialTimestamp': maxInitialTimestamp,
      'wordTimestamps': wordTimestamps,
      'prependPunctuations': prependPunctuations,
      'appendPunctuations': appendPunctuations,
      if (logProbThreshold != null) 'logProbThreshold': logProbThreshold,
      if (noSpeechThreshold != null) 'noSpeechThreshold': noSpeechThreshold,
      if (compressionRatioThreshold != null) 'compressionRatioThreshold': compressionRatioThreshold,
      if (conditionOnPreviousText != null) 'conditionOnPreviousText': conditionOnPreviousText,
      if (prompt != null) 'prompt': prompt,
      if (chunkingStrategy != null) 'chunkingStrategy': chunkingStrategy,
    };
  }
}
