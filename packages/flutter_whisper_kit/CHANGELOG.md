## 0.3.0

- **Flutter SDK Compatibility Update**:
  - Updated Flutter SDK version requirement to 3.35.0+
  - Updated minimum Dart SDK version to 3.9.0+
  - Enhanced compatibility with latest Flutter framework features
- **Platform Package Update**:
  - Updated flutter_whisper_kit_apple dependency to version 0.3.0
  - Improved build system reliability with latest Flutter toolchain
  - Fixed CocoaPods author syntax in platform package
- **Development Environment**:
  - Improved workspace resolution configuration
  - Enhanced dependency management for better development experience

## 0.2.0

- Major enhancements:
  - **Result Type Implementation**: Added comprehensive Result<S, E> pattern for better error handling
    - Sealed class pattern with Success and Failure variants
    - Pattern matching support with `when`, `fold`, `map`, and `mapError` methods
    - Type-safe error handling without throwing exceptions
  - **Result-based API Methods**: New API methods ending with "WithResult" for safer error handling
    - `loadModelWithResult()` - Load models with explicit error states
    - `downloadWithResult()` - Download models with progress tracking
    - `fetchAvailableModelsWithResult()` - Fetch model lists safely
    - `transcribeFileWithResult()` - File transcription with Result pattern
    - `detectLanguageWithResult()` - Language detection with Result pattern
    - `startRecordingWithResult()` / `stopRecordingWithResult()` - Recording control with Result pattern
  - **Enhanced Error Handling**: Improved error management and recovery capabilities
    - WhisperKitError integration with Result pattern
    - Comprehensive error code categorization
    - Better error propagation and handling across platform boundaries
- Improvements:
  - Improved WhisperKit logging format for better readability and consistency
  - Standardized log message format with "WhisperKitLog:" prefix (removed space for cleaner output)

## 0.1.0

- Major API expansion and improvements:
  - Added support for fetching available models, recommended models, and device name.
  - Implemented language detection, model formatting, and model support configuration retrieval.
  - Added recommended remote models and enhanced model management (setup, prewarm, unload, clear state, logging callback).
  - Improved error handling: platform exceptions are now converted to WhisperKitError for better feedback.
  - Centralized error handling for all platform calls.
- Package metadata:
  - Updated repository and homepage URLs.
  - Bumped version to 0.1.0.

## 0.0.1

- Initial release of Flutter WhisperKit
- Features:
  - Speech-to-text transcription using Whisper models
  - Support for multiple languages
  - Streaming transcription capability
  - Customizable model parameters
  - Cross-platform support (iOS, macOS)
