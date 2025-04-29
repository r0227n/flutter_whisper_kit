import Foundation
import WhisperKit

extension DecodingOptions {
    static func fromJson(_ json: [String: Any?]) throws -> DecodingOptions {
        var options = DecodingOptions()

        for (key, value) in json {
            switch key {
            case "verbose":
                if let verbose = value as? Bool {
                    options.verbose = verbose
                }
            case "task":
                if let task = value as? String, task == "translate" {
                    options.task = .translate
                } else {
                    options.task = .transcribe
                }
            case "language":
                if let language = value as? String {
                    options.language = language
                }
            case "temperature":
                if let temperature = value as? Double {
                    options.temperature = Float(temperature)
                }
            case "temperatureFallbackCount":
                if let temperatureFallbackCount = value as? Int {
                    options.temperatureFallbackCount = Int(temperatureFallbackCount)
                }
            case "temperatureIncrementOnFallback":
                if let temperatureIncrementOnFallback = value as? Double {
                    options.temperatureIncrementOnFallback = Float(
                        temperatureIncrementOnFallback)
                }
            case "sampleLength":
                if let sampleLength = value as? Int {
                    options.sampleLength = Int(sampleLength)
                }
            case "topK":
                if let topK = value as? Int {
                    options.topK = Int(topK)
                }
            case "usePrefillPrompt":
                if let usePrefillPrompt = value as? Bool {
                    options.usePrefillPrompt = usePrefillPrompt
                }
            case "usePrefillCache":
                if let usePrefillCache = value as? Bool {
                    options.usePrefillCache = usePrefillCache
                }
            case "detectLanguage":
                if let detectLanguage = value as? Bool {
                    options.detectLanguage = detectLanguage
                }
            case "skipSpecialTokens":
                if let skipSpecialTokens = value as? Bool {
                    options.skipSpecialTokens = skipSpecialTokens
                }
            case "withoutTimestamps":
                if let withoutTimestamps = value as? Bool {
                    options.withoutTimestamps = withoutTimestamps
                }
            case "wordTimestamps":
                if let wordTimestamps = value as? Bool {
                    options.wordTimestamps = wordTimestamps
                }
            case "maxInitialTimestamp":
                if let maxInitialTimestamp = value as? Double {
                    options.maxInitialTimestamp = Float(maxInitialTimestamp)
                }
            case "clipTimestamps":
                if let clipTimestamps = value as? [Double] {
                    options.clipTimestamps = clipTimestamps.map { Float($0) }
                }
            case "promptTokens":
                if let promptTokens = value as? [Int64] {
                    options.promptTokens = promptTokens.map { Int($0) }
                }
            case "prefixTokens":
                if let prefixTokens = value as? [Int64] {
                    options.prefixTokens = prefixTokens.map { Int($0) }
                }
            case "suppressBlank":
                if let suppressBlank = value as? Bool {
                    options.suppressBlank = suppressBlank
                }
            case "supressTokens":
                if let supressTokens = value as? [Int64] {
                    options.supressTokens = supressTokens.map { Int($0) }
                }
            case "compressionRatioThreshold":
                if let compressionRatioThreshold = value as? Double {
                    options.compressionRatioThreshold = Float(compressionRatioThreshold)
                }
            case "logProbThreshold":
                if let logProbThreshold = value as? Double {
                    options.logProbThreshold = Float(logProbThreshold)
                }
            case "firstTokenLogProbThreshold":
                if let firstTokenLogProbThreshold = value as? Double {
                    options.firstTokenLogProbThreshold = Float(firstTokenLogProbThreshold)
                }
            case "noSpeechThreshold":
                if let noSpeechThreshold = value as? Double {
                    options.noSpeechThreshold = Float(noSpeechThreshold)
                }
            case "concurrentWorkerCount":
                if let concurrentWorkerCount = value as? Int {
                    options.concurrentWorkerCount = Int(concurrentWorkerCount)
                }
            case "chunkingStrategy":
                if let chunkingStrategy = value as? String {
                    if chunkingStrategy == "none" {
                        options.chunkingStrategy = .none
                    } else if chunkingStrategy == "vad" {
                        options.chunkingStrategy = .vad
                    }
                }
            default:
                throw NSError(
                    domain: "FlutterWhisperkitApple",
                    code: 1001,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unexpected key in decoding options: \(key)"
                    ]
                )
            }
        }

        return options
    }
}
