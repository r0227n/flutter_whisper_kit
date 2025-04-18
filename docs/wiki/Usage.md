# Usage Guide

This guide demonstrates how to use the Flutter WhisperKit Apple plugin in your Flutter application.

## Basic Usage

### Initialize the Plugin

First, create an instance of the plugin:

```dart
final flutterWhisperkitApple = FlutterWhisperkitApple();
```

### Initialize WhisperKit

Before using the plugin, you need to initialize WhisperKit:

```dart
try {
  await flutterWhisperkitApple.initializeWhisperKit();
  print('WhisperKit initialized successfully');
} catch (e) {
  print('Failed to initialize WhisperKit: $e');
}
```

### Transcribe Audio from a File

To transcribe audio from a file:

```dart
try {
  final result = await flutterWhisperkitApple.transcribeAudio(
    filePath: 'path/to/audio/file.m4a',
    config: TranscriptionConfig(
      language: 'en',
      // Additional configuration options
    ),
  );
  
  print('Transcription: ${result.text}');
} catch (e) {
  print('Transcription failed: $e');
}
```

### Real-time Transcription

For real-time transcription from the microphone:

```dart
// Start recording and transcribing
try {
  await flutterWhisperkitApple.startRecording(
    config: TranscriptionConfig(
      language: 'en',
      // Additional configuration options
    ),
  );
  
  // Listen for transcription updates
  flutterWhisperkitApple.onTranscriptionProgress.listen((result) {
    print('Partial transcription: ${result.text}');
  });
} catch (e) {
  print('Failed to start recording: $e');
}

// Later, stop recording
try {
  final finalResult = await flutterWhisperkitApple.stopRecording();
  print('Final transcription: ${finalResult.text}');
} catch (e) {
  print('Failed to stop recording: $e');
}
```

## Configuration Options

The `TranscriptionConfig` class allows you to customize the transcription process:

```dart
final config = TranscriptionConfig(
  language: 'en',       // Language code (e.g., 'en', 'fr', 'ja')
  modelSize: 'medium',  // Model size: 'tiny', 'small', 'medium', 'large'
  enableVAD: true,      // Voice Activity Detection
  vadFallbackTimeout: 3000, // Timeout in milliseconds
  // Additional options
);
```

## Error Handling

Handle potential errors during transcription:

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

## Checking Permissions

Always check for microphone permissions before recording:

```dart
final hasPermission = await flutterWhisperkitApple.requestAudioPermission();
if (hasPermission) {
  // Proceed with recording
} else {
  // Handle permission denied
  print('Microphone permission denied');
}
```

## Example

For a complete example, see the [Examples](Examples) page or check the example application included in the plugin repository.
