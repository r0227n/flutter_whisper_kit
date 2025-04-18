# API Reference

This page provides detailed documentation for the Flutter WhisperKit Apple plugin API.

## FlutterWhisperkitApple

The main class that serves as the entry point for the plugin.

### Methods

#### `Future<void> initializeWhisperKit()`

Initializes the WhisperKit framework.

**Returns:**
- `Future<void>`: Completes when initialization is successful or throws an exception if initialization fails.

**Throws:**
- `WhisperKitConfigError`: If there's an issue with the configuration.
- `PlatformException`: If there's an issue with the platform-specific implementation.

---

#### `Future<String?> getPlatformVersion()`

Gets the platform version.

**Returns:**
- `Future<String?>`: The platform version string.

---

#### `Future<TranscriptionResult> transcribeAudio({required String filePath, TranscriptionConfig? config})`

Transcribes audio from a file.

**Parameters:**
- `filePath` (required): Path to the audio file to transcribe.
- `config`: Optional configuration for the transcription.

**Returns:**
- `Future<TranscriptionResult>`: The transcription result.

**Throws:**
- `WhisperKitConfigError`: If there's an issue with the configuration.
- `PlatformException`: If there's an issue with the platform-specific implementation.

---

#### `Future<bool> requestAudioPermission()`

Requests permission to access the microphone.

**Returns:**
- `Future<bool>`: `true` if permission is granted, `false` otherwise.

---

#### `Future<void> startRecording({TranscriptionConfig? config})`

Starts recording audio for real-time transcription.

**Parameters:**
- `config`: Optional configuration for the transcription.

**Returns:**
- `Future<void>`: Completes when recording starts successfully or throws an exception if it fails.

**Throws:**
- `WhisperKitConfigError`: If there's an issue with the configuration.
- `PlatformException`: If there's an issue with the platform-specific implementation.

---

#### `Future<TranscriptionResult> stopRecording()`

Stops recording and returns the final transcription result.

**Returns:**
- `Future<TranscriptionResult>`: The final transcription result.

**Throws:**
- `PlatformException`: If there's an issue with the platform-specific implementation.

---

#### `Stream<TranscriptionResult> get onTranscriptionProgress`

A stream of transcription results as they become available during real-time transcription.

**Returns:**
- `Stream<TranscriptionResult>`: Stream of transcription results.

## TranscriptionConfig

Configuration options for transcription.

### Properties

- `String language`: The language code for transcription (e.g., 'en', 'fr', 'ja').
- `String modelSize`: The size of the model to use ('tiny', 'small', 'medium', 'large').
- `bool enableVAD`: Whether to enable Voice Activity Detection.
- `int vadFallbackTimeout`: Timeout in milliseconds for VAD fallback.
- `bool enablePunctuation`: Whether to enable automatic punctuation.
- `bool enableFormatting`: Whether to enable text formatting.
- `bool enableTimestamps`: Whether to include timestamps in the transcription.

## TranscriptionResult

Represents the result of a transcription operation.

### Properties

- `String text`: The transcribed text.
- `double confidence`: Confidence score for the transcription (0.0 to 1.0).
- `List<Segment> segments`: List of segments with detailed information.
- `Duration processingTime`: Time taken to process the transcription.

## Segment

Represents a segment of transcribed speech.

### Properties

- `String text`: The transcribed text for this segment.
- `double startTime`: Start time of the segment in seconds.
- `double endTime`: End time of the segment in seconds.
- `double confidence`: Confidence score for this segment (0.0 to 1.0).

## Errors

### WhisperKitConfigError

Error thrown when there's an issue with the configuration.

### Properties

- `String message`: Error message.
- `String? code`: Error code.
