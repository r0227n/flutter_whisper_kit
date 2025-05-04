import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_whisper_kit/flutter_whisper_kit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _transcriptionText = '';
  bool _isRecording = false;
  bool _isModelLoaded = false;
  String _modelStatus = 'Model not loaded';
  double _modelLoadProgress = 0.0;
  // Added state variables for file transcription
  String _fileTranscriptionText = '';
  bool _isTranscribingFile = false;
  TranscriptionResult? _fileTranscriptionResult;

  final _flutterWhisperkitPlugin = FlutterWhisperKit();
  StreamSubscription<TranscriptionResult>? _transcriptionSubscription;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  @override
  void dispose() {
    _transcriptionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadModel() async {
    try {
      setState(() {
        _modelStatus = 'Loading model...';
      });

      final result = await _flutterWhisperkitPlugin.loadModel(
        'tiny',
        modelRepo: 'argmaxinc/whisperkit-coreml',
        redownload: true,
        onProgress: (progress) {
          setState(() {
            _modelLoadProgress = progress.fractionCompleted;
          });
        },
      );

      setState(() {
        _isModelLoaded = true;
        _modelStatus = 'Model loaded: $result';
      });
    } catch (e) {
      setState(() {
        _modelStatus = 'Error loading model: $e';
      });
    }
  }

  Future<void> _transcribeFromFile() async {
    if (!_isModelLoaded) {
      setState(() {
        _fileTranscriptionText = 'Please wait for the model to load first.';
      });
      return;
    }

    setState(() {
      _isTranscribingFile = true;
      _fileTranscriptionText = 'Transcribing file...';
    });

    try {
      // Use a placeholder as specified in the task
      const filePath = '<mp3 file path>';
      
      // Create custom decoding options
      final options = DecodingOptions(
        verbose: true,
        task: DecodingTask.transcribe,
        language: 'en', // Default to English
        temperature: 0.0,
        temperatureFallbackCount: 5,
        wordTimestamps: true,
        chunkingStrategy: ChunkingStrategy.vad,
      );

      final result = await _flutterWhisperkitPlugin.transcribeFromFile(
        filePath,
        options: options,
      );

      setState(() {
        _isTranscribingFile = false;
        _fileTranscriptionResult = result;
        _fileTranscriptionText = result?.text ?? 'No transcription result';
      });
    } catch (e) {
      setState(() {
        _isTranscribingFile = false;
        _fileTranscriptionText = 'Error transcribing file: $e';
      });
    }
  }

  Future<void> _toggleRecording() async {
    if (!_isModelLoaded) {
      setState(() {
        _transcriptionText = 'Please wait for the model to load first.';
      });
      return;
    }

    try {
      if (_isRecording) {
        await _flutterWhisperkitPlugin.stopRecording();
        _transcriptionSubscription?.cancel();
      } else {
        // Create custom decoding options for real-time transcription
        final options = DecodingOptions(
          verbose: true,
          task: DecodingTask.transcribe,
          language: 'en', // Default to English
          temperature: 0.0,
          temperatureFallbackCount: 5,
          wordTimestamps: true,
          chunkingStrategy: ChunkingStrategy.vad,
        );
        
        await _flutterWhisperkitPlugin.startRecording(options: options);
        _transcriptionSubscription = _flutterWhisperkitPlugin
            .transcriptionStream
            .listen((result) {
              setState(() {
                _transcriptionText = result.text;
              });
            });
      }

      setState(() {
        _isRecording = !_isRecording;
      });
    } catch (e) {
      setState(() {
        _transcriptionText = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Flutter WhisperKit Example')),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Model loading section
                Text('Model Status: $_modelStatus'),
                if (_modelLoadProgress > 0 && _modelLoadProgress < 1) ...[
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: _modelLoadProgress),
                  Text('${(_modelLoadProgress * 100).toStringAsFixed(1)}%'),
                ],
                const SizedBox(height: 16),
                
                // File transcription section
                const Text(
                  'File Transcription',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _isModelLoaded ? _transcribeFromFile : null,
                  child: Text(_isTranscribingFile 
                      ? 'Transcribing...' 
                      : 'Transcribe from File'),
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
                        _fileTranscriptionText.isEmpty
                            ? 'Press the button to transcribe a file'
                            : _fileTranscriptionText,
                        style: const TextStyle(fontSize: 16),
                      ),
                      if (_fileTranscriptionResult != null) ...[
                        const SizedBox(height: 8),
                        const Text('Detected Language:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(_fileTranscriptionResult?.language ?? 'Unknown'),
                        const SizedBox(height: 8),
                        const Text('Segments:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        ...(_fileTranscriptionResult?.segments ?? []).map(
                          (segment) => Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text(
                              '[${segment.start.toStringAsFixed(2)}s - ${segment.end.toStringAsFixed(2)}s]: ${segment.text}',
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text('Performance:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Real-time factor: ${_fileTranscriptionResult?.timings.realTimeFactor.toStringAsFixed(2)}x'),
                        Text('Processing time: ${_fileTranscriptionResult?.timings.fullPipeline.toStringAsFixed(2)}s'),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Real-time transcription section
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
                  child: SingleChildScrollView(
                    child: Text(
                      _transcriptionText.isEmpty
                          ? 'Press the button to start recording'
                          : _transcriptionText,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isModelLoaded ? _toggleRecording : null,
                  child: Text(
                    _isRecording ? 'Stop Recording' : 'Start Recording',
                  ),
                ),
                
                // Model information section
                const SizedBox(height: 24),
                const Text(
                  'Model Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This example demonstrates the following FlutterWhisperKit features:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text('• Model loading with progress tracking'),
                const Text('• File transcription with custom options'),
                const Text('• Real-time transcription with streaming results'),
                const Text('• Detailed transcription results with segments and timing information'),
                const SizedBox(height: 8),
                const Text(
                  'Note: The file transcription feature uses a placeholder path "<mp3 file path>" and will not actually transcribe a file when running this example.',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
