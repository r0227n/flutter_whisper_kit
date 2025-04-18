# WhisperKit Documentation

## Overview

WhisperKit is a Swift framework developed by [Argmax](https://www.takeargmax.com) for deploying state-of-the-art speech-to-text systems (e.g. [Whisper](https://github.com/openai/whisper)) on Apple devices. It provides advanced features such as real-time streaming, word timestamps, voice activity detection, and more.

The original repository is located at [https://github.com/argmaxinc/WhisperKit.git](https://github.com/argmaxinc/WhisperKit.git).

## Key Features

- On-device speech-to-text transcription
- Real-time streaming capabilities
- Word timestamps
- Voice activity detection
- Support for multiple languages
- Optimized for Apple devices using CoreML

## Installation

WhisperKit can be integrated into Swift projects using the Swift Package Manager.

### Prerequisites

- macOS 14.0 or later
- Xcode 15.0 or later

### Swift Package Manager Integration

1. Open your Swift project in Xcode
2. Navigate to `File` > `Add Package Dependencies...`
3. Enter the package repository URL: `https://github.com/argmaxinc/whisperkit`
4. Choose the version range or specific version
5. Click `Finish` to add WhisperKit to your project

### Package.swift Integration

If you're using WhisperKit as part of a Swift package, include it in your Package.swift dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/argmaxinc/WhisperKit.git", from: "0.9.0"),
],
```

Then add `WhisperKit` as a dependency for your target:

```swift
.target(
    name: "YourApp",
    dependencies: ["WhisperKit"]
),
```

### Homebrew Installation

You can install the WhisperKit command line app using Homebrew:

```bash
brew install whisperkit-cli
```

## Usage

### Basic Transcription

```swift
import WhisperKit

// Initialize WhisperKit with default settings
Task {
   let pipe = try? await WhisperKit()
   let transcription = try? await pipe!.transcribe(audioPath: "path/to/your/audio.{wav,mp3,m4a,flac}")?.text
    print(transcription)
}
```

### Model Selection

WhisperKit automatically downloads the recommended model for the device if not specified. You can also select a specific model:

```swift
let pipe = try? await WhisperKit(WhisperKitConfig(model: "large-v3"))
```

This method also supports glob search with wildcards:

```swift
let pipe = try? await WhisperKit(WhisperKitConfig(model: "distil*large-v3"))
```

For a list of available models, see the [HuggingFace repo](https://huggingface.co/argmaxinc/whisperkit-coreml).

### Custom Models

WhisperKit supports creating and deploying custom fine-tuned versions of Whisper in CoreML format using the [`whisperkittools`](https://github.com/argmaxinc/whisperkittools) repository. Once generated, they can be loaded by changing the repo name:

```swift
let config = WhisperKitConfig(model: "large-v3", modelRepo: "username/your-model-repo")
let pipe = try? await WhisperKit(config)
```

## Integration with Flutter

The Flutter WhisperKit Apple plugin provides a bridge between Flutter applications and the native WhisperKit framework. This allows Flutter developers to implement speech-to-text functionality in their iOS and macOS applications without writing native code themselves.

### Flutter Plugin Structure

The Flutter plugin consists of:

1. **Flutter API Layer**: Dart code that provides a clean interface for Flutter applications
2. **Platform Channel Communication**: Bridge between Dart code and native Apple platform code
3. **Native Implementation**: iOS/macOS Swift code that interfaces with the WhisperKit framework

### Using WhisperKit in Flutter

To use WhisperKit in a Flutter application:

1. Add the Flutter WhisperKit Apple plugin to your pubspec.yaml
2. Import the plugin in your Dart code
3. Initialize the plugin and use its API to perform transcription

For detailed information on using the Flutter plugin, refer to the [Flutter WhisperKit Apple documentation](https://github.com/r0227n/flutter_whisperkit).

## Additional Resources

- [TestFlight Demo App](https://testflight.apple.com/join/LPVOyJZW)
- [Python Tools](https://github.com/argmaxinc/whisperkittools)
- [Benchmarks & Device Support](https://huggingface.co/spaces/argmaxinc/whisperkit-benchmarks)
- [WhisperKit Android](https://github.com/argmaxinc/WhisperKitAndroid)

## License

WhisperKit is released under the MIT License. See [LICENSE](https://github.com/argmaxinc/WhisperKit/blob/main/LICENSE) for more details.
