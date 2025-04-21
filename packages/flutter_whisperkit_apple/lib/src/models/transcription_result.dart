import 'dart:convert';

/// Represents a segment in a transcription result.
class TranscriptionSegment {
  /// The transcribed text for this segment.
  final String text;
  
  /// The start time of this segment in seconds.
  final double start;
  
  /// The end time of this segment in seconds.
  final double end;
  
  /// The tokens for this segment, if available.
  final List<String>? tokens;
  
  TranscriptionSegment({
    required this.text,
    required this.start,
    required this.end,
    this.tokens,
  });
  
  /// Creates a [TranscriptionSegment] from a JSON map.
  factory TranscriptionSegment.fromJson(Map<String, dynamic> json) {
    return TranscriptionSegment(
      text: json['text'] as String,
      start: (json['start'] as num).toDouble(),
      end: (json['end'] as num).toDouble(),
      tokens: json['tokens'] != null 
          ? List<String>.from(json['tokens'] as List) 
          : null,
    );
  }
  
  /// Converts this [TranscriptionSegment] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'start': start,
      'end': end,
      if (tokens != null) 'tokens': tokens,
    };
  }
}

/// Represents timing information for a transcription.
class TranscriptionTimings {
  /// Time spent loading the audio file in seconds.
  final double audioFile;
  
  /// Time spent extracting features in seconds.
  final double featureExtraction;
  
  /// Time spent running the model in seconds.
  final double model;
  
  /// Time until the first token was generated in seconds.
  final double firstToken;
  
  /// Time spent in the decoding loop in seconds.
  final double decodingLoop;
  
  /// Total elapsed time for the transcription in seconds.
  final double totalElapsed;
  
  /// Tokens transcribed per second.
  final double tokensPerSecond;
  
  /// Real-time factor (total elapsed time / audio duration).
  final double realTimeFactor;
  
  /// Speed factor (audio duration / total elapsed time).
  final double speedFactor;
  
  TranscriptionTimings({
    required this.audioFile,
    required this.featureExtraction,
    required this.model,
    required this.firstToken,
    required this.decodingLoop,
    required this.totalElapsed,
    required this.tokensPerSecond,
    required this.realTimeFactor,
    required this.speedFactor,
  });
  
  /// Creates a [TranscriptionTimings] from a JSON map.
  factory TranscriptionTimings.fromJson(Map<String, dynamic> json) {
    return TranscriptionTimings(
      audioFile: (json['audioFile'] as num).toDouble(),
      featureExtraction: (json['featureExtraction'] as num).toDouble(),
      model: (json['model'] as num).toDouble(),
      firstToken: (json['firstToken'] as num).toDouble(),
      decodingLoop: (json['decodingLoop'] as num).toDouble(),
      totalElapsed: (json['totalElapsed'] as num).toDouble(),
      tokensPerSecond: (json['tokensPerSecond'] as num).toDouble(),
      realTimeFactor: (json['realTimeFactor'] as num).toDouble(),
      speedFactor: (json['speedFactor'] as num).toDouble(),
    );
  }
  
  /// Converts this [TranscriptionTimings] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'audioFile': audioFile,
      'featureExtraction': featureExtraction,
      'model': model,
      'firstToken': firstToken,
      'decodingLoop': decodingLoop,
      'totalElapsed': totalElapsed,
      'tokensPerSecond': tokensPerSecond,
      'realTimeFactor': realTimeFactor,
      'speedFactor': speedFactor,
    };
  }
}

/// Represents the result of a transcription.
class TranscriptionResult {
  /// The segments of the transcription.
  final List<TranscriptionSegment> segments;
  
  /// Timing information for the transcription.
  final TranscriptionTimings? timings;
  
  TranscriptionResult({
    required this.segments,
    this.timings,
  });
  
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
      segments: (json['segments'] as List)
          .map((e) => TranscriptionSegment.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      timings: json['timings'] != null
          ? TranscriptionTimings.fromJson(Map<String, dynamic>.from(json['timings'] as Map))
          : null,
    );
  }
  
  /// Converts this [TranscriptionResult] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'segments': segments.map((e) => e.toJson()).toList(),
      if (timings != null) 'timings': timings!.toJson(),
    };
  }
  
  /// Returns the combined text of all segments.
  String get text {
    return segments.map((segment) => segment.text).join(' ');
  }
}
