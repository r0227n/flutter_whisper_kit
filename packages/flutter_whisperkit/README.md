# Flutter WhisperKit

A Flutter plugin that provides on-device speech recognition capabilities using WhisperKit.

## Features

- High-quality on-device speech recognition
- No data sent to external servers
- Support for multiple model sizes (tiny to large)
- File-based audio transcription
- Real-time microphone transcription
- Progress tracking for model downloads
- Configurable transcription options

## Installation

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_whisperkit: latest
```

## Usage

### Basic Usage

```dart
import 'package:flutter_whisperkit/flutter_whisperkit.dart';

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
import 'package:flutter_whisperkit/flutter_whisperkit.dart';

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

## Model Management

WhisperKit requires models to perform speech recognition. The plugin provides functionality to load these models:

```dart
import 'package:flutter_whisperkit/flutter_whisperkit.dart';

// Create an instance of the plugin
final whisperKit = FlutterWhisperKit();

// Set storage location (optional)
whisperKit.setModelStorageLocation(ModelStorageLocation.packageDirectory);

// Load a model with progress tracking
await whisperKit.loadModel(
  variant: 'tiny-en',
  modelRepo: 'argmaxinc/whisperkit-coreml',
  redownload: false,
  onProgress: (progress) {
    print('Download progress: ${(progress * 100).toStringAsFixed(1)}%');
  },
);
```

## Available Models

WhisperKit supports various model sizes:

- `tiny-en`: Smallest model, English only
- `tiny`: Small model, multilingual
- `base-en`: Base model, English only
- `base`: Base model, multilingual
- `small-en`: Small model, English only
- `small`: Small model, multilingual
- `medium-en`: Medium model, English only
- `medium`: Medium model, multilingual
- `large-v2`: Large model, multilingual
- `large-v3`: Latest large model, multilingual

Smaller models are faster but less accurate, while larger models are more accurate but require more resources.

## Platform Support

Currently, Flutter WhisperKit supports:

- iOS
- macOS

Android support is planned for future releases.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

