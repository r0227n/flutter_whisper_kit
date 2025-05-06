# Flutter WhisperKit Tests

This directory contains the tests for the Flutter WhisperKit platform interface package. The tests verify the functionality of the package and ensure that it correctly implements the platform interface for WhisperKit.

## Test Structure

The tests are organized into the following files:

### Core Plugin Tests

- **flutter_whisperkit_test.dart**: Tests the main plugin interface and verifies that the platform interface is correctly set up.
  - Validates that the default platform implementation is the method channel implementation
  - Tests basic plugin functionality

- **flutter_whisperkit_method_channel_test.dart**: Tests the method channel implementation that communicates with the native code.
  - Verifies that the method channel correctly handles method calls and returns expected values

### Feature Tests

- **transcription_test.dart**: Tests the file transcription functionality.
  - Verifies that audio files can be transcribed with default and custom options
  - Tests handling of invalid file paths

- **realtime_transcription_test.dart**: Tests the real-time transcription functionality.
  - Verifies that recording can be started and stopped
  - Tests customization of recording options
  - Validates that the transcription stream emits results correctly

- **model_progress_test.dart**: Tests the model progress streaming functionality.
  - Verifies that progress updates are emitted correctly

- **models_test.dart**: Tests the model classes used by the plugin.
  - Tests DecodingOptions class and its JSON serialization
  - Tests TranscriptionResult class and its JSON serialization
  - Tests Progress class and its JSON serialization

## Test Utilities

The `test_utils` directory contains shared utilities for testing:

- **mocks.dart**: Contains mock implementations of the platform interface for testing without actual native code.
- **mock_method_channel.dart**: Contains mock implementations of the method channel for testing.

## Running the Tests

To run all tests:

```bash
cd packages/flutter_whisper_kit
fvm flutter test
```

To run a specific test file:

```bash
cd packages/flutter_whisper_kit
fvm flutter test test/file_name_test.dart # Replace 'file_name_test.dart' with the actual test file name
```

## Test Coverage

The tests cover the following plugin functionality:

1. **Model Loading**
   - Loading WhisperKit models with various configurations
   - Managing model download and caching

2. **File Transcription**
   - Transcribing audio files with default and custom options
   - Handling of invalid file paths
   - Parsing and validating transcription results

3. **Real-time Transcription**
   - Starting and stopping audio recording
   - Configuring transcription parameters
   - Streaming transcription results

4. **Model Progress Streaming**
   - Tracking model loading progress
   - Handling progress updates

5. **Model Classes**
   - Creating and customizing DecodingOptions
   - JSON serialization of options and results
   - Default values and parameter validation
