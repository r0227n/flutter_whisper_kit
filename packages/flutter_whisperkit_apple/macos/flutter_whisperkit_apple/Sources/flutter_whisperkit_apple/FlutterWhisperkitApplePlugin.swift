import Cocoa
import FlutterMacOS
import WhisperKit
import Foundation

enum ModelStorageLocation: Int64 {
    case packageDirectory = 0
    case userFolder = 1
}

private class WhisperKitApiImpl: WhisperKitMessage {
  private var whisperKit: WhisperKit?
  private var modelStorageLocation: ModelStorageLocation = .packageDirectory
  
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
  
  func loadModel(variant: String?, modelRepo: String?, redownload: Bool?, storageLocation: Int64?, completion: @escaping (Result<String?, Error>) -> Void) {
    guard let variant = variant else {
      completion(.failure(NSError(domain: "WhisperKitError", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Model variant is required"])))
      return
    }
    
    if let storageLocation = storageLocation, let location = ModelStorageLocation(rawValue: storageLocation) {
      modelStorageLocation = location
    }
    
    Task {
      do {
        let modelDirURL = getModelFolderPath()
        
        do {
          if !FileManager.default.fileExists(atPath: modelDirURL.path) {
            try FileManager.default.createDirectory(at: modelDirURL, withIntermediateDirectories: true, attributes: nil)
          }
          
          let testFile = modelDirURL.appendingPathComponent("test_write_permission.txt")
          try "test".write(to: testFile, atomically: true, encoding: .utf8)
          try FileManager.default.removeItem(at: testFile)
        } catch {
          throw NSError(domain: "WhisperKitError", code: 1004, userInfo: [
            NSLocalizedDescriptionKey: "Cannot write to model directory: \(error.localizedDescription)"
          ])
        }
        
        if whisperKit == nil {
          let config = WhisperKitConfig(
              verbose: true,
              logLevel: .debug,
              prewarm: false,
              load: false,
              download: false
          )
          whisperKit = try await WhisperKit(config)
        }
        
        guard let whisperKit = whisperKit else {
          throw NSError(domain: "WhisperKitError", code: 1002, userInfo: [
              NSLocalizedDescriptionKey: "Failed to initialize WhisperKit"
          ])
        }
        
        var modelFolder: URL?
        let localModels = await getLocalModels()
        
        if localModels.contains(variant) && !(redownload ?? false) {
          modelFolder = modelDirURL.appendingPathComponent(variant)
        } else {
          let downloadDestination = modelDirURL.appendingPathComponent(variant)
          
          if !FileManager.default.fileExists(atPath: downloadDestination.path) {
            try FileManager.default.createDirectory(at: downloadDestination, withIntermediateDirectories: true, attributes: nil)
          }
          
          do {
            modelFolder = try await WhisperKit.download(
                variant: variant,
                from: modelRepo ?? "argmaxinc/whisperkit-coreml"
            )
          } catch {
            print("Download error: \(error.localizedDescription)")
            throw NSError(domain: "WhisperKitError", code: 1005, userInfo: [
                NSLocalizedDescriptionKey: "Failed to download model: \(error.localizedDescription)"
            ])
          }
        }
        
        if let folder = modelFolder {
          whisperKit.modelFolder = folder
          
          try await whisperKit.prewarmModels()
          
          try await whisperKit.loadModels()
          
          completion(.success("Model \(variant) loaded successfully"))
        } else {
          throw NSError(domain: "WhisperKitError", code: 1003, userInfo: [
              NSLocalizedDescriptionKey: "Failed to get model folder"
          ])
        }
      } catch {
        print("LoadModel error: \(error.localizedDescription)")
        completion(.failure(error))
      }
    }
  }
  
  private func getModelFolderPath() -> URL {
    switch modelStorageLocation {
    case .packageDirectory:
      if let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
        return appSupport.appendingPathComponent("WhisperKitModels")
      }
      return getDocumentsDirectory().appendingPathComponent("WhisperKitModels")
        
    case .userFolder:
      if let downloads = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first {
        let testFile = downloads.appendingPathComponent("whisperkit_write_test.txt")
        do {
          try "test".write(to: testFile, atomically: true, encoding: .utf8)
          try FileManager.default.removeItem(at: testFile)
          
          return downloads.appendingPathComponent("WhisperKitModels")
        } catch {
          print("Cannot write to Downloads directory: \(error.localizedDescription)")
        }
      }
      
      return getDocumentsDirectory().appendingPathComponent("WhisperKitModels")
    }
  }
    
  private func getDocumentsDirectory() -> URL {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
  }
    
  private func getLocalModels() async -> [String] {
    let modelPath = getModelFolderPath()
    var localModels: [String] = []
      
    do {
      if FileManager.default.fileExists(atPath: modelPath.path) {
        let contents = try FileManager.default.contentsOfDirectory(atPath: modelPath.path)
        localModels = contents
      }
    } catch {
      print("Error checking local models: \(error.localizedDescription)")
    }
      
    return WhisperKit.formatModelFiles(localModels)
  }
}

public class FlutterWhisperkitApplePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    // Pigeonで生成されたSetupコードを呼び出す
    WhisperKitMessageSetup.setUp(binaryMessenger: registrar.messenger, api: WhisperKitApiImpl())
  }
}
