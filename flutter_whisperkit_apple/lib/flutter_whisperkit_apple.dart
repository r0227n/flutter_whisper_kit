import 'package:flutter/services.dart';
import 'src/whisper_kit_api.dart';

export 'src/whisper_kit_api.dart' show WhisperKitConfig, TranscriptionResult;

class FlutterWhisperkitApple {
  static const MethodChannel _channel = MethodChannel('flutter_whisperkit_apple');
  static final WhisperKitApi _api = WhisperKitApi();

  /// プラグインバージョンを取得
  static Future<String> getPlatformVersion() async {
    try {
      return await _api.getPlatformVersion();
    } on PlatformException catch (e) {
      throw Exception('Failed to get platform version: ${e.message}');
    }
  }

  /// WhisperKitの初期化
  static Future<bool> initialize({
    String? modelPath,
    bool? enableVAD,
    int? vadFallbackSilenceThreshold,
    double? vadTemperature,
    bool? enableLanguageIdentification,
  }) async {
    try {
      final config = WhisperKitConfig(
        modelPath: modelPath,
        enableVAD: enableVAD,
        vadFallbackSilenceThreshold: vadFallbackSilenceThreshold,
        vadTemperature: vadTemperature,
        enableLanguageIdentification: enableLanguageIdentification,
      );
      
      return await _api.initializeWhisperKit(config);
    } on PlatformException catch (e) {
      throw Exception('Failed to initialize WhisperKit: ${e.message}');
    }
  }
  
  /// 音声ファイルから文字起こしを実行
  static Future<TranscriptionResult> transcribeAudioFile(String filePath) async {
    try {
      return await _api.transcribeAudioFile(filePath);
    } on PlatformException catch (e) {
      throw Exception('Failed to transcribe audio file: ${e.message}');
    }
  }
  
  /// ストリーミング文字起こしを開始
  static Future<bool> startStreamingTranscription() async {
    try {
      return await _api.startStreamingTranscription();
    } on PlatformException catch (e) {
      throw Exception('Failed to start streaming transcription: ${e.message}');
    }
  }
  
  /// ストリーミング文字起こしを停止
  static Future<TranscriptionResult> stopStreamingTranscription() async {
    try {
      return await _api.stopStreamingTranscription();
    } on PlatformException catch (e) {
      throw Exception('Failed to stop streaming transcription: ${e.message}');
    }
  }
  
  /// 利用可能なモデルのリストを取得
  static Future<List<String>> getAvailableModels() async {
    try {
      return await _api.getAvailableModels();
    } on PlatformException catch (e) {
      throw Exception('Failed to get available models: ${e.message}');
    }
  }
}