# Flutter WhisperKit

A Flutter plugin for WhisperKit speech recognition.

This package provides the platform interface for WhisperKit implementations.
It is designed to be used by the following platform-specific implementations:

- [flutter_whisperkit_apple](../flutter_whisperkit_apple): Implementation for iOS and macOS
- flutter_whisperkit_android (future implementation)

## Usage

This package is not meant to be used directly.
Instead, use the main `flutter_whisperkit_apple` package in your project:

```dart
import 'package:flutter_whisperkit_apple/flutter_whisperkit_apple.dart';

// Register the platform implementation
FlutterWhisperkitApple.registerWith();

// Use the plugin
final plugin = FlutterWhisperkitApple();
final version = await plugin.getPlatformVersion();
```
