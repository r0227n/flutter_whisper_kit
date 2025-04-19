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
    
    public func initializeWhisperKit(config: PigeonWhisperKitConfig) throws -> Bool {
        do {
            var audioEncoderComputeUnits: ComputeUnits = .cpuAndNeuralEngine
            var textDecoderComputeUnits: ComputeUnits = .cpuAndNeuralEngine
            
            if #available(iOS 16.0, *) {
                audioEncoderComputeUnits = .cpuAndNeuralEngine
                textDecoderComputeUnits = .cpuAndNeuralEngine
            } else {
                audioEncoderComputeUnits = .cpuAndGPU
                textDecoderComputeUnits = .cpuAndGPU
            }
            
            let computeOptions = ModelComputeOptions(
                audioEncoderCompute: audioEncoderComputeUnits,
                textDecoderCompute: textDecoderComputeUnits
            )
            
            let modelFolder = config.modelPath ?? NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/WhisperKit/Models"
            let modelName = modelFolder.components(separatedBy: "/").last ?? "tiny"
            
            var modelVariant = "tiny"
            if modelName.contains("tiny") { modelVariant = "tiny" }
            else if modelName.contains("base") { modelVariant = "base" }
            else if modelName.contains("small") { modelVariant = "small" }
            else if modelName.contains("medium") { modelVariant = "medium" }
            else if modelName.contains("large") { modelVariant = "large" }
            
            let whisperKitConfig = WhisperKit.Configuration(
                model: modelVariant,
                modelFolder: modelFolder,
                computeOptions: computeOptions,
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
            
            whisperKit = try WhisperKit(config: whisperKitConfig)
            return true
        } catch {
            throw FlutterError(code: "INITIALIZATION_ERROR", 
                              message: "Failed to initialize WhisperKit: \(error.localizedDescription)", 
                              details: nil)
        }
    }
    
    public func transcribeAudioFile(filePath: String) throws -> PigeonTranscriptionResult {
        guard let whisperKit = whisperKit else {
            throw FlutterError(code: "NOT_INITIALIZED", 
                              message: "WhisperKit is not initialized", 
                              details: nil)
        }
        
        do {
            let result = try whisperKit.transcribeAudioFile(filePath)
            
            let pigeonSegments = result.segments.map { segment in
                return PigeonTranscriptionSegment(
                    text: segment.text,
                    startTime: segment.start,
                    endTime: segment.end
                )
            }
            
            return PigeonTranscriptionResult(
                text: result.text,
                segments: pigeonSegments,
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
    
    public func stopStreamingTranscription() throws -> PigeonTranscriptionResult {
        guard let whisperKit = whisperKit else {
            throw FlutterError(code: "NOT_INITIALIZED", 
                              message: "WhisperKit is not initialized", 
                              details: nil)
        }
        
        streamingTask?.cancel()
        
        do {
            let result = try whisperKit.stopStreamingTranscription()
            
            let pigeonSegments = result.segments.map { segment in
                return PigeonTranscriptionSegment(
                    text: segment.text,
                    startTime: segment.start,
                    endTime: segment.end
                )
            }
            
            return PigeonTranscriptionResult(
                text: result.text,
                segments: pigeonSegments,
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
