import FlutterMacOS
import WhisperKit

public class FlutterWhisperkitApplePlugin: NSObject, FlutterPlugin, WhisperKitApi {
    private var whisperKit: WhisperKit?
    private var streamingTask: Task<Void, Never>?
    private var events: WhisperKitEvents?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = FlutterWhisperkitApplePlugin()
        WhisperKitApiSetup.setUp(binaryMessenger: registrar.messenger, api: instance)
        instance.events = WhisperKitEvents(binaryMessenger: registrar.messenger)
    }
    
    public func getPlatformVersion() throws -> String {
        let version = ProcessInfo.processInfo.operatingSystemVersion
        return "macOS \(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
    }
    
    public func initializeWhisperKit(config: WhisperKitConfig) throws -> Bool {
        let whisperConfig = WhisperKitConfig(
            modelPath: config.modelPath,
            enableVAD: config.enableVAD ?? false,
            vadFallbackSilenceThreshold: config.vadFallbackSilenceThreshold ?? 0,
            vadTemperature: config.vadTemperature ?? 0.0,
            enableLanguageIdentification: config.enableLanguageIdentification ?? false
        )
        
        whisperKit = try WhisperKit(config: whisperConfig)
        return true
    }
    
    public func transcribeAudioFile(filePath: String) throws -> TranscriptionResult {
        guard let whisperKit = whisperKit else {
            throw FlutterError(code: "NOT_INITIALIZED", message: "WhisperKit is not initialized", details: nil)
        }
        
        let result = try whisperKit.transcribeAudioFile(filePath)
        return TranscriptionResult(
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
    }
    
    public func startStreamingTranscription() throws -> Bool {
        guard let whisperKit = whisperKit else {
            throw FlutterError(code: "NOT_INITIALIZED", message: "WhisperKit is not initialized", details: nil)
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
    
    public func stopStreamingTranscription() throws -> TranscriptionResult {
        guard let whisperKit = whisperKit else {
            throw FlutterError(code: "NOT_INITIALIZED", message: "WhisperKit is not initialized", details: nil)
        }
        
        streamingTask?.cancel()
        let result = try whisperKit.stopStreamingTranscription()
        
        return TranscriptionResult(
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
    }
    
    public func getAvailableModels() throws -> [String] {
        return try WhisperKit.getAvailableModels()
    }
} 