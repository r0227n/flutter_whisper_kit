# WhisperKit API Reference

This document provides a detailed reference for the WhisperKit API, including classes, methods, and configuration options.

## Core Classes

### WhisperKit

The main class that serves as the entry point for the WhisperKit framework.

#### Initialization

```swift
init(_ config: WhisperKitConfig = WhisperKitConfig()) async throws
```

Creates a new WhisperKit instance with the specified configuration.

**Parameters:**
- `config`: Configuration options for WhisperKit. Defaults to standard configuration.

**Throws:**
- `WhisperKitError.modelNotFound`: If the specified model cannot be found.
- `WhisperKitError.modelLoadFailed`: If the model fails to load.
- `WhisperKitError.invalidConfiguration`: If the configuration is invalid.

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
- `WhisperKitError.fileNotFound`: If the audio file cannot be found.
- `WhisperKitError.audioProcessingFailed`: If audio processing fails.
- `WhisperKitError.transcriptionFailed`: If transcription fails.

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
- `WhisperKitError.audioProcessingFailed`: If audio processing fails.
- `WhisperKitError.transcriptionFailed`: If transcription fails.

##### startStreaming(config:)

```swift
func startStreaming(config: StreamingConfig = StreamingConfig()) async throws
```

Starts streaming transcription from the microphone.

**Parameters:**
- `config`: Configuration options for streaming. Defaults to standard configuration.

**Throws:**
- `WhisperKitError.microphoneAccessDenied`: If microphone access is denied.
- `WhisperKitError.streamingSetupFailed`: If streaming setup fails.

##### stopStreaming()

```swift
func stopStreaming() async throws -> TranscriptionResult?
```

Stops streaming transcription and returns the final result.

**Returns:**
- `TranscriptionResult?`: The final transcription result, or nil if transcription failed.

**Throws:**
- `WhisperKitError.streamingNotActive`: If streaming is not active.
- `WhisperKitError.transcriptionFailed`: If transcription fails.

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
The repository to download models from.

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
Whether to enable Voice Activity Detection.

```swift
var vadFallbackTimeout: TimeInterval = 3.0
```
Timeout in seconds for VAD fallback.

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
Whether to include timestamps in the transcription.

### StreamingConfig

Configuration options for streaming transcription.

#### Properties

```swift
var bufferSize: Int = 4096
```
The size of the audio buffer in samples.

```swift
var sampleRate: Double = 16000
```
The sample rate of the audio in Hz.

```swift
var channels: Int = 1
```
The number of audio channels.

```swift
var updateInterval: TimeInterval = 0.5
```
The interval in seconds between transcription updates.

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

Represents a segment of transcribed speech.

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
Timing information for individual words, if available.

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

Defines the task for the transcription:
- `transcribe`: Transcribe audio in the original language
- `translate`: Transcribe audio and translate to English

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

Defines possible errors that can occur during WhisperKit operations.

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
Called when a partial transcription result is available.

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
        print("Transcription: \(result?.text ?? "No transcription available")")
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
            print("Final transcription: \(result?.text ?? "No transcription available")")
        } catch {
            print("Error: \(error)")
        }
    }
    
    // TranscriptionDelegate methods
    func transcriptionDidUpdate(result: TranscriptionResult) {
        print("Partial transcription: \(result.text)")
    }
    
    func transcriptionDidComplete(result: TranscriptionResult?) {
        print("Transcription complete: \(result?.text ?? "No transcription available")")
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
        
        print("Transcription: \(result?.text ?? "No transcription available")")
        
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
