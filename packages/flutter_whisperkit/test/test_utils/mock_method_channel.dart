import 'package:flutter_whisperkit/flutter_whisperkit_method_channel.dart';
import 'package:flutter_whisperkit/src/models.dart';

class MockMethodChannelFlutterWhisperkit
    extends MethodChannelFlutterWhisperKit {
  String? mockLoadModelResponse;
  TranscriptionResult? mockTranscribeResponse;
  String? mockStartRecordingResponse;
  String? mockStopRecordingResponse;

  @override
  Future<String?> loadModel(
    String? modelName, {
    String? modelDownloadPath,
    String? modelRepo,
    bool? redownload,
  }) async {
    return mockLoadModelResponse;
  }

  @override
  Future<TranscriptionResult?> transcribeFromFile(
    String filePath, {
    DecodingOptions? options,
  }) async {
    return mockTranscribeResponse;
  }

  @override
  Future<String?> startRecording({bool? loop, DecodingOptions? options}) async {
    return mockStartRecordingResponse;
  }

  @override
  Future<String?> stopRecording({bool? loop}) async {
    return mockStopRecordingResponse;
  }
}
