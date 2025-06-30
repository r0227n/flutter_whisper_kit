# flutter_whisper_kit

[![pub package](https://img.shields.io/pub/v/flutter_whisper_kit.svg)](https://pub.dev/packages/flutter_whisper_kit)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A Flutter plugin that provides on-device speech recognition capabilities using [WhisperKit](https://github.com/argmaxinc/WhisperKit). Achieve high-quality speech-to-text transcription while maintaining privacy.

[日本語 README](./doc/README_ja.md)

## Features

- 🔒 **Complete On-Device Processing** - No data is sent to external servers
- 🎯 **High-Accuracy Speech Recognition** - High-quality transcription with Whisper models
- 📱 **Multiple Model Sizes** - Choose from tiny to large based on your needs
- 🎙️ **Real-Time Transcription** - Convert microphone audio in real-time
- 📁 **File-Based Transcription** - Support for audio file transcription
- 📊 **Progress Tracking** - Monitor model download progress
- 🌍 **Multi-Language Support** - Supports 100+ languages
- ⚡ **Type-Safe Error Handling** - Safe error handling with Result type

## Platform Support

| Platform | Minimum Version | Status                        |
| -------- | --------------- | ----------------------------- |
| iOS      | 16.0+           | ✅ Fully Supported            |
| macOS    | 13.0+           | ✅ Fully Supported            |
| Android  | -               | 🚧 Planned for Future Release |

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_whisper_kit: ^0.2.0
```

### iOS Configuration

Add these permissions to your iOS app's `ios/Runner/Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access to record audio for speech transcription</string>
<key>NSDownloadsFolderUsageDescription</key>
<string>This app needs to access your Downloads folder to store WhisperKit models</string>
<key>NSDocumentsFolderUsageDescription</key>
<string>This app needs to access your Documents folder to store WhisperKit models</string>
```

### macOS Configuration

Add these permissions to your macOS app's `macos/Runner/Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access to record audio for speech transcription</string>
<key>NSLocalNetworkUsageDescription</key>
<string>This app needs to access your local network to download WhisperKit models</string>
<key>NSDownloadsFolderUsageDescription</key>
<string>This app needs to access your Downloads folder to store WhisperKit models</string>
<key>NSDocumentsFolderUsageDescription</key>
<string>This app needs to access your Documents folder to store WhisperKit models</string>
```

Also, ensure your macOS deployment target is set to 13.0 or higher in `macos/Runner.xcodeproj/project.pbxproj`:

```
MACOSX_DEPLOYMENT_TARGET = 13.0;
```

## Usage

### Basic Usage

```dart
import 'package:flutter_whisper_kit/flutter_whisper_kit.dart';

// Create an instance of the plugin
final whisperKit = FlutterWhisperKit();

// Load a model
final result = await whisperKit.loadModel(
  'tiny',  // Model size: tiny, base, small, medium, large-v2, large-v3
  modelRepo: 'argmaxinc/whisperkit-coreml',
);
print('Model loaded: $result');

// Transcribe from audio file
final transcription = await whisperKit.transcribeFromFile(
  '/path/to/audio/file.mp3',
  options: DecodingOptions(
    task: DecodingTask.transcribe,
    language: 'en',  // Specify language (null for auto-detection)
  ),
);
print('Transcription: ${transcription?.text}');
```

### Real-Time Transcription

```dart
// Listen to transcription stream
whisperKit.transcriptionStream.listen((transcription) {
  print('Real-time transcription: ${transcription.text}');
});

// Start recording
await whisperKit.startRecording(
  options: DecodingOptions(
    task: DecodingTask.transcribe,
    language: 'en',
  ),
);

// Stop recording
final finalTranscription = await whisperKit.stopRecording();
print('Final transcription: ${finalTranscription?.text}');
```

### Error Handling (Result Type)

Since v0.2.0, Result type APIs have been added for safer error handling:

```dart
// Load model with Result type
final loadResult = await whisperKit.loadModelWithResult(
  'tiny',
  modelRepo: 'argmaxinc/whisperkit-coreml',
);

loadResult.when(
  success: (modelPath) {
    print('Model loaded successfully: $modelPath');
  },
  failure: (error) {
    print('Model loading failed: ${error.message}');
    // Handle errors by error code
    switch (error.code) {
      case WhisperKitErrorCode.modelNotFound:
        // Handle model not found
        break;
      case WhisperKitErrorCode.networkError:
        // Handle network error
        break;
      default:
        // Handle other errors
    }
  },
);

// Transcribe with Result type
final transcribeResult = await whisperKit.transcribeFileWithResult(
  audioPath,
  options: DecodingOptions(language: 'en'),
);

// Handle success/failure with fold method
final text = transcribeResult.fold(
  onSuccess: (result) => result?.text ?? 'No result',
  onFailure: (error) => 'Error: ${error.message}',
);
```

### Model Management

```dart
// Fetch available models
final models = await whisperKit.fetchAvailableModels(
  modelRepo: 'argmaxinc/whisperkit-coreml',
);

// Get recommended models
final recommended = await whisperKit.recommendedModels();
print('Recommended model: ${recommended?.defaultModel}');

// Download model with progress
await whisperKit.download(
  variant: 'base',
  repo: 'argmaxinc/whisperkit-coreml',
  onProgress: (progress) {
    print('Download progress: ${(progress.fractionCompleted * 100).toStringAsFixed(1)}%');
  },
);

// Monitor model progress stream
whisperKit.modelProgressStream.listen((progress) {
  print('Model progress: ${progress.fractionCompleted * 100}%');
});
```

### Language Detection

```dart
// Detect language from audio file
final detection = await whisperKit.detectLanguage(audioPath);
print('Detected language: ${detection?.language}');
print('Confidence: ${detection?.probabilities[detection.language]}');
```

### Advanced Configuration

```dart
// Custom decoding options
final options = DecodingOptions(
  verbose: true,                        // Enable verbose logging
  task: DecodingTask.transcribe,       // transcribe or translate
  language: 'en',                       // Language code (null for auto-detection)
  temperature: 0.0,                     // Sampling temperature (0.0-1.0)
  temperatureFallbackCount: 5,          // Temperature fallback count
  wordTimestamps: true,                 // Enable word timestamps
  chunkingStrategy: ChunkingStrategy.vad, // Chunking strategy
);

// Detailed transcription results
final result = await whisperKit.transcribeFromFile(audioPath, options: options);
if (result != null) {
  print('Text: ${result.text}');
  print('Language: ${result.language}');

  // Segment information
  for (final segment in result.segments) {
    print('Segment ${segment.id}: ${segment.text}');
    print('  Start: ${segment.startTime}s, End: ${segment.endTime}s');

    // Word timing information (if wordTimestamps: true)
    for (final word in segment.words) {
      print('  Word: ${word.word} (${word.start}s - ${word.end}s)');
    }
  }
}
```

## Model Size Selection

Choose the appropriate model size based on your use case:

| Model    | Size   | Speed     | Accuracy           | Use Case                                |
| -------- | ------ | --------- | ------------------ | --------------------------------------- |
| tiny     | ~39MB  | Very Fast | Low                | Real-time processing, battery-conscious |
| tiny-en  | ~39MB  | Very Fast | Low (English only) | English-only real-time processing       |
| base     | ~145MB | Fast      | Medium             | Balanced performance                    |
| small    | ~466MB | Medium    | High               | When higher accuracy is needed          |
| medium   | ~1.5GB | Slow      | Higher             | When even higher accuracy is needed     |
| large-v2 | ~2.9GB | Very Slow | Very High          | When maximum accuracy is needed         |
| large-v3 | ~2.9GB | Very Slow | Highest            | Latest and highest accuracy             |

## Example App

The `example` folder contains a sample app that demonstrates all features:

```bash
cd packages/flutter_whisper_kit/example
flutter run
```

## Troubleshooting

### Build errors on iOS/macOS

1. Check minimum deployment target (iOS 16.0+, macOS 13.0+)
2. Update to the latest Xcode
3. Run `pod install`

### Model download fails

1. Check network connection
2. Ensure sufficient storage space
3. Try `redownload: true` option

### Low transcription accuracy

1. Try a larger model size
2. Explicitly specify language with `language` parameter
3. Adjust `temperature` parameter (0.0 for more deterministic, 1.0 for more creative)

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

## Acknowledgments

This plugin is based on [WhisperKit](https://github.com/argmaxinc/WhisperKit). Thanks to the Argmax Inc. team for providing this excellent library.
