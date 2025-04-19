import Cocoa
import FlutterMacOS
import WhisperKit

public class FlutterWhisperkitApplePlugin: NSObject, FlutterPlugin {
  private var implementation: WhisperKitImplementation?
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = FlutterWhisperkitApplePlugin()
    instance.implementation = WhisperKitImplementation(binaryMessenger: registrar.messenger)
    WhisperKitApiSetup.setUp(binaryMessenger: registrar.messenger, api: instance.implementation)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("macOS " + ProcessInfo.processInfo.operatingSystemVersionString)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
