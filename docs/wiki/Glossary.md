# Glossary

This page provides definitions for codebase-specific terms used in the Flutter WhisperKit Apple plugin.

## Core Concepts

### FlutterWhisperkitApple
Main plugin class that provides the API for Flutter applications. This is the primary entry point for developers using the plugin.

### WhisperKit
Apple's framework for on-device speech recognition that this plugin wraps. WhisperKit is Apple's implementation of the Whisper model for iOS and macOS platforms.

### transcribeAudio()
Core method for converting audio data to text transcriptions. This is the main functionality that developers will use to perform speech-to-text conversion.

### WhisperKitManager
Native class that coordinates between the Flutter plugin and WhisperKit framework. This manages the lifecycle and configuration of the WhisperKit instance.

### AudioProcessor
Component responsible for processing and normalizing audio data before it's passed to the WhisperKit framework for transcription.

### TranscriptionHandler
Manages the transcription process and formats results. This component handles the output from WhisperKit and converts it into a format that's easy for Flutter developers to use.

## API Methods

### startRecording()
Method to begin audio capture for real-time transcription. This starts the microphone and begins processing audio for transcription.

### stopRecording()
Method to end audio capture and finalize transcription. This stops the microphone and returns the final transcription result.

### setLanguage()
Configuration method for specifying the language model for transcription. This allows developers to specify which language the audio should be transcribed in.

### initializeWhisperKit()
Method to set up the WhisperKit framework. This must be called before any transcription can be performed.

## Data Classes

### TranscriptionConfig
Class for configuring transcription parameters like language and model. This allows developers to customize the transcription process.

### TranscriptionResult
Class representing the output of a transcription operation. This contains the transcribed text and additional metadata.

### WhisperKitWrapper
Abstracts interaction with the WhisperKit framework. This provides a simplified interface to the native WhisperKit functionality.

## Plugin Architecture

### PluginRegistrar
Interface for registering the plugin with the Flutter engine. This is part of the Flutter plugin architecture.

### MethodCallHandler
Interface that handles method calls from the Flutter side. This processes requests from the Dart code and forwards them to the native implementation.

## Audio Handling

### AVFoundationRecorder
Uses AVFoundation to capture audio on iOS devices. This component handles the low-level audio capture functionality.

## Transcription Modes

### StreamingTranscription
Mode for real-time transcription as audio is being captured. This provides continuous updates as speech is detected.

### FileTranscription
Mode for transcribing pre-recorded audio files. This processes an entire audio file at once.

## Callback Types

### TranscriptionCallback
Function type for receiving transcription results asynchronously. This is used to notify the Flutter application when transcription results are available.

### onTranscriptionProgress
Event stream for receiving real-time updates during transcription. This provides continuous updates during streaming transcription.

## Models

### WhisperModel
Represents the ML model used for speech recognition. This encapsulates the machine learning model that powers the transcription.

### ModelDownloader
Handles downloading WhisperKit models if not available locally. This ensures that the necessary models are available for transcription.

## Error Types

### PlatformException
Error type thrown when transcription or initialization fails due to platform-specific issues.

### WhisperKitConfigError
Error type for configuration issues with WhisperKit. This is thrown when there's a problem with the configuration parameters.

## Utilities

### AudioCapturePermission
Utility for handling microphone permissions. This helps manage the permission requests required for audio capture.
