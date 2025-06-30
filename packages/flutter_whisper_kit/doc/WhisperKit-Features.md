# WhisperKit Features

This document provides detailed information about WhisperKit's key features and how to leverage them in your applications.

## Core Features

### On-Device Speech-to-Text

WhisperKit provides high-quality speech-to-text transcription that runs entirely on-device, ensuring privacy and offline capability. Transcription is performed using Apple's CoreML framework, optimized for performance on Apple devices.

### Real-Time Streaming

WhisperKit supports real-time streaming transcription, allowing audio to be processed as soon as it's captured. This feature is essential for applications requiring immediate feedback, such as voice assistants, live captioning, and interactive voice experiences.

### Word-Level Timestamps

WhisperKit can generate timestamps for each word in the transcription, enabling precise alignment between audio and text. This feature is valuable for applications such as:

- Subtitle generation
- Audio/video editing tools
- Educational applications
- Accessibility features

### Voice Activity Detection (VAD)

The built-in voice activity detection system can identify when someone is speaking compared to background noise. This helps:

- Reduce processing of non-speech audio
- Improve transcription accuracy
- Save battery life by processing only relevant audio
- Enhance user experience by transcribing only when speech is detected

### Multi-Language Support

WhisperKit supports transcription in multiple languages, making it suitable for international applications. The framework can automatically detect the spoken language or be configured to transcribe in a specific language.

## Advanced Features

### Customizable Models

WhisperKit allows you to choose between different model sizes to balance accuracy and performance:

- **Tiny**: Fastest, smallest memory footprint, suitable for resource-constrained environments
- **Small**: Good balance of speed and accuracy for most applications
- **Medium**: Higher accuracy with moderate resource requirements
- **Large**: Best accuracy, suitable for applications where precision is critical

### Fine-Tuned Models

WhisperKit supports loading custom fine-tuned models, allowing developers to optimize for specific domains, accents, or terminology. This is particularly useful for:

- Medical transcription
- Legal documentation
- Technical fields with specialized vocabulary
- Regional accent optimization

### Automatic Punctuation and Formatting

WhisperKit can automatically add punctuation and format the transcribed text to make the output more readable and natural. This includes:

- Sentence capitalization
- Comma and period placement
- Question marks and exclamation points
- Paragraph breaks

### Confidence Scores

WhisperKit provides confidence scores for each transcribed segment, indicating how certain the transcription is. This allows applications to:

- Highlight potentially misrecognized words
- Request user confirmation for low-confidence segments
- Filter out unreliable transcriptions
- Improve user experience by indicating uncertainty

## Performance Optimizations

### Adaptive Sampling

WhisperKit can adapt its processing based on available system resources, ensuring optimal performance across different devices. This includes:

- Dynamic model selection based on device capabilities
- Adjustable processing batch sizes
- Memory usage optimization

### Background Processing

WhisperKit supports background processing, allowing transcription to continue even when the application is not in the foreground. This is particularly useful for:

- Long-form audio transcription
- Voice memo applications
- Meeting recording and transcription

### Energy Efficiency

The framework is optimized for energy efficiency, making it suitable for mobile applications where battery life is a concern. This includes:

- Efficient use of the Neural Engine
- Minimized CPU usage
- Optimized memory access patterns

## Integration Features

### Swift API

WhisperKit provides a clean, easy-to-use Swift API that integrates seamlessly with iOS and macOS applications. The API follows Swift conventions and best practices, making it intuitive for Swift developers.

### Command-Line Interface

WhisperKit includes a command-line interface for testing and debugging outside of Xcode projects. This is useful for:

- Quick testing of transcription capabilities
- Batch processing of audio files
- Integration with other command-line tools
- Automated testing and CI/CD pipelines

### Flutter Integration

Through the Flutter WhisperKit Apple plugin, WhisperKit can be used in Flutter applications, providing cross-platform capabilities while leveraging the native performance of WhisperKit on Apple devices.

## Use Cases

### Accessibility Applications

WhisperKit is perfect for creating accessibility applications that convert speech to text for users with hearing impairments. Its real-time capabilities and high accuracy make it suitable for live captioning and transcription.

### Content Creation Tools

Applications for content creators can use WhisperKit to automatically transcribe interviews, podcasts, or video content, saving time and effort in the content production process.

### Language Learning

Language learning applications can use WhisperKit to provide real-time feedback on pronunciation and conversation practice, helping users improve their language skills.

### Meeting Transcription

WhisperKit can be used to transcribe meetings and conversations, creating searchable records and ensuring all team members have access to the discussion.

### Voice Assistants

With its real-time capabilities and on-device processing, WhisperKit is suitable for creating privacy-focused voice assistants that don't rely on cloud services for speech recognition.

## Technical Specifications

### Supported Audio Formats

WhisperKit supports various audio formats including:

- WAV
- MP3
- M4A
- FLAC
- AAC

### Supported Languages

WhisperKit supports transcription in over 50 languages, including:

- English
- Spanish
- French
- German
- Italian
- Portuguese
- Russian
- Japanese
- Chinese (Mandarin)
- Korean
- Arabic
- And many more

### System Requirements

- **iOS**: iOS 14.0 or later
- **macOS**: macOS 14.0 or later
- **Xcode**: Xcode 15.0 or later for development
- **Memory**: Varies by model size (from 100MB for tiny to 3GB for large models)

### Performance Characteristics

Performance varies by device and model size:

- **Real-time factor**: 0.1x to 1.0x (faster than real-time on most devices)
- **Latency**: 100ms to 2s depending on model size and device
- **Accuracy**: WER (Word Error Rate) ranging from 5% to 15% depending on audio quality and language

## Configuration Options

### Model Configuration

```swift
var config = WhisperKitConfig()
config.model = "medium"                    // Model size selection
config.modelRepo = "argmaxinc/whisperkit-coreml"  // Model repository
config.language = "en"                     // Language specification
config.task = .transcribe                  // Task type (transcribe/translate)
```

### Processing Configuration

```swift
config.enableVAD = true                    // Voice activity detection
config.vadFallbackTimeout = 3.0           // VAD timeout in seconds
config.enablePunctuation = true           // Automatic punctuation
config.enableFormatting = true            // Text formatting
config.enableTimestamps = false           // Word-level timestamps
```

### Streaming Configuration

```swift
var streamingConfig = StreamingConfig()
streamingConfig.bufferSize = 4096          // Audio buffer size
streamingConfig.sampleRate = 16000         // Sample rate in Hz
streamingConfig.channels = 1               // Number of audio channels
streamingConfig.updateInterval = 0.5       // Update interval in seconds
```

## Quality Considerations

### Audio Quality Impact

Transcription quality is affected by:

- **Audio clarity**: Clear audio produces better results
- **Background noise**: Minimize background noise for best results
- **Speaking pace**: Natural speaking pace is optimal
- **Microphone quality**: Better microphones improve accuracy

### Model Selection Guidelines

Choose models based on your requirements:

- **Tiny**: For resource-constrained devices or real-time applications where speed is critical
- **Small**: For general-purpose applications with good balance of speed and accuracy
- **Medium**: For applications requiring higher accuracy with acceptable performance
- **Large**: For applications where maximum accuracy is required and performance is secondary

### Language-Specific Considerations

Some languages may have better support than others:

- **High-resource languages** (English, Spanish, French) generally have better accuracy
- **Low-resource languages** may have reduced accuracy but are still functional
- **Code-switching** (mixing languages) may reduce accuracy
- **Regional accents** may affect performance depending on training data
