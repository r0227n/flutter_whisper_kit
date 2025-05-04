# Flutter WhisperKit

Flutter WhisperKit is a Flutter plugin that provides integration with [WhisperKit](https://github.com/argmaxinc/WhisperKit), an on-device speech recognition framework. This plugin enables Flutter developers to incorporate high-quality speech transcription capabilities in their applications without writing native code.

## Features

- Load and manage WhisperKit models of various sizes and language capabilities
- Transcribe audio from files with configurable options
- Perform real-time audio transcription with streaming results
- Configure model storage locations and transcription parameters
- Support for iOS and macOS platforms

## Getting Started

### Installation

Add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  flutter_whisperkit: ^0.1.0
```

### Basic Usage

```dart
import 'package:flutter_whisperkit/flutter_whisperkit.dart';

// Initialize WhisperKit
final whisperKit = FlutterWhisperKit();

// Load a model
await whisperKit.loadModel(variant: 'large-v3');

// Transcribe from a file
final transcription = await whisperKit.transcribeFromFile('path/to/audio.mp3');
print(transcription);

// Start real-time transcription
await whisperKit.startRecording();

// Listen to transcription stream
whisperKit.transcriptionStream.listen((transcription) {
  print(transcription);
});

// Stop recording
await whisperKit.stopRecording();
```

## Platform Support

| Platform | Support |
|----------|---------|
| iOS      | ✅      |
| macOS    | ✅      |
| Android  | ❌      |
| Windows  | ❌      |
| Linux    | ❌      |
| Web      | ❌      |

## Models

Flutter WhisperKit supports various WhisperKit models:

- tiny-en
- tiny
- base
- small
- medium
- large-v2
- large-v3

## Documentation

For more detailed documentation, please refer to the package-specific READMEs:

- [flutter_whisperkit](package/flutter_whisperkit/READEME.md) - Platform interface and common code
- [flutter_whisperkit_apple](package/flutter_whisperkit_apple/READEME.md) - iOS and macOS implementation

## License

This project is licensed under the MIT License - see the LICENSE file for details.
