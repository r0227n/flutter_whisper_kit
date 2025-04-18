import 'package:pigeon/pigeon.dart';

// WhisperKitの設定を保持するクラス
class WhisperKitConfig {
  String? modelPath;
  bool? enableVAD;
  int? vadFallbackSilenceThreshold;
  double? vadTemperature;
  bool? enableLanguageIdentification;
}

// 文字起こし結果を格納するクラス
class TranscriptionResult {
  String? text;
  double? duration;
  List<String>? segments;
  String? language;
  String? error;
}

// ホストとのやり取りを定義するAPI
@HostApi()
abstract class WhisperKitApi {
  // プラットフォームのバージョンを取得
  String getPlatformVersion();
  
  // WhisperKitを初期化
  bool initializeWhisperKit(WhisperKitConfig config);
  
  // 音声ファイルから文字起こしを実行
  TranscriptionResult transcribeAudioFile(String filePath);
  
  // ストリーミング文字起こしを開始
  bool startStreamingTranscription();
  
  // ストリーミング文字起こしを停止
  TranscriptionResult stopStreamingTranscription();
  
  // 利用可能なモデルのリストを取得
  List<String> getAvailableModels();
}

// Flutterアプリにイベントを通知するAPI
@FlutterApi()
abstract class WhisperKitEvents {
  // 文字起こし処理の進捗状況
  void onTranscriptionProgress(double progress);
  
  // ストリーミング時の中間結果
  void onInterimTranscriptionResult(TranscriptionResult result);
}