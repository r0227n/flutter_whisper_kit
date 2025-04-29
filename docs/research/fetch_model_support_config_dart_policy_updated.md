# Policy for Implementing fetchModelSupportConfig in Dart with huggingface_client

## Overview

This document outlines the policy for implementing the `fetchModelSupportConfig` function in Dart for the flutter_whisperkit plugin using the `huggingface_client` package. This approach provides a standardized way to interact with Hugging Face repositories while maintaining cross-platform compatibility, robust error handling, and offline support.

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
│ HuggingFace Client Layer        │
│ (Communication with HF API)     │
└─────────────────────────────────┘
```

### 2. Core Components

1. **ModelSupportConfig Class**: A Dart representation of WhisperKit's ModelSupportConfig
2. **ModelSupportService**: Handles fetching, caching, and providing model configurations
3. **HuggingFaceClient**: Manages communication with the Hugging Face API

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

### 2. HuggingFace Client Integration

1. **Package Dependency**:
   Add the `huggingface_client` package to the pubspec.yaml:
   ```yaml
   dependencies:
     huggingface_client: ^latest_version
   ```

2. **Client Configuration**:
   ```dart
   import 'package:huggingface_client/huggingface_client.dart';

   class HuggingFaceService {
     final HuggingFaceClient _client;
     
     HuggingFaceService({String? token}) 
         : _client = HuggingFaceClient(token: token);
     
     // Methods for interacting with Hugging Face API
   }
   ```

3. **File Fetching**:
   ```dart
   Future<Result<String>> fetchConfigFile({
     required String repo,
     String path = 'config.json',
     String? revision,
   }) async {
     try {
       final response = await _client.getRepositoryFile(
         repo: repo,
         path: path,
         revision: revision,
       );
       
       return Result.success(response);
     } catch (e) {
       return Result.failure(
         ModelSupportConfigError.networkError,
         'Failed to fetch config file: ${e.toString()}',
       );
     }
   }
   ```

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
     huggingFaceApiError,
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
     factory Result.success(T data) => Result(data: data);
     factory Result.failure(ModelSupportConfigError error, [String? message]) => 
         Result(error: error, message: message);
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
3. Hugging Face API request to specified repository
4. Default fallback configuration (hardcoded)

### 6. Testing Strategy

Implement a comprehensive testing strategy:

1. **Unit Tests**:
   - Test each component in isolation
   - Mock the HuggingFaceClient for deterministic testing
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
/// - [configPath]: Path to the configuration file in the repository (default: "config.json")
/// - [revision]: Optional branch or commit hash
/// - [token]: Optional Hugging Face API token
/// - [forceRefresh]: Whether to force a refresh from the network (default: false)
/// 
/// Returns a [Future<Result<ModelSupportConfig>>] containing either the configuration or an error.
Future<Result<ModelSupportConfig>> fetchModelSupportConfig({
  String repo = "argmaxinc/whisperkit-coreml",
  String configPath = "config.json",
  String? revision,
  String? token,
  bool forceRefresh = false,
});
```

### Internal Service API

```dart
class ModelSupportService {
  final HuggingFaceService _huggingFaceService;
  final CacheService _cacheService;
  
  ModelSupportService({
    HuggingFaceService? huggingFaceService,
    CacheService? cacheService,
  }) : _huggingFaceService = huggingFaceService ?? HuggingFaceService(),
       _cacheService = cacheService ?? CacheService();
  
  /// Fetches model support configuration from the specified repository.
  Future<Result<ModelSupportConfig>> fetchConfig({
    String repo = "argmaxinc/whisperkit-coreml",
    String configPath = "config.json",
    String? revision,
    String? token,
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

1. Add the `huggingface_client` package to pubspec.yaml
2. Define the Dart models for ModelSupportConfig
3. Implement the HuggingFaceService for fetching configuration files
4. Create the ModelSupportService with caching logic
5. Implement error handling and result types
6. Add the public API to the flutter_whisperkit package
7. Write comprehensive tests for all components
8. Document the API and usage examples

## HuggingFace Client Integration Details

### 1. Authentication

```dart
// Initialize with token
final hfService = HuggingFaceService(token: 'your_hf_token');

// Or use environment variable
final hfService = HuggingFaceService();
```

### 2. Fetching Configuration

```dart
// Fetch configuration file
final result = await hfService.fetchConfigFile(
  repo: 'argmaxinc/whisperkit-coreml',
  path: 'config.json',
);

// Parse configuration
if (result.isSuccess) {
  final config = ModelSupportConfig.fromJson(jsonDecode(result.data!));
  // Use configuration
} else {
  // Handle error
  print('Error: ${result.error} - ${result.message}');
}
```

### 3. Error Handling

```dart
// Handle specific error types
switch (result.error) {
  case ModelSupportConfigError.networkError:
    // Handle network error
    break;
  case ModelSupportConfigError.huggingFaceApiError:
    // Handle API error
    break;
  // Handle other error types
}
```

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
5. Store Hugging Face API tokens securely

## Conclusion

This policy provides a comprehensive approach to implementing the fetchModelSupportConfig function in Dart using the huggingface_client package. By following these guidelines, the implementation will be robust, maintainable, and extensible while providing a consistent API for Flutter applications.
