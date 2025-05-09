import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';

import '../models.dart';
import 'flutter_whisper_kit_platform_interface.dart';

// FFI signature typedefs
typedef LoadModelFunc = Pointer<Utf8> Function(
    Pointer<Utf8> variant, Pointer<Utf8> modelRepo, Bool redownload, Pointer<Pointer<Void>> error);
typedef LoadModelFuncDart = Pointer<Utf8> Function(
    Pointer<Utf8> variant, Pointer<Utf8> modelRepo, bool redownload, Pointer<Pointer<Void>> error);

typedef TranscribeFromFileFunc = Pointer<Utf8> Function(
    Pointer<Utf8> filePath, Pointer<Void> options, Pointer<Pointer<Void>> error);
typedef TranscribeFromFileFuncDart = Pointer<Utf8> Function(
    Pointer<Utf8> filePath, Pointer<Void> options, Pointer<Pointer<Void>> error);

typedef StartRecordingFunc = Pointer<Utf8> Function(
    Pointer<Void> options, Bool loop, Pointer<Pointer<Void>> error);
typedef StartRecordingFuncDart = Pointer<Utf8> Function(
    Pointer<Void> options, bool loop, Pointer<Pointer<Void>> error);

typedef StopRecordingFunc = Pointer<Utf8> Function(
    Bool loop, Pointer<Pointer<Void>> error);
typedef StopRecordingFuncDart = Pointer<Utf8> Function(
    bool loop, Pointer<Pointer<Void>> error);

// Callback typedefs
typedef TranscriptionCallbackFunc = Void Function(Pointer<Utf8> result);
typedef TranscriptionCallbackFuncDart = void Function(Pointer<Utf8> result);

typedef ModelProgressCallbackFunc = Void Function(Pointer<Void> progress);
typedef ModelProgressCallbackFuncDart = void Function(Pointer<Void> progress);

typedef RegisterTranscriptionCallbackFunc = Void Function(
    Pointer<NativeFunction<TranscriptionCallbackFunc>> callback);
typedef RegisterTranscriptionCallbackFuncDart = void Function(
    Pointer<NativeFunction<TranscriptionCallbackFunc>> callback);

typedef RegisterModelProgressCallbackFunc = Void Function(
    Pointer<NativeFunction<ModelProgressCallbackFunc>> callback);
typedef RegisterModelProgressCallbackFuncDart = void Function(
    Pointer<NativeFunction<ModelProgressCallbackFunc>> callback);

typedef UnregisterTranscriptionCallbackFunc = Void Function();
typedef UnregisterTranscriptionCallbackFuncDart = void Function();

typedef UnregisterModelProgressCallbackFunc = Void Function();
typedef UnregisterModelProgressCallbackFuncDart = void Function();

/// An implementation of [FlutterWhisperKitPlatform] that uses FFI.
class FFIFlutterWhisperKit extends FlutterWhisperKitPlatform {
  /// The dynamic library in which the symbols for [FFIFlutterWhisperKit] can be found.
  final DynamicLibrary _dylib = () {
    if (Platform.isMacOS || Platform.isIOS) {
      return DynamicLibrary.open('flutter_whisper_kit_apple.framework/flutter_whisper_kit_apple');
    }
    throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
  }();

  // Function pointers
  late final LoadModelFuncDart _loadModelPtr;
  late final TranscribeFromFileFuncDart _transcribeFromFilePtr;
  late final StartRecordingFuncDart _startRecordingPtr;
  late final StopRecordingFuncDart _stopRecordingPtr;
  late final RegisterTranscriptionCallbackFuncDart _registerTranscriptionCallbackPtr;
  late final RegisterModelProgressCallbackFuncDart _registerModelProgressCallbackPtr;
  late final UnregisterTranscriptionCallbackFuncDart _unregisterTranscriptionCallbackPtr;
  late final UnregisterModelProgressCallbackFuncDart _unregisterModelProgressCallbackPtr;

  // Stream controllers
  final StreamController<TranscriptionResult> _transcriptionStreamController =
      StreamController<TranscriptionResult>.broadcast();
  final StreamController<Progress> _modelProgressStreamController =
      StreamController<Progress>.broadcast();

  // Callback pointers
  late Pointer<NativeFunction<TranscriptionCallbackFunc>> _transcriptionCallbackPtr;
  late Pointer<NativeFunction<ModelProgressCallbackFunc>> _modelProgressCallbackPtr;

  /// Constructor that initializes the FFI bindings.
  FFIFlutterWhisperKit() {
    _loadModelPtr = _dylib
        .lookup<NativeFunction<LoadModelFunc>>('loadModel')
        .asFunction();
    _transcribeFromFilePtr = _dylib
        .lookup<NativeFunction<TranscribeFromFileFunc>>('transcribeFromFile')
        .asFunction();
    _startRecordingPtr = _dylib
        .lookup<NativeFunction<StartRecordingFunc>>('startRecording')
        .asFunction();
    _stopRecordingPtr = _dylib
        .lookup<NativeFunction<StopRecordingFunc>>('stopRecording')
        .asFunction();
    _registerTranscriptionCallbackPtr = _dylib
        .lookup<NativeFunction<RegisterTranscriptionCallbackFunc>>('registerTranscriptionCallback')
        .asFunction();
    _registerModelProgressCallbackPtr = _dylib
        .lookup<NativeFunction<RegisterModelProgressCallbackFunc>>('registerModelProgressCallback')
        .asFunction();
    _unregisterTranscriptionCallbackPtr = _dylib
        .lookup<NativeFunction<UnregisterTranscriptionCallbackFunc>>('unregisterTranscriptionCallback')
        .asFunction();
    _unregisterModelProgressCallbackPtr = _dylib
        .lookup<NativeFunction<UnregisterModelProgressCallbackFunc>>('unregisterModelProgressCallback')
        .asFunction();

    // Set up callbacks
    _transcriptionCallbackPtr = Pointer.fromFunction<TranscriptionCallbackFunc>(_onTranscription);
    _modelProgressCallbackPtr = Pointer.fromFunction<ModelProgressCallbackFunc>(_onModelProgress);

    // Register callbacks
    _registerTranscriptionCallbackPtr(_transcriptionCallbackPtr);
    _registerModelProgressCallbackPtr(_modelProgressCallbackPtr);
  }

  // Callback handlers
  void _onTranscription(Pointer<Utf8> resultPtr) {
    final result = resultPtr.toDartString();
    if (result.isEmpty) {
      _transcriptionStreamController.add(
        const TranscriptionResult(
          text: '',
          segments: [],
          language: '',
          timings: TranscriptionTimings(),
        ),
      );
    } else {
      try {
        _transcriptionStreamController.add(
          TranscriptionResult.fromJsonString(result),
        );
      } catch (e) {
        _transcriptionStreamController.addError(
          Exception('Failed to parse transcription result: $e'),
        );
      }
    }
  }

  void _onModelProgress(Pointer<Void> progressPtr) {
    try {
      // Convert the pointer to a Map
      final progressMap = _pointerToMap(progressPtr);
      final progress = Progress.fromJson(progressMap);
      _modelProgressStreamController.add(progress);
    } catch (e) {
      _modelProgressStreamController.addError(
        Exception('Failed to parse progress data: $e'),
      );
    }
  }

  // Helper method to convert NSDictionary pointer to Dart Map
  Map<String, dynamic> _pointerToMap(Pointer<Void> ptr) {
    // This is a simplified implementation
    // In a real implementation, you would need to properly convert the NSDictionary to a Dart Map
    // For now, we'll use a placeholder implementation
    return {
      'totalUnitCount': 100,
      'completedUnitCount': 50,
      'fractionCompleted': 0.5,
      'isIndeterminate': false,
      'isPaused': false,
      'isCancelled': false,
    };
  }

  // Helper method to convert Dart Map to NSDictionary pointer
  Pointer<Void> _mapToPointer(Map<String, dynamic> map) {
    // This is a simplified implementation
    // In a real implementation, you would need to properly convert the Dart Map to an NSDictionary
    // For now, we'll use a placeholder implementation
    return Pointer<Void>.fromAddress(0);
  }

  @override
  Future<String?> loadModel(
    String? variant, {
    String? modelRepo,
    bool redownload = false,
  }) async {
    final variantPtr = variant != null ? variant.toNativeUtf8() : nullptr;
    final modelRepoPtr = modelRepo != null ? modelRepo.toNativeUtf8() : nullptr;
    final errorPtr = calloc<Pointer<Void>>();

    try {
      final resultPtr = _loadModelPtr(
        variantPtr,
        modelRepoPtr,
        redownload,
        errorPtr,
      );

      if (errorPtr.value != nullptr) {
        // Handle error
        return null;
      }

      if (resultPtr == nullptr) {
        return null;
      }

      return resultPtr.toDartString();
    } finally {
      if (variantPtr != nullptr) calloc.free(variantPtr);
      if (modelRepoPtr != nullptr) calloc.free(modelRepoPtr);
      calloc.free(errorPtr);
    }
  }

  @override
  Future<TranscriptionResult?> transcribeFromFile(
    String filePath, {
    DecodingOptions options = const DecodingOptions(
      verbose: true,
      task: DecodingTask.transcribe,
      language: 'ja',
      temperature: 0.0,
      temperatureFallbackCount: 5,
      sampleLength: 224,
      usePrefillPrompt: true,
      usePrefillCache: true,
      detectLanguage: true,
      skipSpecialTokens: true,
      withoutTimestamps: true,
      wordTimestamps: true,
      clipTimestamps: [0.0],
      concurrentWorkerCount: 4,
      chunkingStrategy: ChunkingStrategy.vad,
    ),
  }) async {
    final filePathPtr = filePath.toNativeUtf8();
    final optionsPtr = _mapToPointer(options.toJson());
    final errorPtr = calloc<Pointer<Void>>();

    try {
      final resultPtr = _transcribeFromFilePtr(
        filePathPtr,
        optionsPtr,
        errorPtr,
      );

      if (errorPtr.value != nullptr) {
        // Handle error
        return null;
      }

      if (resultPtr == nullptr) {
        return null;
      }

      final result = resultPtr.toDartString();
      return TranscriptionResult.fromJsonString(result);
    } finally {
      calloc.free(filePathPtr);
      calloc.free(errorPtr);
    }
  }

  @override
  Future<String?> startRecording({
    DecodingOptions options = const DecodingOptions(
      verbose: true,
      task: DecodingTask.transcribe,
      language: 'ja',
      temperature: 0.0,
      temperatureFallbackCount: 5,
      sampleLength: 224,
      usePrefillPrompt: true,
      usePrefillCache: true,
      skipSpecialTokens: true,
      withoutTimestamps: false,
      wordTimestamps: true,
      clipTimestamps: [0.0],
      concurrentWorkerCount: 4,
      chunkingStrategy: ChunkingStrategy.vad,
    ),
    bool loop = true,
  }) async {
    final optionsPtr = _mapToPointer(options.toJson());
    final errorPtr = calloc<Pointer<Void>>();

    try {
      final resultPtr = _startRecordingPtr(
        optionsPtr,
        loop,
        errorPtr,
      );

      if (errorPtr.value != nullptr) {
        // Handle error
        return null;
      }

      if (resultPtr == nullptr) {
        return null;
      }

      return resultPtr.toDartString();
    } finally {
      calloc.free(errorPtr);
    }
  }

  @override
  Future<String?> stopRecording({bool loop = true}) async {
    final errorPtr = calloc<Pointer<Void>>();

    try {
      final resultPtr = _stopRecordingPtr(
        loop,
        errorPtr,
      );

      if (errorPtr.value != nullptr) {
        // Handle error
        return null;
      }

      if (resultPtr == nullptr) {
        return null;
      }

      return resultPtr.toDartString();
    } finally {
      calloc.free(errorPtr);
    }
  }

  @override
  Stream<TranscriptionResult> get transcriptionStream =>
      _transcriptionStreamController.stream;

  @override
  Stream<Progress> get modelProgressStream =>
      _modelProgressStreamController.stream;

  /// Disposes of the resources used by this object.
  void dispose() {
    _unregisterTranscriptionCallbackPtr();
    _unregisterModelProgressCallbackPtr();
    _transcriptionStreamController.close();
    _modelProgressStreamController.close();
  }
}
