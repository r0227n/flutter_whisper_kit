import WhisperKit
/// Extension for DeviceSupport to handle JSON conversion
extension DeviceSupport {
    /// Converts DeviceSupport to a dictionary for JSON serialization
    func toJson() -> [String: Any] {
        return [
            "chips": chips as Any,
            "identifiers": identifiers,
            "models": models.toJson()
        ]
    }
}