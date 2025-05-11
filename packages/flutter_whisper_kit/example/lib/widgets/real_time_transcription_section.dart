import 'package:flutter/material.dart';
import 'package:flutter_whisper_kit/flutter_whisper_kit.dart';

/// Widget for real-time transcription section
class RealTimeTranscriptionSection extends StatelessWidget {
  const RealTimeTranscriptionSection({
    super.key,
    required this.isModelLoaded,
    required this.isRecording,
    required this.transcriptionText,
    required this.segments,
    required this.onRecordPressed,
  });

  final bool isModelLoaded;
  final bool isRecording;
  final List<TranscriptionSegment> segments;
  final String transcriptionText;
  final VoidCallback onRecordPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Real-time Transcription',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child:
              segments.isNotEmpty
                  ? ListView.builder(
                    itemCount: segments.length,
                    itemBuilder: (context, index) {
                      return Text(
                        '[${segments[index].start.toStringAsFixed(2)}s - ${segments[index].end.toStringAsFixed(2)}s]: ${segments[index].text}',
                      );
                    },
                  )
                  : const Text('No segments'),
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: SingleChildScrollView(
            child: Text(
              transcriptionText.isEmpty
                  ? 'Press the button to start recording'
                  : transcriptionText,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: isModelLoaded ? onRecordPressed : null,
          child: Text(isRecording ? 'Stop Recording' : 'Start Recording'),
        ),
      ],
    );
  }
}
