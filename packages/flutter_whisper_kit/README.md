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

## Demo

https://github.com/user-attachments/assets/4a405460-2eb9-4485-a467-24b8ebf6bee7

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

## Platform Support

Currently, Flutter WhisperKit supports:

- iOS 16.0+
- macOS 13.0+

Android support is planned for future releases.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

