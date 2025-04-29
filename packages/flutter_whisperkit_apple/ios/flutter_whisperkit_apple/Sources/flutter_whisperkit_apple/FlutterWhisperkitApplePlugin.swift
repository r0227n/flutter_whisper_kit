import Flutter
import Foundation
import UIKit
import WhisperKit

enum ModelStorageLocation: Int64 {
  case packageDirectory = 0
  case userFolder = 1
}

private let transcriptionStreamChannelName = "flutter_whisperkit_apple/transcription_stream"

private class TranscriptionStreamHandler: NSObject, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?
  
  func sendTranscription(_ result: TranscriptionResult?) {
    if let eventSink = eventSink {
      DispatchQueue.main.async {
        if let result = result {
          let resultDict = result.toJson()
          if let jsonData = try? JSONSerialization.data(withJSONObject: resultDict, options: []),
             let jsonString = String(data: jsonData, encoding: .utf8) {
            eventSink(jsonString)
          }
        } else {
          eventSink("")
        }
      }
    }
  }
}

private class WhisperKitApiImpl: WhisperKitMessage {
  private var whisperKit: WhisperKit?
  private var modelStorageLocation: ModelStorageLocation = .packageDirectory
  private var isRecording: Bool = false
  private var transcriptionTask: Task<Void, Never>?
  public static var transcriptionStreamHandler: TranscriptionStreamHandler?

  func loadModel(
    variant: String?, modelRepo: String?, redownload: Bool?, storageLocation: Int64?,
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

    if let storageLocation = storageLocation,
      let location = ModelStorageLocation(rawValue: storageLocation)
    {
      modelStorageLocation = location
    }

    Task {
      do {
        let modelDirURL = getModelFolderPath()

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
        let localModels = await getLocalModels()

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
              from: modelRepo ?? "argmaxinc/whisperkit-coreml"
            )
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

  func transcribeFromFile(filePath: String?, options: [AnyHashable?: Any]?, completion: @escaping (Result<String?, Error>) -> Void)
  {
    guard let filePath = filePath else {
      completion(
        .failure(
          NSError(
            domain: "WhisperKitError", code: 5001,
            userInfo: [NSLocalizedDescriptionKey: "File path is required"])))
      return
    }
    
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
        print("Loading audio file: \(filePath)")
        let loadingStart = Date()
        let audioFileSamples = try await Task {
          try autoreleasepool {
            try AudioProcessor.loadAudioAsFloatArray(fromPath: filePath)
          }
        }.value
        print("Loaded audio file in \(Date().timeIntervalSince(loadingStart)) seconds")

        var decodingOptions = DecodingOptions()

        if let options = options {
          if let decodingOptionsDict = options["decodingOptions"] as? [String: Any] {
            if let task = decodingOptionsDict["task"] as? String {
              if task == "translate" {
                decodingOptions.task = .translate
              } else {
                decodingOptions.task = .transcribe
              }
            }
            
            if let language = decodingOptionsDict["language"] as? String {
              decodingOptions.language = language
            }
            
            if let temperature = decodingOptionsDict["temperature"] as? Double {
              decodingOptions.temperature = temperature
            }
            
            if let sampleLen = decodingOptionsDict["sampleLen"] as? Int {
              decodingOptions.sampleLen = sampleLen
            }
            
            if let bestOf = decodingOptionsDict["bestOf"] as? Int {
              decodingOptions.bestOf = bestOf
            }
            
            if let beamSize = decodingOptionsDict["beamSize"] as? Int {
              decodingOptions.beamSize = beamSize
            }
            
            if let patience = decodingOptionsDict["patience"] as? Double {
              decodingOptions.patience = patience
            }
            
            if let lengthPenalty = decodingOptionsDict["lengthPenalty"] as? Double {
              decodingOptions.lengthPenalty = lengthPenalty
            }
            
            if let suppressBlank = decodingOptionsDict["suppressBlank"] as? Bool {
              decodingOptions.suppressBlank = suppressBlank
            }
            
            if let suppressTokens = decodingOptionsDict["suppressTokens"] as? Bool {
              decodingOptions.suppressTokens = suppressTokens
            }
            
            if let withoutTimestamps = decodingOptionsDict["withoutTimestamps"] as? Bool {
              decodingOptions.withoutTimestamps = withoutTimestamps
            }
            
            if let maxInitialTimestamp = decodingOptionsDict["maxInitialTimestamp"] as? Double {
              decodingOptions.maxInitialTimestamp = maxInitialTimestamp
            }
            
            if let wordTimestamps = decodingOptionsDict["wordTimestamps"] as? Bool {
              decodingOptions.wordTimestamps = wordTimestamps
            }
            
            if let prependPunctuations = decodingOptionsDict["prependPunctuations"] as? String {
              decodingOptions.prependPunctuations = prependPunctuations
            }
            
            if let appendPunctuations = decodingOptionsDict["appendPunctuations"] as? String {
              decodingOptions.appendPunctuations = appendPunctuations
            }
            
            if let logProbThreshold = decodingOptionsDict["logProbThreshold"] as? Double {
              decodingOptions.logProbThreshold = logProbThreshold
            }
            
            if let noSpeechThreshold = decodingOptionsDict["noSpeechThreshold"] as? Double {
              decodingOptions.noSpeechThreshold = noSpeechThreshold
            }
            
            if let compressionRatioThreshold = decodingOptionsDict["compressionRatioThreshold"] as? Double {
              decodingOptions.compressionRatioThreshold = compressionRatioThreshold
            }
            
            if let conditionOnPreviousText = decodingOptionsDict["conditionOnPreviousText"] as? String {
              decodingOptions.conditionOnPreviousText = conditionOnPreviousText
            }
            
            if let prompt = decodingOptionsDict["prompt"] as? String {
              decodingOptions.prompt = prompt
            }
          } else {
            for (key, value) in options {
              if let key = key as? String {
                switch key {
                case "task":
                  if let task = value as? String, task == "translate" {
                    decodingOptions.task = .translate
                  } else {
                    decodingOptions.task = .transcribe
                  }
                case "language":
                  if let language = value as? String {
                    decodingOptions.language = language
                  }
                case "temperature":
                  if let temperature = value as? Double {
                    decodingOptions.temperature = temperature
                  }
                case "sampleLen":
                  if let sampleLen = value as? Int {
                    decodingOptions.sampleLen = sampleLen
                  }
                case "bestOf":
                  if let bestOf = value as? Int {
                    decodingOptions.bestOf = bestOf
                  }
                case "beamSize":
                  if let beamSize = value as? Int {
                    decodingOptions.beamSize = beamSize
                  }
                case "patience":
                  if let patience = value as? Double {
                    decodingOptions.patience = patience
                  }
                case "lengthPenalty":
                  if let lengthPenalty = value as? Double {
                    decodingOptions.lengthPenalty = lengthPenalty
                  }
                case "suppressBlank":
                  if let suppressBlank = value as? Bool {
                    decodingOptions.suppressBlank = suppressBlank
                  }
                case "suppressTokens":
                  if let suppressTokens = value as? Bool {
                    decodingOptions.suppressTokens = suppressTokens
                  }
                case "withoutTimestamps":
                  if let withoutTimestamps = value as? Bool {
                    decodingOptions.withoutTimestamps = withoutTimestamps
                  }
                case "maxInitialTimestamp":
                  if let maxInitialTimestamp = value as? Double {
                    decodingOptions.maxInitialTimestamp = maxInitialTimestamp
                  }
                case "wordTimestamps":
                  if let wordTimestamps = value as? Bool {
                    decodingOptions.wordTimestamps = wordTimestamps
                  }
                case "prependPunctuations":
                  if let prependPunctuations = value as? String {
                    decodingOptions.prependPunctuations = prependPunctuations
                  }
                case "appendPunctuations":
                  if let appendPunctuations = value as? String {
                    decodingOptions.appendPunctuations = appendPunctuations
                  }
                case "logProbThreshold":
                  if let logProbThreshold = value as? Double {
                    decodingOptions.logProbThreshold = logProbThreshold
                  }
                case "noSpeechThreshold":
                  if let noSpeechThreshold = value as? Double {
                    decodingOptions.noSpeechThreshold = noSpeechThreshold
                  }
                case "compressionRatioThreshold":
                  if let compressionRatioThreshold = value as? Double {
                    decodingOptions.compressionRatioThreshold = compressionRatioThreshold
                  }
                case "conditionOnPreviousText":
                  if let conditionOnPreviousText = value as? String {
                    decodingOptions.conditionOnPreviousText = conditionOnPreviousText
                  }
                case "prompt":
                  if let prompt = value as? String {
                    decodingOptions.prompt = prompt
                  }
                default:
                  break
                }
              }
            }
          }
        }

        let transcription = try await whisperKit.transcribe(
          audioArray: audioFileSamples, decodeOptions: decodingOptions)

        var transcriptionDict: [String: Any] = [:]

        if let text = transcription?.text {
          transcriptionDict["text"] = text
        }

        if let language = transcription?.language {
          transcriptionDict["language"] = language
        }

        if let segments = transcription?.segments {
          var segmentsArray: [[String: Any]] = []

          for segment in segments {
            var segmentDict: [String: Any] = [
              "id": segment.id,
              "seek": segment.seek,
              "text": segment.text,
              "start": segment.start,
              "end": segment.end,
              "temperature": segment.temperature,
              "avgLogprob": segment.avgLogprob,
              "compressionRatio": segment.compressionRatio,
              "noSpeechProb": segment.noSpeechProb,
            ]

            if let tokens = segment.tokens {
              segmentDict["tokens"] = tokens
            }

            if let tokenLogProbs = segment.tokenLogProbs {
              var logProbsArray: [Any] = []
              for logProbs in tokenLogProbs {
                var logProbsDict: [String: Double] = [:]
                for (token, prob) in logProbs {
                  logProbsDict[String(token)] = prob
                }
                logProbsArray.append(logProbsDict)
              }
              segmentDict["tokenLogProbs"] = logProbsArray
            }

            if let words = segment.words {
              var wordsArray: [[String: Any]] = []
              for word in words {
                let wordDict: [String: Any] = [
                  "word": word.word,
                  "tokens": word.tokens,
                  "start": word.start,
                  "end": word.end,
                  "probability": word.probability,
                ]
                wordsArray.append(wordDict)
              }
              segmentDict["words"] = wordsArray
            }

            segmentsArray.append(segmentDict)
          }

          transcriptionDict["segments"] = segmentsArray
        }

        if let timings = transcription?.timings {
          transcriptionDict["timings"] = [
            "pipelineStart": timings.pipelineStart,
            "firstTokenTime": timings.firstTokenTime,
            "inputAudioSeconds": timings.inputAudioSeconds,
            "modelLoading": timings.modelLoading,
            "prewarmLoadTime": timings.prewarmLoadTime,
            "encoderLoadTime": timings.encoderLoadTime,
            "decoderLoadTime": timings.decoderLoadTime,
            "encoderSpecializationTime": timings.encoderSpecializationTime,
            "decoderSpecializationTime": timings.decoderSpecializationTime,
            "tokenizerLoadTime": timings.tokenizerLoadTime,
            "audioLoading": timings.audioLoading,
            "audioProcessing": timings.audioProcessing,
            "logmels": timings.logmels,
            "encoding": timings.encoding,
            "prefill": timings.prefill,
            "decodingInit": timings.decodingInit,
            "decodingLoop": timings.decodingLoop,
            "decodingPredictions": timings.decodingPredictions,
            "decodingFiltering": timings.decodingFiltering,
            "decodingSampling": timings.decodingSampling,
            "decodingFallback": timings.decodingFallback,
            "decodingWindowing": timings.decodingWindowing,
            "decodingKvCaching": timings.decodingKvCaching,
            "decodingWordTimestamps": timings.decodingWordTimestamps,
            "decodingNonPrediction": timings.decodingNonPrediction,
            "totalAudioProcessingRuns": timings.totalAudioProcessingRuns,
            "totalLogmelRuns": timings.totalLogmelRuns,
            "totalEncodingRuns": timings.totalEncodingRuns,
            "totalDecodingLoops": timings.totalDecodingLoops,
            "totalKVUpdateRuns": timings.totalKVUpdateRuns,
            "totalTimestampAlignmentRuns": timings.totalTimestampAlignmentRuns,
            "totalDecodingFallbacks": timings.totalDecodingFallbacks,
            "totalDecodingWindows": timings.totalDecodingWindows,
            "fullPipeline": timings.fullPipeline,
          ]
        }

        if let seekTime = transcription?.seekTime {
          transcriptionDict["seekTime"] = seekTime
        }

        do {
          let jsonData = try JSONSerialization.data(withJSONObject: transcriptionDict, options: [])
          if let jsonString = String(data: jsonData, encoding: .utf8) {
            completion(.success(jsonString))
          } else {
            throw NSError(
              domain: "WhisperKitError", code: 2003,
              userInfo: [
                NSLocalizedDescriptionKey: "Failed to create JSON string from transcription result"
              ])
          }
        } catch {
          throw NSError(
            domain: "WhisperKitError", code: 2002,
            userInfo: [
              NSLocalizedDescriptionKey:
                "Failed to serialize transcription result: \(error.localizedDescription)"
            ])
        }
      } catch {
        print("transcribeFromFile error: \(error.localizedDescription)")
        completion(.failure(error))
      }
    }
  }

  private func getModelFolderPath() -> URL {
    switch modelStorageLocation {
    case .packageDirectory:
      if let appSupport = FileManager.default.urls(
        for: .applicationSupportDirectory, in: .userDomainMask
      ).first {
        return appSupport.appendingPathComponent("WhisperKitModels")
      }
      return getDocumentsDirectory().appendingPathComponent("WhisperKitModels")

    case .userFolder:
      let documents = getDocumentsDirectory()
      return documents.appendingPathComponent("WhisperKitModels")
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
  
  private func stopRealtimeTranscription() {
    transcriptionTask?.cancel()
    transcriptionTask = nil
  }
  
  private func transcribeCurrentBufferInternal(options: [String: Any?]) async throws -> TranscriptionResult? {
    guard let whisperKit = whisperKit else { return nil }
    
    let currentBuffer = whisperKit.audioProcessor.audioSamples
    
    let bufferSeconds = Float(currentBuffer.count) / Float(WhisperKit.sampleRate)
    guard bufferSeconds > 1.0 else {
      throw NSError(
        domain: "WhisperKitError", code: 3003,
        userInfo: [NSLocalizedDescriptionKey: "Not enough audio data for transcription"])
    }
    
    var decodingOptions = DecodingOptions()
    
    if let options = options as? [String: Any] {
      if let task = options["task"] as? String, task == "translate" {
        decodingOptions.task = .translate
      }
      
      if let language = options["language"] as? String {
        decodingOptions.language = language
      }
      
      if let temperature = options["temperature"] as? Double {
        decodingOptions.temperature = temperature
      }
      
      if let wordTimestamps = options["wordTimestamps"] as? Bool {
        decodingOptions.wordTimestamps = wordTimestamps
      }
    }
    
    let transcriptionResults = try await whisperKit.transcribe(
      audioArray: Array(currentBuffer),
      decodeOptions: decodingOptions
    )
    
    return mergeTranscriptionResults(transcriptionResults)
  }
  
  private func mergeTranscriptionResults(_ results: [TranscriptionResult]) -> TranscriptionResult? {
    guard !results.isEmpty else { return nil }
    
    if results.count == 1 {
      return results[0]
    }
    
    var mergedText = ""
    var mergedSegments: [TranscriptionSegment] = []
    
    for result in results {
      if !mergedText.isEmpty {
        mergedText += " "
      }
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

public class FlutterWhisperkitApplePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    WhisperKitMessageSetup.setUp(binaryMessenger: registrar.messenger(), api: WhisperKitApiImpl())
    
    let streamHandler = TranscriptionStreamHandler()
    WhisperKitApiImpl.transcriptionStreamHandler = streamHandler
    let channel = FlutterEventChannel(name: transcriptionStreamChannelName, binaryMessenger: registrar.messenger())
    channel.setStreamHandler(streamHandler)
    
    let methodChannel = FlutterMethodChannel(name: "flutter_whisperkit_apple/register", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(FlutterWhisperkitApplePlugin(), channel: methodChannel)
  }
  
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "registerWith":
      result(true)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
