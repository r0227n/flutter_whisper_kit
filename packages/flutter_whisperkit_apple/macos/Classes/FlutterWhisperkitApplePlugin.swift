import FlutterMacOS
import Foundation
import flutter_whisperkit_apple

public class FlutterWhisperkitApplePlugin: NSObject, FlutterPlugin, WhisperKitApi {
    private var whisperKitImplementation: WhisperKitImplementation?
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
    
    public func initializeWhisperKit(config: PigeonWhisperKitConfig, completion: @escaping (Result<Bool, Error>) -> Void) {
        do {
            let whisperConfig = WhisperKit.Configuration()
            whisperConfig.computeOptions.modelFolder = config.modelPath ?? ""
            whisperConfig.vadOptions.enabled = config.enableVAD ?? false
            whisperConfig.vadOptions.silenceThreshold = Double(config.vadFallbackSilenceThreshold ?? 0)
            whisperConfig.vadOptions.speechThreshold = config.vadTemperature ?? 0.0
            whisperConfig.languageIdentificationOptions.enabled = config.enableLanguageIdentification ?? false
            
            whisperKitImplementation = WhisperKitImplementation()
            let result = try whisperKitImplementation?.initialize(config: whisperConfig) ?? false
            completion(.success(result))
        } catch {
            print("WhisperKit initialization error: \(error)")
            completion(.failure(FlutterError(code: "INITIALIZATION_ERROR", 
                                           message: "Failed to initialize WhisperKit: \(error.localizedDescription)", 
                                           details: nil)))
        }
    }
    
    public func transcribeAudioFile(filePath: String, completion: @escaping (Result<PigeonTranscriptionResult, Error>) -> Void) {
        guard let whisperKitImplementation = whisperKitImplementation else {
            completion(.failure(FlutterError(code: "NOT_INITIALIZED", 
                                           message: "WhisperKit is not initialized", 
                                           details: nil)))
            return
        }
        
        do {
            let result = try whisperKitImplementation.transcribeAudioFile(filePath)
            
            let pigeonSegments = result.segments.map { segment in
                return PigeonTranscriptionSegment(
                    text: segment.text,
                    startTime: segment.start,
                    endTime: segment.end
                )
            }
            
            let pigeonResult = PigeonTranscriptionResult(
                text: result.text,
                segments: pigeonSegments,
                language: result.language
            )
            
            completion(.success(pigeonResult))
        } catch {
            print("Transcription error: \(error)")
            completion(.failure(FlutterError(code: "TRANSCRIPTION_ERROR", 
                                           message: "Failed to transcribe audio file: \(error.localizedDescription)", 
                                           details: nil)))
        }
    }
    
    public func startStreamingTranscription(completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let whisperKitImplementation = whisperKitImplementation else {
            completion(.failure(FlutterError(code: "NOT_INITIALIZED", 
                                           message: "WhisperKit is not initialized", 
                                           details: nil)))
            return
        }
        
        streamingTask = Task {
            do {
                try await whisperKitImplementation.startStreamingTranscription()
            } catch {
                print("Streaming transcription error: \(error)")
            }
        }
        
        completion(.success(true))
    }
    
    public func stopStreamingTranscription(completion: @escaping (Result<PigeonTranscriptionResult, Error>) -> Void) {
        guard let whisperKitImplementation = whisperKitImplementation else {
            completion(.failure(FlutterError(code: "NOT_INITIALIZED", 
                                           message: "WhisperKit is not initialized", 
                                           details: nil)))
            return
        }
        
        streamingTask?.cancel()
        
        do {
            let result = try whisperKitImplementation.stopStreamingTranscription()
            
            let pigeonSegments = result.segments.map { segment in
                return PigeonTranscriptionSegment(
                    text: segment.text,
                    startTime: segment.start,
                    endTime: segment.end
                )
            }
            
            let pigeonResult = PigeonTranscriptionResult(
                text: result.text,
                segments: pigeonSegments,
                language: result.language
            )
            
            completion(.success(pigeonResult))
        } catch {
            print("Stop streaming error: \(error)")
            completion(.failure(FlutterError(code: "TRANSCRIPTION_ERROR", 
                                           message: "Failed to stop streaming transcription: \(error.localizedDescription)", 
                                           details: nil)))
        }
    }
    
    public func getAvailableModels(completion: @escaping (Result<[String], Error>) -> Void) {
        do {
            let models = try WhisperKitImplementation.getAvailableModels()
            completion(.success(models))
        } catch {
            print("Get available models error: \(error)")
            completion(.failure(FlutterError(code: "MODEL_ERROR", 
                                           message: "Failed to get available models: \(error.localizedDescription)", 
                                           details: nil)))
        }
    }
}
