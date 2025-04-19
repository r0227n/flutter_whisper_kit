# Flutter WhisperKit Apple

A Flutter plugin for WhisperKit on iOS and macOS platforms.

## Features

- Initialize WhisperKit with custom configuration
- Transcribe audio files
- Stream real-time transcription
- Get available WhisperKit models

## Getting Started

### Prerequisites

- iOS 16.0+ / macOS 13.0+
- Flutter 3.0.0+
- Dart 3.0.0+

### Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_whisperkit_apple: ^0.0.1
```

### iOS Setup

Update your `Info.plist` to include microphone permissions:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access for speech recognition</string>
```

### macOS Setup

Update your `Info.plist` to include microphone permissions:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access for speech recognition</string>
```

Add the following to your `DebugProfile.entitlements` and `Release.entitlements`:

```xml
<key>com.apple.security.device.audio-input</key>
<true/>
```

## Usage

### Initialize WhisperKit

```dart
import 'package:flutter_whisperkit_apple/flutter_whisperkit_apple.dart';

final flutterWhisperkitApple = FlutterWhisperkitApple();

// Initialize with default configuration
await flutterWhisperkitApple.initializeWhisperKit();

// Or initialize with custom configuration
await flutterWhisperkitApple.initializeWhisperKit(
  config: WhisperKitConfig(
    modelPath: 'path/to/model',
    enableVAD: true,
    vadFallbackSilenceThreshold: 3000,
    vadTemperature: 0.5,
    enableLanguageIdentification: true,
  ),
);
```

### Transcribe Audio File

```dart
final result = await flutterWhisperkitApple.transcribeAudioFile('path/to/audio.wav');
print('Transcription: ${result.text}');
```

### Stream Real-time Transcription

```dart
// Start streaming
await flutterWhisperkitApple.startStreamingTranscription();

// Listen for interim results
flutterWhisperkitApple.onInterimTranscriptionResult.listen((result) {
  print('Interim transcription: ${result.text}');
});

// Listen for progress updates
flutterWhisperkitApple.onTranscriptionProgress.listen((progress) {
  print('Progress: ${progress * 100}%');
});

// Stop streaming
final finalResult = await flutterWhisperkitApple.stopStreamingTranscription();
print('Final transcription: ${finalResult.text}');
```

### Get Available Models

```dart
final models = await flutterWhisperkitApple.getAvailableModels();
print('Available models: $models');
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.
