# ADR-002: Platform Abstraction

## Status

Accepted

## Date

2024-12-29

## Context

Flutter WhisperKit needed to support multiple Apple platforms (iOS and macOS) while maintaining a unified API. The challenge was designing an abstraction layer that:

1. **Hides platform differences**: Provides consistent behavior across platforms
2. **Enables platform-specific optimizations**: Allows leveraging unique platform features
3. **Maintains type safety**: Ensures compile-time verification of platform capabilities
4. **Supports future expansion**: Easy to add new platforms (Android, Windows, etc.)
5. **Performance considerations**: Minimal overhead for platform-specific calls

## Decision

We implemented a **Platform Interface Pattern** with the following architecture:

### 1. Platform Interface Layer

```dart
abstract class FlutterWhisperKitPlatform extends PlatformInterface {
  /// Platform-agnostic method definitions
  Future<String?> loadModel(String? variant, {/* parameters */});
  Future<TranscriptionResult?> transcribeFromFile(String path, {/* parameters */});
  Future<String?> startRecording({/* parameters */});
  Future<String?> stopRecording({/* parameters */});

  /// Platform capability queries
  bool get supportsBackgroundDownloads;
  bool get supportsRealtimeTranscription;
  List<String> get supportedAudioFormats;
}
```

### 2. Platform-Specific Implementations

#### Apple Platform Implementation

```dart
class FlutterWhisperKitApple extends FlutterWhisperKitPlatform {
  @override
  bool get supportsBackgroundDownloads => true;

  @override
  bool get supportsRealtimeTranscription => true;

  @override
  List<String> get supportedAudioFormats => ['wav', 'mp3', 'm4a', 'caf'];
}
```

#### Future Android Platform Implementation

```dart
class FlutterWhisperKitAndroid extends FlutterWhisperKitPlatform {
  @override
  bool get supportsBackgroundDownloads => false; // Limited by Android constraints

  @override
  bool get supportsRealtimeTranscription => true;

  @override
  List<String> get supportedAudioFormats => ['wav', 'mp3', 'aac'];
}
```

### 3. Platform Registration System

```dart
class FlutterWhisperKit {
  static FlutterWhisperKitPlatform get _platform {
    return FlutterWhisperKitPlatform.instance;
  }

  // Platform detection happens automatically through plugin registration
}
```

### 4. Federated Plugin Architecture

```
flutter_whisper_kit/
├── flutter_whisper_kit/          # Main plugin package
│   ├── lib/src/platform_specifics/
│   │   └── flutter_whisper_kit_platform_interface.dart
│   └── lib/flutter_whisper_kit.dart
├── flutter_whisper_kit_apple/     # iOS/macOS implementation
│   ├── lib/flutter_whisper_kit_apple.dart
│   └── darwin/                    # Native Swift code
└── flutter_whisper_kit_android/   # Future Android implementation
    ├── lib/flutter_whisper_kit_android.dart
    └── android/                   # Native Kotlin/Java code
```

## Rationale

### Why Platform Interface Pattern

1. **Separation of concerns**: Platform-specific logic isolated from business logic
2. **Testability**: Easy to mock platform implementations for testing
3. **Extensibility**: New platforms can be added without changing existing code
4. **Type safety**: Compile-time verification of platform capabilities
5. **Performance**: Direct platform calls without unnecessary abstraction layers

### Why Federated Plugin Architecture

1. **Platform independence**: Each platform can evolve independently
2. **Reduced bundle size**: Apps only include code for their target platforms
3. **Specialized teams**: Platform experts can focus on their domains
4. **Maintenance**: Platform-specific issues don't affect other platforms
5. **Flutter ecosystem best practices**: Follows recommended plugin patterns

### Platform Capability System

```dart
// Platform-aware feature usage
class WhisperKitFeatures {
  static bool canUseBackgroundDownloads() {
    return FlutterWhisperKitPlatform.instance.supportsBackgroundDownloads;
  }

  static Future<void> downloadWithOptimalStrategy(String variant) async {
    if (canUseBackgroundDownloads()) {
      await whisperKit.download(variant: variant, useBackgroundSession: true);
    } else {
      await whisperKit.download(variant: variant, useBackgroundSession: false);
    }
  }
}
```

## Implementation Details

### Method Channel Abstraction

```dart
abstract class FlutterWhisperKitPlatform {
  static const MethodChannel _channel = MethodChannel('flutter_whisper_kit');

  /// Template method for platform calls with consistent error handling
  Future<T> _handlePlatformCall<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on PlatformException catch (e) {
      throw WhisperKitError.fromPlatformException(e);
    } catch (e) {
      throw WhisperKitError(
        code: ErrorCodes.platformError,
        message: 'Platform call failed: $e',
      );
    }
  }
}
```

### Platform-Specific Optimizations

#### iOS/macOS Optimizations

```swift
// Swift implementation with platform-specific features
class WhisperKitApplePlugin: NSObject, FlutterPlugin {
    // Use iOS-specific audio session configuration
    private func configureAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.record, mode: .measurement)
    }

    // Leverage macOS-specific hardware acceleration
    private func configureMetalPerformanceShaders() {
        // macOS-specific GPU acceleration
    }
}
```

### Error Propagation Across Platforms

```dart
class WhisperKitError {
  static WhisperKitError fromPlatformException(PlatformException e) {
    // Map platform-specific error codes to unified error codes
    final platformCode = e.code;
    final unifiedCode = _mapPlatformErrorCode(platformCode);

    return WhisperKitError(
      code: unifiedCode,
      message: e.message ?? 'Platform error',
      details: e.details,
      platformCode: platformCode,
    );
  }

  static int _mapPlatformErrorCode(String platformCode) {
    // iOS/macOS error code mappings
    if (platformCode.startsWith('AVAudioSession')) {
      return ErrorCodes.audioSessionError;
    }
    // Add more platform-specific mappings
    return ErrorCodes.platformError;
  }
}
```

## Consequences

### Positive

1. **Unified API**: Developers use the same API regardless of platform
2. **Platform optimization**: Each platform can be optimized independently
3. **Future-proof**: Easy to add new platforms
4. **Testing**: Platform logic can be tested independently
5. **Maintenance**: Platform-specific bugs are isolated
6. **Bundle optimization**: Apps only include necessary platform code

### Negative

1. **Complexity**: Additional abstraction layers increase cognitive load
2. **Debugging**: Platform-specific issues may be harder to trace
3. **Feature parity**: Need to maintain consistent behavior across platforms
4. **Development overhead**: Changes may require updates to multiple packages
5. **Documentation**: Need to document platform-specific behaviors

### Mitigation Strategies

1. **Clear documentation**: Document platform differences and capabilities
2. **Capability queries**: Provide runtime platform capability detection
3. **Unified testing**: Test common functionality across all platforms
4. **Tooling**: Develop tools to synchronize changes across platform packages
5. **Examples**: Provide platform-specific usage examples

## Platform-Specific Considerations

### iOS/macOS Specific Features

1. **Background downloads**: URLSession background configuration
2. **Hardware acceleration**: Metal Performance Shaders for GPU acceleration
3. **Audio session management**: AVAudioSession for optimal recording
4. **File system access**: Platform-specific document directory handling

### Future Android Considerations

1. **Background limitations**: Android background execution restrictions
2. **Audio focus**: AudioManager for audio focus handling
3. **Storage access**: Scoped storage compliance
4. **Performance**: NNAPI for hardware acceleration

### Web Platform Considerations (Future)

1. **WebAssembly**: WASM compilation of Whisper models
2. **Web Audio API**: Browser audio capture and processing
3. **Service Workers**: Background processing capabilities
4. **File API**: Browser file access limitations

## Monitoring and Success Criteria

### Metrics to Track

1. **Platform parity**: Feature consistency across platforms
2. **Performance**: Platform-specific performance optimizations
3. **Error rates**: Platform-specific error frequency
4. **Developer experience**: API usage patterns across platforms

### Success Indicators

- [ ] Consistent behavior across all supported platforms
- [ ] Platform-specific optimizations improve performance by >20%
- [ ] Easy addition of new platforms with <2 weeks development time
- [ ] Platform-specific error rates remain below 1%

## Related ADRs

- ADR-001: Error Handling Strategy (error propagation across platforms)
- ADR-003: Testing Approach (platform-specific testing strategies)

## References

- [Flutter Federated Plugins](https://docs.flutter.dev/development/packages-and-plugins/developing-packages#federated-plugins)
- [Platform Channels](https://docs.flutter.dev/development/platform-integration/platform-channels)
- [Plugin Architecture Patterns](https://flutter.dev/docs/development/packages-and-plugins/plugin-api-migration)
