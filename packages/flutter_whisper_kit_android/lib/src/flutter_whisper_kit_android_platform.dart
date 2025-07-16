/// Android platform implementation for FlutterWhisperKit
/// 
/// SOLID Principles Implementation:
/// - SRP: Single responsibility for Android platform abstraction
/// - OCP: Open for extension through interface pattern
/// - LSP: Substitutable implementation for base platform interface
/// - ISP: Interface segregation will be applied when implementing WhisperKit API
/// - DIP: Depends on abstractions (will implement platform interface)
/// 
/// Following flutter_whisper_kit_apple architecture pattern.
abstract interface class PlatformInfo {
  /// Package identifier
  String get packageName;
  
  /// Version information
  String get version;
  
  /// Platform detection
  bool get isPlatformSupported;
}

/// Android-specific platform implementation
/// 
/// SRP: Responsible only for Android platform identification and info
class FlutterWhisperKitAndroidPlatform implements PlatformInfo {
  const FlutterWhisperKitAndroidPlatform();
  
  @override
  String get packageName => 'flutter_whisper_kit_android';
  
  @override
  String get version => '0.1.0';
  
  @override
  bool get isPlatformSupported => true;
  
  /// Factory constructor for dependency injection
  /// DIP: Allows injection of platform-specific implementations
  static PlatformInfo create() => const FlutterWhisperKitAndroidPlatform();
}