import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/platform_specifics/whisper_kit_message.g.dart',
    swiftOut:
        '../flutter_whisper_kit_apple/darwin/flutter_whisper_kit_apple/Sources/flutter_whisper_kit_apple/WhisperKitMessage.g.swift',
    dartPackageName: 'flutter_whisper_kit',
  ),
)
@HostApi()
abstract class WhisperKitMessage {
  @async
  String? loadModel(String? variant, String? modelRepo, bool redownload);
  @async
  String? transcribeFromFile(String filePath, Map<String, Object?> options);
  @async
  String? startRecording(Map<String, Object?> options, bool loop);
  @async
  String? stopRecording(bool loop);
  @async
  List<String?> fetchAvailableModels(
    String modelRepo,
    List<String> matching,
    String? token,
  );

  /// Retrieves the name of the device asynchronously.
  ///
  /// This method is asynchronous and returns a [Future] containing the device name as a [String].
  /// Ensure to use `await` or handle the returned [Future] appropriately.
  @async
  String deviceName();
  @async
  String? recommendedModels();
  @async
  List<String?> formatModelFiles(List<String> modelFiles);
  @async
  String? detectLanguage(String audioPath);
  @async
  String? fetchModelSupportConfig(
    String repo,
    String? downloadBase,
    String? token,
  );
  @async
  String? recommendedRemoteModels(
    String repo,
    String? downloadBase,
    String? token,
  );
  @async
  String? setupModels(String? model, String? downloadBase, String? modelRepo,
      String? modelToken, String? modelFolder, bool download);
  @async
  String? download(String variant, String? downloadBase,
      bool useBackgroundSession, String repo, String? token);
  @async
  String? prewarmModels();
  @async
  String? unloadModels();
  @async
  String? clearState();
  @async
  void loggingCallback(String? level);
}
