# Project Organization

This page provides detailed information about the organization of the Flutter WhisperKit Apple plugin project.

## Directory Structure

```
flutter_whisperkit_apple/
├── lib/                      # Dart implementation
│   ├── flutter_whisperkit_apple.dart  # Main plugin entry point
│   └── src/                  # Internal implementation files
├── ios/                      # iOS platform implementation
│   ├── Classes/              # Native Swift code
│   └── flutter_whisperkit_apple.podspec  # iOS dependency specification
├── macos/                    # macOS platform implementation
├── example/                  # Example Flutter application
│   ├── lib/                  # Example app Dart code
│   ├── ios/                  # iOS-specific example code
│   └── integration_test/     # Integration tests
├── CHANGELOG.md              # Version history
├── README.md                 # Project documentation
├── pubspec.yaml              # Plugin metadata and dependencies
└── analysis_options.yaml     # Dart analyzer configuration
```

## Core Systems

### 1. Flutter API Layer

The Dart code in the `lib/` directory provides a clean, easy-to-use interface for Flutter applications. This layer abstracts away the complexity of the native implementation and provides a consistent API for developers.

Key files:
- `flutter_whisperkit_apple.dart`: Main entry point for the plugin
- `src/transcription_config.dart`: Configuration options for transcription
- `src/transcription_result.dart`: Classes representing transcription results

### 2. Platform Channel Communication

The bridge between Dart code and native Apple platform code is implemented using Flutter's platform channel mechanism. This allows for efficient communication between the Flutter application and the native WhisperKit framework.

Key files:
- `flutter_whisperkit_apple_method_channel.dart`: Implementation of method channel communication
- `flutter_whisperkit_apple_platform_interface.dart`: Platform interface definition

### 3. Native Implementation

The iOS and macOS implementations in the `ios/` and `macos/` directories contain Swift code that interfaces with Apple's WhisperKit framework. This code handles the low-level details of audio processing and transcription.

Key components:
- `WhisperKitManager`: Manages the interaction with the WhisperKit framework
- `AudioProcessor`: Handles audio data preprocessing
- `TranscriptionHandler`: Processes transcription results

### 4. Example Application

The `example/` directory contains a sample Flutter application that demonstrates how to use the plugin. This serves as both a reference for developers and a testing ground for the plugin's functionality.

Key features:
- File-based transcription example
- Real-time transcription from microphone
- Configuration options demonstration

## Development Workflow

1. **Dart API Development**: Changes to the public API and Dart implementation
2. **Platform Channel Updates**: Modifications to the communication between Dart and native code
3. **Native Implementation**: Updates to the Swift code that interfaces with WhisperKit
4. **Testing**: Validation through unit tests, integration tests, and the example application

## Testing Strategy

The plugin employs several testing approaches:

1. **Unit Tests**: Located in the `test/` directory, these verify the behavior of individual components
2. **Integration Tests**: Found in `example/integration_test/`, these ensure the plugin works correctly in a Flutter application
3. **Example Application**: Serves as a manual testing environment for the plugin's functionality

## Build and Deployment

The plugin uses standard Flutter plugin packaging and deployment mechanisms:

1. **pubspec.yaml**: Defines the plugin's metadata, dependencies, and platform support
2. **flutter_whisperkit_apple.podspec**: Specifies iOS/macOS native dependencies
3. **CHANGELOG.md**: Documents version history and changes
