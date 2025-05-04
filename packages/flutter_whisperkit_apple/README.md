# Flutter WhisperKit Apple

A Flutter plugin that provides Apple platform (iOS and macOS) implementation for the flutter_whisperkit package.

## Overview

This package is part of the flutter_whisperkit plugin system and provides the Apple-specific implementation for WhisperKit integration. It is not intended for direct use by application developers but serves as a platform implementation for the main flutter_whisperkit package.

## Platform Support

This package specifically supports:
- iOS 14.0+
- macOS 11.0+

## Implementation Details

Flutter WhisperKit Apple provides the native implementation that connects Flutter applications to Apple's WhisperKit framework. It handles:

1. Native integration with WhisperKit for iOS and macOS
2. Model downloading and management
3. Audio processing and transcription
4. Real-time streaming of transcription results
5. Platform-specific optimizations

## Architecture

The implementation uses:
- Swift for native code
- Pigeon for type-safe communication between Flutter and native code
- CoreML for optimized model inference
- AVFoundation for audio capture and processing

## For Plugin Developers

If you're working on extending or maintaining this plugin:

### Key Components

1. **FlutterWhisperkitApplePlugin**: Main plugin class that registers with the Flutter engine
2. **WhisperKitApiImpl**: Implementation of the Pigeon-generated interface
3. **TranscriptionStreamHandler**: Manages streaming transcription results back to Flutter

### Native Implementation

The native implementation:
1. Configures WhisperKit with compute options
2. Manages model downloading and storage
3. Handles audio file transcription
4. Processes real-time audio from the microphone
5. Streams transcription results back to Flutter

### Error Handling

The plugin uses a structured error code system to report issues back to Flutter:

| Error Code Range | Category |
|------------------|----------|
| 1000-1999 | Model Initialization and Loading |
| 2000-2999 | Transcription and Processing |
| 3000-3999 | Recording and Audio Capture |
| 4000-4999 | File System and Permissions |
| 5000-5999 | Configuration and Parameters |

## References

- [WhisperKit GitHub Repository](https://github.com/argmaxinc/WhisperKit)
- [Flutter Plugin Development](https://docs.flutter.dev/packages-and-plugins/developing-packages)
- [Pigeon Documentation](https://pub.dev/packages/pigeon)

