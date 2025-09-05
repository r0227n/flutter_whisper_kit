import 'package:flutter_whisper_kit/src/models.dart';
import 'package:flutter_whisper_kit/src/services/model_management_service.dart';
import 'package:flutter_whisper_kit/src/services/recording_service.dart';
import 'package:flutter_whisper_kit/src/services/transcription_service.dart';
import 'package:flutter_whisper_kit/src/whisper_kit_error.dart';

/// Service class for Result-based API methods.
///
/// This class provides Result-based versions of the main API methods,
/// offering better error handling and more explicit success/failure states
/// instead of throwing exceptions.
class ResultApiService {
  ResultApiService({
    required ModelManagementService modelService,
    required RecordingService recordingService,
    required TranscriptionService transcriptionService,
  }) : _modelService = modelService,
       _recordingService = recordingService,
       _transcriptionService = transcriptionService;
  final ModelManagementService _modelService;
  final RecordingService _recordingService;
  final TranscriptionService _transcriptionService;

  /// Loads a WhisperKit model using the Result pattern.
  ///
  /// This is a new API that returns a Result type instead of throwing exceptions,
  /// providing better error handling and more explicit success/failure states.
  ///
  /// Parameters:
  /// - [variant]: The model variant to load.
  /// - [modelRepo]: The repository to download the model from.
  /// - [redownload]: Whether to force redownload the model.
  /// - [onProgress]: A callback function for download progress updates.
  ///
  /// Returns a [Result] containing either:
  /// - Success: The path to the loaded model folder
  /// - Failure: A [WhisperKitError] describing what went wrong
  ///
  /// Example:
  /// ```dart
  /// final result = await resultApiService.loadModelWithResult('tiny-en');
  /// result.when(
  ///   success: (modelPath) => print('Model loaded at: $modelPath'),
  ///   failure: (error) => print('Failed to load model: $error'),
  /// );
  /// ```
  Future<Result<String, WhisperKitError>> loadModelWithResult(
    String? variant, {
    String? modelRepo,
    bool redownload = false,
    Function(Progress progress)? onProgress,
  }) async {
    try {
      final modelPath = await _modelService.loadModel(
        variant,
        modelRepo: modelRepo,
        redownload: redownload,
        onProgress: onProgress,
      );

      if (modelPath == null) {
        return Failure(
          ModelLoadingFailedError(
            code: 1001,
            message: 'Model loading returned null',
          ),
        );
      }

      return Success(modelPath);
    } on WhisperKitError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(UnknownError(code: 1000, message: 'Unexpected error: $e'));
    }
  }

  /// Downloads a WhisperKit model using the Result pattern.
  ///
  /// This is a new API that returns a Result type instead of throwing exceptions,
  /// providing better error handling and more explicit success/failure states.
  ///
  /// Parameters:
  /// - [variant]: The model variant to download (required).
  /// - [downloadBase]: The base URL for downloads.
  /// - [useBackgroundSession]: Whether to use a background session for the download.
  /// - [repo]: The repository to download from (default: 'argmaxinc/whisperkit-coreml').
  /// - [token]: An access token for the repository.
  /// - [onProgress]: A callback function that receives download progress updates.
  ///
  /// Returns a [Result] containing either:
  /// - Success: The path to the downloaded model
  /// - Failure: A [WhisperKitError] describing what went wrong
  Future<Result<String, WhisperKitError>> downloadWithResult({
    required String variant,
    String? downloadBase,
    bool useBackgroundSession = false,
    String repo = 'argmaxinc/whisperkit-coreml',
    String? token,
    Function(Progress progress)? onProgress,
  }) async {
    try {
      final modelPath = await _modelService.download(
        variant: variant,
        downloadBase: downloadBase,
        useBackgroundSession: useBackgroundSession,
        repo: repo,
        token: token,
        onProgress: onProgress,
      );

      if (modelPath == null) {
        return Failure(
          ModelLoadingFailedError(
            code: 1000,
            message: 'Download failed: model path is null',
          ),
        );
      }

      return Success(modelPath);
    } on WhisperKitError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(UnknownError(code: 1000, message: 'Download failed: $e'));
    }
  }

  /// Fetches available WhisperKit models using the Result pattern.
  ///
  /// This is a new API that returns a Result type instead of throwing exceptions,
  /// providing better error handling and more explicit success/failure states.
  ///
  /// Parameters:
  /// - [modelRepo]: The repository to fetch models from (default: "argmaxinc/whisperkit-coreml").
  /// - [matching]: Optional list of glob patterns to filter models by (default: ['*']).
  /// - [token]: Optional access token for private repositories.
  ///
  /// Returns a [Result] containing either:
  /// - Success: A list of available model names
  /// - Failure: A [WhisperKitError] describing what went wrong
  Future<Result<List<String>, WhisperKitError>> fetchAvailableModelsWithResult({
    String modelRepo = 'argmaxinc/whisperkit-coreml',
    List<String> matching = const ['*'],
    String? token,
  }) async {
    try {
      final models = await _modelService.fetchAvailableModels(
        modelRepo: modelRepo,
        matching: matching,
        token: token,
      );

      return Success(models);
    } on WhisperKitError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(
        UnknownError(
          code: 1001,
          message: 'Failed to fetch available models: $e',
        ),
      );
    }
  }

  /// Starts audio recording using the Result pattern.
  ///
  /// This is a **Result-based API** that returns a [Result] type instead of
  /// throwing exceptions, providing better error handling and more explicit
  /// success/failure states for real-time audio capture.
  ///
  /// Parameters:
  /// - [loop]: Recording loop behavior (default: true)
  ///
  /// Returns a [Result] containing either:
  /// - Success: A success message indicating recording has started
  /// - Failure: A [WhisperKitError] with specific error code and message
  Future<Result<String, WhisperKitError>> startRecordingWithResult({
    bool loop = true,
  }) async {
    try {
      final result = await _recordingService.startRecording(loop: loop);

      if (result == null) {
        return Failure(
          RecordingFailedError(
            code: 2003,
            message: 'Failed to start recording: result is null',
          ),
        );
      }

      return Success(result);
    } on WhisperKitError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(
        RecordingFailedError(
          code: 2003,
          message: 'Failed to start recording: $e',
        ),
      );
    }
  }

  /// Stops audio recording using the Result pattern.
  ///
  /// This is a **Result-based API** that returns a [Result] type instead of
  /// throwing exceptions, providing better error handling and more explicit
  /// success/failure states for audio recording termination.
  ///
  /// Parameters:
  /// - [loop]: Recording loop behavior control (default: true)
  ///
  /// Returns a [Result] containing either:
  /// - Success: A success message indicating recording has stopped
  /// - Failure: A [WhisperKitError] with specific error code and message
  Future<Result<String, WhisperKitError>> stopRecordingWithResult({
    bool loop = true,
  }) async {
    try {
      final result = await _recordingService.stopRecording(loop: loop);

      if (result == null) {
        return Failure(
          RecordingFailedError(
            code: 2004,
            message: 'Failed to stop recording: result is null',
          ),
        );
      }

      return Success(result);
    } on WhisperKitError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(
        RecordingFailedError(
          code: 2004,
          message: 'Failed to stop recording: $e',
        ),
      );
    }
  }

  /// Transcribes an audio file using the Result pattern.
  ///
  /// This method provides a safer alternative to the throwing version,
  /// returning a Result that explicitly represents success or failure.
  ///
  /// Parameters:
  /// - [path]: The path to the audio file to transcribe.
  /// - [options]: Optional decoding options for transcription.
  /// - [onProgress]: Optional callback for transcription progress.
  ///
  /// Returns a [Result] containing either:
  /// - Success: A [TranscriptionResult] with the transcribed text
  /// - Failure: A [WhisperKitError] describing what went wrong
  Future<Result<TranscriptionResult?, WhisperKitError>>
  transcribeFileWithResult(
    String path, {
    DecodingOptions? options,
    Function(Progress progress)? onProgress,
  }) async {
    try {
      final result = await _transcriptionService.transcribeFromFile(
        path,
        options: options ?? const DecodingOptions(),
      );
      return Success(result);
    } on WhisperKitError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(
        TranscriptionFailedError(
          code: 2001,
          message: 'Transcription failed: $e',
        ),
      );
    }
  }

  /// Detects the language of an audio file using the Result pattern.
  ///
  /// Returns a [Result] containing either:
  /// - Success: A [LanguageDetectionResult] with detected language info
  /// - Failure: A [WhisperKitError] describing what went wrong
  Future<Result<LanguageDetectionResult?, WhisperKitError>>
  detectLanguageWithResult(String audioPath) async {
    try {
      final result = await _transcriptionService.detectLanguage(audioPath);
      return Success(result);
    } on WhisperKitError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(
        TranscriptionFailedError(
          code: 2002,
          message: 'Language detection failed: $e',
        ),
      );
    }
  }
}
