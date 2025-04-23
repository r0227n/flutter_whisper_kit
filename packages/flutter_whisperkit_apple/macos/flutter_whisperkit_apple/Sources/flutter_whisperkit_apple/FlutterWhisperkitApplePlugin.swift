import Cocoa
import FlutterMacOS
import Foundation
import WhisperKit

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

  func createWhisperKit(
    model: String?, modelRepo: String?, completion: @escaping (Result<String?, Error>) -> Void
  ) {
    Task {
      do {
        whisperKit = try await WhisperKit()

        completion(
          .success(
            "WhisperKit instance created successfully: \(model ?? "default") \(modelRepo ?? "default")"
          ))
      } catch {
        completion(.failure(error))
      }
    }
  }

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
            domain: "WhisperKitError", code: 1004,
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

  func transcribeFromFile(
    filePath: String, options: [String: Any?]?,
    completion: @escaping (Result<String?, Error>) -> Void
  ) {

    guard let whisperKit = whisperKit else {
      completion(
        .failure(
          NSError(
            domain: "WhisperKitError", code: 2002,
            userInfo: [
              NSLocalizedDescriptionKey:
                "WhisperKit instance not initialized. Call loadModel first."
            ])))
      return
    }

    Task {
      do {
        // Check if file exists and is readable
        guard FileManager.default.fileExists(atPath: filePath) else {
          throw NSError(
            domain: "WhisperKitError", code: 2005,
            userInfo: [NSLocalizedDescriptionKey: "Audio file does not exist at path: \(filePath)"])
        }

        // Check file permissions
        guard FileManager.default.isReadableFile(atPath: filePath) else {
          throw NSError(
            domain: "WhisperKitError", code: 2006,
            userInfo: [
              NSLocalizedDescriptionKey: "No read permission for audio file at path: \(filePath)"
            ])
        }

        // Load and convert buffer in a limited scope
        Logging.debug("Loading audio file: \(filePath)")
        let loadingStart = Date()
        let audioFileSamples = try await Task {
          try autoreleasepool {
            try AudioProcessor.loadAudioAsFloatArray(fromPath: filePath)
          }
        }.value
        Logging.debug("Loaded audio file in \(Date().timeIntervalSince(loadingStart)) seconds")

        var decodingOptions = DecodingOptions()

        if let options = options {
          // Check if options contains a DecodingOptions property
          if let decodingOptionsDict = options["decodingOptions"] as? [String: Any] {
            // Convert the dictionary to DecodingOptions
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
              decodingOptions.temperature = Float(temperature)
            }

            if let sampleLen = decodingOptionsDict["sampleLen"] as? Int {
              decodingOptions.sampleLength = Int(sampleLen)
            }

            if let bestOf = decodingOptionsDict["bestOf"] as? Int {
              decodingOptions.temperatureFallbackCount = Int(bestOf)
            }

            if let withoutTimestamps = decodingOptionsDict["withoutTimestamps"] as? Bool {
              decodingOptions.withoutTimestamps = withoutTimestamps
            }

            if let wordTimestamps = decodingOptionsDict["wordTimestamps"] as? Bool {
              decodingOptions.wordTimestamps = wordTimestamps
            }

            if let logProbThreshold = decodingOptionsDict["logProbThreshold"] as? Double {
              decodingOptions.logProbThreshold = Float(logProbThreshold)
            }

            if let noSpeechThreshold = decodingOptionsDict["noSpeechThreshold"] as? Double {
              decodingOptions.noSpeechThreshold = Float(noSpeechThreshold)
            }

            if let compressionRatioThreshold = decodingOptionsDict["compressionRatioThreshold"]
              as? Double
            {
              decodingOptions.compressionRatioThreshold = Float(compressionRatioThreshold)
            }

            if let promptTokens = decodingOptionsDict["promptTokens"] as? [Int64] {
              decodingOptions.promptTokens = promptTokens.map { Int($0) }
            }

            if let prefixTokens = decodingOptionsDict["prefixTokens"] as? [Int64] {
              decodingOptions.prefixTokens = prefixTokens.map { Int($0) }
            }

            if let chunkingStrategy = decodingOptionsDict["chunkingStrategy"] as? String {
              if chunkingStrategy == "none" {
                decodingOptions.chunkingStrategy = .none
              } else if chunkingStrategy == "vad" {
                decodingOptions.chunkingStrategy = .vad
              }
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
                    decodingOptions.temperature = Float(temperature)
                  }
                case "sampleLen":
                  if let sampleLen = value as? Int {
                    decodingOptions.sampleLength = Int(sampleLen)
                  }
                case "bestOf":
                  if let bestOf = value as? Int {
                    decodingOptions.temperatureFallbackCount = Int(bestOf)
                  }

                case "withoutTimestamps":
                  if let withoutTimestamps = value as? Bool {
                    decodingOptions.withoutTimestamps = withoutTimestamps
                  }
                case "wordTimestamps":
                  if let wordTimestamps = value as? Bool {
                    decodingOptions.wordTimestamps = wordTimestamps
                  }
                case "logProbThreshold":
                  if let logProbThreshold = value as? Double {
                    decodingOptions.logProbThreshold = Float(logProbThreshold)
                  }
                case "noSpeechThreshold":
                  if let noSpeechThreshold = value as? Double {
                    decodingOptions.noSpeechThreshold = Float(noSpeechThreshold)
                  }
                case "compressionRatioThreshold":
                  if let compressionRatioThreshold = value as? Double {
                    decodingOptions.compressionRatioThreshold = Float(compressionRatioThreshold)
                  }
                case "promptTokens":
                  if let promptTokens = value as? [Int64] {
                    decodingOptions.promptTokens = promptTokens.map { Int($0) }
                  }
                case "prefixTokens":
                  if let prefixTokens = value as? [Int64] {
                    decodingOptions.prefixTokens = prefixTokens.map { Int($0) }
                  }
                case "chunkingStrategy":
                  if let chunkingStrategy = value as? String {
                    if chunkingStrategy == "none" {
                      decodingOptions.chunkingStrategy = .none
                    } else if chunkingStrategy == "vad" {
                      decodingOptions.chunkingStrategy = .vad
                    }
                  }
                default:
                  break
                }
              }
            }
          }
        }

        let transcription: TranscriptionResult? = try await transcribeAudioSamples(
          audioFileSamples,
          options: decodingOptions,
        )

        var transcriptionDict: [String: Any] = [:]

        if let segments: [TranscriptionSegment] = transcription?.segments {
          var segmentsArray: [[String: Any]] = []

          for segment in segments {
            var segmentDict: [String: Any] = [
              "id": segment.id,
              "seek": segment.seek,
              "start": segment.start,
              "end": segment.end,
              "text": segment.text,
              "tokens": segment.tokens,
              "tokenLogProbs": segment.tokenLogProbs.map { logProbDict in
                var jsonDict: [String: Float] = [:]
                for (token, prob) in logProbDict {
                  jsonDict[String(token)] = prob
                }
                return jsonDict
              },
              "temperature": segment.temperature,
              "avgLogprob": segment.avgLogprob,
              "compressionRatio": segment.compressionRatio,
              "noSpeechProb": segment.noSpeechProb,
              "words": segment.words?.map { word in
                return [
                  "word": word.word,
                  "tokens": word.tokens,
                  "start": word.start,
                  "end": word.end,
                  "probability": word.probability,
                ]
              },
            ]

            segmentsArray.append(segmentDict)
          }

          transcriptionDict["segments"] = segmentsArray
        }

        if let timings: TranscriptionTimings = transcription?.timings {
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

        do {
          let jsonData = try JSONSerialization.data(withJSONObject: transcriptionDict, options: [])
          guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw NSError(
              domain: "WhisperKitError", code: 2004,
              userInfo: [
                NSLocalizedDescriptionKey: "Failed to create JSON string from transcription result"
              ])
          }
          completion(.success(jsonString))
        } catch {
          throw NSError(
            domain: "WhisperKitError", code: 2003,
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
      DecodingOptions(
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

    var currentChunks: [Int: (chunkText: [String], fallbacks: Int)] = [:]

    //  TODO: consider the presence or absence of decodingCallback
    // Early stopping checks
    let decodingCallback: ((TranscriptionProgress) -> Bool?) = {
      (progress: TranscriptionProgress) in
      DispatchQueue.main.async {
        let fallbacks = Int(progress.timings.totalDecodingFallbacks)
        // let chunkId = isStreamMode ? 0 : progress.windowId
        let chunkId = progress.windowId

        // First check if this is a new window for the same chunk, append if so
        var updatedChunk = (chunkText: [progress.text], fallbacks: fallbacks)

        if var currentChunk = currentChunks[chunkId],
          let previousChunkText = currentChunk.chunkText.last
        {
          if progress.text.count >= previousChunkText.count {
            // This is the same window of an existing chunk, so we just update the last value
            currentChunk.chunkText[currentChunk.chunkText.endIndex - 1] = progress.text
            updatedChunk = currentChunk
          } else {
            // This is either a new window or a fallback (only in streaming mode)
            if fallbacks == currentChunk.fallbacks && false {
              // New window (since fallbacks havent changed)
              updatedChunk.chunkText = [updatedChunk.chunkText.first ?? "" + progress.text]
            } else {
              // Fallback, overwrite the previous bad text
              updatedChunk.chunkText[currentChunk.chunkText.endIndex - 1] = progress.text
              updatedChunk.fallbacks = fallbacks
              print("Fallback occured: \(fallbacks)")
            }
          }
        }

        // Set the new text for the chunk
        currentChunks[chunkId] = updatedChunk
        let joinedChunks = currentChunks.sorted { $0.key < $1.key }.flatMap { $0.value.chunkText }
          .joined(separator: "\n")

        // self.currentText = joinedChunks
        // currentFallbacks = fallbacks
        // currentDecodingLoops += 1
      }

      // Check early stopping
      let currentTokens = progress.tokens
      let checkWindow = Int(0)
      if currentTokens.count > checkWindow {
        let checkTokens: [Int] = currentTokens.suffix(checkWindow)
        let compressionRatio = compressionRatio(of: checkTokens)
        if compressionRatio > options.compressionRatioThreshold! {
          Logging.debug("Early stopping due to compression threshold")
          return false
        }
      }
      if progress.avgLogprob! < options.logProbThreshold! {
        Logging.debug("Early stopping due to logprob threshold")
        return false
      }
      return nil
    }

    let transcriptionResults: [TranscriptionResult] = try await whisperKit.transcribe(
      audioArray: samples,
      decodeOptions: options,
      // callback: decodingCallback
    )

    let mergedResults = mergeTranscriptionResults(transcriptionResults)

    return mergedResults
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
      if let downloads = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)
        .first
      {
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
