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

// Initialize WhisperKit
await flutterWhisperkitApple.createWhisperKit('tiny-en', 'argmaxinc/whisperkit-coreml');

// Load a model
final result = await flutterWhisperkitApple.loadModel(
  'tiny-en',
  modelRepo: 'argmaxinc/whisperkit-coreml',
  redownload: false,
);
print('Model loaded: $result');
```

## Loading Models

WhisperKit requires models to perform speech recognition. The plugin provides functionality to load these models either from the package directory or from a user folder.

### Using the Model Loader

```dart
import 'package:flutter_whisperkit_apple/flutter_whisperkit_apple.dart';
import 'package:flutter_whisperkit_apple/model_loader.dart';

// Create an instance of the model loader
final modelLoader = WhisperKitModelLoader();

// Set storage location (optional, defaults to package directory)
modelLoader.setStorageLocation(ModelStorageLocation.packageDirectory);

// Load a model
try {
  final result = await modelLoader.loadModel(
    variant: 'tiny-en',
    modelRepo: 'argmaxinc/whisperkit-coreml',
    redownload: false,
    onProgress: (progress) {
      print('Download progress: ${(progress * 100).toStringAsFixed(1)}%');
    },
  );
  print('Model loaded: $result');
} catch (e) {
  print('Error loading model: $e');
}
```

### Model Storage Options

The plugin supports two storage locations for WhisperKit models:

1. **Package Directory** (default): Models are stored within the application's package directory.
   - Advantages: Models are contained within the application, better security, no permission issues
   - Disadvantages: Uses application storage space, models not shared between applications

2. **User Folder**: Models are stored in user-accessible locations like Documents or Downloads folders.
   - Advantages: Models can be shared between applications, models persist beyond application lifecycle
   - Disadvantages: Requires permission management, risk of user accidentally deleting models

```dart
// Set storage location to package directory (default)
modelLoader.setStorageLocation(ModelStorageLocation.packageDirectory);

// Set storage location to user folder
modelLoader.setStorageLocation(ModelStorageLocation.userFolder);
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

## Error Handling

```dart
try {
  final result = await modelLoader.loadModel(variant: 'tiny-en');
  print('Model loaded: $result');
} catch (e) {
  if (e is PlatformException) {
    print('Platform error: ${e.message}');
    // Handle platform-specific errors
  } else {
    print('Error loading model: $e');
    // Handle other errors
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

