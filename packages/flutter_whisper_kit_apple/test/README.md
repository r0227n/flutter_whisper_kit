# Flutter WhisperKit Apple Tests

This directory contains the tests for the Flutter WhisperKit Apple plugin. The tests verify the functionality of the plugin and ensure that it correctly interacts with the WhisperKit framework on Apple platforms.

## Test Structure

The tests are organized into the following files:

### Core Plugin Tests

- **flutter_whisperkit_apple_test.dart**: Tests the main plugin interface and verifies that the plugin correctly delegates calls to the platform interface.
  - Validates that the default platform implementation is the method channel implementation
  - Tests the model loading functionality
  - Tests the WhisperKitModelLoader utility class

- **flutter_whisperkit_apple_method_channel_test.dart**: Tests the method channel implementation that communicates with the native code.
  - Verifies that the method channel correctly handles method calls and returns expected values

### Feature Tests

- **transcribe_current_file_test.dart**: Tests the file transcription functionality.
  - Verifies that audio files can be transcribed with default and custom options
  - Tests handling of invalid file paths
  - Validates the DecodingOptions class and its JSON serialization

- **realtime_transcription_test.dart**: Tests the real-time transcription functionality.
  - Verifies that recording can be started and stopped
  - Tests customization of recording options
  - Validates that the transcription stream emits results correctly

## Test Utilities

The `test_utils` directory contains shared utilities for testing:

- **mocks.dart**: Contains mock implementations of the platform interface for testing without actual native code.

## Running the Tests

To run all tests:

```bash
cd packages/flutter_whisper_kit_apple
fvm flutter test
```

To run a specific test file:

```bash
cd packages/flutter_whisper_kit_apple
fvm flutter test test/file_name_test.dart
```

## Test Coverage

The tests cover the following plugin functionality:

1. **Model Loading**
   - Loading WhisperKit models with various configurations
   - Managing model storage locations
   - Tracking and reporting download progress
   - Testing model prewarming behavior
   - Handling errors during model loading

2. **File Transcription**
   - Transcribing audio files with default and custom options
   - Handling of invalid file paths
   - Parsing and validating transcription results
   - Testing word-level timestamp accuracy
   - Verifying segment information in transcription results

3. **Real-time Transcription**
   - Starting and stopping audio recording
   - Configuring transcription parameters
   - Streaming transcription results in real-time, including edge cases and parameter configurations, beyond the basic functionality tested in `realtime_transcription_test.dart`
   - Handling microphone permissions
   - Testing loop and non-loop recording modes
   - Verifying transcription result format and content

4. **Configuration Options**
   - Creating and customizing DecodingOptions
   - JSON serialization of options
   - Default values and parameter validation
