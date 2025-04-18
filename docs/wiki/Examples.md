# Examples

This page provides examples of how to use the Flutter WhisperKit Apple plugin in your Flutter applications.

## Basic Example

Here's a simple example of how to transcribe audio from a file:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_whisperkit_apple/flutter_whisperkit_apple.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _flutterWhisperkitApple = FlutterWhisperkitApple();
  String _transcriptionResult = 'Press the button to start transcription';
  bool _isTranscribing = false;

  @override
  void initState() {
    super.initState();
    _initializeWhisperKit();
  }

  Future<void> _initializeWhisperKit() async {
    try {
      await _flutterWhisperkitApple.initializeWhisperKit();
      setState(() {
        _transcriptionResult = 'WhisperKit initialized successfully';
      });
    } catch (e) {
      setState(() {
        _transcriptionResult = 'Failed to initialize WhisperKit: $e';
      });
    }
  }

  Future<void> _transcribeFromFile() async {
    if (_isTranscribing) return;

    setState(() {
      _isTranscribing = true;
      _transcriptionResult = 'Transcribing...';
    });

    try {
      final result = await _flutterWhisperkitApple.transcribeAudio(
        filePath: 'path/to/your/audio/file.m4a',
        config: TranscriptionConfig(
          language: 'en',
          modelSize: 'medium',
        ),
      );

      setState(() {
        _transcriptionResult = result.text;
      });
    } catch (e) {
      setState(() {
        _transcriptionResult = 'Transcription failed: $e';
      });
    } finally {
      setState(() {
        _isTranscribing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('WhisperKit Example'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _transcriptionResult,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isTranscribing ? null : _transcribeFromFile,
                  child: Text(_isTranscribing ? 'Transcribing...' : 'Transcribe Audio File'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

## Real-time Transcription Example

This example demonstrates how to perform real-time transcription from the microphone:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_whisperkit_apple/flutter_whisperkit_apple.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _flutterWhisperkitApple = FlutterWhisperkitApple();
  String _transcriptionResult = 'Press the button to start recording';
  bool _isRecording = false;
  StreamSubscription? _transcriptionSubscription;

  @override
  void initState() {
    super.initState();
    _initializeWhisperKit();
  }

  @override
  void dispose() {
    _transcriptionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeWhisperKit() async {
    try {
      await _flutterWhisperkitApple.initializeWhisperKit();
      setState(() {
        _transcriptionResult = 'WhisperKit initialized successfully';
      });
    } catch (e) {
      setState(() {
        _transcriptionResult = 'Failed to initialize WhisperKit: $e';
      });
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    final hasPermission = await _flutterWhisperkitApple.requestAudioPermission();
    if (!hasPermission) {
      setState(() {
        _transcriptionResult = 'Microphone permission denied';
      });
      return;
    }

    try {
      await _flutterWhisperkitApple.startRecording(
        config: TranscriptionConfig(
          language: 'en',
          modelSize: 'medium',
          enableVAD: true,
        ),
      );

      _transcriptionSubscription = _flutterWhisperkitApple.onTranscriptionProgress.listen(
        (result) {
          setState(() {
            _transcriptionResult = result.text;
          });
        },
        onError: (error) {
          setState(() {
            _transcriptionResult = 'Error during transcription: $error';
            _isRecording = false;
          });
        },
      );

      setState(() {
        _isRecording = true;
        _transcriptionResult = 'Listening...';
      });
    } catch (e) {
      setState(() {
        _transcriptionResult = 'Failed to start recording: $e';
      });
    }
  }

  Future<void> _stopRecording() async {
    try {
      final result = await _flutterWhisperkitApple.stopRecording();
      _transcriptionSubscription?.cancel();
      _transcriptionSubscription = null;

      setState(() {
        _isRecording = false;
        _transcriptionResult = result.text;
      });
    } catch (e) {
      setState(() {
        _isRecording = false;
        _transcriptionResult = 'Failed to stop recording: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('WhisperKit Real-time Example'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _transcriptionResult,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _toggleRecording,
                  child: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

## Advanced Configuration Example

This example shows how to use advanced configuration options:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_whisperkit_apple/flutter_whisperkit_apple.dart';

class AdvancedTranscriptionScreen extends StatefulWidget {
  const AdvancedTranscriptionScreen({Key? key}) : super(key: key);

  @override
  State<AdvancedTranscriptionScreen> createState() => _AdvancedTranscriptionScreenState();
}

class _AdvancedTranscriptionScreenState extends State<AdvancedTranscriptionScreen> {
  final _flutterWhisperkitApple = FlutterWhisperkitApple();
  String _transcriptionResult = '';
  bool _isTranscribing = false;
  
  // Configuration options
  String _selectedLanguage = 'en';
  String _selectedModelSize = 'medium';
  bool _enableVAD = true;
  bool _enablePunctuation = true;
  bool _enableFormatting = true;
  bool _enableTimestamps = false;
  
  final List<String> _availableLanguages = [
    'en', 'fr', 'de', 'es', 'it', 'ja', 'zh', 'ru'
  ];
  
  final List<String> _availableModelSizes = [
    'tiny', 'small', 'medium', 'large'
  ];

  @override
  void initState() {
    super.initState();
    _initializeWhisperKit();
  }

  Future<void> _initializeWhisperKit() async {
    try {
      await _flutterWhisperkitApple.initializeWhisperKit();
    } catch (e) {
      setState(() {
        _transcriptionResult = 'Failed to initialize WhisperKit: $e';
      });
    }
  }

  Future<void> _startTranscription() async {
    if (_isTranscribing) return;

    final hasPermission = await _flutterWhisperkitApple.requestAudioPermission();
    if (!hasPermission) {
      setState(() {
        _transcriptionResult = 'Microphone permission denied';
      });
      return;
    }

    setState(() {
      _isTranscribing = true;
      _transcriptionResult = 'Transcribing...';
    });

    try {
      // Create configuration with selected options
      final config = TranscriptionConfig(
        language: _selectedLanguage,
        modelSize: _selectedModelSize,
        enableVAD: _enableVAD,
        enablePunctuation: _enablePunctuation,
        enableFormatting: _enableFormatting,
        enableTimestamps: _enableTimestamps,
        vadFallbackTimeout: 3000,
      );

      await _flutterWhisperkitApple.startRecording(config: config);
      
      _flutterWhisperkitApple.onTranscriptionProgress.listen(
        (result) {
          setState(() {
            _transcriptionResult = result.text;
          });
        },
        onError: (error) {
          setState(() {
            _transcriptionResult = 'Error during transcription: $error';
            _isTranscribing = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _isTranscribing = false;
        _transcriptionResult = 'Failed to start transcription: $e';
      });
    }
  }

  Future<void> _stopTranscription() async {
    try {
      final result = await _flutterWhisperkitApple.stopRecording();
      setState(() {
        _isTranscribing = false;
        _transcriptionResult = result.text;
      });
    } catch (e) {
      setState(() {
        _isTranscribing = false;
        _transcriptionResult = 'Failed to stop transcription: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Transcription'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Configuration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            // Language selection
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Language'),
              value: _selectedLanguage,
              items: _availableLanguages.map((lang) {
                return DropdownMenuItem(
                  value: lang,
                  child: Text(lang),
                );
              }).toList(),
              onChanged: _isTranscribing ? null : (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
              },
            ),
            
            // Model size selection
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Model Size'),
              value: _selectedModelSize,
              items: _availableModelSizes.map((size) {
                return DropdownMenuItem(
                  value: size,
                  child: Text(size),
                );
              }).toList(),
              onChanged: _isTranscribing ? null : (value) {
                setState(() {
                  _selectedModelSize = value!;
                });
              },
            ),
            
            // Toggle options
            SwitchListTile(
              title: const Text('Enable Voice Activity Detection'),
              value: _enableVAD,
              onChanged: _isTranscribing ? null : (value) {
                setState(() {
                  _enableVAD = value;
                });
              },
            ),
            
            SwitchListTile(
              title: const Text('Enable Punctuation'),
              value: _enablePunctuation,
              onChanged: _isTranscribing ? null : (value) {
                setState(() {
                  _enablePunctuation = value;
                });
              },
            ),
            
            SwitchListTile(
              title: const Text('Enable Formatting'),
              value: _enableFormatting,
              onChanged: _isTranscribing ? null : (value) {
                setState(() {
                  _enableFormatting = value;
                });
              },
            ),
            
            SwitchListTile(
              title: const Text('Enable Timestamps'),
              value: _enableTimestamps,
              onChanged: _isTranscribing ? null : (value) {
                setState(() {
                  _enableTimestamps = value;
                });
              },
            ),
            
            const SizedBox(height: 24),
            
            // Transcription result
            const Text('Transcription Result', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              width: double.infinity,
              child: Text(_transcriptionResult.isEmpty ? 'No transcription yet' : _transcriptionResult),
            ),
            
            const SizedBox(height: 24),
            
            // Control buttons
            Center(
              child: ElevatedButton(
                onPressed: _isTranscribing ? _stopTranscription : _startTranscription,
                child: Text(_isTranscribing ? 'Stop Transcription' : 'Start Transcription'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## For More Examples

Check out the example application included in the plugin repository for more detailed examples and implementation patterns.
