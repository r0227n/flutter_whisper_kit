import 'package:flutter/material.dart';
import 'dart:async';

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
  String _transcriptionText = '';
  bool _isRecording = false;
  bool _isModelLoaded = false;
  String _modelStatus = 'Model not loaded';

  final _flutterWhisperkitPlugin = FlutterWhisperkit();
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
        'large-v3',
        modelRepo: 'argmaxinc/whisperkit-coreml',
        redownload: true,
        storageLocation: ModelStorageLocation.packageDirectory,
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
        await _flutterWhisperkitPlugin.startRecording();
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
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _toggleRecording,
                child: Text(
                  _isRecording ? 'Stop Recording' : 'Start Recording',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
