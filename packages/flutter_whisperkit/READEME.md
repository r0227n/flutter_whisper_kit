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
  Future<String?> loadModel(String? variant, {String? modelRepo, bool? redownload, int? storageLocation});
  Future<String?> transcribeFromFile(String filePath, {DecodingOptions options});
  Future<String?> startRecording({DecodingOptions options, bool loop = false});
  Future<String?> stopRecording({bool loop = false});
  Stream<String> get transcriptionStream;
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

### ModelStorageLocation

An enum defining where models are stored:

```dart
enum ModelStorageLocation {
  packageDirectory,
  userFolder
}
```

## Implementation

Platform-specific implementations should extend `FlutterWhisperkitPlatform` and register themselves using:

```dart
static void registerWith() {
  FlutterWhisperkitPlatform.instance = MyPlatformImplementation();
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker](https://github.com/r0227n/flutter_whisperkit/issues).
