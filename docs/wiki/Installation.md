# Installation Guide

This guide will help you integrate the Flutter WhisperKit Apple plugin into your Flutter project.

## Requirements

- Flutter SDK 3.3.0 or higher
- Dart SDK 3.7.2 or higher
- iOS 14.0+ / macOS 11.0+
- Xcode 14.0+

## Adding the Dependency

Add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  flutter_whisperkit_apple: ^0.0.1
```

Then run:

```bash
flutter pub get
```

## iOS Setup

### Update Info.plist

For iOS applications, you need to add microphone permissions to your `Info.plist` file:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to your microphone for speech recognition</string>
```

### Podfile Configuration

Ensure your Podfile has the correct iOS version:

```ruby
platform :ios, '14.0'
```

## macOS Setup

### Update Info.plist

For macOS applications, add the following to your `Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to your microphone for speech recognition</string>
```

### Entitlements

Make sure your macOS app has the appropriate entitlements for microphone access:

```xml
<key>com.apple.security.device.audio-input</key>
<true/>
```

## Importing the Plugin

In your Dart code, import the plugin:

```dart
import 'package:flutter_whisperkit_apple/flutter_whisperkit_apple.dart';
```

## Next Steps

After installation, proceed to the [Usage Guide](Usage) to learn how to use the plugin in your application.
