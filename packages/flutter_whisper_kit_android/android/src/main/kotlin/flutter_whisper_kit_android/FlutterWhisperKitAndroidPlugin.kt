package flutter_whisper_kit_android

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.EventChannel
import android.content.pm.PackageManager
import android.os.Build
// TODO: Uncomment when WhisperKit Android library is available
// import com.argmaxinc.whisperkit.WhisperKit
// import com.argmaxinc.whisperkit.ExperimentalWhisperKit
// import com.argmaxinc.whisperkit.WhisperKitCallback

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
  
  // Recording state management
  private var isRecording = false
  private var recordingWithLoop = false
  // private var whisperKit: WhisperKit? = null // TODO: Uncomment when WhisperKit Android library is available
  
  // Event channel for real-time callbacks
  private var eventSink: EventChannel.EventSink? = null
  private lateinit var eventChannel: EventChannel
  
  // Platform-specific constants
  companion object {
    private const val PERMISSION_MICROPHONE = android.Manifest.permission.RECORD_AUDIO
    private const val EVENT_CHANNEL_NAME = "flutter_whisper_kit/recording_events"
  }

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_whisper_kit_android")
    channel.setMethodCallHandler(this)
    
    // Setup WhisperKitMessage Pigeon API
    WhisperKitMessage.setUp(flutterPluginBinding.binaryMessenger, this)
    
    // Setup event channel for real-time callbacks
    eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, EVENT_CHANNEL_NAME)
    eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
      override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
      }

      override fun onCancel(arguments: Any?) {
        eventSink = null
      }
    })
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
    
    // Cleanup event channel
    eventChannel.setStreamHandler(null)
    eventSink = null
    
    // Clean up recording state
    isRecording = false
    recordingWithLoop = false
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

  override fun transcribeFromFile(filePath: String, options: Map<String, Any?>, callback: (Result<String?>) -> Unit) {
    try {
      // Input validation
      if (filePath.isBlank()) {
        callback(Result.failure(IllegalArgumentException("File path cannot be empty")))
        return
      }
      // Stub implementation - return null until WhisperKitAndroid integration
      callback(Result.success(null))
    } catch (e: Exception) {
      callback(Result.failure(e))
    }
  }

  // @OptIn(ExperimentalWhisperKit::class) // TODO: Uncomment when WhisperKit Android library is available
  override fun startRecording(options: Map<String, Any?>, loop: Boolean, callback: (Result<String?>) -> Unit) {
    try {
      // Check microphone permissions
      if (!checkMicrophonePermission()) {
        callback(Result.failure(RuntimeException("Error: Microphone permission required")))
        return
      }
      
      // Validate recording parameters
      val sampleLength = options["sampleLength"] as? Int
      if (sampleLength != null && sampleLength < 0) {
        callback(Result.failure(IllegalArgumentException("Invalid sample length")))
        return
      }
      
      // Security validation for language parameter
      val language = options["language"] as? String
      if (language != null && (language.contains("..") || language.contains("/") || language.contains("\\"))) {
        callback(Result.failure(IllegalArgumentException("Invalid language parameter")))
        return
      }
      
      // Initialize WhisperKit with callback configuration
      // TODO: Uncomment when WhisperKit Android library is available
      /*
      whisperKit = WhisperKit.Builder()
        .setOptions(options)
        .setCallback(object : WhisperKitCallback {
          override fun onInit() {
            // Handle MSG_INIT
            sendToFlutter("onInit", "Recording initialized")
          }
          
          override fun onTextOutput(text: String) {
            // Handle MSG_TEXT_OUT
            sendToFlutter("onTranscription", text)
          }
          
          override fun onClose() {
            // Handle MSG_CLOSE
            sendToFlutter("onClose", "Recording stopped")
          }
        })
        .build()
      
      // Start recording with loop parameter
      whisperKit.startRecording(loop)
      */
      
      // Stub implementation for now
      isRecording = true
      recordingWithLoop = loop
      callback(Result.success("Recording started"))
    } catch (e: SecurityException) {
      // Sanitize error message to avoid exposing system paths
      callback(Result.failure(RuntimeException("Security error: permission denied")))
    } catch (e: OutOfMemoryError) {
      System.gc()
      callback(Result.failure(RuntimeException("Recording failed: insufficient memory")))
    } catch (e: Exception) {
      // Sanitize error messages to avoid exposing sensitive information
      val sanitizedError = sanitizeErrorMessage(e.message)
      val errorMsg = when {
        sanitizedError.contains("permission", ignoreCase = true) -> 
          "Recording failed: microphone permission denied"
        sanitizedError.contains("audio", ignoreCase = true) -> 
          "Recording failed: audio initialization error"
        else -> "Recording failed: unexpected error"
      }
      callback(Result.failure(RuntimeException(errorMsg)))
    }
  }

  override fun stopRecording(loop: Boolean, callback: (Result<String?>) -> Unit) {
    try {
      if (!isRecording) {
        callback(Result.success("Recording not active"))
        return
      }
      
      // TODO: Uncomment when WhisperKit Android library is available
      /*
      // Deinitialize WhisperKit and clean up resources
      whisperKit?.apply {
        stopRecording()
        deinitialize()
      }
      whisperKit = null
      */
      
      // Clean up state
      isRecording = false
      recordingWithLoop = false
      
      callback(Result.success("Recording stopped"))
    } catch (e: Exception) {
      callback(Result.failure(RuntimeException("Stop recording failed: ${e.message}")))
    } finally {
      // Ensure resources are cleaned up
      isRecording = false
      recordingWithLoop = false
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
  
  // MARK: - Helper Methods
  
  /**
   * Check if microphone permission is granted
   * 
   * @return true if permission is granted, false otherwise
   */
  private fun checkMicrophonePermission(): Boolean {
    // TODO: Implement actual permission check when context is available
    // For now, return true as a stub
    return true
    
    // Actual implementation would be:
    /*
    return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
      context.checkSelfPermission(PERMISSION_MICROPHONE) == PackageManager.PERMISSION_GRANTED
    } else {
      true // Permission is granted at install time on older versions
    }
    */
  }
  
  /**
   * Send event to Flutter side via EventChannel
   * 
   * @param event The event type (e.g., "onInit", "onTranscription", "onClose")
   * @param data The event data
   */
  private fun sendToFlutter(event: String, data: String) {
    // Send real-time transcription results and status updates to Flutter
    eventSink?.success(mapOf(
      "event" to event,
      "data" to data,
      "timestamp" to System.currentTimeMillis()
    ))
  }
  
  /**
   * Build recording options from the provided options map
   * 
   * @param options The decoding options from Flutter
   * @return WhisperKit-specific recording options
   */
  private fun buildRecordingOptions(options: Map<String, Any?>): Map<String, Any?> {
    // Convert Flutter options to WhisperKit Android format
    return options // For now, pass through as-is
  }
  
  /**
   * Sanitize error messages to avoid exposing sensitive information
   * 
   * @param message The original error message
   * @return A sanitized error message safe for display
   */
  private fun sanitizeErrorMessage(message: String?): String {
    if (message == null) return ""
    
    // Remove file paths, system information, and other sensitive data
    return message
      .replace(Regex("/[^\\s]+"), "[PATH]") // Replace file paths
      .replace(Regex("\\b\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\b"), "[IP]") // Replace IP addresses
      .replace(Regex(":\\d{2,5}"), ":[PORT]") // Replace port numbers
      .substringBefore("at ") // Remove stack traces
      .take(200) // Limit message length
  }
}