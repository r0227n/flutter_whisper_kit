import FlutterMacOS
import Foundation

public class FlutterWhisperkitApplePlugin: NSObject, FlutterPlugin, WhisperKitApi {
    private var whisperKit: WhisperKit?
    private var streamingTask: Task<Void, Never>?
    private var events: WhisperKitEvents?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = FlutterWhisperkitApplePlugin()
        WhisperKitApiSetup.setUp(binaryMessenger: registrar.messenger, api: instance)
        instance.events = WhisperKitEvents(binaryMessenger: registrar.messenger)
    }
    
    public func getPlatformVersion(completion: @escaping (Result<String, Error>) -> Void) {
        let version = ProcessInfo.processInfo.operatingSystemVersion
        let versionString = "macOS \(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
        completion(.success(versionString))
    }
    
    public func initializeWhisperKit(config: WhisperKitConfig, completion: @escaping (Result<Bool, Error>) -> Void) {
        let whisperConfig = WhisperKitConfig(
            modelPath: config.modelPath,
            enableVAD: config.enableVAD ?? false,
            vadFallbackSilenceThreshold: Int(config.vadFallbackSilenceThreshold ?? 0),
            vadTemperature: config.vadTemperature ?? 0.0,
            enableLanguageIdentification: config.enableLanguageIdentification ?? false
        )
        
        do {
            whisperKit = try WhisperKit(config: whisperConfig)
            completion(.success(true))
        } catch {
            completion(.failure(FlutterError(code: "INITIALIZATION_ERROR", 
                                           message: "Failed to initialize WhisperKit: \(error.localizedDescription)", 
                                           details: nil)))
        }
    }
    
    public func transcribeAudioFile(filePath: String, completion: @escaping (Result<TranscriptionResult, Error>) -> Void) {
        guard let whisperKit = whisperKit else {
            completion(.failure(FlutterError(code: "NOT_INITIALIZED", 
                                           message: "WhisperKit is not initialized", 
                                           details: nil)))
            return
        }
        
        do {
            let result = try whisperKit.transcribeAudioFile(filePath)
            
            let transcriptionResult = TranscriptionResult(
                text: result.text,
                segments: result.segments.map { segment in
                    TranscriptionSegment(
                        text: segment.text,
                        startTime: segment.startTime,
                        endTime: segment.endTime
                    )
                },
                language: result.language
            )
            
            completion(.success(transcriptionResult))
        } catch {
            completion(.failure(FlutterError(code: "TRANSCRIPTION_ERROR", 
                                           message: "Failed to transcribe audio file: \(error.localizedDescription)", 
                                           details: nil)))
        }
    }
    
    public func startStreamingTranscription(completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let whisperKit = whisperKit else {
            completion(.failure(FlutterError(code: "NOT_INITIALIZED", 
                                           message: "WhisperKit is not initialized", 
                                           details: nil)))
            return
        }
        
        streamingTask = Task {
            do {
                try await whisperKit.startStreamingTranscription()
            } catch {
                print("Streaming transcription error: \(error)")
            }
        }
        
        completion(.success(true))
    }
    
    public func stopStreamingTranscription(completion: @escaping (Result<TranscriptionResult, Error>) -> Void) {
        guard let whisperKit = whisperKit else {
            completion(.failure(FlutterError(code: "NOT_INITIALIZED", 
                                           message: "WhisperKit is not initialized", 
                                           details: nil)))
            return
        }
        
        streamingTask?.cancel()
        
        do {
            let result = try whisperKit.stopStreamingTranscription()
            
            let transcriptionResult = TranscriptionResult(
                text: result.text,
                segments: result.segments.map { segment in
                    TranscriptionSegment(
                        text: segment.text,
                        startTime: segment.startTime,
                        endTime: segment.endTime
                    )
                },
                language: result.language
            )
            
            completion(.success(transcriptionResult))
        } catch {
            completion(.failure(FlutterError(code: "TRANSCRIPTION_ERROR", 
                                           message: "Failed to stop streaming transcription: \(error.localizedDescription)", 
                                           details: nil)))
        }
    }
    
    public func getAvailableModels(completion: @escaping (Result<[String], Error>) -> Void) {
        do {
            let models = try WhisperKit.getAvailableModels()
            completion(.success(models))
        } catch {
            completion(.failure(FlutterError(code: "MODEL_ERROR", 
                                           message: "Failed to get available models: \(error.localizedDescription)", 
                                           details: nil)))
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
