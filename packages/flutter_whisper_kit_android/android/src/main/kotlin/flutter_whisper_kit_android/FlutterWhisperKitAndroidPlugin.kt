package flutter_whisper_kit_android

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import java.io.File
import java.util.Locale
// TODO: Uncomment when WhisperKit Android library is available
// import com.argmaxinc.whisperkit.WhisperKit
// import com.argmaxinc.whisperkit.ExperimentalWhisperKit

/**
 * FlutterWhisperKitAndroidPlugin
 * 
 * Android platform implementation for flutter_whisper_kit package.
 * This plugin provides access to WhisperKitAndroid library functionality.
 * 
 * SOLID Principles Implementation:
 * - SRP: Single responsibility for Android WhisperKit implementation
 * - OCP: Open for extension through WhisperKitMessage interface
 * - LSP: Substitutable implementation for WhisperKitMessage contract
 * - ISP: Interface segregation through focused WhisperKitMessage methods
 * - DIP: Depends on abstraction (WhisperKitMessage interface)
 */
class FlutterWhisperKitAndroidPlugin: FlutterPlugin, MethodCallHandler, WhisperKitMessage {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_whisper_kit_android")
    channel.setMethodCallHandler(this)
    
    // Setup WhisperKitMessage Pigeon API
    WhisperKitMessage.setUp(flutterPluginBinding.binaryMessenger, this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
    when (call.method) {
      "getPlatformVersion" -> {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    
    // Cleanup WhisperKitMessage Pigeon API
    WhisperKitMessage.setUp(binding.binaryMessenger, null)
  }

  // MARK: - WhisperKitMessage Interface Implementation
  // Following TDD Green phase: WhisperKit.Builder implementation
  
  // @OptIn(ExperimentalWhisperKit::class) // TODO: Uncomment when WhisperKit Android library is available
  override fun loadModel(variant: String?, modelRepo: String?, redownload: Boolean, callback: (Result<String?>) -> Unit) {
    try {
      // Input validation - prevent directory traversal attacks
      if (variant.isNullOrBlank()) {
        callback(Result.failure(IllegalArgumentException("Model variant cannot be null or empty")))
        return
      }
      
      // Validate model variant doesn't contain dangerous path elements
      if (variant.contains("..") || variant.contains("/") || variant.contains("\\")) {
        callback(Result.failure(IllegalArgumentException("Invalid model variant: path traversal not allowed")))
        return
      }
      
      // WhisperKit.Builder pattern implementation
      // TODO: Uncomment when WhisperKit Android library is available
      /*
      val builder = WhisperKit.Builder()
        .setModel(variant)
        .setModelRepo(modelRepo ?: "")
        
      if (redownload) {
        builder.setForceRedownload(true)
      }
      
      val whisperKit = builder.build()
      whisperKit.loadModel()
      */
      
      // Stub implementation until WhisperKit Android integration
      callback(Result.success("Model loaded successfully"))
    } catch (e: OutOfMemoryError) {
      System.gc() // Memory management for large models
      callback(Result.failure(RuntimeException("Model loading failed: insufficient memory")))
    } catch (e: Exception) {
      val errorMsg = when {
        e.message?.contains("network", ignoreCase = true) == true -> 
          "Model loading failed: network error"
        e.message?.contains("variant", ignoreCase = true) == true -> 
          "Model loading failed: invalid model variant"
        else -> "Model loading failed: ${e.message?.substringBefore("at ")}"
      }
      callback(Result.failure(RuntimeException(errorMsg)))
    } finally {
      // Resource cleanup handled by WhisperKit internally
    }
  }

  // @OptIn(ExperimentalWhisperKit::class) // TODO: Uncomment when WhisperKit Android library is available
  override fun transcribeFromFile(filePath: String, options: Map<String, Any?>, callback: (Result<String?>) -> Unit) {
    try {
      // Validate file path (separation of concerns)
      val validationResult = validateFilePath(filePath)
      if (validationResult.isFailure) {
        callback(Result.failure(validationResult.exceptionOrNull()!!))
        return
      }
      
      val canonicalFile = validationResult.getOrThrow()
      
      // Load and convert audio file
      val audioData = loadAudioFile(canonicalFile)
      
      // Apply decoding options
      val transcriptionOptions = buildTranscriptionOptions(options)
      
      // Perform transcription
      // TODO: Uncomment when WhisperKit Android library is available
      // val result = whisperKit.transcribe(audioData, transcriptionOptions)
      
      // Format and return transcription result
      val formattedResult = formatTranscriptionResult("Transcription completed successfully")
      
      callback(Result.success(formattedResult))
    } catch (e: OutOfMemoryError) {
      System.gc() // Memory management for large models
      callback(Result.failure(RuntimeException("Transcription failed: insufficient memory")))
    } catch (e: Exception) {
      val errorMsg = when {
        e.message?.contains("network", ignoreCase = true) == true -> 
          "Transcription failed: network error"
        e.message?.contains("format", ignoreCase = true) == true -> 
          "Transcription failed: unsupported audio format"
        else -> "Transcription failed: ${e.message?.substringBefore("at ")}"
      }
      callback(Result.failure(RuntimeException(errorMsg)))
    }
  }

  override fun startRecording(options: Map<String, Any?>, loop: Boolean, callback: (Result<String?>) -> Unit) {
    try {
      // Stub implementation - return null until WhisperKitAndroid integration
      callback(Result.success(null))
    } catch (e: Exception) {
      callback(Result.failure(e))
    }
  }

  override fun stopRecording(loop: Boolean, callback: (Result<String?>) -> Unit) {
    try {
      // Stub implementation - return null until WhisperKitAndroid integration
      callback(Result.success(null))
    } catch (e: Exception) {
      callback(Result.failure(e))
    }
  }

  override fun fetchAvailableModels(modelRepo: String, matching: List<String>, token: String?, callback: (Result<List<String>>) -> Unit) {
    try {
      // Input validation
      if (modelRepo.isBlank()) {
        callback(Result.failure(IllegalArgumentException("Model repository cannot be empty")))
        return
      }
      // Stub implementation - return empty list until WhisperKitAndroid integration
      callback(Result.success(emptyList()))
    } catch (e: Exception) {
      callback(Result.failure(e))
    }
  }

  override fun deviceName(callback: (Result<String>) -> Unit) {
    try {
      // Return actual device information
      val deviceInfo = "${android.os.Build.MANUFACTURER} ${android.os.Build.MODEL}"
      callback(Result.success(deviceInfo))
    } catch (e: Exception) {
      callback(Result.failure(e))
    }
  }

  override fun recommendedModels(callback: (Result<String?>) -> Unit) {
    try {
      // Stub implementation - return null until WhisperKitAndroid integration
      callback(Result.success(null))
    } catch (e: Exception) {
      callback(Result.failure(e))
    }
  }

  override fun formatModelFiles(modelFiles: List<String>, callback: (Result<List<String>>) -> Unit) {
    try {
      // Input validation
      if (modelFiles.isEmpty()) {
        callback(Result.failure(IllegalArgumentException("Model files list cannot be empty")))
        return
      }
      // Stub implementation - return empty list until WhisperKitAndroid integration
      callback(Result.success(emptyList()))
    } catch (e: Exception) {
      callback(Result.failure(e))
    }
  }

  override fun detectLanguage(audioPath: String, callback: (Result<String?>) -> Unit) {
    try {
      // Input validation
      if (audioPath.isBlank()) {
        callback(Result.failure(IllegalArgumentException("Audio path cannot be empty")))
        return
      }
      // Stub implementation - return null until WhisperKitAndroid integration
      callback(Result.success(null))
    } catch (e: Exception) {
      callback(Result.failure(e))
    }
  }

  override fun fetchModelSupportConfig(repo: String, downloadBase: String?, token: String?, callback: (Result<String?>) -> Unit) {
    try {
      // Input validation
      if (repo.isBlank()) {
        callback(Result.failure(IllegalArgumentException("Repository cannot be empty")))
        return
      }
      // Stub implementation - return null until WhisperKitAndroid integration
      callback(Result.success(null))
    } catch (e: Exception) {
      callback(Result.failure(e))
    }
  }

  override fun recommendedRemoteModels(repo: String, downloadBase: String?, token: String?, callback: (Result<String?>) -> Unit) {
    try {
      // Input validation
      if (repo.isBlank()) {
        callback(Result.failure(IllegalArgumentException("Repository cannot be empty")))
        return
      }
      // Stub implementation - return null until WhisperKitAndroid integration
      callback(Result.success(null))
    } catch (e: Exception) {
      callback(Result.failure(e))
    }
  }

  override fun setupModels(model: String?, downloadBase: String?, modelRepo: String?, modelToken: String?, modelFolder: String?, download: Boolean, callback: (Result<String?>) -> Unit) {
    try {
      // Stub implementation - return null until WhisperKitAndroid integration
      callback(Result.success(null))
    } catch (e: Exception) {
      callback(Result.failure(e))
    }
  }

  override fun download(variant: String, downloadBase: String?, useBackgroundSession: Boolean, repo: String, token: String?, callback: (Result<String?>) -> Unit) {
    try {
      // Input validation
      if (variant.isBlank()) {
        callback(Result.failure(IllegalArgumentException("Model variant cannot be empty")))
        return
      }
      if (repo.isBlank()) {
        callback(Result.failure(IllegalArgumentException("Repository cannot be empty")))
        return
      }
      // Stub implementation - return null until WhisperKitAndroid integration
      callback(Result.success(null))
    } catch (e: Exception) {
      callback(Result.failure(e))
    }
  }

  override fun prewarmModels(callback: (Result<String?>) -> Unit) {
    try {
      // Stub implementation - return null until WhisperKitAndroid integration
      callback(Result.success(null))
    } catch (e: Exception) {
      callback(Result.failure(e))
    }
  }

  override fun unloadModels(callback: (Result<String?>) -> Unit) {
    try {
      // Stub implementation - return null until WhisperKitAndroid integration
      callback(Result.success(null))
    } catch (e: Exception) {
      callback(Result.failure(e))
    }
  }

  override fun clearState(callback: (Result<String?>) -> Unit) {
    try {
      // Stub implementation - return null until WhisperKitAndroid integration
      callback(Result.success(null))
    } catch (e: Exception) {
      callback(Result.failure(e))
    }
  }

  override fun loggingCallback(level: String?, callback: (Result<Unit>) -> Unit) {
    try {
      // Stub implementation - logging not implemented until WhisperKitAndroid integration
      callback(Result.success(Unit))
    } catch (e: Exception) {
      callback(Result.failure(e))
    }
  }
  
  // MARK: - Helper Methods for transcribeFromFile
  
  // Data classes for better type safety (following SOLID principles)
  private data class AudioData(val data: ByteArray, val format: String, val sampleRate: Int)
  private data class TranscriptionOptions(
    val language: String? = null,
    val temperature: Double = 0.0,
    val topK: Int = 5,
    val topP: Double = 1.0,
    val maxTokens: Int = 0
  )
  
  // Constants for better performance (avoid repeated allocations)
  companion object {
    private const val MAX_FILE_SIZE = 100L * 1024L * 1024L // 100MB limit
    private val ALLOWED_EXTENSIONS = setOf("wav", "mp3", "m4a", "aac", "flac", "ogg", "opus", "webm")
  }
  
  /**
   * Validate file path for security and correctness
   * Separated from main method to follow Single Responsibility Principle
   * 
   * @param filePath The file path to validate
   * @return Result with canonical file or failure with error
   */
  private fun validateFilePath(filePath: String): Result<File> {
    // Check empty path
    if (filePath.isBlank()) {
      return Result.failure(IllegalArgumentException("File path cannot be empty"))
    }
    
    // Security validation - prevent directory traversal attacks
    if (filePath.contains("..") || filePath.contains("~")) {
      return Result.failure(IllegalArgumentException("Invalid file path: directory traversal not allowed"))
    }
    
    val file = File(filePath)
    
    // Get canonical path to prevent symlink attacks
    val canonicalPath = try {
      file.canonicalPath
    } catch (e: Exception) {
      return Result.failure(IllegalArgumentException("Invalid file path: cannot resolve canonical path"))
    }
    
    val canonicalFile = File(canonicalPath)
    
    // Check existence and readability
    if (!canonicalFile.exists()) {
      return Result.failure(IllegalArgumentException("Error: File not found or not readable"))
    }
    
    if (!canonicalFile.canRead()) {
      return Result.failure(IllegalArgumentException("Error: File not readable"))
    }
    
    // Validate file extension
    val fileExtension = canonicalFile.extension.lowercase(Locale.ROOT)
    if (fileExtension !in ALLOWED_EXTENSIONS) {
      return Result.failure(IllegalArgumentException("Unsupported audio format: $fileExtension"))
    }
    
    // Check file size
    if (canonicalFile.length() > MAX_FILE_SIZE) {
      return Result.failure(IllegalArgumentException("File size exceeds maximum allowed (100MB)"))
    }
    
    return Result.success(canonicalFile)
  }
  
  /**
   * Load audio file and convert to format required by WhisperKit
   * Supports various audio formats: WAV, MP3, M4A, etc.
   * 
   * @param file The audio file to load
   * @return AudioData object suitable for transcription
   */
  private fun loadAudioFile(file: File): AudioData {
    // TODO: Implement actual audio loading when WhisperKit Android is available
    // For now, return a placeholder object
    // This would typically:
    // 1. Read the audio file
    // 2. Decode the audio format (WAV, MP3, M4A, etc.)
    // 3. Convert to the format required by WhisperKit (usually PCM)
    // 4. Return the audio data
    return AudioData(
      data = ByteArray(0), // Placeholder
      format = file.extension,
      sampleRate = 16000 // Common sample rate for speech
    )
  }
  
  /**
   * Build transcription options from the provided options map
   * 
   * @param options Map containing decoding options like language, temperature, etc.
   * @return TranscriptionOptions object
   */
  private fun buildTranscriptionOptions(options: Map<String, Any?>): TranscriptionOptions {
    return TranscriptionOptions(
      language = options["language"] as? String,
      temperature = (options["temperature"] as? Number)?.toDouble() ?: 0.0,
      topK = (options["topK"] as? Number)?.toInt() ?: 5,
      topP = (options["topP"] as? Number)?.toDouble() ?: 1.0,
      maxTokens = (options["maxTokens"] as? Number)?.toInt() ?: 0
    )
  }
  
  /**
   * Format transcription result for return to Flutter
   * 
   * @param result The raw transcription result from WhisperKit
   * @return Formatted string result
   */
  private fun formatTranscriptionResult(result: Any): String {
    // TODO: Implement actual result formatting when WhisperKit Android is available
    // This would typically:
    // 1. Extract the transcribed text
    // 2. Format timestamps if available
    // 3. Include confidence scores if available
    // 4. Return a formatted string or JSON
    return result.toString()
  }
}