# Policy for Implementing fetchModelSupportConfig in Dart

## Overview

This document outlines the policy for implementing the `fetchModelSupportConfig` function in Dart for the flutter_whisperkit plugin. While the original evaluation recommended a Swift implementation, this policy provides guidelines for a Dart-centric approach that maintains cross-platform compatibility, robust error handling, and offline support.

## Architecture

### 1. Layered Architecture

Implement a layered architecture with clear separation of concerns:

```
┌─────────────────────────────────┐
│ Dart API Layer                  │
│ (Public interface for Flutter apps) │
├─────────────────────────────────┤
│ Model Support Service           │
│ (Business logic, caching)       │
├─────────────────────────────────┤
│ Platform Channel Layer          │
│ (Communication with native code)│
└─────────────────────────────────┘
```

### 2. Core Components

1. **ModelSupportConfig Class**: A Dart representation of WhisperKit's ModelSupportConfig
2. **ModelSupportService**: Handles fetching, caching, and providing model configurations
3. **PlatformChannelHandler**: Manages communication with platform-specific code

## Implementation Guidelines

### 1. ModelSupportConfig Class

Create a Dart class that mirrors the Swift ModelSupportConfig structure:

```dart
class ModelSupportConfig {
  final Map<String, DeviceSupportInfo> deviceSupport;
  final Map<String, ModelInfo> modelInfo;
  
  // Constructor, serialization methods, utility functions
}

class DeviceSupportInfo {
  final List<String> supportedModels;
  final Map<String, dynamic> capabilities;
  
  // Constructor, serialization methods
}

class ModelInfo {
  final String name;
  final String url;
  final Map<String, dynamic> metadata;
  
  // Constructor, serialization methods
}
```

### 2. Platform Channel Communication

1. Define clear method channel interfaces for platform-specific operations:
   - Network requests (when platform-specific implementations are needed)
   - Device capability detection
   - File system operations for caching

2. Use Pigeon for type-safe communication between Dart and native code:
   - Define API interfaces in Pigeon
   - Generate type-safe code for both Dart and Swift
   - Ensure consistent error handling across platforms

### 3. Error Handling Strategy

Implement a comprehensive error handling strategy:

1. **Error Types**: Define specific error types for different failure scenarios:
   ```dart
   enum ModelSupportConfigError {
     networkError,
     parsingError,
     fileSystemError,
     invalidConfiguration,
     unsupportedDevice,
     // Additional error types as needed
   }
   ```

2. **Result Type**: Use a Result type for error handling:
   ```dart
   class Result<T> {
     final T? data;
     final ModelSupportConfigError? error;
     final String? message;
     
     bool get isSuccess => error == null;
     
     // Constructor and utility methods
   }
   ```

3. **Error Reporting**: Provide detailed error information to help diagnose issues:
   - Error type
   - Error message
   - Stack trace (in debug mode)
   - Suggestions for resolution

### 4. Offline Support

Implement robust caching for offline support:

1. **Cache Strategy**:
   - Cache the configuration file locally
   - Use a timestamp to determine when to refresh
   - Implement a configurable refresh policy

2. **Cache Implementation**:
   - Use `shared_preferences` for small configuration data
   - Use file system for larger configuration files
   - Implement encryption for sensitive configuration data if needed

3. **Cache Invalidation**:
   - Allow manual cache invalidation
   - Implement automatic invalidation based on version changes
   - Provide hooks for custom invalidation logic

### 5. Configuration Source Hierarchy

Implement a hierarchical approach to configuration sources:

1. In-memory cache (fastest)
2. Local file cache
3. Network request to specified repository
4. Default fallback configuration (hardcoded)

### 6. Testing Strategy

Implement a comprehensive testing strategy:

1. **Unit Tests**:
   - Test each component in isolation
   - Mock dependencies for deterministic testing
   - Test error handling paths

2. **Integration Tests**:
   - Test the interaction between components
   - Test caching behavior
   - Test offline behavior

3. **Platform Tests**:
   - Test platform-specific behavior
   - Test on different device types

## API Design

### Public API

```dart
/// Fetches model support configuration from the specified repository.
/// 
/// Parameters:
/// - [repo]: The repository to fetch the configuration from (default: "argmaxinc/whisperkit-coreml")
/// - [downloadBase]: Optional base URL for downloads
/// - [forceRefresh]: Whether to force a refresh from the network (default: false)
/// 
/// Returns a [Future<Result<ModelSupportConfig>>] containing either the configuration or an error.
Future<Result<ModelSupportConfig>> fetchModelSupportConfig({
  String repo = "argmaxinc/whisperkit-coreml",
  String? downloadBase,
  bool forceRefresh = false,
});
```

### Internal Service API

```dart
class ModelSupportService {
  /// Fetches model support configuration from the specified repository.
  Future<Result<ModelSupportConfig>> fetchConfig({
    String repo = "argmaxinc/whisperkit-coreml",
    String? downloadBase,
    bool forceRefresh = false,
  });
  
  /// Clears the cached configuration.
  Future<void> clearCache();
  
  /// Gets the cached configuration if available.
  Future<ModelSupportConfig?> getCachedConfig();
  
  /// Checks if the device supports the specified model.
  Future<bool> isModelSupported(String modelName);
  
  /// Gets the list of supported models for the current device.
  Future<List<String>> getSupportedModels();
}
```

## Implementation Steps

1. Define the Dart models for ModelSupportConfig
2. Implement the platform channel communication using Pigeon
3. Create the ModelSupportService with caching logic
4. Implement error handling and result types
5. Add the public API to the flutter_whisperkit package
6. Write comprehensive tests for all components
7. Document the API and usage examples

## Cross-Platform Considerations

While the initial implementation will focus on Apple platforms (iOS/macOS), the architecture should be designed to support additional platforms in the future:

1. Use platform-specific implementations behind a common interface
2. Isolate platform-specific code in separate packages
3. Use feature detection to handle platform differences
4. Provide sensible defaults for unsupported platforms

## Performance Considerations

1. Minimize serialization/deserialization overhead
2. Use efficient caching mechanisms
3. Implement lazy loading for large configurations
4. Optimize network requests with appropriate headers and caching

## Security Considerations

1. Validate configuration data before use
2. Implement secure storage for sensitive configuration data
3. Use HTTPS for all network requests
4. Implement proper error handling to prevent information leakage

## Conclusion

This policy provides a comprehensive approach to implementing the fetchModelSupportConfig function in Dart. By following these guidelines, the implementation will be robust, maintainable, and extensible while providing a consistent API for Flutter applications.
