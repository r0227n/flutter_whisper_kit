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

  final _flutterWhisperkitPlugin = FlutterWhisperKit();
  StreamSubscription<TranscriptionResult>? _transcriptionSubscription;
  StreamSubscription<Progress>? _modelProgressSubscription;

  final List<String> _modelVariants = [
    'tiny',
    'tiny-en',
    'base',
    'small',
    'medium',
    'large-v2',
  ];

  final Map<String, DecodingOptions> _decodingOptionsPresets = {
    'Default': const DecodingOptions(
      verbose: true,
      task: DecodingTask.transcribe,
      language: 'en',
      temperature: 0.0,
      wordTimestamps: true,
    ),
    'Japanese': const DecodingOptions(
      verbose: true,
      task: DecodingTask.transcribe,
      language: 'ja',
      temperature: 0.0,
      wordTimestamps: true,
    ),
    'Translation': const DecodingOptions(
      verbose: true,
      task: DecodingTask.translate,
      temperature: 0.0,
      wordTimestamps: false,
    ),
    'Auto-detect': const DecodingOptions(
      verbose: true,
      task: DecodingTask.transcribe,
      detectLanguage: true,
      temperature: 0.0,
      wordTimestamps: true,
    ),
  };

  String _selectedOptionsPreset = 'Default';

  @override
  void initState() {
    super.initState();
    // Subscribe to model progress stream
    _modelProgressSubscription = _flutterWhisperkitPlugin.modelProgressStream
        .listen((progress) {
          setState(() {
            _modelLoadProgress = progress.fractionCompleted;
          });
        });
    _loadModel();
  }

  @override
  void dispose() {
    _transcriptionSubscription?.cancel();
    _modelProgressSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadModel() async {
    try {
      setState(() {
        _modelStatus = 'Loading model...';
        _modelLoadProgress = 0.0;
        _isModelLoaded = false;
      });

      final result = await _flutterWhisperkitPlugin.loadModel(
        _selectedModelVariant,
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
        await _flutterWhisperkitPlugin.startRecording(
          options: _decodingOptionsPresets[_selectedOptionsPreset]!,
        );
        _transcriptionSubscription = _flutterWhisperkitPlugin
            .transcriptionStream
            .listen((result) {
              setState(() {
                _transcriptionResult = result;
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

  Future<void> _transcribeFromFile() async {
    if (!_isModelLoaded) {
      setState(() {
        _transcriptionText = 'Please wait for the model to load first.';
      });
      return;
    }

    try {
      setState(() {
        _transcriptionText = 'Transcribing file...';
      });

      final result = await _flutterWhisperkitPlugin.transcribeFromFile(
        '<mp3 file path>',
        options: _decodingOptionsPresets[_selectedOptionsPreset]!,
      );

      setState(() {
        _transcriptionResult = result;
        _transcriptionText = result?.text ?? 'No transcription result';
      });
    } catch (e) {
      setState(() {
        _transcriptionText = 'Error transcribing file: $e';
      });
    }
  }

  void _showTranscriptionDetails() {
    if (_transcriptionResult == null) return;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Transcription Details'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Language: ${_transcriptionResult!.language}'),
                  const SizedBox(height: 8),
                  const Text(
                    'Segments:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...(_transcriptionResult!.segments
                      .map(
                        (segment) => Padding(
                          padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                          child: Text(
                            '${segment.start.toStringAsFixed(1)}s - ${segment.end.toStringAsFixed(1)}s: ${segment.text}',
                          ),
                        ),
                      )
                      .toList()),
                  const SizedBox(height: 8),
                  const Text(
                    'Timings:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Full pipeline: ${_transcriptionResult!.timings.fullPipeline.toStringAsFixed(3)}s',
                  ),
                  Text(
                    'Real-time factor: ${_transcriptionResult!.timings.realTimeFactor.toStringAsFixed(3)}',
                  ),
                  if (_transcriptionResult!.allWords.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Word Timestamps:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ...(_transcriptionResult!.allWords
                        .take(5)
                        .map(
                          (word) => Padding(
                            padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                            child: Text(
                              '${word.word}: ${word.start.toStringAsFixed(2)}s - ${word.end.toStringAsFixed(2)}s',
                            ),
                          ),
                        )
                        .toList()),
                    if (_transcriptionResult!.allWords.length > 5)
                      const Text('... and more words'),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Flutter WhisperKit Example')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(_modelStatus),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
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
              ),

              const SizedBox(height: 8),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isModelLoaded ? _toggleRecording : null,
                      child: Text(
                        _isRecording ? 'Stop Recording' : 'Start Recording',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isModelLoaded ? _transcribeFromFile : null,
                      child: const Text('Transcribe File'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
