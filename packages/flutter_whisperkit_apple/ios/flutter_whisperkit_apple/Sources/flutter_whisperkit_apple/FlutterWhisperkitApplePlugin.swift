import Flutter
import UIKit
import WhisperKit

public class FlutterWhisperkitApplePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_whisperkit_apple", binaryMessenger: registrar.messenger())
    let instance = FlutterWhisperkitApplePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "createWhisperKit":
      guard let args = call.arguments as? [String: Any],
            let model = args["model"] as? String,
            let modelRepo = args["modelRepo"] as? String else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
        return
      }
      
      Task {
        do {
          let whisperKit = try await createWhisperKit(model: model, modelRepo: modelRepo)
          result("WhisperKit instance created successfully")
        } catch {
          result(FlutterError(code: "WHISPERKIT_INIT_ERROR", message: error.localizedDescription, details: nil))
        }
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  public func createWhisperKit(model: String, modelRepo: String) async throws -> WhisperKit? {
    let config = WhisperKitConfig(model: model, modelRepo: modelRepo)
    return try await WhisperKit(config)
  }
}
