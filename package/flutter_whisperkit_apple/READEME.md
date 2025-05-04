# Flutter WhisperKit Apple

A Flutter plugin that provides integration with WhisperKit, an on-device speech recognition framework for Apple platforms (iOS and macOS).

## Features

- High-quality speech transcription on iOS and macOS devices
- Support for file-based transcription and real-time streaming from microphone
- Word-level timestamps for precise audio alignment
- Voice activity detection for improved transcription quality
- Multiple model sizes to balance accuracy and performance
- Support for multiple languages

## Requirements

- iOS 14.0 or later
- macOS 11.0 or later
- Flutter 3.0.0 or later

## Installation

Add this to your package's pubspec.yaml file:

```yaml
dependencies:
  flutter_whisperkit_apple: ^0.1.0
```

## Usage

### Initialization

```dart
import 'package:flutter_whisperkit/flutter_whisperkit.dart';

// Initialize WhisperKit
final whisperKit = FlutterWhisperKit();
```

### Loading a Model

```dart
// Load a model with progress tracking
await whisperKit.loadModel(
  variant: 'large-v3',
  onProgress: (progress) {
    print('Download progress: ${progress * 100}%');
  },
);
```

### Transcribing an Audio File

```dart
// Configure transcription options
final options = DecodingOptions(
  task: DecodingTask.transcribe,
  language: 'en',
  temperature: 0.0,
  wordTimestamps: true,
);

// Transcribe from a file
final transcription = await whisperKit.transcribeFromFile(
  'path/to/audio.mp3',
  options: options,
);

print(transcription);
```

### Real-time Transcription

```dart
// Start recording with streaming transcription
await whisperKit.startRecording(
  options: DecodingOptions(
    task: DecodingTask.transcribe,
    language: 'en',
  ),
);

// Listen to transcription stream
final subscription = whisperKit.transcriptionStream.listen((transcription) {
  print('Transcription: $transcription');
});

// Stop recording when done
await whisperKit.stopRecording();
subscription.cancel();
```

## Model Variants

WhisperKit supports various model sizes:

| Variant   | Size    | Languages | Performance |
|-----------|---------|-----------|-------------|
| tiny-en   | ~75MB   | English   | Fastest     |
| tiny      | ~75MB   | Multilingual | Fast     |
| base      | ~150MB  | Multilingual | Fast     |
| small     | ~500MB  | Multilingual | Balanced |
| medium    | ~1.5GB  | Multilingual | Good     |
| large-v2  | ~3GB    | Multilingual | Best     |
| large-v3  | ~3GB    | Multilingual | Best     |

## Implementation Details

This plugin uses [Pigeon](https://pub.dev/packages/pigeon) to generate type-safe communication between Flutter and native code. The native implementation interfaces with the WhisperKit framework to provide speech recognition capabilities.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- [WhisperKit](https://github.com/argmaxinc/WhisperKit) - The underlying speech recognition framework
- [Argmax, Inc.](https://www.takeargmax.com) - Creators of WhisperKit
