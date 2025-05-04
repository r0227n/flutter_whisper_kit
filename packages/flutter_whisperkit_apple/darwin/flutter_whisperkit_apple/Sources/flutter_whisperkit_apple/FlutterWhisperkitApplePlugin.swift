import Foundation
import WhisperKit

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#else
  #error("Unsupported platform.")
#endif

/// Flutter WhisperKit Apple Plugin
///
/// This plugin provides WhisperKit functionality to Flutter applications on Apple platforms.
/// It handles model loading, audio transcription, and real-time recording capabilities.

private let transcriptionStreamChannelName = "flutter_whisperkit/transcription_stream"
private let modelProgressStreamChannelName = "flutter_whisperkit/model_progress_stream"

#if os(iOS)
private var flutterPluginRegistrar: FlutterPluginRegistrar?
#endif

/// Implementation of the WhisperKit API
///
/// This class handles all the core functionality of the plugin, including:
/// - Loading and managing WhisperKit models
/// - Transcribing audio from files
/// - Real-time audio recording and transcription
/// - Streaming transcription results back to Flutter
private class WhisperKitApiImpl: WhisperKitMessage {
  /// The WhisperKit instance used for transcription
  private var whisperKit: WhisperKit?
  
  /// Flag indicating if recording is currently active
  private var isRecording: Bool = false
  
  /// Task for handling real-time transcription
  private var transcriptionTask: Task<Void, Never>?
  
  /// Stream handler for sending transcription results to Flutter
  public static var transcriptionStreamHandler: TranscriptionStreamHandler?
  
  /// Stream handler for sending model download progress to Flutter
  public static var modelProgressStreamHandler: ModelProgressStreamHandler?

  /// Loads a WhisperKit model
  ///
  /// - Parameters:
  ///   - variant: The model variant to load (required)
  ///   - modelRepo: The repository to download the model from (optional)
  ///   - redownload: Whether to force redownload the model (optional)
  ///   - modelDownloadPath: Custom path for model storage (optional)
  ///   - completion: Callback with result of the operation
  func loadModel(
    variant: String?, modelRepo: String?, redownload: Bool?, modelDownloadPath: String?,
    completion: @escaping (Result<String?, Error>) -> Void
  ) {
    guard let variant = variant else {
      completion(
        .failure(
          NSError(
            domain: "WhisperKitError", code: 1001,
            userInfo: [NSLocalizedDescriptionKey: "Model variant is required"])))
      return
    }

    Task {
      do {
        let modelDirURL = getModelFolderPath(path: modelDownloadPath)

        do {
          if !FileManager.default.fileExists(atPath: modelDirURL.path) {
            try FileManager.default.createDirectory(
              at: modelDirURL, withIntermediateDirectories: true, attributes: nil)
          }

          let testFile = modelDirURL.appendingPathComponent("test_write_permission.txt")
          try "test".write(to: testFile, atomically: true, encoding: .utf8)
          try FileManager.default.removeItem(at: testFile)
        } catch {
          throw NSError(
            domain: "WhisperKitError", code: 4001,
            userInfo: [
              NSLocalizedDescriptionKey:
                "Cannot write to model directory: \(error.localizedDescription)"
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
          throw NSError(
            domain: "WhisperKitError", code: 1002,
            userInfo: [
              NSLocalizedDescriptionKey: "Failed to initialize WhisperKit"
            ])
        }

        var modelFolder: URL?
        let localModels = await getLocalModels(path: modelDownloadPath)

        if localModels.contains(variant) && !(redownload ?? false) {
          modelFolder = modelDirURL.appendingPathComponent(variant)
        } else {
          let downloadDestination = modelDirURL.appendingPathComponent(variant)

          if !FileManager.default.fileExists(atPath: downloadDestination.path) {
            try FileManager.default.createDirectory(
              at: downloadDestination, withIntermediateDirectories: true, attributes: nil)
          }

          do {
            modelFolder = try await WhisperKit.download(
              variant: variant,
              from: modelRepo ?? "argmaxinc/whisperkit-coreml",
              progressCallback: { progress in
                if let streamHandler = WhisperKitApiImpl.modelProgressStreamHandler as? ModelProgressStreamHandler {
                  streamHandler.sendProgress(progress)
                }
              }
            )
            // Save the downloaded model folder to the specified model directory
            if let downloadedFolder = modelFolder {
              // Ensure the model directory exists
              if !FileManager.default.fileExists(atPath: modelDirURL.path) {
                try FileManager.default.createDirectory(
                  at: modelDirURL, withIntermediateDirectories: true, attributes: nil)
              }
              
              // If the model was downloaded to a different location than modelDirURL,
              // copy or move it to the correct location
              if downloadedFolder.path != modelDirURL.appendingPathComponent(variant).path {
                let targetFolder = modelDirURL.appendingPathComponent(variant)
                
                // Remove existing folder if it exists
                if FileManager.default.fileExists(atPath: targetFolder.path) {
                  try FileManager.default.removeItem(at: targetFolder)
                }
                
                // Copy the downloaded folder to the model directory
                try FileManager.default.copyItem(at: downloadedFolder, to: targetFolder)
                
                // Update the model folder reference
                modelFolder = targetFolder
              }
            }
          } catch {
            print("Download error: \(error.localizedDescription)")
            throw NSError(
              domain: "WhisperKitError", code: 1005,
              userInfo: [
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
          throw NSError(
            domain: "WhisperKitError", code: 1003,
            userInfo: [
              NSLocalizedDescriptionKey: "Failed to get model folder"
            ])
        }
      } catch {
        print("LoadModel error: \(error.localizedDescription)")
        completion(.failure(error))
      }
    }
  }

  /// Transcribes audio from a file
  ///
  /// - Parameters:
  ///   - filePath: Path to the audio file to transcribe
  ///   - options: Transcription options
  ///   - completion: Callback with result of the transcription
  func transcribeFromFile(
    filePath: String, options: [String: Any?],
    completion: @escaping (Result<String?, Error>) -> Void
  ) {
    guard let whisperKit = whisperKit else {
      completion(
        .failure(
          NSError(
            domain: "WhisperKitError", code: 2001,
            userInfo: [
              NSLocalizedDescriptionKey:
                "WhisperKit instance not initialized. Call loadModel first."
            ])))
      return
    }

    Task {
      do {
        let resolvedPath: String
        #if os(iOS)
        if filePath.hasPrefix("assets/") {
          guard let path = resolveAssetPath(assetPath: filePath) else {
            throw NSError(
              domain: "WhisperKitError", code: 4002,
              userInfo: [NSLocalizedDescriptionKey: "Could not resolve asset path: \(filePath)"])
          }
          resolvedPath = path
        } else {
          resolvedPath = filePath
        }
        #else
        resolvedPath = filePath
        #endif
        
        // Check if file exists and is readable
        guard FileManager.default.fileExists(atPath: resolvedPath) else {
          throw NSError(
            domain: "WhisperKitError", code: 4002,
            userInfo: [NSLocalizedDescriptionKey: "Audio file does not exist at path: \(resolvedPath)"])
        }

        // Check file permissions
        guard FileManager.default.isReadableFile(atPath: resolvedPath) else {
          throw NSError(
            domain: "WhisperKitError", code: 4003,
            userInfo: [
              NSLocalizedDescriptionKey: "No read permission for audio file at path: \(resolvedPath)"
            ])
        }

        // Load and convert buffer in a limited scope
        Logging.debug("Loading audio file: \(resolvedPath)")
        let loadingStart = Date()
        let audioFileSamples = try await Task {
          try autoreleasepool {
            try AudioProcessor.loadAudioAsFloatArray(fromPath: resolvedPath)
          }
        }.value
        Logging.debug("Loaded audio file in \(Date().timeIntervalSince(loadingStart)) seconds")

        let decodingOptions = try DecodingOptions.fromJson(options)

        let transcription: TranscriptionResult? = try await transcribeAudioSamples(
          audioFileSamples,
          options: decodingOptions,
        )

        guard let transcription = transcription else {
          throw NSError(
            domain: "WhisperKitError", code: 2004,
            userInfo: [NSLocalizedDescriptionKey: "Transcription result is nil"])
        }
        let transcriptionDict = transcription.toJson()

        do {
          let jsonData = try JSONSerialization.data(withJSONObject: transcriptionDict, options: [])
          guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw NSError(
              domain: "WhisperKitError", code: 2003,
              userInfo: [
                NSLocalizedDescriptionKey: "Failed to create JSON string from transcription result"
              ])
          }
          completion(.success(jsonString))
        } catch {
          throw NSError(
            domain: "WhisperKitError", code: 2002,
            userInfo: [
              NSLocalizedDescriptionKey:
                "Failed to serialize transcription result: \(error.localizedDescription)"
            ])
        }

      } catch {
        completion(.failure(error))
      }
    }
  }

  /// Transcribes audio samples
  ///
  /// - Parameters:
  ///   - samples: Array of float audio samples to transcribe
  ///   - options: Decoding options for transcription
  /// - Returns: Transcription result or nil if transcription failed
  func transcribeAudioSamples(_ samples: [Float], options: DecodingOptions?) async throws
    -> TranscriptionResult?
  {
    guard let whisperKit = whisperKit else { return nil }
    var selectedLanguage: String = "japanese"
    let languageCode = Constants.languages[selectedLanguage, default: Constants.defaultLanguageCode]
    // let task: DecodingTask = selectedTask == "transcribe" ? .transcribe : .translate
    let task: DecodingTask = .transcribe
    var lastConfirmedSegmentEndSeconds: Float = 0
    let seekClip: [Float] = [lastConfirmedSegmentEndSeconds]

    let options =
      options
      ?? DecodingOptions(
        verbose: true,
        task: task,
        language: languageCode,
        temperature: Float(0),
        temperatureFallbackCount: Int(5),
        sampleLength: Int(224),
        usePrefillPrompt: true,
        usePrefillCache: true,
        skipSpecialTokens: true,
        withoutTimestamps: false,
        wordTimestamps: true,
        clipTimestamps: seekClip,
        concurrentWorkerCount: Int(4),
        chunkingStrategy: .vad
      )

    // var currentChunks: [Int: (chunkText: [String], fallbacks: Int)] = [:]

    //  TODO: consider the presence or absence of decodingCallback
    // Early stopping checks
    // let decodingCallback: ((TranscriptionProgress) -> Bool?) = {
    //   (progress: TranscriptionProgress) in
    //   DispatchQueue.main.async {
    //     let fallbacks = Int(progress.timings.totalDecodingFallbacks)
    //     // let chunkId = isStreamMode ? 0 : progress.windowId
    //     let chunkId = progress.windowId

    //     // First check if this is a new window for the same chunk, append if so
    //     var updatedChunk = (chunkText: [progress.text], fallbacks: fallbacks)

    //     if var currentChunk = currentChunks[chunkId],
    //       let previousChunkText = currentChunk.chunkText.last
    //     {
    //       if progress.text.count >= previousChunkText.count {
    //         // This is the same window of an existing chunk, so we just update the last value
    //         currentChunk.chunkText[currentChunk.chunkText.endIndex - 1] = progress.text
    //         updatedChunk = currentChunk
    //       } else {
    //         // This is either a new window or a fallback (only in streaming mode)
    //         if fallbacks == currentChunk.fallbacks && false {
    //           // New window (since fallbacks havent changed)
    //           updatedChunk.chunkText = [updatedChunk.chunkText.first ?? "" + progress.text]
    //         } else {
    //           // Fallback, overwrite the previous bad text
    //           updatedChunk.chunkText[currentChunk.chunkText.endIndex - 1] = progress.text
    //           updatedChunk.fallbacks = fallbacks
    //           print("Fallback occured: \(fallbacks)")
    //         }
    //       }
    //     }

    //     // Set the new text for the chunk
    //     currentChunks[chunkId] = updatedChunk
    //     let joinedChunks = currentChunks.sorted { $0.key < $1.key }.flatMap { $0.value.chunkText }
    //       .joined(separator: "\n")

    //     // self.currentText = joinedChunks
    //     // currentFallbacks = fallbacks
    //     // currentDecodingLoops += 1
    //   }

    //   // Check early stopping
    //   let currentTokens = progress.tokens
    //   let checkWindow = Int(0)
    //   if currentTokens.count > checkWindow {
    //     let checkTokens: [Int] = currentTokens.suffix(checkWindow)
    //     let compressionRatio = compressionRatio(of: checkTokens)
    //     if compressionRatio > options.compressionRatioThreshold! {
    //       Logging.debug("Early stopping due to compression threshold")
    //       return false
    //     }
    //   }
    //   if progress.avgLogprob! < options.logProbThreshold! {
    //     Logging.debug("Early stopping due to logprob threshold")
    //     return false
    //   }
    //   return nil
    // }

    let transcriptionResults: [TranscriptionResult] = try await whisperKit.transcribe(
      audioArray: samples,
      decodeOptions: options,
      // callback: decodingCallback
    )

    let mergedResults = mergeTranscriptionResults(transcriptionResults)

    return mergedResults
  }

  /// Gets the path to the WhisperKit models directory
  ///
  /// - Parameter path: Optional custom path for model storage
  /// - Returns: URL to the WhisperKit models directory
  private func getModelFolderPath(path: String?) -> URL {
    if path == nil {
      if let appSupport = FileManager.default.urls(
        for: .applicationSupportDirectory, in: .userDomainMask
      ).first {
        return appSupport.appendingPathComponent("WhisperKitModels")
      }
      return getDocumentsDirectory().appendingPathComponent("WhisperKitModels")
    } else {
      let userPath = URL(fileURLWithPath: path!)
      let testFile = userPath.appendingPathComponent("whisperkit_write_test.txt")
      do {
        try "test".write(to: testFile, atomically: true, encoding: .utf8)
        try FileManager.default.removeItem(at: testFile)
        return userPath.appendingPathComponent("WhisperKitModels")
      } catch {
        print("Cannot write to custom directory: \(error.localizedDescription)")
      }
      
      return getDocumentsDirectory().appendingPathComponent("WhisperKitModels")
    }
  }

  /// Gets the Documents directory
  ///
  /// - Returns: URL to the Documents directory
  private func getDocumentsDirectory() -> URL {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
  }

  /// Gets the list of locally available models
  ///
  /// - Parameter path: Optional custom path for model storage
  /// - Returns: Array of model names that are available locally
  private func getLocalModels(path: String?) async -> [String] {
    let modelPath = getModelFolderPath(path: path)
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
  
  /// Starts recording audio for transcription
  ///
  /// - Parameters:
  ///   - options: Recording and transcription options
  ///   - loop: Whether to continuously transcribe in real-time
  ///   - completion: Callback with result of the operation
  func startRecording(
    options: [String: Any?], loop: Bool,
    completion: @escaping (Result<String?, Error>) -> Void
  ) {
    guard let whisperKit = whisperKit else {
      completion(
        .failure(
          NSError(
            domain: "WhisperKitError", code: 3001,
            userInfo: [
              NSLocalizedDescriptionKey:
                "WhisperKit instance not initialized. Call loadModel first."
            ])))
      return
    }
    
    if whisperKit.audioProcessor == nil {
      whisperKit.audioProcessor = AudioProcessor()
    }
    
    Task(priority: .userInitiated) {
      do {
        guard await AudioProcessor.requestRecordPermission() else {
          throw NSError(
            domain: "WhisperKitError", code: 3002,
            userInfo: [NSLocalizedDescriptionKey: "Microphone access was not granted."])
        }
        
        var deviceId: DeviceID?
        
        try whisperKit.audioProcessor.startRecordingLive(inputDeviceID: deviceId) { _ in
        }
        
        isRecording = true
        
        if loop {
          self.startRealtimeLoop(options: options)
        }
        
        completion(.success("Recording started successfully"))
      } catch {
        completion(.failure(error))
      }
    }
  }
  
  /// Stops recording audio
  ///
  /// - Parameters:
  ///   - loop: Whether real-time transcription was active
  ///   - completion: Callback with result of the operation
  func stopRecording(
    loop: Bool, completion: @escaping (Result<String?, Error>) -> Void
  ) {
    guard let whisperKit = whisperKit else {
      completion(
        .failure(
          NSError(
            domain: "WhisperKitError", code: 3001,
            userInfo: [
              NSLocalizedDescriptionKey:
                "WhisperKit instance not initialized. Call loadModel first."
            ])))
      return
    }
    
    isRecording = false
    stopRealtimeTranscription()
    whisperKit.audioProcessor.stopRecording()
    
    if !loop {
      Task {
        do {
          _ = try await transcribeCurrentBufferInternal(options: [:])
          completion(.success("Recording stopped and transcription completed"))
        } catch {
          completion(.failure(error))
        }
      }
    } else {
      completion(.success("Recording stopped"))
    }
  }
  
  /// Starts a loop for real-time transcription
  ///
  /// - Parameter options: Transcription options
  private func startRealtimeLoop(options: [String: Any?]) {
    transcriptionTask = Task {
      var lastTranscribedText = ""
      
      while isRecording && !Task.isCancelled {
        do {
          if let result = try await transcribeCurrentBufferInternal(options: options) {
            if result.text != lastTranscribedText {
              lastTranscribedText = result.text
              
              if let streamHandler = WhisperKitApiImpl.transcriptionStreamHandler as? TranscriptionStreamHandler {
                streamHandler.sendTranscription(result)
              }
            }
          }
          
          try await Task.sleep(nanoseconds: 300_000_000) // 300ms delay between transcriptions
        } catch {
          print("Realtime transcription error: \(error.localizedDescription)")
          try? await Task.sleep(nanoseconds: 1_000_000_000) // 1s delay on error
        }
      }
      
      if let streamHandler = WhisperKitApiImpl.transcriptionStreamHandler as? TranscriptionStreamHandler {
        streamHandler.sendTranscription(nil)
      }
    }
  }
  
  /// Stops the real-time transcription loop
  private func stopRealtimeTranscription() {
    transcriptionTask?.cancel()
    transcriptionTask = nil
  }
  
  /// Transcribes the current audio buffer
  ///
  /// - Parameter options: Transcription options
  /// - Returns: Transcription result or nil if transcription failed
  private func transcribeCurrentBufferInternal(options: [String: Any?]) async throws -> TranscriptionResult? {
    guard let whisperKit = whisperKit else { return nil }
    
    let currentBuffer = whisperKit.audioProcessor.audioSamples
    
    let bufferSeconds = Float(currentBuffer.count) / Float(WhisperKit.sampleRate)
    guard bufferSeconds > 1.0 else {
      throw NSError(
        domain: "WhisperKitError", code: 3003,
        userInfo: [NSLocalizedDescriptionKey: "Not enough audio data for transcription"])
    }
    
    let decodingOptions = try DecodingOptions.fromJson(options)
    
    let transcriptionResults: [TranscriptionResult] = try await whisperKit.transcribe(
      audioArray: Array(currentBuffer),
      decodeOptions: decodingOptions
    )
    
    return mergeTranscriptionResults(transcriptionResults)
  }
  
  /// Merges multiple transcription results into a single result
  ///
  /// - Parameter results: Array of transcription results to merge
  /// - Returns: Merged transcription result or nil if input is empty
  private func mergeTranscriptionResults(_ results: [TranscriptionResult]) -> TranscriptionResult? {
    guard !results.isEmpty else { return nil }
    
    if results.count == 1 {
      return results[0]
    }
    
    var mergedText = ""
    var mergedSegments: [TranscriptionSegment] = []
    
    for result in results {
      mergedText += result.text
      mergedSegments.append(contentsOf: result.segments)
    }
    
    return TranscriptionResult(
      text: mergedText,
      segments: mergedSegments,
      language: results[0].language,
      timings: results[0].timings,
      seekTime: results[0].seekTime
    )
  }
}

/// Handler for streaming transcription results to Flutter
private class TranscriptionStreamHandler: NSObject, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?
  
  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    eventSink = events
    return nil
  }
  
  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    return nil
  }
  
  /// Sends a transcription result to the Flutter event sink
  ///
  /// - Parameter result: The transcription result to send
  func sendTranscription(_ result: TranscriptionResult?) {
    if let eventSink = eventSink {
      DispatchQueue.main.async {
        if let result = result {
          let resultDict = result.toJson()
          do {
            let jsonData = try JSONSerialization.data(withJSONObject: resultDict, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
              eventSink(jsonString)
            } else {
              print("Error: Failed to convert JSON data to string.")
              eventSink(FlutterError(code: "JSON_CONVERSION_ERROR", message: "Failed to convert JSON data to string.", details: nil))
            }
          } catch {
            print("Error: JSON serialization failed with error: \(error.localizedDescription)")
            eventSink(FlutterError(code: "JSON_SERIALIZATION_ERROR", message: "JSON serialization failed.", details: error.localizedDescription))
          }
        } else {
          eventSink("")
        }
      }
    }
  }
}

/// Handler for streaming model download progress to Flutter
private class ModelProgressStreamHandler: NSObject, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    eventSink = events
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    return nil
  }
  
  /// Sends download progress to the Flutter event sink
  ///
  /// - Parameter progress: The progress object to send
  func sendProgress(_ progress: Progress) {
    if let eventSink = eventSink {
      DispatchQueue.main.async {
        let progressDict: [String: Any] = [
          "totalUnitCount": progress.totalUnitCount,
          "completedUnitCount": progress.completedUnitCount,
          "fractionCompleted": progress.fractionCompleted,
          "isIndeterminate": progress.isIndeterminate,
          "isPaused": progress.isPaused,
          "isCancelled": progress.isCancelled
        ]
        eventSink(progressDict)
      }
    }
  }
}

/// Main plugin class that registers with Flutter
public class FlutterWhisperkitApplePlugin: NSObject, FlutterPlugin {
  /// Registers the plugin with the Flutter engine
  ///
  /// - Parameter registrar: The plugin registrar for the Flutter app
  public static func register(with registrar: FlutterPluginRegistrar) {
    #if os(iOS)
      let messenger = registrar.messenger()
      flutterPluginRegistrar = registrar
    #elseif os(macOS)
      let messenger = registrar.messenger
    #else
      #error("Unsupported platform.")
    #endif

    let streamHandler = TranscriptionStreamHandler()
    WhisperKitApiImpl.transcriptionStreamHandler = streamHandler
    
    let modelProgressHandler = ModelProgressStreamHandler()
    WhisperKitApiImpl.modelProgressStreamHandler = modelProgressHandler
    
    WhisperKitMessageSetup.setUp(binaryMessenger: messenger, api: WhisperKitApiImpl())
    
    let transcriptionChannel = FlutterEventChannel(name: transcriptionStreamChannelName, binaryMessenger: messenger)
    transcriptionChannel.setStreamHandler(streamHandler)
    
    let modelProgressChannel = FlutterEventChannel(name: modelProgressStreamChannelName, binaryMessenger: messenger)
    modelProgressChannel.setStreamHandler(modelProgressHandler)
  }
}

/// Resolves a Flutter asset path to a file system path
///
/// - Parameter assetPath: The asset path to resolve
/// - Returns: The resolved file system path or nil if not found
#if os(iOS)
private func resolveAssetPath(assetPath: String) -> String? {
  guard let registrar = flutterPluginRegistrar else {
    print("Error: Flutter plugin registrar not available")
    return nil
  }
  
  
  let key1 = registrar.lookupKey(forAsset: assetPath)
  print("Debug: Full path key: \(key1)")
  if let path1 = Bundle.main.path(forResource: key1, ofType: nil) {
    print("Debug: Found asset using full path: \(path1)")
    return path1
  }
  
  let assetName = assetPath.hasPrefix("assets/") ? String(assetPath.dropFirst(7)) : assetPath
  let key2 = registrar.lookupKey(forAsset: assetName)
  print("Debug: Asset name key: \(key2)")
  if let path2 = Bundle.main.path(forResource: key2, ofType: nil) {
    print("Debug: Found asset using asset name: \(path2)")
    return path2
  }
  
  if let path3 = Bundle.main.path(forResource: assetName.split(separator: ".").first?.description, ofType: assetName.split(separator: ".").last?.description) {
    print("Debug: Found asset directly in bundle: \(path3)")
    return path3
  }
  
  let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
  let filePath = "\(documentsPath)/\(assetName)"
  if FileManager.default.fileExists(atPath: filePath) {
    print("Debug: Found asset in Documents directory: \(filePath)")
    return filePath
  }
  
  if let resourcePath = Bundle.main.resourcePath {
    let possiblePaths = [
      "\(resourcePath)/\(assetName)",
      "\(resourcePath)/flutter_assets/\(assetName)",
      "\(resourcePath)/Frameworks/App.framework/flutter_assets/\(assetName)"
    ]
    
    for path in possiblePaths {
      if FileManager.default.fileExists(atPath: path) {
        print("Debug: Found asset at path: \(path)")
        return path
      }
    }
  }
  
  print("Error: Could not find asset at path: \(assetPath)")
  print("Debug: Available resources in main bundle: \(Bundle.main.paths(forResourcesOfType: nil, inDirectory: nil))")
  return nil
}
#endif
