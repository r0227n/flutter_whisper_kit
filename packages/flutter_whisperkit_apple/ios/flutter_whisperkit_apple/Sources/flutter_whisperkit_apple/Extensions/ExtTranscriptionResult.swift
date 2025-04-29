import Foundation
import WhisperKit

extension TranscriptionResult {
    func toJson() -> [String: Any] {
        var transcriptionDict: [String: Any] = [:]

        let segments = self.segments
        var segmentsArray: [[String: Any]] = []

        transcriptionDict["text"] = self.text

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

        transcriptionDict["language"] = self.language

        let timings = self.timings
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

        transcriptionDict["seekTime"] = self.seekTime

        return transcriptionDict
    }
}
