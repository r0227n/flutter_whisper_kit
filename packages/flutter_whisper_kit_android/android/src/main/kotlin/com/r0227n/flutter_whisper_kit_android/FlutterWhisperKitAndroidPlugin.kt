package com.r0227n.flutter_whisper_kit_android

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

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

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
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
  // Following TDD Green phase: minimal stub implementations
  
  override fun loadModel(variant: String?, modelRepo: String?, redownload: Boolean, callback: (Result<String?>) -> Unit) {
    try {
      // Input validation
      if (variant.isNullOrBlank()) {
        callback(Result.failure(IllegalArgumentException("Model variant cannot be null or empty")))
        return
      }
      // Stub implementation - return null until WhisperKitAndroid integration
      callback(Result.success(null))
    } catch (e: Exception) {
      callback(Result.failure(e))
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
}