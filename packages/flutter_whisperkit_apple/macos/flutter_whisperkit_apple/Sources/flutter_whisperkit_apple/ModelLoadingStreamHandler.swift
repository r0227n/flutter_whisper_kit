import FlutterMacOS
import Foundation

private class ModelLoadingStreamHandler: NSObject, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?
  
  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    eventSink = events
    return nil
  }
  
  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    return nil
  }
  
  func sendProgress(_ progress: Double) {
    if let eventSink = eventSink {
      DispatchQueue.main.async {
        eventSink(progress)
      }
    }
  }
}
