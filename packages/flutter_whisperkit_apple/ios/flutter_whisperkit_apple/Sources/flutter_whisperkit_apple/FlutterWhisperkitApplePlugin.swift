import Flutter
import UIKit
import WhisperKit

private class WhisperKitApiImpl: WhisperKitMessage {
  private var whisperKit: WhisperKit?
  
  func getPlatformVersion(completion: @escaping (Result<String?, Error>) -> Void) {
    completion(.success("macOS " + ProcessInfo.processInfo.operatingSystemVersionString))
  }
  
  func createWhisperKit(model: String?, modelRepo: String?, completion: @escaping (Result<String?, Error>) -> Void) {
    Task {
        do {
          whisperKit = try? await WhisperKit()
     
          completion(.success("WhisperKit instance created successfully: \(model ?? "default") \(modelRepo ?? "default")"))
        } catch {
          completion(.failure(error))
        }
      }
  }
  
  func transcribeCurrentFile(filePath: String?, completion: @escaping (Result<String?, Error>) -> Void) {
    guard let filePath = filePath, !filePath.isEmpty else {
      completion(.failure(NSError(domain: "com.flutter.whisperkit", code: 1, userInfo: [NSLocalizedDescriptionKey: "File path is required"])))
      return
    }
    
    Task {
      do {
        if whisperKit == nil {
          whisperKit = try? await WhisperKit()
        }
        
        guard let whisperKit = whisperKit else {
          completion(.failure(NSError(domain: "com.flutter.whisperkit", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to initialize WhisperKit"])))
          return
        }
        
        let url = URL(fileURLWithPath: filePath)
        let result = try await whisperKit.transcribe(audioFile: url)
        
        completion(.success(result.text))
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
