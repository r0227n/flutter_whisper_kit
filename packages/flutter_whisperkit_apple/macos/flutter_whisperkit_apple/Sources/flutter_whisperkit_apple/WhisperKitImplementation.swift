import Foundation
import WhisperKit

public class WhisperKitImplementation {
    private var whisperKit: WhisperKit?
    
    public func initialize(config: WhisperKitConfig) throws -> Bool {
        do {
            let modelPath = config.modelPath ?? WhisperKit.defaultModelPath
            
            whisperKit = try WhisperKit(
                modelFolder: URL(fileURLWithPath: modelPath),
                verbose: true
            )
            
            if let whisperKit = whisperKit {
                if config.enableVAD ?? false {
                    try whisperKit.setVADOptions(
                        vadFallbackSilenceThreshold: TimeInterval(config.vadFallbackSilenceThreshold ?? 600) / 1000.0,
                        vadTemperature: config.vadTemperature ?? 0.15
                    )
                }
                
                if config.enableLanguageIdentification ?? false {
                    whisperKit.setLanguageDetection(enabled: true)
                }
            }
            
            return true
        } catch {
            print("WhisperKit initialization error: \(error)")
            throw error
        }
    }
    
    public func transcribeAudioFile(_ filePath: String) throws -> TranscriptionResult {
        guard let whisperKit = whisperKit else {
            throw NSError(domain: "WhisperKitError", code: 1, userInfo: [NSLocalizedDescriptionKey: "WhisperKit not initialized"])
        }
        
        do {
            let audioURL = URL(fileURLWithPath: filePath)
            let result = try whisperKit.transcribe(audioURL: audioURL)
            
            let segments = result.segments.map { segment in
                return TranscriptionSegment(
                    text: segment.text,
                    startTime: segment.start,
                    endTime: segment.end
                )
            }
            
            return TranscriptionResult(
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
            try await whisperKit.startStreamingASR()
        } catch {
            print("Start streaming error: \(error)")
            throw error
        }
    }
    
    public func stopStreamingTranscription() throws -> TranscriptionResult {
        guard let whisperKit = whisperKit else {
            throw NSError(domain: "WhisperKitError", code: 1, userInfo: [NSLocalizedDescriptionKey: "WhisperKit not initialized"])
        }
        
        do {
            let result = try whisperKit.stopStreamingASR()
            
            let segments = result.segments.map { segment in
                return TranscriptionSegment(
                    text: segment.text,
                    startTime: segment.start,
                    endTime: segment.end
                )
            }
            
            return TranscriptionResult(
                text: result.text,
                segments: segments,
                language: result.language
            )
        } catch {
            print("Stop streaming error: \(error)")
            throw error
        }
    }
    
    public static func getAvailableModels() throws -> [String] {
        return ["tiny", "base", "small", "medium", "large"]
    }
}

public struct WhisperKitConfig {
    public let modelPath: String?
    public let enableVAD: Bool
    public let vadFallbackSilenceThreshold: Int
    public let vadTemperature: Double
    public let enableLanguageIdentification: Bool
    
    public init(
        modelPath: String? = nil,
        enableVAD: Bool = false,
        vadFallbackSilenceThreshold: Int = 600,
        vadTemperature: Double = 0.15,
        enableLanguageIdentification: Bool = false
    ) {
        self.modelPath = modelPath
        self.enableVAD = enableVAD
        self.vadFallbackSilenceThreshold = vadFallbackSilenceThreshold
        self.vadTemperature = vadTemperature
        self.enableLanguageIdentification = enableLanguageIdentification
    }
}

public struct TranscriptionSegment {
    public let text: String
    public let startTime: Double
    public let endTime: Double
    
    public init(text: String, startTime: Double, endTime: Double) {
        self.text = text
        self.startTime = startTime
        self.endTime = endTime
    }
}

public struct TranscriptionResult {
    public let text: String
    public let segments: [TranscriptionSegment]
    public let language: String?
    
    public init(text: String, segments: [TranscriptionSegment], language: String? = nil) {
        self.text = text
        self.segments = segments
        self.language = language
    }
}

extension WhisperKit {
    static var defaultModelPath: String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/WhisperKit/Models"
    }
}
