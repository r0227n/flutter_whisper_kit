# flutter_whisper_kit

A Flutter plugin that provides on-device speech recognition capabilities using WhisperKit.

## Features

- High-quality on-device speech recognition
- No data sent to external servers
- Support for multiple model sizes (tiny to large)
- File-based audio transcription
- Real-time microphone transcription
- Progress tracking for model downloads
- Configurable transcription options
- Language detection
- Word-level timestamps
- Voice activity detection (VAD) for chunking audio
- Model recommendations based on device capabilities

## Demo

![Demo](https://github.com/user-attachments/assets/4a405460-2eb9-4485-a467-24b8ebf6bee7)

## Installation

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_whisper_kit: latest
```

## Usage

### Basic Usage

```dart
import 'package:flutter_whisper_kit/flutter_whisper_kit.dart';

// Create an instance of the plugin
final whisperKit = FlutterWhisperKit();

// Load a model
final result = await whisperKit.loadModel(
  variant: 'tiny-en',
  modelRepo: 'argmaxinc/whisperkit-coreml',
  redownload: false,
);
print('Model loaded: $result');

// Transcribe from a file
final transcription = await whisperKit.transcribeFromFile(
  '/path/to/audio/file.mp3',
  options: DecodingOptions(
    task: DecodingTask.transcribe,
    language: 'en',
  ),
);
print('Transcription: $transcription');
```

### Real-time Transcription

```dart
import 'package:flutter_whisper_kit/flutter_whisper_kit.dart';

// Create an instance of the plugin
final whisperKit = FlutterWhisperKit();

// Load a model
await whisperKit.loadModel(variant: 'tiny-en');

// Start listening to the transcription stream
whisperKit.transcriptionStream.listen((transcription) {
  print('Real-time transcription: $transcription');
});

// Start recording
await whisperKit.startRecording(
  options: DecodingOptions(
    task: DecodingTask.transcribe,
    language: 'en',
  ),
);

// Stop recording after some time
await Future.delayed(Duration(seconds: 10));
final finalTranscription = await whisperKit.stopRecording();
print('Final transcription: $finalTranscription');
```

### Model Recommendations

```dart
// Get recommended models for the current device
final modelSupport = await whisperKit.recommendedModels();
print('Default model: ${modelSupport.defaultModel}');
print('Supported models: ${modelSupport.supported}');
print('Disabled models: ${modelSupport.disabled}');

// Get recommended models from remote configuration
final remoteModelSupport = await whisperKit.recommendedRemoteModels();
```

### Language Detection

```dart
// Detect the language in an audio file
final languageResult = await whisperKit.detectLanguage('/path/to/audio.mp3');
print('Detected language: ${languageResult.language}');
print('Language probabilities: ${languageResult.probabilities}');
```

### Tracking Model Download Progress

```dart
// Load a model with progress tracking
whisperKit.loadModel(
  'medium',
  onProgress: (progress) {
    print('Download progress: ${progress.fractionCompleted * 100}%');
    print('${progress.completed}/${progress.total} units completed');
  },
);

// Alternatively, listen to the progress stream
whisperKit.modelProgressStream.listen((progress) {
  print('Download progress: ${progress.fractionCompleted * 100}%');
});
```

## Decoding Options

The plugin provides extensive customization through the `DecodingOptions` class:

```dart
DecodingOptions options = DecodingOptions(
  // Task type: transcribe or translate
  task: DecodingTask.transcribe,
  
  // Target language (ISO 639-1 code)
  language: 'en',
  
  // Temperature for sampling (0.0 to 1.0)
  temperature: 0.0,
  
  // Number of temperature fallbacks
  temperatureFallbackCount: 5,
  
  // Sample length for processing
  sampleLength: 224,
  
  // Whether to use prefill prompt
  usePrefillPrompt: true,
  
  // Whether to use prefill cache
  usePrefillCache: true,
  
  // Whether to automatically detect language
  detectLanguage: true,
  
  // Whether to skip special tokens
  skipSpecialTokens: true,
  
  // Whether to include timestamps
  withoutTimestamps: false,
  
  // Whether to generate word-level timestamps
  wordTimestamps: true,
  
  // Timestamps for clipping audio
  clipTimestamps: [0.0],
  
  // Number of concurrent workers
  concurrentWorkerCount: 4,
  
  // Strategy for chunking audio
  chunkingStrategy: ChunkingStrategy.vad,
);
```

## Available Models

WhisperKit supports various model sizes:

| Model | Size | Languages | Performance |
|-------|------|-----------|-------------|
| tiny-en | ~75MB | English only | Fastest, lowest accuracy |
| tiny | ~75MB | Multilingual | Fast, low accuracy |
| base-en | ~142MB | English only | Good balance for English |
| base | ~142MB | Multilingual | Good balance for multiple languages |
| small-en | ~466MB | English only | Better accuracy, slower |
| small | ~466MB | Multilingual | Better accuracy for multiple languages |
| medium-en | ~1.5GB | English only | High accuracy, slower |
| medium | ~1.5GB | Multilingual | High accuracy for multiple languages |
| large-v2 | ~3GB | Multilingual | Highest accuracy, slowest |

## Platform Support

Currently, Flutter WhisperKit supports:

- iOS 16.0+
- macOS 13.0+

Android support is planned for future releases.

## WhisperKit Version

This plugin uses WhisperKit v0.12.0.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

