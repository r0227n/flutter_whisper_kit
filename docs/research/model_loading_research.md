# WhisperKit Model Loading Research

## Table of Contents
- [Introduction](#introduction)
- [Overview of WhisperKit's loadModel Function](#overview-of-whisperkits-loadmodel-function)
- [Implementation Options](#implementation-options)
  - [Swift Implementation](#swift-implementation)
  - [Dart Implementation](#dart-implementation)
  - [Comparison](#comparison)
- [Model Storage Options](#model-storage-options)
  - [Package Directory Storage](#package-directory-storage)
  - [User Folder Storage](#user-folder-storage)
  - [Comparison](#comparison-1)
- [Recommended Approach](#recommended-approach)
- [Sample Code](#sample-code)
  - [Swift Implementation Example](#swift-implementation-example)
  - [Dart Implementation Example](#dart-implementation-example)
- [References](#references)

## Introduction
This document presents research on implementing WhisperKit's model loading functionality in the Flutter WhisperKit Apple plugin. We examine the original `loadModel` function from WhisperKit's example project, compare Swift and Dart implementation options, and analyze different strategies for model storage locations.

## Overview of WhisperKit's loadModel Function
The `loadModel` function in WhisperKit's example project handles:
1. Configuring WhisperKit with compute options
2. Checking if the model is available locally
3. Downloading the model if not available locally
4. Loading and prewarming the model
5. Updating application state during the process

Key components of the function include:

```swift
func loadModel(_ model: String, redownload: Bool = false) {
    // Create a configuration
    whisperKit = nil
    Task {
        let config = WhisperKitConfig(computeOptions: getComputeOptions(),
                                      verbose: true,
                                      logLevel: .debug,
                                      prewarm: false,
                                      load: false,
                                      download: false)
        whisperKit = try await WhisperKit(config)
        
        // Check local models or download
        var folder: URL?
        if localModels.contains(model) && !redownload {
            folder = URL(fileURLWithPath: localModelPath).appendingPathComponent(model)
        } else {
            // Download the model
            folder = try await WhisperKit.download(variant: model, from: repoName, progressCallback: { progress in
                // Update UI with download progress
            })
        }
        
        // Set model folder and load models
        if let modelFolder = folder {
            whisperKit.modelFolder = modelFolder
            try await whisperKit.prewarmModels()
            try await whisperKit.loadModels()
        }
    }
}
```

## Implementation Options

### Swift Implementation
Implementing model loading in Swift provides direct access to WhisperKit's APIs.

**Advantages:**
- Direct access to native WhisperKit functionality
- No bridging overhead
- Full type safety and better error handling
- Seamless integration with WhisperKit updates
- Better performance for compute-intensive operations

**Disadvantages:**
- Platform-specific code (iOS/macOS only)
- Requires Pigeon to expose functionality to Dart
- Might require duplicate Swift code for iOS and macOS platforms
- Less control from Flutter side

### Dart Implementation
Implementing model loading in Dart would involve creating platform channel methods to handle model operations.

**Advantages:**
- Unified code across platforms
- More control from Flutter side
- Better integration with Flutter state management
- Easier to extend to other platforms in the future
- More familiar to Flutter developers

**Disadvantages:**
- Requires complex platform channel communication
- Performance overhead from bridging
- Duplicate implementation of WhisperKit functionality
- Limited access to platform-specific features
- More complex error handling across platform boundaries

### Comparison
| Aspect | Swift | Dart |
|--------|-------|------|
| Performance | Higher | Lower due to bridging |
| Development Complexity | Lower for iOS/macOS developers | Lower for Flutter developers |
| Maintainability | Better aligned with WhisperKit updates | May require updates with WhisperKit changes |
| Cross-platform | iOS/macOS only | Better architecture for multi-platform |
| Error Handling | Direct access to errors | Errors must be mapped across platforms |
| UI Integration | Requires bridging for UI updates | Direct integration with Flutter UI |

## Model Storage Options

### Package Directory Storage
Storing models within the app's package directory.

**Advantages:**
- Models are contained within the application
- Simplifies installation and updates
- Better security as models are in protected app space
- No permission issues for accessing models
- Clear lifecycle management (models removed when app is uninstalled)

**Disadvantages:**
- Uses application storage space
- Models not shared between applications
- Requires re-download for each application
- Models lost when application is uninstalled
- Limited visibility to users

### User Folder Storage
Storing models in user-accessible locations like Documents or Downloads folders.

**Advantages:**
- Models can be shared between applications
- Models persist beyond application lifecycle
- Visible to users (transparency)
- Can be manually managed by users
- Reduces duplicate downloads across applications

**Disadvantages:**
- Requires permission management
- Risk of user accidentally deleting or modifying models
- More complex path handling
- Platform-specific implementation differences
- Requires handling missing models if user deletes them

### Comparison
| Aspect | Package Directory | User Folder |
|--------|-------------------|-------------|
| Security | Higher (protected space) | Lower (user access) |
| Visibility | Hidden from user | Visible to user |
| Persistence | Tied to app lifecycle | Independent of app |
| Sharing | Not possible | Possible between apps |
| Storage Usage | Duplicated across apps | Can be shared |
| User Control | Limited | Full access |

## Recommended Approach
Based on the research, we recommend a **Swift implementation** with **optional user folder storage**:

1. Implement the core model loading functionality in Swift for direct WhisperKit integration
2. Use Pigeon to expose a configurable API to the Flutter side
3. Allow configuration of model storage location (package or user folder) with package directory as default
4. Provide progress updates and status information via event channels to the Flutter side

This approach combines the performance benefits of Swift implementation while providing flexibility for storage location based on the use case.

## Sample Code

### Swift Implementation Example

```swift
// WhisperKitModelLoader.swift
import WhisperKit
import Foundation

class WhisperKitModelLoader {
    enum ModelStorageLocation {
        case packageDirectory
        case userFolder
    }
    
    private var whisperKit: WhisperKit?
    private var modelStorageLocation: ModelStorageLocation = .packageDirectory
    
    func setStorageLocation(_ location: ModelStorageLocation) {
        modelStorageLocation = location
    }
    
    func loadModel(
        variant: String,
        modelRepo: String = "argmaxinc/whisperkit-coreml",
        redownload: Bool = false,
        progressCallback: @escaping (Float) -> Void,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        Task {
            do {
                // 1. Initialize WhisperKit with configuration
                let config = WhisperKitConfig(
                    verbose: true,
                    logLevel: .debug,
                    prewarm: false,
                    load: false,
                    download: false
                )
                whisperKit = try await WhisperKit(config)
                
                guard let whisperKit = whisperKit else {
                    throw NSError(domain: "WhisperKitError", code: 1001, userInfo: [
                        NSLocalizedDescriptionKey: "Failed to initialize WhisperKit"
                    ])
                }
                
                // 2. Determine model folder location
                var modelFolder: URL?
                let localModels = await getLocalModels()
                
                if localModels.contains(variant) && !redownload {
                    // Use existing model
                    modelFolder = getModelFolderPath().appendingPathComponent(variant)
                } else {
                    // Download the model
                    progressCallback(0.1)
                    modelFolder = try await WhisperKit.download(
                        variant: variant,
                        from: modelRepo,
                        progressCallback: { progress in
                            progressCallback(Float(progress.fractionCompleted) * 0.7)
                        }
                    )
                }
                
                // 3. Set model folder and load models
                if let folder = modelFolder {
                    whisperKit.modelFolder = folder
                    
                    progressCallback(0.8)
                    // Prewarm models
                    try await whisperKit.prewarmModels()
                    
                    progressCallback(0.9)
                    // Load models
                    try await whisperKit.loadModels()
                    
                    progressCallback(1.0)
                    completion(.success("Model loaded successfully"))
                } else {
                    throw NSError(domain: "WhisperKitError", code: 1002, userInfo: [
                        NSLocalizedDescriptionKey: "Failed to get model folder"
                    ])
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    private func getModelFolderPath() -> URL {
        switch modelStorageLocation {
        case .packageDirectory:
            // Use application support directory
            if let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
                let modelDir = appSupport.appendingPathComponent("WhisperKitModels")
                try? FileManager.default.createDirectory(at: modelDir, withIntermediateDirectories: true)
                return modelDir
            }
            // Fallback to documents
            return getDocumentsDirectory().appendingPathComponent("WhisperKitModels")
            
        case .userFolder:
            // Use Downloads folder
            if let downloads = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first {
                let modelDir = downloads.appendingPathComponent("WhisperKitModels")
                try? FileManager.default.createDirectory(at: modelDir, withIntermediateDirectories: true)
                return modelDir
            }
            // Fallback to documents
            return getDocumentsDirectory().appendingPathComponent("WhisperKitModels")
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private func getLocalModels() async -> [String] {
        let modelPath = getModelFolderPath()
        var localModels: [String] = []
        
        do {
            if FileManager.default.fileExists(atPath: modelPath.path) {
                let contents = try FileManager.default.contentsOfDirectory(atPath: modelPath.path)
                localModels = contents
            }
        } catch {
            print("Error checking local models: \(error.localizedDescription)")
        }
        
        return WhisperKit.formatModelFiles(localModels)
    }
}
```

### Dart Implementation Example

```dart
// whisper_kit_model_loader.dart
import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

enum ModelStorageLocation {
  packageDirectory,
  userFolder
}

class WhisperKitModelLoader {
  static const MethodChannel _channel = MethodChannel('flutter_whisper_kit_apple/model_loader');
  static const EventChannel _progressChannel = EventChannel('flutter_whisper_kit_apple/model_progress');
  
  ModelStorageLocation storageLocation = ModelStorageLocation.packageDirectory;
  
  Stream<double> get progressStream => _progressChannel.receiveBroadcastStream().map((event) => event as double);
  
  Future<void> setStorageLocation(ModelStorageLocation location) async {
    storageLocation = location;
    await _channel.invokeMethod('setStorageLocation', {
      'location': location.index,
    });
  }
  
  Future<String> loadModel({
    required String variant,
    String modelRepo = 'argmaxinc/whisperkit-coreml',
    bool redownload = false,
    Function(double progress)? onProgress,
  }) async {
    try {
      // Subscribe to progress updates if callback provided
      StreamSubscription? progressSubscription;
      if (onProgress != null) {
        progressSubscription = progressStream.listen(onProgress);
      }
      
      // Call platform-specific implementation
      final result = await _channel.invokeMethod('loadModel', {
        'variant': variant,
        'modelRepo': modelRepo,
        'redownload': redownload,
        'storageLocation': storageLocation.index,
      });
      
      // Clean up subscription
      await progressSubscription?.cancel();
      
      return result as String;
    } on PlatformException catch (e) {
      throw Exception('Failed to load model: ${e.message}');
    }
  }
  
  Future<List<String>> getAvailableModels() async {
    try {
      final result = await _channel.invokeMethod('getAvailableModels');
      return List<String>.from(result as List);
    } on PlatformException catch (e) {
      throw Exception('Failed to get available models: ${e.message}');
    }
  }
  
  Future<String> getModelStoragePath() async {
    switch (storageLocation) {
      case ModelStorageLocation.packageDirectory:
        final directory = await getApplicationSupportDirectory();
        final modelDir = Directory('${directory.path}/WhisperKitModels');
        if (!await modelDir.exists()) {
          await modelDir.create(recursive: true);
        }
        return modelDir.path;
        
      case ModelStorageLocation.userFolder:
        if (Platform.isIOS || Platform.isMacOS) {
          final directory = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
          final modelDir = Directory('${directory.path}/WhisperKitModels');
          if (!await modelDir.exists()) {
            await modelDir.create(recursive: true);
          }
          return modelDir.path;
        } else {
          // Fallback for unsupported platforms
          final directory = await getApplicationDocumentsDirectory();
          final modelDir = Directory('${directory.path}/WhisperKitModels');
          if (!await modelDir.exists()) {
            await modelDir.create(recursive: true);
          }
          return modelDir.path;
        }
    }
  }
}
```

## References
1. WhisperKit GitHub Repository: https://github.com/argmaxinc/WhisperKit
2. Flutter Plugin Development: https://docs.flutter.dev/packages-and-plugins/developing-packages
3. Pigeon for Type-Safe Platform Channels: https://pub.dev/packages/pigeon
4. Apple File System Programming Guide: https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/Introduction/Introduction.html
