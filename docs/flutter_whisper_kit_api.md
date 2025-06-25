# FlutterWhisperKit API Reference

This document provides a detailed reference for the public API of the `FlutterWhisperKit` class, part of the `flutter_whisper_kit` package.
The `FlutterWhisperKit` class is the main entry point for using WhisperKit in Flutter applications, providing methods for model management, audio transcription, and real-time speech recognition.

## Methods

### `loadModel`

Downloads and initializes a WhisperKit model for speech recognition. This method handles both downloading the model if it doesn't exist locally and loading it into memory for use.

**Parameters:**

- `variant` (String?): The model variant to load (e.g., 'tiny-en', 'base', 'small', 'medium', 'large-v2'). Different variants offer different trade-offs between accuracy and performance.
- `modelRepo` (String?, optional): The repository to download the model from (default: 'argmaxinc/whisperkit-coreml'). This is the Hugging Face repository where the model files are hosted.
- `redownload` (bool, optional): Whether to force redownload the model even if it exists locally. Set to `true` to ensure you have the latest version of the model. Defaults to `false`.
- `onProgress` (Function(Progress progress)?, optional): A callback function that receives download progress updates. This can be used to display a progress indicator to the user. The `Progress` object contains `completedUnits`, `totalUnits`, and `fractionCompleted`.

**Returns:**

- `Future<String?>`: A future that completes with the path to the model folder if the model is loaded successfully, or `null` otherwise. Throws a `WhisperKitError` if loading fails.

**Example:**

```dart
try {
  String? modelPath = await flutterWhisperKit.loadModel(
    'base',
    onProgress: (progress) {
      print('Model loading progress: ${progress.fractionCompleted * 100}%');
    },
  );
  if (modelPath != null) {
    print('Model loaded from: $modelPath');
  }
} on WhisperKitError catch (e) {
  print('Error loading model: $e');
}
```

### `transcribeFromFile`

Processes an audio file and generates a text transcription using the loaded WhisperKit model. This method handles the entire transcription process, including audio loading, processing, and text generation.

**Parameters:**

- `filePath` (String): The path to the audio file to transcribe. This should be a valid path to an audio file in a supported format.
- `options` (DecodingOptions, optional): Optional decoding options to customize the transcription process. These options control various aspects of the transcription, such as language, task type, temperature, and more. Defaults to a predefined set of options (see source code for specifics).

**Returns:**

- `Future<TranscriptionResult?>`: A future that completes with a `TranscriptionResult` object containing the transcription text, segments, and timing information, or `null` if transcription fails. Throws a `WhisperKitError` if transcription encounters an error. The `TranscriptionResult` object contains `text` (String), `language` (String), and `segments` (List<Segment>). Each `Segment` has `text` (String), `start` (double), `end` (double), and `confidence` (double).

**Example:**

```dart
try {
  TranscriptionResult? result = await flutterWhisperKit.transcribeFromFile('path/to/your/audio.wav');
  if (result != null) {
    print('Transcription: ${result.text}');
    result.segments.forEach((segment) {
      print('Segment: ${segment.text} [${segment.start}s - ${segment.end}s]');
    });
  }
} on WhisperKitError catch (e) {
  print('Error transcribing file: $e');
}
```

### `startRecording`

Begins capturing audio from the device's microphone and optionally starts real-time transcription. This method handles microphone permission requests, audio capture configuration, and transcription setup.

**Parameters:**

- `options` (DecodingOptions, optional): Optional decoding options to customize the transcription process. These options control various aspects of the transcription, such as language, task type, temperature, and more. Defaults to a predefined set of options (see source code for specifics).
- `loop` (bool, optional): If `true`, continuously transcribes audio in a loop until stopped. If `false`, transcription happens when `stopRecording` is called. Defaults to `true`.

**Returns:**

- `Future<String?>`: A future that completes with a success message if recording starts successfully, or `null` otherwise. Throws a `WhisperKitError` if starting recording fails.

**Example:**

```dart
try {
  await flutterWhisperKit.startRecording(
    options: DecodingOptions(language: 'en', detectLanguage: false),
    loop: true,
  );
  print('Recording started.');
} on WhisperKitError catch (e) {
  print('Error starting recording: $e');
}
```

### `stopRecording`

Stops the audio capture from the device's microphone and, depending on the `loop` parameter used when starting, may trigger transcription of the recorded audio.

**Parameters:**

- `loop` (bool, optional): Must match the `loop` parameter used when starting recording. This ensures consistent behavior between starting and stopping recording. Defaults to `true`.

**Returns:**

- `Future<String?>`: A future that completes with a success message when recording is stopped. If `loop` was `false` during `startRecording`, this also triggers transcription of the recorded audio. Throws a `WhisperKitError` if stopping recording fails.

**Example:**

```dart
try {
  await flutterWhisperKit.stopRecording(loop: true);
  print('Recording stopped.');
} on WhisperKitError catch (e) {
  print('Error stopping recording: $e');
}
```

## Getters

### `transcriptionStream`

A stream of real-time transcription results. This stream emits `TranscriptionResult` objects containing the full transcription data as it becomes available during real-time transcription (when `startRecording` was called with `loop: true`). The stream will emit an empty result when recording stops.

The `TranscriptionResult` object contains `text` (String), `language` (String), and `segments` (List<Segment>). Each `Segment` has `text` (String), `start` (double), `end` (double), and `confidence` (double).

**Returns:**

- `Stream<TranscriptionResult>`: A stream that emits `TranscriptionResult` objects.

**Example:**

```dart
final subscription = flutterWhisperKit.transcriptionStream.listen((result) {
  setState(() {
    _transcriptionText = result.text;
    _language = result.language;
    _segments = result.segments;
  });
});

// Don't forget to cancel the subscription when done
// subscription.cancel();
```

## Methods (continued)

### `fetchAvailableModels`

Fetches available WhisperKit models from a repository.

**Parameters:**

- `modelRepo` (String, optional): The repository to fetch models from. Defaults to `"argmaxinc/whisperkit-coreml"`.
- `matching` (List<String>, optional): Optional list of glob patterns to filter models by. Defaults to `['*']` (all models).
- `token` (String?, optional): Optional access token for private repositories.

**Returns:**

- `Future<List<String>>`: A future that completes with a list of available model names (e.g., "tiny.en", "base", "small"). Throws a `WhisperKitError` if fetching fails.

**Example:**

```dart
try {
  final models = await flutterWhisperKit.fetchAvailableModels(
    matching: ['tiny*', 'base*']
  );
  print('Available models: $models');
} on WhisperKitError catch (e) {
  print('Error fetching available models: $e');
}
```

### `deviceName`

Returns the name of the device running the application.

**Parameters:** None.

**Returns:**

- `Future<String>`: A future that completes with the name of the device. Throws a `WhisperKitError` if fetching the device name fails.

**Example:**

```dart
try {
  final deviceName = await flutterWhisperKit.deviceName();
  print('Device name: $deviceName');
} on WhisperKitError catch (e) {
  print('Error getting device name: $e');
}
```

### `recommendedModels`

Returns a list of recommended models for the current device. This method returns a list of model variants that are recommended for the current device based on its hardware capabilities and WhisperKit's model compatibility matrix.

**Parameters:** None.

**Returns:**

- `Future<ModelSupport>`: A future that completes with a `ModelSupport` object. Throws a `WhisperKitError` if fetching recommended models fails.
  The `ModelSupport` object has the following properties:
    - `defaultModel` (String): The default recommended model for the device.
    - `supported` (List<String>): A list of all supported model variants for the device.
    - `disabled` (List<String>): A list of model variants that are disabled for the device.

**Example:**

```dart
try {
  final modelSupport = await flutterWhisperKit.recommendedModels();
  print('Default model: ${modelSupport.defaultModel}');
  print('Supported models: ${modelSupport.supported}');
  print('Disabled models: ${modelSupport.disabled}');
} on WhisperKitError catch (e) {
  print('Error getting recommended models: $e');
}
```

### `detectLanguage`

Detects the language of an audio file. This method analyzes the audio content and determines the most likely language being spoken, along with confidence scores for various languages.

**Parameters:**

- `audioPath` (String): The path to the audio file for language detection.

**Returns:**

- `Future<LanguageDetectionResult>`: A future that completes with a `LanguageDetectionResult` object. Throws a `WhisperKitError` if language detection fails.
  The `LanguageDetectionResult` object has the following properties:
    - `language` (String): The detected language code (e.g., "en", "es").
    - `probabilities` (Map<String, double>): A map of language codes to their confidence scores (probabilities).

**Example:**

```dart
try {
  final result = await flutterWhisperKit.detectLanguage('path/to/your/audio.wav');
  print('Detected language: ${result.language}');
  print('Language probabilities: ${result.probabilities}');
} on WhisperKitError catch (e) {
  print('Error detecting language: $e');
}
```

### `formatModelFiles`

Formats model files for consistent handling across the plugin. (The exact formatting details are platform-specific and handled internally).

**Parameters:**

- `modelFiles` (List<String>): A list of model file names to format.

**Returns:**

- `Future<List<String>>`: A future that completes with a list of formatted model file names. Throws a `WhisperKitError` if formatting fails.

**Example:**

```dart
try {
  final formattedModelFiles = await flutterWhisperKit.formatModelFiles(['model.bin', 'vocab.json']);
  print('Formatted model files: $formattedModelFiles');
} on WhisperKitError catch (e) {
  print('Error formatting model files: $e');
}
```

### `fetchModelSupportConfig`

Fetches model support configuration from a remote repository. This method retrieves a configuration file from the specified repository that contains information about which models are supported on different devices.

**Parameters:** (Note: The current implementation in `flutter_whisper_kit.dart` does not seem to pass these through to the platform interface, relying on platform defaults or hardcoded values. The documentation here reflects the Dart layer.)
  - The method currently takes no arguments at the Dart layer, though the underlying platform interface might accept `repo`, `downloadBase`, and `token`.

**Returns:**

- `Future<ModelSupportConfig>`: A future that completes with a `ModelSupportConfig` object. Throws a `WhisperKitError` if fetching the config fails.
  The `ModelSupportConfig` object structure can be complex, typically containing device-specific model support information. Refer to the `ModelSupportConfig` class definition in `models.dart` for its detailed structure.

**Example:**

```dart
try {
  final modelSupportConfig = await flutterWhisperKit.fetchModelSupportConfig();
  // Process modelSupportConfig, e.g., print(modelSupportConfig.toJson());
  print('Fetched model support config.');
} on WhisperKitError catch (e) {
  print('Error fetching model support config: $e');
}
```

### `recommendedRemoteModels`

Fetches recommended models for the current device from a remote repository. This method retrieves model support information specifically tailored for the current device.

**Parameters:** None at the Dart layer.

**Returns:**

- `Future<ModelSupport>`: A future that completes with a `ModelSupport` object containing information about supported models for the current device. Throws a `WhisperKitError` if fetching fails.
  The `ModelSupport` object has the following properties:
    - `defaultModel` (String): The default recommended model for the device.
    - `supported` (List<String>): A list of all supported model variants for the device.
    - `disabled` (List<String>): A list of model variants that are disabled for the device.

**Example:**

```dart
try {
  final modelSupport = await flutterWhisperKit.recommendedRemoteModels();
  print('Default remote model: ${modelSupport.defaultModel}');
  print('Supported remote models: ${modelSupport.supported}');
} on WhisperKitError catch (e) {
  print('Error fetching recommended remote models: $e');
}
```

### `setupModels`

Initializes the WhisperKit framework with the specified configuration. It either uses a local model folder if provided or downloads the model.

**Parameters:**

- `model` (String?, optional): The model variant to use.
- `downloadBase` (String?, optional): The base URL for downloads.
- `modelRepo` (String?, optional): The repository to download the model from.
- `modelToken` (String?, optional): An access token for the repository.
- `modelFolder` (String?, optional): A local folder containing the model files. If provided, `download` is typically `false`.
- `download` (bool, optional): Whether to download the model if not available locally. Defaults to `true`.

**Returns:**

- `Future<String?>`: A future that completes with a success message if the models are set up successfully, or `null` otherwise. Throws a `WhisperKitError` if setup fails.

**Example (using a local model folder):**

```dart
try {
  await flutterWhisperKit.setupModels(
    modelFolder: '/path/to/local/whisperkit-coreml-base',
    model: 'base', // Ensure this matches the model in modelFolder
    download: false,
  );
  print('Models set up successfully from local folder.');
} on WhisperKitError catch (e) {
  print('Error setting up models: $e');
}
```

**Example (downloading a model):**
```dart
try {
  await flutterWhisperKit.setupModels(
    model: 'tiny.en',
    modelRepo: 'argmaxinc/whisperkit-coreml',
    download: true,
  );
  print('Models set up successfully by downloading.');
} on WhisperKitError catch (e) {
  print('Error setting up models: $e');
}
```

### `download`

Downloads a WhisperKit model from a repository and tracks the progress through the `modelProgressStream`.

**Parameters:**

- `variant` (required String): The model variant to download (e.g., "base.en", "small").
- `downloadBase` (String?, optional): The base URL for downloads.
- `useBackgroundSession` (bool, optional): Whether to use a background session for the download (iOS specific). Defaults to `false`.
- `repo` (String, optional): The repository to download from. Defaults to `'argmaxinc/whisperkit-coreml'`.
- `token` (String?, optional): An access token for the repository.
- `onProgress` (Function(Progress progress)?, optional): A callback function that receives download progress updates. The `Progress` object contains `completedUnits`, `totalUnits`, and `fractionCompleted`.

**Returns:**

- `Future<String?>`: A future that completes with the path to the downloaded model, or `null` if download fails. Throws a `WhisperKitError` if download encounters an error.

**Example:**

```dart
try {
  String? modelPath = await flutterWhisperKit.download(
    variant: 'base.en',
    onProgress: (progress) {
      print('Model download progress: ${progress.fractionCompleted * 100}%');
    },
  );
  if (modelPath != null) {
    print('Model downloaded to: $modelPath');
  }
} on WhisperKitError catch (e) {
  print('Error downloading model: $e');
}
```

### `prewarmModels`

Prepares the models for use by loading them into memory but does not perform any inference. This is useful for reducing the latency of the first transcription after models are set up or loaded.

**Parameters:** None.

**Returns:**

- `Future<String?>`: A future that completes with a success message if the models are prewarmed successfully, or `null` otherwise. Throws a `WhisperKitError` if prewarming fails.

**Example:**

```dart
try {
  await flutterWhisperKit.prewarmModels();
  print('Models prewarmed successfully.');
} on WhisperKitError catch (e) {
  print('Error prewarming models: $e');
}
```

### `unloadModels`

Unloads the models from memory to free up resources. This should be called when the models are no longer needed to reduce memory consumption.

**Parameters:** None.

**Returns:**

- `Future<String?>`: A future that completes with a success message if the models are unloaded successfully, or `null` otherwise. Throws a `WhisperKitError` if unloading fails.

**Example:**

```dart
try {
  await flutterWhisperKit.unloadModels();
  print('Models unloaded successfully.');
} on WhisperKitError catch (e) {
  print('Error unloading models: $e');
}
```

### `clearState`

Resets the transcription state. This method stops any ongoing recording and resets internal transcription timings and buffers. It should be called when preparing for a new, distinct transcription session or to ensure a clean state.

**Parameters:** None.

**Returns:**

- `Future<String?>`: A future that completes with a success message if the state is cleared successfully, or `null` otherwise. Throws a `WhisperKitError` if clearing fails.

**Example:**

```dart
try {
  await flutterWhisperKit.clearState();
  print('State cleared successfully.');
} on WhisperKitError catch (e) {
  print('Error clearing state: $e');
}
```

### `loggingCallback`

Configures a callback function for tracking progress and debugging messages from the native WhisperKit library. The callback receives log messages with the specified level.

**Parameters:**

- `level` (String?, optional): The logging level (e.g., "debug", "info", "warning", "error"). If `null` or not provided, a default level (often "info" or "debug") might be used by the native side. The exact behavior for `null` might be platform-dependent.

**Returns:**

- `Future<void>`: A future that completes when the logging callback is set up. Throws a `WhisperKitError` if setting the logging callback fails.
  *(Note: The native side will then asynchronously call back into Dart with log messages. How these are handled/displayed depends on the `PigeonLogger` implementation in the Flutter plugin's native code, typically printing to the console.)*

**Example:**

```dart
try {
  await flutterWhisperKit.loggingCallback(level: 'debug');
  print('Logging callback set to debug level.');
  // Subsequent native logs from WhisperKit will be printed to the console.
} on WhisperKitError catch (e) {
  print('Error setting logging callback: $e');
}
```

### `modelProgressStream`

A stream of model loading progress updates. This stream emits `Progress` objects containing information about the ongoing model loading task, including completed units, total units, and the progress fraction. This allows clients to display progress indicators during model download and initialization.

The `Progress` object contains `completedUnits` (int), `totalUnits` (int), and `fractionCompleted` (double).

**Returns:**

- `Stream<Progress>`: A stream that emits `Progress` objects.

**Example:**

```dart
final subscription = flutterWhisperKit.modelProgressStream.listen((progress) {
  print('Model download progress: ${progress.fractionCompleted * 100}%');
});

// Don't forget to cancel the subscription when done
// subscription.cancel();
```
