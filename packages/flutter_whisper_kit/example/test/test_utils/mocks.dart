import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_whisper_kit/flutter_whisper_kit.dart';
import 'package:flutter_whisper_kit_example/main.dart';

class MockFlutterWhisperKit extends FlutterWhisperKit {
  bool modelLoaded = false;
  String? loadedModelVariant;
  final StreamController<Progress> _modelProgressController = StreamController<Progress>.broadcast();
  final StreamController<TranscriptionResult> _transcriptionController = StreamController<TranscriptionResult>.broadcast();
  
  @override
  Future<String?> loadModel(
    String? variant, {
    String? modelRepo,
    bool redownload = false,
    Function(Progress progress)? onProgress,
  }) async {
    loadedModelVariant = variant;
    modelLoaded = true;
    
    // Simulate progress updates
    final progress50 = const Progress(
      totalUnitCount: 100,
      completedUnitCount: 50,
      fractionCompleted: 0.5,
      isIndeterminate: false,
    );
    
    _modelProgressController.add(progress50);
    if (onProgress != null) {
      onProgress(progress50);
    }
    
    await Future.delayed(const Duration(milliseconds: 100));
    
    final progress100 = const Progress(
      totalUnitCount: 100,
      completedUnitCount: 100,
      fractionCompleted: 1.0,
      isIndeterminate: false,
    );
    
    _modelProgressController.add(progress100);
    if (onProgress != null) {
      onProgress(progress100);
    }
    
    return 'Model loaded: $variant';
  }
  
  @override
  Future<TranscriptionResult?> transcribeFromFile(
    String filePath, {
    DecodingOptions options = const DecodingOptions(),
  }) async {
    if (!modelLoaded) {
      throw Exception('Model not loaded');
    }
    
    return TranscriptionResult(
      text: 'This is a mock transcription result',
      segments: [
        TranscriptionSegment(
          id: 0,
          seek: 0,
          start: 0.0,
          end: 2.0,
          text: 'This is a mock transcription result',
          tokens: [1, 2, 3],
          temperature: 1.0,
          avgLogprob: -0.5,
          compressionRatio: 1.2,
          noSpeechProb: 0.1,
        ),
      ],
      language: options.language ?? 'en',
      timings: const TranscriptionTimings(
        fullPipeline: 1.0,
      ),
    );
  }
  
  @override
  Future<String?> startRecording({
    DecodingOptions options = const DecodingOptions(),
    bool loop = false,
  }) async {
    if (!modelLoaded) {
      throw Exception('Model not loaded');
    }
    
    // Simulate transcription stream
    _transcriptionController.add(
      TranscriptionResult(
        text: 'This is a mock real-time transcription',
        segments: [
          TranscriptionSegment(
            id: 0,
            seek: 0,
            start: 0.0,
            end: 2.0,
            text: 'This is a mock real-time transcription',
            tokens: [1, 2, 3],
            temperature: 1.0,
            avgLogprob: -0.5,
            compressionRatio: 1.2,
            noSpeechProb: 0.1,
          ),
        ],
        language: options.language ?? 'en',
        timings: const TranscriptionTimings(
          fullPipeline: 1.0,
        ),
      ),
    );
    
    return 'Recording started';
  }
  
  @override
  Future<String?> stopRecording({bool loop = false}) async {
    return 'Recording stopped';
  }
  
  @override
  Stream<Progress> get modelProgressStream => _modelProgressController.stream;
  
  @override
  Stream<TranscriptionResult> get transcriptionStream => _transcriptionController.stream;
  
  void dispose() {
    _modelProgressController.close();
    _transcriptionController.close();
  }
}

// Helper function to build test widget
Widget buildTestApp() {
  return const MaterialApp(
    home: MyApp(),
  );
}

// Custom ModelLoadingIndicator for testing that accepts Future<String?>
class TestModelLoadingIndicator extends StatelessWidget {
  const TestModelLoadingIndicator({
    super.key,
    required this.asyncLoadModel,
    required this.modelProgressStream,
  });

  final Future<String?> asyncLoadModel;
  final Stream<Progress> modelProgressStream;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: asyncLoadModel,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error loading model: ${snapshot.error}');
        } else if (snapshot.hasData) {
          return Text('Model loaded successfully');
        }

        return StreamBuilder<Progress>(
          stream: modelProgressStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error loading model: ${snapshot.error}');
            }

            if (snapshot.data?.fractionCompleted == 1.0) {
              return const Center(
                child: Column(
                  children: [CircularProgressIndicator(), Text('Model loaded')],
                ),
              );
            }

            return Column(
              children: [
                LinearProgressIndicator(
                  value: snapshot.data?.fractionCompleted,
                ),
                Text('${(snapshot.data?.fractionCompleted ?? 0) * 100}%'),
              ],
            );
          },
        );
      },
    );
  }
}
