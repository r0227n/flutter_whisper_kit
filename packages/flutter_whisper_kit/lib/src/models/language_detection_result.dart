/// Represents the result of a language detection operation.
class LanguageDetectionResult {
  /// Creates a new [LanguageDetectionResult] instance.
  const LanguageDetectionResult({
    required this.language,
    required this.probabilities,
  });

  /// The detected language code (e.g., 'en', 'ja', 'fr').
  final String language;

  /// A map of language codes to their detection probabilities.
  final Map<String, double> probabilities;

  /// Creates a [LanguageDetectionResult] from a JSON map.
  factory LanguageDetectionResult.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> rawProbs =
        json['probabilities'] as Map<String, dynamic>;
    final Map<String, double> probabilities = {};

    for (final entry in rawProbs.entries) {
      probabilities[entry.key] = (entry.value as num).toDouble();
    }

    return LanguageDetectionResult(
      language: json['language'] as String,
      probabilities: probabilities,
    );
  }

  /// Converts this [LanguageDetectionResult] to a JSON map.
  Map<String, dynamic> toJson() {
    return {'language': language, 'probabilities': probabilities};
  }
}
