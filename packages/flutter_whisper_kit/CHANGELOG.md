## 0.1.0

* Major API expansion and improvements:
  * Added support for fetching available models, recommended models, and device name.
  * Implemented language detection, model formatting, and model support configuration retrieval.
  * Added recommended remote models and enhanced model management (setup, prewarm, unload, clear state, logging callback).
  * Improved error handling: platform exceptions are now converted to WhisperKitError for better feedback.
  * Centralized error handling for all platform calls.
* Package metadata:
  * Updated repository and homepage URLs.
  * Bumped version to 0.1.0.


## 0.0.1

* Initial release of Flutter WhisperKit
* Features:
  * Speech-to-text transcription using Whisper models
  * Support for multiple languages
  * Streaming transcription capability
  * Customizable model parameters
  * Cross-platform support (iOS, macOS)

