import Flutter
import UIKit
import WhisperKit


public class FlutterWhisperkitApplePlugin: NSObject, FlutterPlugin {
  private var whisperKit: WhisperKit?
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_whisperkit_apple", binaryMessenger: registrar.messenger)
    let instance = FlutterWhisperkitApplePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("macOS " + ProcessInfo.processInfo.operatingSystemVersionString)
    case "createWhisperKit":
      Task {
        do {
          let args = call.arguments as? [String: Any]
          let model = args?["model"] as? String
          let modelRepo = args?["modelRepo"] as? String
     
          result("WhisperKit instance created successfully: \(model) \(modelRepo)")
        } catch {
          result(FlutterError(code: "WHISPERKIT_INIT_ERROR", message: error.localizedDescription, details: nil))
        }
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
