import 'package:flutter/material.dart';
import 'package:flutter_whisper_kit/flutter_whisper_kit.dart';

/// Widget for language detection section
class LanguageDetectionSection extends StatelessWidget {
  const LanguageDetectionSection({
    super.key,
    required this.isModelLoaded,
    required this.isDetectingLanguage,
    required this.languageDetectionResult,
    required this.onDetectLanguagePressed,
  });

  final bool isModelLoaded;
  final bool isDetectingLanguage;
  final LanguageDetectionResult? languageDetectionResult;
  final VoidCallback onDetectLanguagePressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Language Detection',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: isModelLoaded && !isDetectingLanguage
              ? onDetectLanguagePressed
              : null,
          child: Text(
            isDetectingLanguage ? 'Detecting...' : 'Detect Language from File',
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Detection Result:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              languageDetectionResult == null
                  ? const Text('Press the button to detect language from a file')
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Detected Language: ${languageDetectionResult.language}'),
                        const SizedBox(height: 8),
                        const Text('Language Probabilities:'),
                        ...languageDetectionResult.probabilities.entries
                            .toList()
                            .where((entry) => entry.value > 0.01) // Filter out very low probabilities
                            .sorted((a, b) => b.value.compareTo(a.value)) // Sort by probability (descending)
                            .take(5) // Take top 5
                            .map((entry) => Text(
                                  '- ${entry.key}: ${(entry.value * 100).toStringAsFixed(2)}%',
                                ))
                            .toList(),
                      ],
                    ),
            ],
          ),
        ),
      ],
    );
  }
}
