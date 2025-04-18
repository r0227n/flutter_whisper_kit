import Cocoa
import FlutterMacOS

public class SwiftFlutterWhisperkitApplePlugin: NSObject, FlutterPlugin, FLTWhisperKitApi {
    private var whisperKitEvents: FLTWhisperKitEvents?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let messenger = registrar.messenger
        let api = SwiftFlutterWhisperkitApplePlugin()
        
        // Pigeonで生成されたセットアップ
        FLTWhisperKitApiSetup.setUp(binaryMessenger: messenger, api: api)
        
        // Flutterからのイベント受信登録
        api.whisperKitEvents = FLTWhisperKitEvents(binaryMessenger: messenger)
    }
    
    // MARK: - WhisperKitApi Implementation
    public func getPlatformVersion() throws -> String {
        let osVersion = ProcessInfo.processInfo.operatingSystemVersion
        return "macOS \(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)"
    }
    
    public func initializeWhisperKit(_ config: FLTWhisperKitConfig) throws -> Bool {
        print("Initializing WhisperKit with config:")
        if let modelPath = config.modelPath { print("- Model Path: \(modelPath)") }
        print("- Enable VAD: \(config.enableVAD ?? true)")
        print("- VAD Threshold: \(config.vadFallbackSilenceThreshold ?? 600)")
        print("- VAD Temperature: \(config.vadTemperature ?? 0.0)")
        print("- Language ID: \(config.enableLanguageIdentification ?? true)")
        
        return true
    }
    
    public func transcribeAudioFile(_ filePath: String) throws -> FLTTranscriptionResult {
        print("Transcribing audio from: \(filePath)")
        
        // デバッグ時の進捗通知の例
        DispatchQueue.global().async {
            for progress in stride(from: 0.0, through: 1.0, by: 0.1) {
                Thread.sleep(forTimeInterval: 0.2)
                try? self.whisperKitEvents?.onTranscriptionProgress(progress)
            }
        }
        
        let result = FLTTranscriptionResult()
        result.text = "This is a placeholder transcription result"
        result.duration = 5.5
        result.segments = ["Segment 1", "Segment 2"]
        result.language = "en"
        
        return result
    }
    
    public func startStreamingTranscription() throws -> Bool {
        print("Starting streaming transcription")
        
        // デモ用の中間結果通知
        DispatchQueue.global().async {
            for i in 1...5 {
                Thread.sleep(forTimeInterval: 1.0)
                let interim = FLTTranscriptionResult()
                interim.text = "Interim result \(i)"
                try? self.whisperKitEvents?.onInterimTranscriptionResult(interim)
            }
        }
        
        return true
    }
    
    public func stopStreamingTranscription() throws -> FLTTranscriptionResult {
        print("Stopping streaming transcription")
        
        let result = FLTTranscriptionResult()
        result.text = "Final streaming transcription result"
        result.duration = 12.3
        
        return result
    }
    
    public func getAvailableModels() throws -> [String] {
        return ["tiny", "base", "small", "medium", "large-v2"]
    }
} 