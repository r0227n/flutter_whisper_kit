# Services Tests

This directory contains tests organized by service functionality, matching the refactored library structure.

## Directory Structure

### model_management/

Tests for `ModelManagementService` functionality:

- `models_test.dart` - Basic model operations and data models
- `model_progress_test.dart` - Model loading progress tracking
- `additional_models_test.dart` - Extended model functionality

### recording/

Tests for `RecordingService` functionality:

- `realtime_transcription_test.dart` - Real-time audio recording and transcription
- `stream_management_test.dart` - Stream handling and management

### transcription/

Tests for `TranscriptionService` functionality:

- `transcription_test.dart` - File-based transcription and language detection

### result_api/

Tests for `ResultApiService` functionality:

- `result_type_test.dart` - Result pattern implementation and error handling

## Test Organization Principles

1. **Service Isolation**: Each service is tested independently
2. **Focused Scope**: Tests in each directory only test the corresponding service
3. **Shared Utilities**: Common test utilities are in `../core/test_utils/`
4. **Clear Naming**: Test files match the service functionality they test

## Running Service Tests

Run all service tests:

```bash
flutter test test/services/
```

Run specific service tests:

```bash
flutter test test/services/model_management/
flutter test test/services/recording/
flutter test test/services/transcription/
flutter test test/services/result_api/
```
