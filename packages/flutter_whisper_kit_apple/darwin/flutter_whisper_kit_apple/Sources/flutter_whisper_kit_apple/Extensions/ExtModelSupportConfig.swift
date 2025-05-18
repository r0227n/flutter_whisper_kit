import WhisperKit
extension ModelSupportConfig {
    func toJson() -> [String: Any] {
        return [
            "repoName": repoName,
            "repoVersion": repoVersion,
            "deviceSupports": deviceSupports.map { $0.toJson() },
            "knownModels": knownModels,
            "defaultSupport": defaultSupport.toJson()
        ]
    }
}

    