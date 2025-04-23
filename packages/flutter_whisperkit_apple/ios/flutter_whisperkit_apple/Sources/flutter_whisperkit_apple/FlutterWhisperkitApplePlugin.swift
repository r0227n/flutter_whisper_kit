import Flutter
import Foundation
import UIKit
import WhisperKit

enum ModelStorageLocation: Int64 {
  case packageDirectory = 0
  case userFolder = 1
}

private class WhisperKitApiImpl: WhisperKitMessage {
  private var whisperKit: WhisperKit?
  private var modelStorageLocation: ModelStorageLocation = .packageDirectory

  func getPlatformVersion(completion: @escaping (Result<String?, Error>) -> Void) {
    completion(.success("iOS " + UIDevice.current.systemVersion))
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

  func transcribeFromFile(filePath: String?, options: [AnyHashable?: Any]?, completion: @escaping (Result<String?, Error>) -> Void)
  {
    guard let filePath = filePath else {
      completion(
        .failure(
          NSError(
            domain: "WhisperKitError", code: 2001,
            userInfo: [NSLocalizedDescriptionKey: "File path is required"])))
      return
    }
    
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
              domain: "WhisperKitError", code: 2004,
              userInfo: [
                NSLocalizedDescriptionKey: "Failed to create JSON string from transcription result"
              ])
          }
        } catch {
          throw NSError(
            domain: "WhisperKitError", code: 2003,
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
}

public class FlutterWhisperkitApplePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    // Pigeonで生成されたSetupコードを呼び出す
    WhisperKitMessageSetup.setUp(binaryMessenger: registrar.messenger(), api: WhisperKitApiImpl())
  }
}
