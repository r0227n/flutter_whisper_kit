# Flutter WhisperKit

[DeepWiki](https://deepwiki.com/r0227n/flutter_whisperkit)


A monorepo for Flutter WhisperKit packages that enable on-device speech recognition in Flutter applications using WhisperKit.

## Overview

Flutter WhisperKit is a wrapper package that enables the use of WhisperKit within Flutter applications. [WhisperKit](https://github.com/argmaxinc/WhisperKit) is an on-device speech recognition framework developed by Argmax that provides high-quality transcription capabilities.

## Repository Structure

This repository is organized as a monorepo containing the following packages:

- **flutter_whisperkit**: The main package that provides a platform-agnostic API for using WhisperKit in Flutter applications.
- **flutter_whisperkit_apple**: The platform implementation for Apple devices (iOS and macOS).

## Features

- On-device speech recognition with no data sent to external servers
- Support for multiple model sizes (tiny to large)
- File-based audio transcription
- Real-time microphone transcription
- Configurable model storage options
- Progress tracking for model downloads

## Getting Started

To use Flutter WhisperKit in your Flutter application, add the following dependency to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_whisperkit: latest
```

For detailed usage instructions, refer to the documentation in the individual package directories:

- [flutter_whisperkit](packages/flutter_whisperkit/README.md)
- [flutter_whisperkit_apple](packages/flutter_whisperkit_apple/README.md)

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- [WhisperKit](https://github.com/argmaxinc/WhisperKit) - The underlying speech recognition framework
- [Flutter](https://flutter.dev/) - The UI toolkit for building natively compiled applications
