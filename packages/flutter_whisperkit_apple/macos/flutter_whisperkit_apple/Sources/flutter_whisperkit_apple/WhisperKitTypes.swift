import Foundation

public struct WhisperKitConfig: Codable {
    let modelPath: String
    let deviceId: Int
    let numThreads: Int
    let language: String?
    let translateToEnglish: Bool
    
    static func fromList(_ list: [Any?]) -> WhisperKitConfig {
        return WhisperKitConfig(
            modelPath: list[0] as! String,
            deviceId: list[1] as! Int,
            numThreads: list[2] as! Int,
            language: list[3] as? String,
            translateToEnglish: list[4] as! Bool
        )
    }
    
    func toList() -> [Any?] {
        return [modelPath, deviceId, numThreads, language, translateToEnglish]
    }
}

public struct TranscriptionSegment: Codable {
    let text: String
    let startTime: Double
    let endTime: Double
    let probability: Double
    
    static func fromList(_ list: [Any?]) -> TranscriptionSegment {
        return TranscriptionSegment(
            text: list[0] as! String,
            startTime: list[1] as! Double,
            endTime: list[2] as! Double,
            probability: list[3] as! Double
        )
    }
    
    func toList() -> [Any?] {
        return [text, startTime, endTime, probability]
    }
}

public struct TranscriptionResult: Codable {
    let segments: [TranscriptionSegment]
    let language: String
    
    static func fromList(_ list: [Any?]) -> TranscriptionResult {
        let segmentsList = list[0] as! [[Any?]]
        let segments = segmentsList.map { TranscriptionSegment.fromList($0) }
        return TranscriptionResult(
            segments: segments,
            language: list[1] as! String
        )
    }
    
    func toList() -> [Any?] {
        return [segments.map { $0.toList() }, language]
    }
} 