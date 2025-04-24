/// Represents a word with timing information in a transcription segment.
class WordTiming {
  const WordTiming({
    required this.word,
    required this.tokens,
    required this.start,
    required this.end,
    required this.probability,
  });

  /// The word text.
  final String word;

  /// The tokens for this word.
  final List<int> tokens;

  /// The start time of this word in seconds.
  final double start;

  /// The end time of this word in seconds.
  final double end;

  /// The probability of this word.
  final double probability;

  /// Computed property for the duration of the word.
  double get duration => end - start;

  /// Creates a [WordTiming] from a JSON map.
  factory WordTiming.fromJson(Map<String, dynamic> json) {
    return WordTiming(
      word: json['word'] as String,
      tokens: (json['tokens'] as List).map((e) => e as int).toList(),
      start: (json['start'] as num).toDouble(),
      end: (json['end'] as num).toDouble(),
      probability: (json['probability'] as num).toDouble(),
    );
  }

  /// Converts this [WordTiming] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'tokens': tokens,
      'start': start,
      'end': end,
      'probability': probability,
    };
  }
}
