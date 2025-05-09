# flutter_whisper_kit_apple

A Flutter plugin that provides Apple platform (iOS and macOS) implementation for the flutter_whisper_kit package.

## Overview

This package is part of the flutter_whisper_kit plugin system and provides the Apple-specific implementation for WhisperKit integration. It is not intended for direct use by application developers but serves as a platform implementation for the main flutter_whisper_kit package.

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

1. **FlutterWhisperKitApplePlugin**: Main plugin class that registers with the Flutter engine
2. **WhisperKitApiImpl**: Implementation of the Pigeon-generated interface
3. **TranscriptionStreamHandler**: Manages streaming transcription results back to Flutter

### Native Implementation

The native implementation:
1. Configures WhisperKit with compute options
2. Manages model downloading and storage
3. Handles audio file transcription
4. Processes real-time audio from the microphone
5. Streams transcription results back to Flutter

### Error Codes

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

## References

- [WhisperKit GitHub Repository](https://github.com/argmaxinc/WhisperKit)
- [Flutter Plugin Development](https://docs.flutter.dev/packages-and-plugins/developing-packages)
- [Pigeon Documentation](https://pub.dev/packages/pigeon)

