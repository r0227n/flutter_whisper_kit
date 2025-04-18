# WhisperKit Integration with Flutter

This document provides detailed information on integrating WhisperKit with Flutter applications using the Flutter WhisperKit Apple plugin.

## Overview

The Flutter WhisperKit Apple plugin serves as a bridge between Flutter applications and Apple's WhisperKit framework. This integration enables Flutter developers to implement speech-to-text functionality in their iOS and macOS applications without writing native code themselves.

## Architecture

The integration architecture consists of three main layers:

1. **Flutter API Layer**: Dart code that provides a clean, easy-to-use interface for Flutter applications
2. **Platform Channel Communication**: The bridge between Dart code and native Apple platform code
3. **Native Implementation**: iOS/macOS Swift code that interfaces with the WhisperKit framework

![Architecture Diagram](https://github.com/r0227n/flutter_whisperkit/raw/doc/docs/images/architecture.png)

## Integration Steps

### 1. Add the Plugin to Your Flutter Project

Add the Flutter WhisperKit Apple plugin to your `pubspec.yaml` file:

```yaml
dependencies:
  flutter_whisperkit_apple: ^0.0.1
```

Run `flutter pub get` to install the plugin.

### 2. Configure iOS/macOS Projects

#### iOS Configuration

Update your `Info.plist` file to include microphone permissions:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to your microphone for speech recognition</string>
```

Ensure your Podfile has the correct iOS version:

```ruby
platform :ios, '14.0'
```

#### macOS Configuration

For macOS applications, add the following to your `Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to your microphone for speech recognition</string>
```

Add the appropriate entitlements for microphone access:

```xml
<key>com.apple.security.device.audio-input</key>
<true/>
```

### 3. Initialize WhisperKit in Your Flutter App

Import the plugin and initialize WhisperKit:

```dart
import 'package:flutter_whisperkit_apple/flutter_whisperkit_apple.dart';

// Create an instance of the plugin
final flutterWhisperkitApple = FlutterWhisperkitApple();

// Initialize WhisperKit
Future<void> initializeWhisperKit() async {
  try {
    await flutterWhisperkitApple.initializeWhisperKit();
    print('WhisperKit initialized successfully');
  } catch (e) {
    print('Failed to initialize WhisperKit: $e');
  }
}
```

### 4. Implement Transcription Functionality

#### File-based Transcription

```dart
Future<String?> transcribeAudioFile(String filePath) async {
  try {
    final result = await flutterWhisperkitApple.transcribeAudio(
      filePath: filePath,
      config: TranscriptionConfig(
        language: 'en',
        modelSize: 'medium',
      ),
    );
    
    return result.text;
  } catch (e) {
    print('Transcription failed: $e');
    return null;
  }
}
```

#### Real-time Transcription

```dart
// Start recording and transcribing
Future<void> startRecording() async {
  try {
    await flutterWhisperkitApple.startRecording(
      config: TranscriptionConfig(
        language: 'en',
        modelSize: 'medium',
        enableVAD: true,
      ),
    );
    
    // Listen for transcription updates
    flutterWhisperkitApple.onTranscriptionProgress.listen((result) {
      print('Partial transcription: ${result.text}');
    });
  } catch (e) {
    print('Failed to start recording: $e');
  }
}

// Stop recording
Future<String?> stopRecording() async {
  try {
    final finalResult = await flutterWhisperkitApple.stopRecording();
    return finalResult.text;
  } catch (e) {
    print('Failed to stop recording: $e');
    return null;
  }
}
```

## Advanced Configuration

The Flutter WhisperKit Apple plugin supports various configuration options through the `TranscriptionConfig` class:

```dart
final config = TranscriptionConfig(
  language: 'en',       // Language code (e.g., 'en', 'fr', 'ja')
  modelSize: 'medium',  // Model size: 'tiny', 'small', 'medium', 'large'
  enableVAD: true,      // Voice Activity Detection
  vadFallbackTimeout: 3000, // Timeout in milliseconds
  enablePunctuation: true,  // Enable automatic punctuation
  enableFormatting: true,   // Enable text formatting
  enableTimestamps: false,  // Include timestamps in the transcription
);
```

## Error Handling

Implement proper error handling to manage potential issues during transcription:

```dart
try {
  // Transcription code
} on WhisperKitConfigError catch (e) {
  print('Configuration error: $e');
} on PlatformException catch (e) {
  print('Platform error: ${e.message}');
} catch (e) {
  print('Unknown error: $e');
}
```

## Performance Considerations

- **Model Size**: Larger models provide better accuracy but require more processing power and memory
- **Real-time Streaming**: Consider using smaller models for real-time applications to reduce latency
- **Battery Usage**: Continuous transcription can impact battery life; implement appropriate UI indicators
- **Memory Management**: Release resources when transcription is no longer needed

## Troubleshooting

### Common Issues

1. **Missing Permissions**: Ensure microphone permissions are properly configured
2. **Model Download Failures**: Check network connectivity and available storage
3. **Transcription Accuracy**: Try different model sizes or language settings
4. **Memory Warnings**: Consider using a smaller model or optimizing your app's memory usage

### Debugging Tips

1. Enable debug logging in the plugin:
   ```dart
   flutterWhisperkitApple.setDebugLogging(true);
   ```

2. Monitor memory usage during transcription
3. Test with different audio sources and quality levels
4. Verify that the correct model is being used

## Resources

- [WhisperKit GitHub Repository](https://github.com/argmaxinc/WhisperKit)
- [Flutter WhisperKit Apple Plugin](https://github.com/r0227n/flutter_whisperkit)
- [WhisperKit Models on HuggingFace](https://huggingface.co/argmaxinc/whisperkit-coreml)
