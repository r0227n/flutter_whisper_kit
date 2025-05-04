# Flutter WhisperKit Apple

A Flutter plugin for Apple platforms (iOS and macOS) that provides access to WhisperKit's on-device speech recognition capabilities.

## Features

- On-device speech recognition using WhisperKit
- Support for iOS and macOS platforms
- Model loading and management

## Getting Started

### Installation

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_whisperkit_apple: ^0.1.0
```

### Usage

#### Basic Usage

```dart
import 'package:flutter_whisperkit_apple/flutter_whisperkit_apple.dart';

// Create an instance of the plugin
final flutterWhisperkitApple = FlutterWhisperkitApple();

// Load a model
final result = await flutterWhisperkitApple.loadModel(
  'tiny-en',
  modelRepo: 'argmaxinc/whisperkit-coreml',
  redownload: false,
);
print('Model loaded: $result');
```

## Loading Models

WhisperKit requires models to perform speech recognition. The plugin provides functionality to load these models with customizable download paths.

### Using the Model Loader

```dart
import 'package:flutter_whisperkit_apple/flutter_whisperkit_apple.dart';
import 'package:flutter_whisperkit_apple/model_loader.dart';

// Create an instance of the model loader
final modelLoader = WhisperKitModelLoader();

// Load a model with a custom download path
try {
  final result = await modelLoader.loadModel(
    variant: 'tiny-en',
    modelRepo: 'argmaxinc/whisperkit-coreml',
    redownload: false,
    modelDownloadPath: '/custom/path/to/models',
    onProgress: (progress) {
      print('Download progress: ${(progress * 100).toStringAsFixed(1)}%');
    },
  );
  print('Model loaded: $result');
} catch (e) {
  print('Error loading model: $e');
}
```

### Model Download Path

You can specify a custom path where the model should be downloaded:

```dart
// Load model with a custom download path
final result = await flutterWhisperkitApple.loadModel(
  'tiny-en',
  modelRepo: 'argmaxinc/whisperkit-coreml',
  redownload: false,
  modelDownloadPath: '/custom/path/to/models',
);
```

If no custom path is provided, the model will be stored in the default location, which is:
- iOS: Application Support directory
- macOS: Application Support directory

## Error Codes

The plugin uses the following error code system to report errors:

| Error Code | Category | Description |
|------------|----------|-------------|
| **1000-1999** | **Model Initialization and Loading** | **Errors related to model initialization and loading** |
| 1001 | Model Initialization | Model variant is required |
| 1002 | Model Initialization | Failed to initialize WhisperKit |
| 1003 | Model Loading | Failed to get model folder |
| 1005 | Model Loading | Failed to download model |
| **2000-2999** | **Transcription and Processing** | **Errors related to audio transcription and processing** |
| 2001 | Transcription | WhisperKit instance not initialized. Call loadModel first |
| 2002 | Transcription | Failed to serialize transcription result |
| 2003 | Transcription | Failed to create JSON string from transcription result |
| 2004 | Transcription | Transcription result is nil |
| **3000-3999** | **Recording and Audio Capture** | **Errors related to recording functionality** |
| 3001 | Recording | WhisperKit instance not initialized. Call loadModel first |
| 3002 | Recording | Microphone access was not granted |
| 3003 | Recording | Not enough audio data for transcription |
| **4000-4999** | **File System and Permissions** | **Errors related to file access and permissions** |
| 4001 | File System | Cannot write to model directory |
| 4002 | File System | Audio file does not exist at specified path |
| 4003 | File System | No read permission for audio file at specified path |
| **5000-5999** | **Configuration and Parameters** | **Errors related to configuration and input parameters** |
| 5001 | Parameters | File path is required |

### Error Handling Example

```dart
try {
  final result = await whisperKitApple.transcribeFromFile(filePath);
  print('Transcription: $result');
} catch (e) {
  if (e is PlatformException) {
    final code = e.code;
    if (code.startsWith('1')) {
      print('Model error: ${e.message}');
      // Handle model errors
    } else if (code.startsWith('2')) {
      print('Transcription error: ${e.message}');
      // Handle transcription errors
    } else if (code.startsWith('4')) {
      print('File system error: ${e.message}');
      // Handle file errors
    }
  }
}
```

## Implementation Details

The model loading functionality is implemented in Swift for optimal performance and direct access to WhisperKit's APIs. The implementation:

1. Configures WhisperKit with compute options
2. Checks if the model is available locally
3. Downloads the model if not available locally
4. Loads and prewarming the model
5. Updates application state during the process

## References

- [WhisperKit GitHub Repository](https://github.com/argmaxinc/WhisperKit)
- [Flutter Plugin Development](https://docs.flutter.dev/packages-and-plugins/developing-packages)
