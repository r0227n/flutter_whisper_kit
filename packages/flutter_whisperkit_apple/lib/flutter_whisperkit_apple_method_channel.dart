import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_whisperkit_apple_platform_interface.dart';
import 'src/whisper_kit_message.g.dart';

/// An implementation of [FlutterWhisperkitApplePlatform] that uses method channels.
class MethodChannelFlutterWhisperkitApple
    extends FlutterWhisperkitApplePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_whisperkit_apple');

  /// The Pigeon-generated API for WhisperKit
  final _whisperKitMessage = WhisperKitMessage();

  @override
  Future<String?> getPlatformVersion() async {
    return _whisperKitMessage.getPlatformVersion();
  }

  @override
  Future<String?> createWhisperKit(String? model, String? modelRepo) async {
    try {
      return _whisperKitMessage.createWhisperKit(model, modelRepo);
    } on PlatformException catch (e) {
      debugPrint('Error creating WhisperKit: ${e.message}');
      throw e;
    }
  }

  @override
  Future<String?> loadModel(
    String? variant,
    String? modelRepo,
    bool? redownload,
    int? storageLocation,
  ) async {
    try {
      return _whisperKitMessage.loadModel(
        variant,
        modelRepo,
        redownload,
        storageLocation,
      );
    } on PlatformException catch (e) {
      debugPrint('Error loading model: ${e.message}');
      throw e;
    }
  }

  @override
  Future<String?> transcribeFromFile(String? filePath, Map<String, dynamic>? options) async {
    try {
      DecodingOptionsMessage? optionsMessage;
      
      if (options != null) {
        optionsMessage = DecodingOptionsMessage(
          task: options['task'] as String?,
          language: options['language'] as String?,
          temperature: options['temperature'] as double?,
          sampleLen: options['sampleLen'] as int?,
          bestOf: options['bestOf'] as int?,
          beamSize: options['beamSize'] as int?,
          patience: options['patience'] as double?,
          lengthPenalty: options['lengthPenalty'] as double?,
          suppressBlank: options['suppressBlank'] as bool?,
          suppressTokens: options['suppressTokens'] as bool?,
          withoutTimestamps: options['withoutTimestamps'] as bool?,
          maxInitialTimestamp: options['maxInitialTimestamp'] as double?,
          wordTimestamps: options['wordTimestamps'] as bool?,
          prependPunctuations: options['prependPunctuations'] as String?,
          appendPunctuations: options['appendPunctuations'] as String?,
          logProbThreshold: options['logProbThreshold'] as double?,
          noSpeechThreshold: options['noSpeechThreshold'] as double?,
          compressionRatioThreshold: options['compressionRatioThreshold'] as double?,
          conditionOnPreviousText: options['conditionOnPreviousText'] as String?,
          prompt: options['prompt'] as String?,
          chunkingStrategy: options['chunkingStrategy'] as String?,
        );
      }
      
      return _whisperKitMessage.transcribeFromFile(filePath ?? '', optionsMessage);
    } on PlatformException catch (e) {
      debugPrint('Error transcribing file: ${e.message}');
      throw e;
    }
  }
}
