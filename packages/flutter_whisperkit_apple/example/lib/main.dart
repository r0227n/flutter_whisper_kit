import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_whisperkit_apple/flutter_whisperkit_apple.dart';
import 'package:flutter_whisperkit_apple/model_loader.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String _modelStatus = 'No model loaded';
  bool _isLoading = false;
  double _loadingProgress = 0.0;

  // Use the proper plugin class instead of the generated message class
  final _flutterWhisperkitApple = FlutterWhisperkitApple();

  // Use the model loader for a cleaner API
  final _modelLoader = WhisperKitModelLoader();

  // Selected model variant
  String _selectedVariant = 'tiny-en';

  // Selected storage location
  ModelStorageLocation _storageLocation = ModelStorageLocation.packageDirectory;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await _flutterWhisperkitApple.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  // Initialize WhisperKit
  Future<void> _initializeWhisperKit() async {
    try {
      final result = await _flutterWhisperkitApple.createWhisperKit(
        _selectedVariant,
        'argmaxinc/whisperkit-coreml',
      );

      if (!mounted) return;

      setState(() {
        _modelStatus = 'WhisperKit initialized: $result';
      });
    } on PlatformException catch (e) {
      setState(() {
        _modelStatus = 'Error initializing WhisperKit: ${e.message}';
      });
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
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _modelStatus = 'Model loaded: $result';
      });
    } on PlatformException catch (e) {
      setState(() {
        _isLoading = false;
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
              Text('Running on: $_platformVersion\n'),

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

              const SizedBox(height: 20),

              // Initialize button
              ElevatedButton(
                onPressed: _initializeWhisperKit,
                child: const Text('Initialize WhisperKit'),
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
                  final result = await _flutterWhisperkitApple
                      .transcribeFromFile('assets/test.mp3');

                  print('Transcribed: $result');
                },
                child: const Text('Transcribe'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
