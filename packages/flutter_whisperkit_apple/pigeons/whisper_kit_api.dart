import 'package:pigeon/pigeon.dart';

const String _kInput = 'pigeons/whisper_kit_api.dart';
const String _kDartOut = 'lib/src/whisper_kit_api.dart';

@ConfigurePigeon(
  PigeonOptions(
    input: _kInput,
    dartOut: _kDartOut,
    swiftOut: 'ios/Classes/WhisperKitApi.swift',
  ),
)
@ConfigurePigeon(
  PigeonOptions(
    input: _kInput,
    dartOut: _kDartOut,
    swiftOut: 'macos/Classes/WhisperKitApi.swift',
  ),
)
class WhisperKitConfig {
  final String? modelPath;
  final bool? enableVAD;
  final int? vadFallbackSilenceThreshold;
  final double? vadTemperature;
  final bool? enableLanguageIdentification;

  WhisperKitConfig({
    this.modelPath,
    this.enableVAD,
    this.vadFallbackSilenceThreshold,
    this.vadTemperature,
    this.enableLanguageIdentification,
  });
}

class TranscriptionSegment {
  final String text;
  final double startTime;
  final double endTime;

  TranscriptionSegment({
    required this.text,
    required this.startTime,
    required this.endTime,
  });
}

class TranscriptionResult {
  final String text;
  final List<TranscriptionSegment> segments;
  final String? language;

  TranscriptionResult({
    required this.text,
    required this.segments,
    this.language,
  });
}

@HostApi()
abstract class WhisperKitApi {
  @async
  String getPlatformVersion();

  @async
  bool initializeWhisperKit(WhisperKitConfig config);

  @async
  TranscriptionResult transcribeAudioFile(String filePath);

  @async
  bool startStreamingTranscription();

  @async
  TranscriptionResult stopStreamingTranscription();

  @async
  List<String> getAvailableModels();
}

@FlutterApi()
abstract class WhisperKitEvents {
  void onTranscriptionProgress(double progress);
  void onInterimTranscriptionResult(TranscriptionResult result);
}
