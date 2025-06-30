# WhisperKit and Flutter Integration

This document provides detailed information on how to integrate WhisperKit with Flutter applications using the Flutter WhisperKit Apple plugin.

## Overview

The Flutter WhisperKit Apple plugin serves as a bridge between Flutter applications and Apple's WhisperKit framework. This integration allows Flutter developers to implement speech-to-text functionality in iOS and macOS applications without writing native code themselves.

## Architecture

The integration architecture consists of three main layers:

1. **Flutter API Layer**: Dart code that provides a clean, easy-to-use interface for Flutter applications
2. **Platform Channel Communication**: A bridge between Dart code and native Apple platform code
3. **Native Implementation**: iOS/macOS Swift code that interfaces with the WhisperKit framework

![Architecture Diagram](https://github.com/r0227n/flutter_whisper_kit/raw/doc/docs/images/architecture.png)

## Integration Steps

### 1. Add Plugin to Flutter Project

Add the Flutter WhisperKit Apple plugin to your `pubspec.yaml` file:

```yaml
dependencies:
  flutter_whisper_kit_apple: ^0.0.1
```

Run `flutter pub get` to install the plugin.

### 2. Configure iOS/macOS Project

#### iOS Configuration

Update your `Info.plist` file to include microphone permissions:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access for speech recognition</string>
```

Ensure your Podfile has the correct iOS version:

```ruby
platform :ios, '14.0'
```

#### macOS Configuration

For macOS applications, add the following to your `Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access for speech recognition</string>
```

Add the appropriate entitlements for microphone access:

```xml
<key>com.apple.security.device.audio-input</key>
<true/>
```

### 3. Initialize WhisperKit in Flutter App

Import the plugin and initialize WhisperKit:

```dart
import 'package:flutter_whisper_kit_apple/flutter_whisper_kit_apple.dart';

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

### 4. Implement Transcription Features

#### File-Based Transcription

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

#### Real-Time Transcription

```dart
// Start recording and transcription
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
  enableVAD: true,      // Voice activity detection
  vadFallbackTimeout: 3000, // Timeout in milliseconds
  enablePunctuation: true,  // Enable automatic punctuation
  enableFormatting: true,   // Enable text formatting
  enableTimestamps: false,  // Include timestamps in transcription
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
- **Real-Time Streaming**: Consider using smaller models for real-time applications to reduce latency
- **Battery Usage**: Continuous transcription can impact battery life. Implement appropriate UI indicators
- **Memory Management**: Release resources when transcription is no longer needed

## Complete Example Application

Here's a complete example of a Flutter app using WhisperKit:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_whisper_kit_apple/flutter_whisper_kit_apple.dart';

class TranscriptionApp extends StatefulWidget {
  @override
  _TranscriptionAppState createState() => _TranscriptionAppState();
}

class _TranscriptionAppState extends State<TranscriptionApp> {
  final flutterWhisperkitApple = FlutterWhisperkitApple();
  String transcriptionText = '';
  bool isRecording = false;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    initializeWhisperKit();
  }

  Future<void> initializeWhisperKit() async {
    try {
      await flutterWhisperkitApple.initializeWhisperKit();
      setState(() {
        isInitialized = true;
      });
      
      // Listen for transcription updates
      flutterWhisperkitApple.onTranscriptionProgress.listen((result) {
        setState(() {
          transcriptionText = result.text;
        });
      });
    } catch (e) {
      print('Failed to initialize WhisperKit: $e');
    }
  }

  Future<void> toggleRecording() async {
    if (!isInitialized) return;

    try {
      if (isRecording) {
        final result = await flutterWhisperkitApple.stopRecording();
        setState(() {
          isRecording = false;
          transcriptionText = result?.text ?? 'No transcription available';
        });
      } else {
        await flutterWhisperkitApple.startRecording(
          config: TranscriptionConfig(
            language: 'en',
            modelSize: 'medium',
            enableVAD: true,
          ),
        );
        setState(() {
          isRecording = true;
          transcriptionText = 'Recording...';
        });
      }
    } catch (e) {
      print('Recording error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WhisperKit Transcription'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              height: 200,
              width: double.infinity,
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: SingleChildScrollView(
                child: Text(
                  transcriptionText.isEmpty ? 'Tap record to start' : transcriptionText,
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isInitialized ? toggleRecording : null,
              child: Text(isRecording ? 'Stop Recording' : 'Start Recording'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isRecording ? Colors.red : Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
            SizedBox(height: 10),
            Text(
              isInitialized ? 'WhisperKit Ready' : 'Initializing WhisperKit...',
              style: TextStyle(
                color: isInitialized ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: TranscriptionApp(),
    title: 'WhisperKit Demo',
  ));
}
```

## Troubleshooting

### Common Issues

1. **Missing Permissions**: Ensure microphone permissions are properly configured
2. **Model Download Failures**: Check network connectivity and available storage
3. **Transcription Accuracy**: Try different model sizes or language settings
4. **Memory Warnings**: Consider using smaller models or optimizing app memory usage

### Debugging Tips

1. Enable debug logging in the plugin:
   ```dart
   flutterWhisperkitApple.setDebugLogging(true);
   ```

2. Monitor memory usage during transcription
3. Test with different audio sources and quality levels
4. Verify that the correct model is being used

### Platform-Specific Considerations

#### iOS
- Ensure your app targets iOS 14.0 or later
- Test on physical devices for accurate performance metrics
- Consider app backgrounding behavior for long transcriptions

#### macOS
- Verify sandbox entitlements for microphone access
- Test with different input devices
- Consider performance on different Mac models

## Best Practices

1. **Initialize Early**: Initialize WhisperKit when your app starts to reduce latency
2. **Handle Permissions**: Request microphone permissions before attempting transcription
3. **Provide Feedback**: Show users when transcription is active and when it's processing
4. **Optimize for Use Case**: Choose appropriate model sizes based on your accuracy vs. performance requirements
5. **Test Thoroughly**: Test on various devices and with different audio conditions
6. **Handle Errors Gracefully**: Provide meaningful error messages to users
7. **Resource Management**: Properly dispose of resources when they're no longer needed

## Resources

- [WhisperKit GitHub Repository](https://github.com/argmaxinc/WhisperKit)
- [Flutter WhisperKit Apple Plugin](https://github.com/r0227n/flutter_whisper_kit)
- [HuggingFace WhisperKit Models](https://huggingface.co/argmaxinc/whisperkit-coreml)
- [Flutter Platform Channels Documentation](https://flutter.dev/docs/development/platform-integration/platform-channels)