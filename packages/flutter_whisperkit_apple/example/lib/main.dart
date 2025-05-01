import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_whisperkit/flutter_whisperkit.dart';
import 'package:flutter_whisperkit/src/models.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _modelStatus = 'No model loaded';
  bool _isLoading = false;
  double _loadingProgress = 0.0;
  bool _isModelLoaded = false;
  bool _isRecording = false;
  String _realtimeTranscription = '';
  // Add variables to store additional TranscriptionResult details
  List<TranscriptionSegment> _segments = [];
  String _language = '';
  double _confidence = 0.0;
  StreamSubscription<TranscriptionResult>? _transcriptionSubscription;

  // Use the proper plugin class instead of the generated message class
  final _flutterWhisperkit = FlutterWhisperkit();

  // Use the model loader for a cleaner API
  final _modelLoader = WhisperKitModelLoader();

  // Selected model variant
  String _selectedVariant = 'tiny-en';

  // Selected storage location
  ModelStorageLocation _storageLocation = ModelStorageLocation.packageDirectory;

  @override
  void dispose() {
    // Cancel the transcription subscription when the widget is disposed
    _transcriptionSubscription?.cancel();
    super.dispose();
  }

  // Start recording for real-time transcription
  Future<void> _toggleRecording() async {
    if (_isRecording) {
      // Stop recording
      try {
        final result = await _flutterWhisperkit.stopRecording(loop: true);

        // Cancel the transcription stream subscription
        _transcriptionSubscription?.cancel();
        _transcriptionSubscription = null;

        setState(() {
          _isRecording = false;
          _modelStatus = 'Recording stopped: $result';
        });
      } catch (e) {
        setState(() {
          _modelStatus = 'Error stopping recording: $e';
        });
      }
    } else {
      // Start recording
      try {
        final result = await _flutterWhisperkit.startRecording(
          options: const DecodingOptions(
            verbose: true,
            task: DecodingTask.transcribe,
            language: 'ja',
            temperature: 0.0,
            wordTimestamps: true,
          ),
          loop: true, // Use loop mode for continuous transcription in Swift
        );

        // Subscribe to the transcription stream
        _transcriptionSubscription = _flutterWhisperkit.transcriptionStream
            .listen(
              (result) {
                print(result.toJson());
                print('Transcription result: ${result.text}');
                setState(() {
                  if (result.text.isNotEmpty) {
                    _realtimeTranscription = result.text;
                    _segments = result.segments;
                    _language = result.language;
                    _confidence =
                        result.segments.isEmpty
                            ? 0.0
                            : result.segments
                                    .map((s) => s.avgLogprob)
                                    .reduce((a, b) => a + b) /
                                result.segments.length;
                  }
                });
              },
              onError: (error) {
                print('Transcription stream error: $error');
              },
            );

        setState(() {
          _isRecording = true;
          _realtimeTranscription = 'Listening... Speak now.';
          _modelStatus = 'Recording started: $result';
        });
      } catch (e) {
        setState(() {
          _modelStatus = 'Error starting recording: $e';
        });
      }
    }
  }

  // Load a model using the model loader
  Future<void> _loadModel({bool redownload = false}) async {
    setState(() {
      _isLoading = true;
      _loadingProgress = 0.0;
      _modelStatus = 'Loading model $_selectedVariant...';
    });

    try {
      // Set the storage location
      _modelLoader.setStorageLocation(_storageLocation);

      // Load the model
      final result = await _modelLoader.loadModel(
        variant: _selectedVariant,
        modelRepo: 'argmaxinc/whisperkit-coreml',
        redownload: redownload,
        onProgress: (progress) {
          setState(() {
            _loadingProgress = progress;
          });
        },
        storageLocation: _storageLocation,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isModelLoaded = true;
        _modelStatus = 'Model loaded: $result';
      });
    } on PlatformException catch (e) {
      setState(() {
        _isLoading = false;
        _isModelLoaded = false;
        _modelStatus = 'Error loading model: ${e.message}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('WhisperKit Model Loading Example'),
          backgroundColor: Colors.blueGrey,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Model Settings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              // Model variant selection
              DropdownButton<String>(
                value: _selectedVariant,
                isExpanded: true,
                hint: const Text('Select Model Variant'),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedVariant = newValue;
                    });
                  }
                },
                items:
                    <String>[
                      'tiny-en',
                      'tiny',
                      'base-en',
                      'base',
                      'small-en',
                      'small',
                      'medium-en',
                      'medium',
                      'large-v2',
                      'large-v3',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
              ),

              const SizedBox(height: 10),

              // Storage location selection
              Row(
                children: [
                  const Text('Storage Location: '),
                  Radio<ModelStorageLocation>(
                    value: ModelStorageLocation.packageDirectory,
                    groupValue: _storageLocation,
                    onChanged: (ModelStorageLocation? value) {
                      if (value != null) {
                        setState(() {
                          _storageLocation = value;
                        });
                      }
                    },
                  ),
                  const Text('Package Directory'),
                  Radio<ModelStorageLocation>(
                    value: ModelStorageLocation.userFolder,
                    groupValue: _storageLocation,
                    onChanged: (ModelStorageLocation? value) {
                      if (value != null) {
                        setState(() {
                          _storageLocation = value;
                        });
                      }
                    },
                  ),
                  const Text('User Folder'),
                ],
              ),

              const SizedBox(height: 10),

              // Load model button
              ElevatedButton(
                onPressed: _isLoading ? null : () => _loadModel(),
                child: const Text('Load Model'),
              ),

              const SizedBox(height: 10),

              // Force redownload button
              ElevatedButton(
                onPressed:
                    _isLoading ? null : () => _loadModel(redownload: true),
                child: const Text('Force Redownload Model'),
              ),

              const SizedBox(height: 20),

              // Loading progress
              if (_isLoading)
                Column(
                  children: [
                    LinearProgressIndicator(value: _loadingProgress),
                    const SizedBox(height: 5),
                    Text(
                      'Loading: ${(_loadingProgress * 100).toStringAsFixed(1)}%',
                    ),
                  ],
                ),

              const SizedBox(height: 20),

              // Status display
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  'Status: $_modelStatus',
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final result = await _flutterWhisperkit.transcribeFromFile(
                    'assets/test.mp3',
                  );

                  print('Transcribed: $result');
                },
                child: const Text('Transcribe File'),
              ),

              const SizedBox(height: 20),

              // Real-time transcription section
              const Text(
                'Real-time Transcription',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              // Start/stop recording button
              ElevatedButton(
                onPressed: _isModelLoaded ? _toggleRecording : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isRecording ? Colors.red : Colors.green,
                ),
                child: Text(
                  _isRecording ? 'Stop Recording' : 'Start Recording',
                ),
              ),

              const SizedBox(height: 10),

              // Real-time transcription display
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                constraints: const BoxConstraints(minHeight: 100),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _realtimeTranscription.isEmpty
                          ? 'Speak to see transcription here...'
                          : _realtimeTranscription,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                    if (_language.isNotEmpty) Text('Language: $_language'),
                    if (_confidence != 0.0)
                      Text('Confidence: ${_confidence.toStringAsFixed(2)}'),
                    if (_segments.isNotEmpty)
                      Text('Segments: ${_segments.length}'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
