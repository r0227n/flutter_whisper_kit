# Flutter WhisperKit Platform Interface

This package provides the platform interface for the Flutter WhisperKit plugin. It defines the API that platform-specific implementations must implement to support cross-platform speech recognition using WhisperKit.

## Usage

This package is not intended to be used directly. Instead, use the `flutter_whisperkit` package which provides a user-friendly API that delegates to this platform interface.

## Platform Interface

The platform interface defines the following key components:

### FlutterWhisperkitPlatform

An abstract class that defines the interface for platform-specific implementations:

```dart
abstract class FlutterWhisperkitPlatform extends PlatformInterface {
  Future<String?> getPlatformVersion();
  Future<String?> createWhisperKit(String? model, String? modelRepo);
  Future<String?> loadModel(String? variant, {String? modelRepo, bool? redownload, String? modelDownloadPath});
  Future<String?> transcribeFromFile(String filePath, {DecodingOptions options});
  Future<String?> startRecording({DecodingOptions options, bool loop = false});
  Future<String?> stopRecording({bool loop = false});
  Stream<TranscriptionResult> get transcriptionStream;
  Stream<Progress> get modelProgressStream;
}
```

### DecodingOptions

A class that encapsulates configuration options for the transcription process:

```dart
class DecodingOptions {
  bool verbose;
  DecodingTask task;
  String? language;
  double temperature;
  // Additional configuration properties...
}
```

## Model Loading

The platform interface provides a method for loading WhisperKit models:

```dart
Future<String?> loadModel(
  String? variant, {
  String? modelRepo,
  bool? redownload,
  String? modelDownloadPath,
});
```

Where:
- `variant`: The model variant to load (e.g., 'tiny-en', 'base', 'small', 'medium', 'large-v2')
- `modelRepo`: The repository to download the model from (default: 'argmaxinc/whisperkit-coreml')
- `redownload`: Whether to force redownload the model even if it exists locally
- `modelDownloadPath`: Custom path where the model should be downloaded

## Implementation

Platform-specific implementations should extend `FlutterWhisperkitPlatform` and register themselves using:

```dart
static void registerWith() {
  FlutterWhisperkitPlatform.instance = MyPlatformImplementation();
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker](https://github.com/r0227n/flutter_whisperkit/issues).
