import Foundation
import WhisperKit

@objc public class WhisperKitBridge: NSObject {
    private static let whisperKitImpl = WhisperKitApiImpl()
    private static var transcriptionCallback: ((String) -> Void)?
    private static var modelProgressCallback: ((NSDictionary) -> Void)?
    
    @objc public static func registerTranscriptionCallback(_ callback: @escaping (String) -> Void) {
        transcriptionCallback = callback
        WhisperKitApiImpl.transcriptionStreamHandler?.onListen(withArguments: nil, eventSink: { event in
            if let event = event as? String {
                transcriptionCallback?(event)
            }
        })
    }
    
    @objc public static func registerModelProgressCallback(_ callback: @escaping (NSDictionary) -> Void) {
        modelProgressCallback = callback
        WhisperKitApiImpl.modelProgressStreamHandler?.onListen(withArguments: nil, eventSink: { event in
            if let event = event as? [String: Any] {
                modelProgressCallback?(event as NSDictionary)
            }
        })
    }
    
    @objc public static func unregisterTranscriptionCallback() {
        transcriptionCallback = nil
        WhisperKitApiImpl.transcriptionStreamHandler?.onCancel(withArguments: nil)
    }
    
    @objc public static func unregisterModelProgressCallback() {
        modelProgressCallback = nil
        WhisperKitApiImpl.modelProgressStreamHandler?.onCancel(withArguments: nil)
    }
    
    @objc public static func loadModel(_ variant: String?,
                                      modelRepo: String?,
                                      redownload: Bool,
                                      error: NSErrorPointer) -> String? {
        do {
            return try await whisperKitImpl.loadModel(variant, modelRepo, redownload)
        } catch {
            if let error = error {
                error.pointee = error as NSError
            }
            return nil
        }
    }
    
    @objc public static func transcribeFromFile(_ filePath: String,
                                              options: NSDictionary,
                                              error: NSErrorPointer) -> String? {
        do {
            return try await whisperKitImpl.transcribeFromFile(filePath, options as? [String: Any?] ?? [:])
        } catch {
            if let error = error {
                error.pointee = error as NSError
            }
            return nil
        }
    }
    
    @objc public static func startRecording(_ options: NSDictionary,
                                          loop: Bool,
                                          error: NSErrorPointer) -> String? {
        do {
            return try await whisperKitImpl.startRecording(options as? [String: Any?] ?? [:], loop)
        } catch {
            if let error = error {
                error.pointee = error as NSError
            }
            return nil
        }
    }
    
    @objc public static func stopRecording(_ loop: Bool,
                                         error: NSErrorPointer) -> String? {
        do {
            return try await whisperKitImpl.stopRecording(loop)
        } catch {
            if let error = error {
                error.pointee = error as NSError
            }
            return nil
        }
    }
}
