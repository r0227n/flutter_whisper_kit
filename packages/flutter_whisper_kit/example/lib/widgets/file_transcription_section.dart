import 'package:flutter/material.dart';
import 'package:flutter_whisper_kit/flutter_whisper_kit.dart';

/// Widget for file transcription section
class FileTranscriptionSection extends StatelessWidget {
  const FileTranscriptionSection({
    super.key,
    required this.isModelLoaded,
    required this.isTranscribingFile,
    required this.fileTranscriptionText,
    required this.fileTranscriptionResult,
    required this.onTranscribePressed,
  });

  final bool isModelLoaded;
  final bool isTranscribingFile;
  final String fileTranscriptionText;
  final TranscriptionResult? fileTranscriptionResult;
  final VoidCallback onTranscribePressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'File Transcription',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: isModelLoaded ? onTranscribePressed : null,
          child: Text(
            isTranscribingFile ? 'Transcribing...' : 'Transcribe from File',
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
              Text(
                fileTranscriptionText.isEmpty
                    ? 'Press the button to transcribe a file'
                    : fileTranscriptionText,
                style: const TextStyle(fontSize: 16),
              ),
              if (fileTranscriptionResult != null) ...[
                const SizedBox(height: 8),
                const Text(
                  'Detected Language:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(fileTranscriptionResult?.language ?? 'Unknown'),
                const SizedBox(height: 8),
                const Text(
                  'Segments:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...(fileTranscriptionResult?.segments ?? []).map(
                  (segment) => Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      '[${segment.start.toStringAsFixed(2)}s - ${segment.end.toStringAsFixed(2)}s]: ${segment.text}',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Performance:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Real-time factor: ${fileTranscriptionResult?.timings.realTimeFactor.toStringAsFixed(2)}x',
                ),
                Text(
                  'Processing time: ${fileTranscriptionResult?.timings.fullPipeline.toStringAsFixed(2)}s',
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
