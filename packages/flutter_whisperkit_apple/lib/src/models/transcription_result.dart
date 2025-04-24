import 'dart:convert';
import 'word_timing.dart';

/// Represents a segment in a transcription result.
class TranscriptionSegment {
  const TranscriptionSegment({
    this.id = 0,
    this.seek = 0,
    required this.start,
    required this.end,
    required this.text,
    this.tokens = const [],
    this.tokenLogProbs = const [],
    this.temperature = 1.0,
    this.avgLogprob = 0.0,
    this.compressionRatio = 1.0,
    this.noSpeechProb = 0.0,
    this.words,
  });

  /// The segment ID.
  final int id;

  /// The seek position in the audio.
  final int seek;

  /// The start time of this segment in seconds.
  final double start;

  /// The end time of this segment in seconds.
  final double end;

  /// The transcribed text for this segment.
  final String text;

  /// The tokens for this segment.
  final List<int> tokens;

  /// The token log probabilities for this segment.
  final List<Map<int, double>> tokenLogProbs;

  /// The temperature used for sampling.
  final double temperature;

  /// The average log probability of the segment.
  final double avgLogprob;

  /// The compression ratio of the segment.
  final double compressionRatio;

  /// The no speech probability of the segment.
  final double noSpeechProb;

  /// The word timings for this segment, if available.
  final List<WordTiming>? words;

  /// Computed property for the duration of the segment.
  double get duration => end - start;

  /// Creates a [TranscriptionSegment] from a JSON map.
  factory TranscriptionSegment.fromJson(Map<String, dynamic> json) {
    return TranscriptionSegment(
      id: json['id'] as int? ?? 0,
      seek: json['seek'] as int? ?? 0,
      start: (json['start'] as num).toDouble(),
      end: (json['end'] as num).toDouble(),
      text: json['text'] as String,
      tokens:
          json['tokens'] != null
              ? (json['tokens'] as List).map((e) => e as int).toList()
              : [],
      tokenLogProbs:
          json['tokenLogProbs'] != null
              ? (json['tokenLogProbs'] as List).map((e) {
                final Map<int, double> logProbs = {};
                (e as Map).forEach((key, value) {
                  logProbs[int.parse(key.toString())] =
                      (value as num).toDouble();
                });
                return logProbs;
              }).toList()
              : [],
      temperature:
          json['temperature'] != null
              ? (json['temperature'] as num).toDouble()
              : 1.0,
      avgLogprob:
          json['avgLogprob'] != null
              ? (json['avgLogprob'] as num).toDouble()
              : 0.0,
      compressionRatio:
          json['compressionRatio'] != null
              ? (json['compressionRatio'] as num).toDouble()
              : 1.0,
      noSpeechProb:
          json['noSpeechProb'] != null
              ? (json['noSpeechProb'] as num).toDouble()
              : 0.0,
      words:
          json['words'] != null
              ? (json['words'] as List)
                  .map(
                    (e) => WordTiming.fromJson(
                      Map<String, dynamic>.from(e as Map),
                    ),
                  )
                  .toList()
              : null,
    );
  }

  /// Converts this [TranscriptionSegment] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seek': seek,
      'start': start,
      'end': end,
      'text': text,
      'tokens': tokens,
      'tokenLogProbs':
          tokenLogProbs.map((logProbs) {
            final Map<String, double> result = {};
            logProbs.forEach((key, value) {
              result[key.toString()] = value;
            });
            return result;
          }).toList(),
      'temperature': temperature,
      'avgLogprob': avgLogprob,
      'compressionRatio': compressionRatio,
      'noSpeechProb': noSpeechProb,
      if (words != null) 'words': words!.map((w) => w.toJson()).toList(),
    };
  }
}

/// Represents timing information for a transcription.
class TranscriptionTimings {
  const TranscriptionTimings({
    this.pipelineStart = 0.0,
    this.firstTokenTime = 0.0,
    this.inputAudioSeconds = 0.001,
    this.modelLoading = 0.0,
    this.prewarmLoadTime = 0.0,
    this.encoderLoadTime = 0.0,
    this.decoderLoadTime = 0.0,
    this.encoderSpecializationTime = 0.0,
    this.decoderSpecializationTime = 0.0,
    this.tokenizerLoadTime = 0.0,
    this.audioLoading = 0.0,
    this.audioProcessing = 0.0,
    this.logmels = 0.0,
    this.encoding = 0.0,
    this.prefill = 0.0,
    this.decodingInit = 0.0,
    this.decodingLoop = 0.0,
    this.decodingPredictions = 0.0,
    this.decodingFiltering = 0.0,
    this.decodingSampling = 0.0,
    this.decodingFallback = 0.0,
    this.decodingWindowing = 0.0,
    this.decodingKvCaching = 0.0,
    this.decodingWordTimestamps = 0.0,
    this.decodingNonPrediction = 0.0,
    this.totalAudioProcessingRuns = 0.0,
    this.totalLogmelRuns = 0.0,
    this.totalEncodingRuns = 0.0,
    this.totalDecodingLoops = 0.0,
    this.totalKVUpdateRuns = 0.0,
    this.totalTimestampAlignmentRuns = 0.0,
    this.totalDecodingFallbacks = 0.0,
    this.totalDecodingWindows = 0.0,
    this.fullPipeline = 0.0,
  });

  /// Pipeline start time.
  final double pipelineStart;

  /// First token time.
  final double firstTokenTime;

  /// Input audio duration in seconds.
  final double inputAudioSeconds;

  /// Time spent loading the model in seconds.
  final double modelLoading;

  /// Time spent prewarming the model in seconds.
  final double prewarmLoadTime;

  /// Time spent loading the encoder in seconds.
  final double encoderLoadTime;

  /// Time spent loading the decoder in seconds.
  final double decoderLoadTime;

  /// Time spent specializing the encoder in seconds.
  final double encoderSpecializationTime;

  /// Time spent specializing the decoder in seconds.
  final double decoderSpecializationTime;

  /// Time spent loading the tokenizer in seconds.
  final double tokenizerLoadTime;

  /// Time spent loading the audio file in seconds.
  final double audioLoading;

  /// Time spent processing audio in seconds.
  final double audioProcessing;

  /// Time spent extracting log mel features in seconds.
  final double logmels;

  /// Time spent encoding audio in seconds.
  final double encoding;

  /// Time spent prefilling the model in seconds.
  final double prefill;

  /// Time spent initializing decoding in seconds.
  final double decodingInit;

  /// Time spent in the decoding loop in seconds.
  final double decodingLoop;

  /// Time spent on predictions in seconds.
  final double decodingPredictions;

  /// Time spent on filtering in seconds.
  final double decodingFiltering;

  /// Time spent on sampling in seconds.
  final double decodingSampling;

  /// Time spent on fallback in seconds.
  final double decodingFallback;

  /// Time spent on windowing in seconds.
  final double decodingWindowing;

  /// Time spent on KV caching in seconds.
  final double decodingKvCaching;

  /// Time spent on word timestamps in seconds.
  final double decodingWordTimestamps;

  /// Time spent on non-prediction operations in seconds.
  final double decodingNonPrediction;

  /// Total number of audio processing runs.
  final double totalAudioProcessingRuns;

  /// Total number of log mel runs.
  final double totalLogmelRuns;

  /// Total number of encoding runs.
  final double totalEncodingRuns;

  /// Total number of decoding loops.
  final double totalDecodingLoops;

  /// Total number of KV update runs.
  final double totalKVUpdateRuns;

  /// Total number of timestamp alignment runs.
  final double totalTimestampAlignmentRuns;

  /// Total number of decoding fallbacks.
  final double totalDecodingFallbacks;

  /// Total number of decoding windows.
  final double totalDecodingWindows;

  /// Full pipeline duration in seconds.
  final double fullPipeline;

  /// Tokens transcribed per second.
  double get tokensPerSecond => totalDecodingLoops / fullPipeline;

  /// Real-time factor (total elapsed time / audio duration).
  double get realTimeFactor => fullPipeline / inputAudioSeconds;

  /// Speed factor (audio duration / total elapsed time).
  double get speedFactor => inputAudioSeconds / fullPipeline;

  /// Creates a [TranscriptionTimings] from a JSON map.
  factory TranscriptionTimings.fromJson(Map<String, dynamic> json) {
    return TranscriptionTimings(
      pipelineStart:
          json['pipelineStart'] != null
              ? (json['pipelineStart'] as num).toDouble()
              : 0.0,
      firstTokenTime:
          json['firstTokenTime'] != null
              ? (json['firstTokenTime'] as num).toDouble()
              : 0.0,
      inputAudioSeconds:
          json['inputAudioSeconds'] != null
              ? (json['inputAudioSeconds'] as num).toDouble()
              : 0.001,
      modelLoading:
          json['modelLoading'] != null
              ? (json['modelLoading'] as num).toDouble()
              : 0.0,
      prewarmLoadTime:
          json['prewarmLoadTime'] != null
              ? (json['prewarmLoadTime'] as num).toDouble()
              : 0.0,
      encoderLoadTime:
          json['encoderLoadTime'] != null
              ? (json['encoderLoadTime'] as num).toDouble()
              : 0.0,
      decoderLoadTime:
          json['decoderLoadTime'] != null
              ? (json['decoderLoadTime'] as num).toDouble()
              : 0.0,
      encoderSpecializationTime:
          json['encoderSpecializationTime'] != null
              ? (json['encoderSpecializationTime'] as num).toDouble()
              : 0.0,
      decoderSpecializationTime:
          json['decoderSpecializationTime'] != null
              ? (json['decoderSpecializationTime'] as num).toDouble()
              : 0.0,
      tokenizerLoadTime:
          json['tokenizerLoadTime'] != null
              ? (json['tokenizerLoadTime'] as num).toDouble()
              : 0.0,
      audioLoading:
          json['audioLoading'] != null
              ? (json['audioLoading'] as num).toDouble()
              : 0.0,
      audioProcessing:
          json['audioProcessing'] != null
              ? (json['audioProcessing'] as num).toDouble()
              : 0.0,
      logmels:
          json['logmels'] != null ? (json['logmels'] as num).toDouble() : 0.0,
      encoding:
          json['encoding'] != null ? (json['encoding'] as num).toDouble() : 0.0,
      prefill:
          json['prefill'] != null ? (json['prefill'] as num).toDouble() : 0.0,
      decodingInit:
          json['decodingInit'] != null
              ? (json['decodingInit'] as num).toDouble()
              : 0.0,
      decodingLoop:
          json['decodingLoop'] != null
              ? (json['decodingLoop'] as num).toDouble()
              : 0.0,
      decodingPredictions:
          json['decodingPredictions'] != null
              ? (json['decodingPredictions'] as num).toDouble()
              : 0.0,
      decodingFiltering:
          json['decodingFiltering'] != null
              ? (json['decodingFiltering'] as num).toDouble()
              : 0.0,
      decodingSampling:
          json['decodingSampling'] != null
              ? (json['decodingSampling'] as num).toDouble()
              : 0.0,
      decodingFallback:
          json['decodingFallback'] != null
              ? (json['decodingFallback'] as num).toDouble()
              : 0.0,
      decodingWindowing:
          json['decodingWindowing'] != null
              ? (json['decodingWindowing'] as num).toDouble()
              : 0.0,
      decodingKvCaching:
          json['decodingKvCaching'] != null
              ? (json['decodingKvCaching'] as num).toDouble()
              : 0.0,
      decodingWordTimestamps:
          json['decodingWordTimestamps'] != null
              ? (json['decodingWordTimestamps'] as num).toDouble()
              : 0.0,
      decodingNonPrediction:
          json['decodingNonPrediction'] != null
              ? (json['decodingNonPrediction'] as num).toDouble()
              : 0.0,
      totalAudioProcessingRuns:
          json['totalAudioProcessingRuns'] != null
              ? (json['totalAudioProcessingRuns'] as num).toDouble()
              : 0.0,
      totalLogmelRuns:
          json['totalLogmelRuns'] != null
              ? (json['totalLogmelRuns'] as num).toDouble()
              : 0.0,
      totalEncodingRuns:
          json['totalEncodingRuns'] != null
              ? (json['totalEncodingRuns'] as num).toDouble()
              : 0.0,
      totalDecodingLoops:
          json['totalDecodingLoops'] != null
              ? (json['totalDecodingLoops'] as num).toDouble()
              : 0.0,
      totalKVUpdateRuns:
          json['totalKVUpdateRuns'] != null
              ? (json['totalKVUpdateRuns'] as num).toDouble()
              : 0.0,
      totalTimestampAlignmentRuns:
          json['totalTimestampAlignmentRuns'] != null
              ? (json['totalTimestampAlignmentRuns'] as num).toDouble()
              : 0.0,
      totalDecodingFallbacks:
          json['totalDecodingFallbacks'] != null
              ? (json['totalDecodingFallbacks'] as num).toDouble()
              : 0.0,
      totalDecodingWindows:
          json['totalDecodingWindows'] != null
              ? (json['totalDecodingWindows'] as num).toDouble()
              : 0.0,
      fullPipeline:
          json['fullPipeline'] != null
              ? (json['fullPipeline'] as num).toDouble()
              : 0.0,
    );
  }

  /// Converts this [TranscriptionTimings] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'pipelineStart': pipelineStart,
      'firstTokenTime': firstTokenTime,
      'inputAudioSeconds': inputAudioSeconds,
      'modelLoading': modelLoading,
      'prewarmLoadTime': prewarmLoadTime,
      'encoderLoadTime': encoderLoadTime,
      'decoderLoadTime': decoderLoadTime,
      'encoderSpecializationTime': encoderSpecializationTime,
      'decoderSpecializationTime': decoderSpecializationTime,
      'tokenizerLoadTime': tokenizerLoadTime,
      'audioLoading': audioLoading,
      'audioProcessing': audioProcessing,
      'logmels': logmels,
      'encoding': encoding,
      'prefill': prefill,
      'decodingInit': decodingInit,
      'decodingLoop': decodingLoop,
      'decodingPredictions': decodingPredictions,
      'decodingFiltering': decodingFiltering,
      'decodingSampling': decodingSampling,
      'decodingFallback': decodingFallback,
      'decodingWindowing': decodingWindowing,
      'decodingKvCaching': decodingKvCaching,
      'decodingWordTimestamps': decodingWordTimestamps,
      'decodingNonPrediction': decodingNonPrediction,
      'totalAudioProcessingRuns': totalAudioProcessingRuns,
      'totalLogmelRuns': totalLogmelRuns,
      'totalEncodingRuns': totalEncodingRuns,
      'totalDecodingLoops': totalDecodingLoops,
      'totalKVUpdateRuns': totalKVUpdateRuns,
      'totalTimestampAlignmentRuns': totalTimestampAlignmentRuns,
      'totalDecodingFallbacks': totalDecodingFallbacks,
      'totalDecodingWindows': totalDecodingWindows,
      'fullPipeline': fullPipeline,
    };
  }
}

/// Represents the result of a transcription.
class TranscriptionResult {
  const TranscriptionResult({
    required this.text,
    required this.segments,
    required this.language,
    required this.timings,
    this.seekTime,
  });

  /// The full transcribed text.
  final String text;

  /// The segments of the transcription.
  final List<TranscriptionSegment> segments;

  /// The detected language code.
  final String language;

  /// Timing information for the transcription.
  final TranscriptionTimings timings;

  /// The seek time in the audio, if applicable.
  final double? seekTime;

  /// Returns all words from all segments.
  List<WordTiming> get allWords =>
      segments
          .where((segment) => segment.words != null)
          .expand((segment) => segment.words!)
          .toList();

  /// Creates a [TranscriptionResult] from a JSON string.
  factory TranscriptionResult.fromJsonString(String jsonString) {
    final Map<String, dynamic> json = Map<String, dynamic>.from(
      jsonDecode(jsonString) as Map,
    );
    return TranscriptionResult.fromJson(json);
  }

  /// Creates a [TranscriptionResult] from a JSON map.
  factory TranscriptionResult.fromJson(Map<String, dynamic> json) {
    return TranscriptionResult(
      text: json['text'] as String? ?? '',
      segments:
          (json['segments'] as List)
              .map(
                (e) => TranscriptionSegment.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList(),
      language: json['language'] as String? ?? 'en',
      timings:
          json['timings'] != null
              ? TranscriptionTimings.fromJson(
                Map<String, dynamic>.from(json['timings'] as Map),
              )
              : TranscriptionTimings(),
      seekTime:
          json['seekTime'] != null
              ? (json['seekTime'] as num).toDouble()
              : null,
    );
  }

  /// Converts this [TranscriptionResult] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'segments': segments.map((e) => e.toJson()).toList(),
      'language': language,
      'timings': timings.toJson(),
      if (seekTime != null) 'seekTime': seekTime,
    };
  }
}
