import Foundation
import WhisperKit

public class WhisperKitImplementation {
    private var whisperKit: WhisperKit?
    
    public func initialize(config: WhisperKitConfig) throws -> Bool {
        do {
            let modelPath = config.modelPath ?? WhisperKitImplementation.defaultModelPath
            
            var modelVariant: ModelVariant = .tiny
            if let modelVariantStr = config.modelVariant {
                switch modelVariantStr.lowercased() {
                case "tiny": modelVariant = .tiny
                case "base": modelVariant = .base
                case "small": modelVariant = .small
                case "medium": modelVariant = .medium
                case "large": modelVariant = .large
                default: modelVariant = .tiny
                }
            }
            
            let computeOptions = ModelComputeOptions(
                preferGPU: true,
                computeUnits: .all
            )
            
            let audioProcessingOptions = AudioProcessingOptions(
                enableVAD: config.enableVAD,
                vadMode: .quality,
                vadSilenceThreshold: config.vadFallbackSilenceThreshold / 1000.0,
                vadSpeechThreshold: config.vadTemperature
            )
            
            // Initialize WhisperKit
            whisperKit = try WhisperKit(
                modelFolder: modelPath,
                modelVariant: modelVariant,
                modelCompute: computeOptions,
                audioProcessing: audioProcessingOptions,
                verbose: true
            )
            
            if config.enableLanguageIdentification {
                NotificationCenter.default.addObserver(
                    forName: .whisperKitModelStateDidChange,
                    object: whisperKit,
                    queue: .main
                ) { notification in
                    if let modelState = notification.userInfo?["modelState"] as? ModelState,
                       modelState == .unloaded {
                    }
                }
            }
            
            return true
        } catch {
            print("WhisperKit initialization error: \(error)")
            throw error
        }
    }
    
    public func transcribeAudioFile(_ filePath: String) throws -> APITranscriptionResult {
        guard let whisperKit = whisperKit else {
            throw NSError(domain: "WhisperKitError", code: 1, userInfo: [NSLocalizedDescriptionKey: "WhisperKit not initialized"])
        }
        
        do {
            let audioURL = URL(fileURLWithPath: filePath)
            let result = try whisperKit.transcribe(audioFile: audioURL)
            
            let segments = result.segments.map { segment in
                return APITranscriptionSegment(
                    text: segment.text,
                    startTime: segment.start,
                    endTime: segment.end
                )
            }
            
            return APITranscriptionResult(
                text: result.text,
                segments: segments,
                language: result.language
            )
        } catch {
            print("Transcription error: \(error)")
            throw error
        }
    }
    
    public func startStreamingTranscription() async throws {
        guard let whisperKit = whisperKit else {
            throw NSError(domain: "WhisperKitError", code: 1, userInfo: [NSLocalizedDescriptionKey: "WhisperKit not initialized"])
        }
        
        do {
            print("Streaming transcription is not supported in this version")
            throw NSError(domain: "WhisperKitError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Streaming transcription is not supported in this version"])
        } catch {
            print("Start streaming error: \(error)")
            throw error
        }
    }
    
    public func stopStreamingTranscription() throws -> APITranscriptionResult {
        guard let whisperKit = whisperKit else {
            throw NSError(domain: "WhisperKitError", code: 1, userInfo: [NSLocalizedDescriptionKey: "WhisperKit not initialized"])
        }
        
        do {
            print("Streaming transcription is not supported in this version")
            throw NSError(domain: "WhisperKitError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Streaming transcription is not supported in this version"])
        } catch {
            print("Stop streaming error: \(error)")
            throw error
        }
    }
    
    public static func getAvailableModels() throws -> [String] {
        return ["tiny", "base", "small", "medium", "large"]
    }
    
    static var defaultModelPath: String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/WhisperKit/Models"
    }
}

public struct WhisperKitConfig {
    public let modelPath: String?
    public let modelVariant: String?
    public let enableVAD: Bool
    public let vadFallbackSilenceThreshold: Double
    public let vadTemperature: Double
    public let enableLanguageIdentification: Bool
    
    public init(
        modelPath: String? = nil,
        modelVariant: String? = "tiny",
        enableVAD: Bool = false,
        vadFallbackSilenceThreshold: Double = 600,
        vadTemperature: Double = 0.15,
        enableLanguageIdentification: Bool = false
    ) {
        self.modelPath = modelPath
        self.modelVariant = modelVariant
        self.enableVAD = enableVAD
        self.vadFallbackSilenceThreshold = vadFallbackSilenceThreshold
        self.vadTemperature = vadTemperature
        self.enableLanguageIdentification = enableLanguageIdentification
    }
}

public struct APITranscriptionSegment {
    public let text: String
    public let startTime: Double
    public let endTime: Double
    
    public init(text: String, startTime: Double, endTime: Double) {
        self.text = text
        self.startTime = startTime
        self.endTime = endTime
    }
}

public struct APITranscriptionResult {
    public let text: String
    public let segments: [APITranscriptionSegment]
    public let language: String?
    
    public init(text: String, segments: [APITranscriptionSegment], language: String? = nil) {
        self.text = text
        self.segments = segments
        self.language = language
    }
}

public typealias TranscriptionSegment = APITranscriptionSegment
public typealias TranscriptionResult = APITranscriptionResult
