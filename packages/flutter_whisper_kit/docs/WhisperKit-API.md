# WhisperKit API Reference

This document provides a detailed reference for the WhisperKit API, including classes, methods, and configuration options.

## Core Classes

### WhisperKit

The main class that serves as the entry point to the WhisperKit framework.

#### Initialization

```swift
init(_ config: WhisperKitConfig = WhisperKitConfig()) async throws
```

Creates a new WhisperKit instance with the specified configuration.

**Parameters:**
- `config`: Configuration options for WhisperKit. Defaults to standard configuration.

**Throws:**
- `WhisperKitError.modelNotFound`: When the specified model cannot be found.
- `WhisperKitError.modelLoadFailed`: When model loading fails.
- `WhisperKitError.invalidConfiguration`: When the configuration is invalid.

#### Methods

##### transcribe(audioPath:)

```swift
func transcribe(audioPath: String) async throws -> TranscriptionResult?
```

Transcribes audio from a file.

**Parameters:**
- `audioPath`: Path to the audio file to transcribe.

**Returns:**
- `TranscriptionResult?`: The transcription result, or nil if transcription failed.

**Throws:**
- `WhisperKitError.fileNotFound`: When the audio file cannot be found.
- `WhisperKitError.audioProcessingFailed`: When audio processing fails.
- `WhisperKitError.transcriptionFailed`: When transcription fails.

##### transcribe(audioData:)

```swift
func transcribe(audioData: Data) async throws -> TranscriptionResult?
```

Transcribes audio from raw audio data.

**Parameters:**
- `audioData`: Raw audio data to transcribe.

**Returns:**
- `TranscriptionResult?`: The transcription result, or nil if transcription failed.

**Throws:**
- `WhisperKitError.audioProcessingFailed`: When audio processing fails.
- `WhisperKitError.transcriptionFailed`: When transcription fails.

##### startStreaming(config:)

```swift
func startStreaming(config: StreamingConfig = StreamingConfig()) async throws
```

Starts streaming transcription from the microphone.

**Parameters:**
- `config`: Streaming configuration options. Defaults to standard configuration.

**Throws:**
- `WhisperKitError.microphoneAccessDenied`: When microphone access is denied.
- `WhisperKitError.streamingSetupFailed`: When streaming setup fails.

##### stopStreaming()

```swift
func stopStreaming() async throws -> TranscriptionResult?
```

Stops streaming transcription and returns the final result.

**Returns:**
- `TranscriptionResult?`: The final transcription result, or nil if transcription failed.

**Throws:**
- `WhisperKitError.streamingNotActive`: When streaming is not active.
- `WhisperKitError.transcriptionFailed`: When transcription fails.

### WhisperKitConfig

Configuration options for WhisperKit.

#### Properties

```swift
var model: String = "medium"
```
The model to use for transcription. Options include "tiny", "small", "medium", "large", and "large-v3".

```swift
var modelRepo: String = "argmaxinc/whisperkit-coreml"
```
The repository to download the model from.

```swift
var language: String? = nil
```
The language to use for transcription. If nil, language will be auto-detected.

```swift
var task: TranscriptionTask = .transcribe
```
The transcription task. Options include `.transcribe` and `.translate`.

```swift
var enableVAD: Bool = true
```
Whether to enable voice activity detection.

```swift
var vadFallbackTimeout: TimeInterval = 3.0
```
Timeout for VAD fallback in seconds.

```swift
var enablePunctuation: Bool = true
```
Whether to enable automatic punctuation.

```swift
var enableFormatting: Bool = true
```
Whether to enable text formatting.

```swift
var enableTimestamps: Bool = false
```
Whether to include timestamps in transcription.

### StreamingConfig

Configuration options for streaming transcription.

#### Properties

```swift
var bufferSize: Int = 4096
```
Size of the audio buffer in samples.

```swift
var sampleRate: Double = 16000
```
Sample rate of the audio in Hz.

```swift
var channels: Int = 1
```
Number of audio channels.

```swift
var updateInterval: TimeInterval = 0.5
```
Interval between transcription updates in seconds.

### TranscriptionResult

Represents the result of a transcription operation.

#### Properties

```swift
var text: String
```
The transcribed text.

```swift
var segments: [TranscriptionSegment]
```
List of segments with detailed information.

```swift
var language: String?
```
The detected or specified language.

```swift
var processingTime: TimeInterval
```
Time taken to process the transcription.

### TranscriptionSegment

Represents a segment of transcribed audio.

#### Properties

```swift
var text: String
```
The transcribed text for this segment.

```swift
var startTime: TimeInterval
```
Start time of the segment in seconds.

```swift
var endTime: TimeInterval
```
End time of the segment in seconds.

```swift
var confidence: Double
```
Confidence score for this segment (0.0 to 1.0).

```swift
var words: [WordTiming]?
```
Word timing information, if available.

### WordTiming

Represents timing information for a word.

#### Properties

```swift
var word: String
```
The word text.

```swift
var startTime: TimeInterval
```
Start time of the word in seconds.

```swift
var endTime: TimeInterval
```
End time of the word in seconds.

```swift
var confidence: Double
```
Confidence score for this word (0.0 to 1.0).

## Enumerations

### TranscriptionTask

```swift
enum TranscriptionTask {
    case transcribe
    case translate
}
```

Defines the transcription task:
- `transcribe`: Transcribe audio in the original language
- `translate`: Transcribe and translate audio to English

### WhisperKitError

```swift
enum WhisperKitError: Error {
    case modelNotFound
    case modelLoadFailed
    case invalidConfiguration
    case fileNotFound
    case audioProcessingFailed
    case transcriptionFailed
    case microphoneAccessDenied
    case streamingSetupFailed
    case streamingNotActive
}
```

Defines errors that can occur during WhisperKit operations.

## Protocols

### TranscriptionDelegate

```swift
protocol TranscriptionDelegate: AnyObject {
    func transcriptionDidUpdate(result: TranscriptionResult)
    func transcriptionDidComplete(result: TranscriptionResult?)
    func transcriptionDidFail(error: Error)
}
```

Delegate protocol for receiving transcription updates.

#### Methods

```swift
func transcriptionDidUpdate(result: TranscriptionResult)
```
Called when partial transcription results are available.

```swift
func transcriptionDidComplete(result: TranscriptionResult?)
```
Called when transcription is complete.

```swift
func transcriptionDidFail(error: Error)
```
Called when transcription fails.

## Extensions

### String Extensions

```swift
extension String {
    func containsLanguage(_ language: String) -> Bool
}
```

Checks if a string contains text in a specific language.

```swift
extension String {
    func formatTranscription(enablePunctuation: Bool, enableFormatting: Bool) -> String
}
```

Formats transcription text with punctuation and formatting.

## Usage Examples

### Basic Transcription

```swift
import WhisperKit

Task {
    do {
        let whisperKit = try await WhisperKit()
        let result = try await whisperKit.transcribe(audioPath: "path/to/audio.mp3")
        print("Transcription: \(result?.text ?? "Transcription not available")")
    } catch {
        print("Error: \(error)")
    }
}
```

### Streaming Transcription with Delegate

```swift
import WhisperKit

class TranscriptionManager: TranscriptionDelegate {
    private var whisperKit: WhisperKit?
    
    func startTranscription() async {
        do {
            whisperKit = try await WhisperKit()
            whisperKit?.delegate = self
            try await whisperKit?.startStreaming()
        } catch {
            print("Error: \(error)")
        }
    }
    
    func stopTranscription() async {
        do {
            let result = try await whisperKit?.stopStreaming()
            print("Final transcription: \(result?.text ?? "Transcription not available")")
        } catch {
            print("Error: \(error)")
        }
    }
    
    // TranscriptionDelegate methods
    func transcriptionDidUpdate(result: TranscriptionResult) {
        print("Partial transcription: \(result.text)")
    }
    
    func transcriptionDidComplete(result: TranscriptionResult?) {
        print("Transcription completed: \(result?.text ?? "Transcription not available")")
    }
    
    func transcriptionDidFail(error: Error) {
        print("Transcription failed: \(error)")
    }
}
```

### Custom Configuration

```swift
import WhisperKit

Task {
    do {
        var config = WhisperKitConfig()
        config.model = "large-v3"
        config.language = "en"
        config.enableVAD = true
        config.enableTimestamps = true
        
        let whisperKit = try await WhisperKit(config)
        let result = try await whisperKit.transcribe(audioPath: "path/to/audio.mp3")
        
        print("Transcription: \(result?.text ?? "Transcription not available")")
        
        if let segments = result?.segments {
            for segment in segments {
                print("Segment: \(segment.text)")
                print("Time: \(segment.startTime) - \(segment.endTime)")
                
                if let words = segment.words {
                    for word in words {
                        print("Word: \(word.word), Time: \(word.startTime) - \(word.endTime)")
                    }
                }
            }
        }
    } catch {
        print("Error: \(error)")
    }
}
```