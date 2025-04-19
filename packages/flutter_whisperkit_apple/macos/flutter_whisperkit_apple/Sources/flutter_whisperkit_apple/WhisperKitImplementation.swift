import Foundation
import WhisperKit
import FlutterMacOS


public class WhisperKitImplementation {
    private var whisperKit: WhisperKit?
    
    public func initialize(config: PigeonWhisperKitConfig) throws -> Bool {
        do {
            let modelPath = config.modelPath ?? WhisperKitImplementation.defaultModelPath
            
            var modelVariant: WhisperKit.ModelVariant = .tiny
            if let modelVariantStr = config.modelPath?.components(separatedBy: "/").last {
                if modelVariantStr.contains("tiny") { modelVariant = .tiny }
                else if modelVariantStr.contains("base") { modelVariant = .base }
                else if modelVariantStr.contains("small") { modelVariant = .small }
                else if modelVariantStr.contains("medium") { modelVariant = .medium }
                else if modelVariantStr.contains("large") { modelVariant = .large }
            }
            
            let whisperKitConfig = WhisperKit.Configuration(
                model: modelVariant.rawValue,
                modelFolder: modelPath,
                computeOptions: {
                    let options = ModelComputeOptions()
                    options.preferGPU = true
                    options.computeUnits = .all
                    return options
                }(),
                audioProcessingOptions: {
                    let options = AudioProcessingOptions()
                    options.vadEnabled = config.enableVAD ?? false
                    if let silenceThreshold = config.vadFallbackSilenceThreshold {
                        options.vadSilenceThreshold = Double(silenceThreshold) / 1000.0
                    }
                    if let speechThreshold = config.vadTemperature {
                        options.vadSpeechThreshold = speechThreshold
                    }
                    return options
                }(),
                languageIdentificationOptions: {
                    let options = LanguageIdentificationOptions()
                    options.enabled = config.enableLanguageIdentification ?? false
                    return options
                }(),
                verbose: true,
                logLevel: .info
            )
            
            // Initialize WhisperKit with the config
            whisperKit = try WhisperKit(config: whisperKitConfig)
            
            if config.enableLanguageIdentification ?? false {
                NotificationCenter.default.addObserver(
                    forName: Notification.Name.whisperKitDidChangeModelState,
                    object: whisperKit,
                    queue: .main
                ) { notification in
                    if let modelState = notification.userInfo?["modelState"] as? WhisperKit.ModelState,
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
    
    public func transcribeAudioFile(_ filePath: String) throws -> WhisperKitTranscriptionResult {
        guard let whisperKit = whisperKit else {
            throw NSError(domain: "WhisperKitError", code: 1, userInfo: [NSLocalizedDescriptionKey: "WhisperKit not initialized"])
        }
        
        do {
            let audioURL = URL(fileURLWithPath: filePath)
            let result = try whisperKit.transcribe(audioURL: audioURL)
            
            let segments = result.segments.map { segment in
                return WhisperKitTranscriptionSegment(
                    text: segment.text,
                    startTime: segment.start,
                    endTime: segment.end
                )
            }
            
            return WhisperKitTranscriptionResult(
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
    
    public func stopStreamingTranscription() throws -> WhisperKitTranscriptionResult {
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
public struct WhisperKitTranscriptionSegment {
    public let text: String
    public let startTime: Double
    public let endTime: Double
    
    public init(text: String, startTime: Double, endTime: Double) {
        self.text = text
        self.startTime = startTime
        self.endTime = endTime
    }
}

public struct WhisperKitTranscriptionResult {
    public let text: String
    public let segments: [WhisperKitTranscriptionSegment]
    public let language: String?
    
    public init(text: String, segments: [WhisperKitTranscriptionSegment], language: String? = nil) {
        self.text = text
        self.segments = segments
        self.language = language
    }
}
