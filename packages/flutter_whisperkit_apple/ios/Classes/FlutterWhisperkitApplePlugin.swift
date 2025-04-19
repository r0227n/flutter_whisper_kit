import Flutter
import UIKit

public class FlutterWhisperkitApplePlugin: NSObject, FlutterPlugin, WhisperKitApi {
    private var whisperKit: WhisperKit?
    private var streamingTask: Task<Void, Never>?
    private var events: WhisperKitEvents?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = FlutterWhisperkitApplePlugin()
        WhisperKitApiSetup.setUp(binaryMessenger: registrar.messenger(), api: instance)
        instance.events = WhisperKitEvents(binaryMessenger: registrar.messenger())
    }
    
    public func getPlatformVersion() throws -> String {
        return "iOS " + UIDevice.current.systemVersion
    }
    
    public func initializeWhisperKit(config: WhisperKitConfig_pigeongenerated) throws -> Bool {
        let whisperConfig = WhisperKitConfig(
            modelPath: config.modelPath,
            enableVAD: config.enableVAD ?? false,
            vadFallbackSilenceThreshold: config.vadFallbackSilenceThreshold ?? 0,
            vadTemperature: config.vadTemperature ?? 0.0,
            enableLanguageIdentification: config.enableLanguageIdentification ?? false
        )
        
        do {
            whisperKit = try WhisperKit(config: whisperConfig)
            return true
        } catch {
            throw FlutterError(code: "INITIALIZATION_ERROR", 
                              message: "Failed to initialize WhisperKit: \(error.localizedDescription)", 
                              details: nil)
        }
    }
    
    public func transcribeAudioFile(filePath: String) throws -> TranscriptionResult_pigeongenerated {
        guard let whisperKit = whisperKit else {
            throw FlutterError(code: "NOT_INITIALIZED", 
                              message: "WhisperKit is not initialized", 
                              details: nil)
        }
        
        do {
            let result = try whisperKit.transcribeAudioFile(filePath)
            
            return TranscriptionResult_pigeongenerated(
                text: result.text,
                segments: result.segments.map { segment in
                    TranscriptionSegment_pigeongenerated(
                        text: segment.text,
                        startTime: segment.startTime,
                        endTime: segment.endTime
                    )
                },
                language: result.language
            )
        } catch {
            throw FlutterError(code: "TRANSCRIPTION_ERROR", 
                              message: "Failed to transcribe audio file: \(error.localizedDescription)", 
                              details: nil)
        }
    }
    
    public func startStreamingTranscription() throws -> Bool {
        guard let whisperKit = whisperKit else {
            throw FlutterError(code: "NOT_INITIALIZED", 
                              message: "WhisperKit is not initialized", 
                              details: nil)
        }
        
        streamingTask = Task {
            do {
                try await whisperKit.startStreamingTranscription()
            } catch {
                print("Streaming transcription error: \(error)")
            }
        }
        
        return true
    }
    
    public func stopStreamingTranscription() throws -> TranscriptionResult_pigeongenerated {
        guard let whisperKit = whisperKit else {
            throw FlutterError(code: "NOT_INITIALIZED", 
                              message: "WhisperKit is not initialized", 
                              details: nil)
        }
        
        streamingTask?.cancel()
        
        do {
            let result = try whisperKit.stopStreamingTranscription()
            
            return TranscriptionResult_pigeongenerated(
                text: result.text,
                segments: result.segments.map { segment in
                    TranscriptionSegment_pigeongenerated(
                        text: segment.text,
                        startTime: segment.startTime,
                        endTime: segment.endTime
                    )
                },
                language: result.language
            )
        } catch {
            throw FlutterError(code: "TRANSCRIPTION_ERROR", 
                              message: "Failed to stop streaming transcription: \(error.localizedDescription)", 
                              details: nil)
        }
    }
    
    public func getAvailableModels() throws -> [String] {
        do {
            return try WhisperKit.getAvailableModels()
        } catch {
            throw FlutterError(code: "MODEL_ERROR", 
                              message: "Failed to get available models: \(error.localizedDescription)", 
                              details: nil)
        }
    }
}

private class WhisperKit {
    struct WhisperKitConfig {
        let modelPath: String?
        let enableVAD: Bool
        let vadFallbackSilenceThreshold: Int
        let vadTemperature: Double
        let enableLanguageIdentification: Bool
    }
    
    struct TranscriptionSegment {
        let text: String
        let startTime: Double
        let endTime: Double
    }
    
    struct TranscriptionResult {
        let text: String
        let segments: [TranscriptionSegment]
        let language: String?
    }
    
    init(config: WhisperKitConfig) throws {
    }
    
    func transcribeAudioFile(_ filePath: String) throws -> TranscriptionResult {
        return TranscriptionResult(
            text: "Sample transcription",
            segments: [
                TranscriptionSegment(text: "Sample segment", startTime: 0.0, endTime: 1.0)
            ],
            language: "en"
        )
    }
    
    func startStreamingTranscription() async throws {
    }
    
    func stopStreamingTranscription() throws -> TranscriptionResult {
        return TranscriptionResult(
            text: "Sample transcription",
            segments: [
                TranscriptionSegment(text: "Sample segment", startTime: 0.0, endTime: 1.0)
            ],
            language: "en"
        )
    }
    
    static func getAvailableModels() throws -> [String] {
        return ["tiny", "base", "small", "medium", "large"]
    }
}
