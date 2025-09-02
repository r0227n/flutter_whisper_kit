## 0.2.1

- **CocoaPods Compatibility Fix**:
  - Fixed invalid author syntax in `flutter_whisper_kit_apple.podspec`
  - Changed author field from hash syntax `{ 'Ryo24' }` to valid string `'Ryo24'`
  - Resolves CocoaPods validation error that prevented pod installation
  - Ensures compatibility with CocoaPods specification requirements

## 0.2.0

- **Model Download Progress Tracking**:
  - Added `ModelProgressStreamHandler` to stream model download progress in real-time
  - Provides detailed progress information (completion rate, completed/total units) through `progressCallback`
  - Supports progress display on Flutter side
- **Enhanced Testing Capabilities**:
  - Added `MockFlutterWhisperkitPlatform` and `MockMethodChannelFlutterWhisperkit` for testing
  - Improved unit test reliability through method channel mocking functionality
  - Expanded test coverage for streaming features

## 0.1.0

- Expanded native API and improved platform integration:
  - Added support for device name retrieval, recommended models, and model support configuration.
  - Implemented language detection, model formatting, and recommended remote models.
  - Enhanced model management: setup, prewarm, unload, clear state, and logging callback support.
  - Improved error handling and reporting for platform method calls.
- Improved test coverage and reliability for platform features.
- Package metadata:
  - Updated repository and homepage URLs.
  - Bumped version to 0.1.0.

## 0.0.1

- Initial release of Flutter WhisperKit for Apple platforms.
- Implements core functionality for speech recognition using Whisper models.
- Supports iOS and macOS platforms.
- Features include:
  - Audio recording and processing
  - Transcription of audio to text
  - Language detection
  - Support for various Whisper model sizes
- Known limitations:
  - Limited configuration options
  - Performance optimizations pending
