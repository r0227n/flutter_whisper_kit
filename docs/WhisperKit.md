# WhisperKit Documentation

## Overview

WhisperKit is a Swift framework developed by [Argmax](https://www.takeargmax.com) for deploying cutting-edge speech-to-text systems (e.g., [Whisper](https://github.com/openai/whisper)) on Apple devices. It provides advanced features such as real-time streaming, word timestamps, and voice activity detection.

The original repository can be found at [https://github.com/argmaxinc/WhisperKit.git](https://github.com/argmaxinc/WhisperKit.git).

## Key Features

- On-device speech-to-text transcription
- Real-time streaming capabilities
- Word-level timestamps
- Voice activity detection
- Multi-language support
- Apple device optimization using CoreML

## Installation

WhisperKit can be integrated into Swift projects using Swift Package Manager.

### Prerequisites

- macOS 14.0 or later
- Xcode 15.0 or later

### Integration via Swift Package Manager

1. Open your Swift project in Xcode
2. Navigate to `File` > `Add Package Dependencies...`
3. Enter the package repository URL: `https://github.com/argmaxinc/whisperkit`
4. Select a version range or specific version
5. Click `Finish` to add WhisperKit to your project

### Adding to Package.swift

If you're using WhisperKit as part of a Swift package, you can add it to your Package.swift dependencies as follows:

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

### Installation via Homebrew

You can install the `WhisperKit` command-line app using [Homebrew](https://brew.sh):

```bash
brew install whisperkit-cli
```

## Usage

### Basic Usage Example

Here's a basic example of transcribing a local audio file:

```swift
import WhisperKit

// Initialize WhisperKit with default configuration
Task {
   let pipe = try? await WhisperKit()
   let transcription = try? await pipe!.transcribe(audioPath: "path/to/your/audio.{wav,mp3,m4a,flac}")?.text
    print(transcription)
}
```

### Model Selection

WhisperKit automatically downloads the recommended model for your device if none is specified. You can also select a specific model by specifying its name:

```swift
let pipe = try? await WhisperKit(WhisperKitConfig(model: "large-v3"))
```

This method also supports glob search, allowing you to select models using wildcards:

```swift
let pipe = try? await WhisperKit(WhisperKitConfig(model: "distil*large-v3"))
```

For a list of available models, see the [HuggingFace repository](https://huggingface.co/argmaxinc/whisperkit-coreml).

### Custom Models

WhisperKit supports creating and deploying custom fine-tuned versions of Whisper in CoreML format using the [`whisperkittools`](https://github.com/argmaxinc/whisperkittools) repository. Once generated, you can load them by changing the repository name:

```swift
let config = WhisperKitConfig(model: "large-v3", modelRepo: "username/your-model-repo")
let pipe = try? await WhisperKit(config)
```

## Flutter Integration

The Flutter WhisperKit Apple plugin provides a bridge between Flutter applications and the native WhisperKit framework. This allows Flutter developers to implement speech-to-text functionality in iOS and macOS applications without writing native code themselves.

### Flutter Plugin Structure

The Flutter plugin consists of:

1. **Flutter API Layer**: Dart code that provides a clean interface for Flutter applications
2. **Platform Channel Communication**: A bridge between Dart code and native Apple platform code
3. **Native Implementation**: iOS/macOS Swift code that interfaces with the WhisperKit framework

### Using WhisperKit in Flutter

To use WhisperKit in a Flutter application:

1. Add the Flutter WhisperKit Apple plugin to pubspec.yaml
2. Import the plugin in your Dart code
3. Initialize the plugin and use its API to perform transcription

For detailed information on using the Flutter plugin, see the [Flutter WhisperKit Apple documentation](https://github.com/r0227n/flutter_whisper_kit).

## Additional Resources

- [TestFlight demo app](https://testflight.apple.com/join/LPVOyJZW)
- [Python tools](https://github.com/argmaxinc/whisperkittools)
- [Benchmarks and device support](https://huggingface.co/spaces/argmaxinc/whisperkit-benchmarks)
- [WhisperKit Android](https://github.com/argmaxinc/WhisperKitAndroid)

## License

WhisperKit is released under the MIT License. See [LICENSE](https://github.com/argmaxinc/WhisperKit/blob/main/LICENSE) for details.
