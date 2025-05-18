# flutter_whisper_kit

A Flutter plugin that provides on-device speech recognition capabilities using [WhisperKit].

## Features

### 🧠 [DeepWiki]

- High-quality on-device speech recognition
- No data sent to external servers
- Support for multiple model sizes (tiny to large)
- File-based audio transcription
- Real-time microphone transcription
- Progress tracking for model downloads
- Configurable transcription options

## Platform Support

| Platform | Minimum Version |
|----------|----------------|
| iOS      | 16.0+         |
| macOS    | 13.0+         |

`Android` support is planned for future releases.

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


<!-- URLs -->
[WhisperKit]: https://github.com/argmaxinc/WhisperKit
[DeepWiki]: https://deepwiki.com/r0227n/flutter_whisper_kit
