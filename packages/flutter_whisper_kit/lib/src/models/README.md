# Model Directory Structure

This directory contains all data models used by the Flutter WhisperKit plugin.

## Directory Organization

### Current Structure (Phase 2 - In Progress)

```
models/
├── README.md                      # This file
├── decoding/                      # Decoding-related models
│   ├── decoding_options.dart
│   └── decoding_options_builder.dart
├── device/                        # Device and model support
│   ├── device_support.dart
│   ├── model_support.dart
│   └── model_support_config.dart
├── transcription/                 # Transcription results
│   ├── language_detection_result.dart
│   ├── transcription_result.dart
│   └── word_timing.dart
└── common/                        # Common/shared models
    └── progress.dart
```

## Model Categories

### 1. Decoding Models

- `DecodingOptions`: Configuration for transcription decoding
- `DecodingOptionsBuilder`: Builder pattern implementation for DecodingOptions

### 2. Device/Support Models

- `DeviceSupport`: Device-specific model support information
- `ModelSupport`: Available models and their support status
- `ModelSupportConfig`: Configuration for model support

### 3. Transcription Models

- `LanguageDetectionResult`: Results from language detection
- `TranscriptionResult`: Complete transcription output
- `WordTiming`: Word-level timing information

### 4. Common Models

- `Progress`: Progress tracking for long-running operations

## Type Safety Enhancements

All models use:

- Immutable data structures with `const` constructors where possible
- Factory constructors for JSON deserialization
- Comprehensive null safety
- Clear documentation with examples

## Code Generation (Future)

In future phases, we may introduce code generation for:

- JSON serialization/deserialization
- copyWith methods
- Equality and hashCode implementations
