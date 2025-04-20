import Cocoa
import FlutterMacOS
import WhisperKit


private class WhisperKitApiImpl: WhisperKitMessage {
  private var whisperKit: WhisperKit?
  
  func getPlatformVersion(completion: @escaping (Result<String?, Error>) -> Void) {
    completion(.success("macOS " + ProcessInfo.processInfo.operatingSystemVersionString))
  }
  
  func createWhisperKit(model: String?, modelRepo: String?, completion: @escaping (Result<String?, Error>) -> Void) {
    Task {
        do {
          whisperKit = try await WhisperKit()
     
          completion(.success("WhisperKit instance created successfully: \(model ?? "default") \(modelRepo ?? "default")"))
        } catch {
          completion(.failure(error))
        }
      }
  }
  
  func transcribeCurrentFile(filePath: String?, completion: @escaping (Result<String?, Error>) -> Void) {
    guard let filePath = filePath else {
      completion(.failure(NSError(domain: "WhisperKitError", code: 1001, userInfo: [NSLocalizedDescriptionKey: "File path is required"])))
      return
    }
    
    Task {
      do {
        if whisperKit == nil {
          whisperKit = try await WhisperKit()
        }
        
        guard let whisperKit = whisperKit else {
          completion(.failure(NSError(domain: "WhisperKitError", code: 1002, userInfo: [NSLocalizedDescriptionKey: "Failed to initialize WhisperKit"])))
          return
        }
        
        let transcriptionResults = try await whisperKit.transcribe(audioPath: filePath)
        
        let resultText = transcriptionResults.map { $0.text }.joined(separator: " ")
        
        completion(.success(resultText))
      } catch {
        completion(.failure(error))
      }
    }
  }
}

public class FlutterWhisperkitApplePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    // Pigeonで生成されたSetupコードを呼び出す
    WhisperKitMessageSetup.setUp(binaryMessenger: registrar.messenger, api: WhisperKitApiImpl())
  }
}
