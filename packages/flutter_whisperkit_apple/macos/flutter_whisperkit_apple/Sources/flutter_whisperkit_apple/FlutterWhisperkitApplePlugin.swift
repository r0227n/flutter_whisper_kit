import Cocoa
import FlutterMacOS
import WhisperKit


private class WhisperKitApiImpl: WhisperKitMessage {
  func getPlatformVersion(completion: @escaping (Result<String?, Error>) -> Void) {
    completion(.success("macOS " + ProcessInfo.processInfo.operatingSystemVersionString))
  }
  
  func createWhisperKit(model: String?, modelRepo: String?, completion: @escaping (Result<String?, Error>) -> Void) {
    Task {
        do {

          let pipe = try? await WhisperKit()
     
          completion(.success("WhisperKit instance created successfully: \(model ?? "default") \(modelRepo ?? "default")"))
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
