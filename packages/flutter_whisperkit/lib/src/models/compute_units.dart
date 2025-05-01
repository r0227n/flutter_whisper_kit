/// Compute units available for WhisperKit model loading.
/// 
/// Corresponds to MLComputeUnits in WhisperKit.
enum MLComputeUnits {
  /// Use CPU only.
  cpuOnly,

  /// Use both CPU and GPU.
  cpuAndGPU,

  /// Use CPU and Neural Engine.
  cpuAndNeuralEngine,

  /// Use all available compute resources.
  all,
}
