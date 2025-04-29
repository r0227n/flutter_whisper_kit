import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisperkit_apple/flutter_whisperkit_apple.dart';
import 'package:flutter_whisperkit_apple/flutter_whisperkit_apple_platform_interface.dart';
import 'package:flutter_whisperkit_apple/flutter_whisperkit_apple_method_channel.dart';
import 'package:flutter_whisperkit_apple/model_loader.dart';
import 'package:flutter_whisperkit_apple/src/models/decoding_options.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterWhisperkitApplePlatform
    with MockPlatformInterfaceMixin
    implements FlutterWhisperkitApplePlatform {
  @override
  Future<String?> loadModel(
    String? variant,
    String? modelRepo,
    bool? redownload,
    int? storageLocation,
  ) => Future.value('Model loaded successfully');

  @override
  Future<String?> transcribeFromFile(
    String filePath,
    DecodingOptions? options,
  ) => Future.value(
    '{"text":"Test transcription","segments":[{"text":"Test transcription"}],"language":"en","timings":{}}',
  );

  @override
  Future<String?> startRecording(DecodingOptions options, bool loop) =>
      Future.value('Recording started');

  @override
  Future<String?> stopRecording(bool loop) => Future.value('Recording stopped');

  @override
  Stream<String> get transcriptionStream =>
      Stream<String>.fromIterable(['Test transcription']);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final FlutterWhisperkitApplePlatform initialPlatform =
      FlutterWhisperkitApplePlatform.instance;

  test('$MethodChannelFlutterWhisperkitApple is the default instance', () {
    expect(
      initialPlatform,
      isInstanceOf<MethodChannelFlutterWhisperkitApple>(),
    );
  });

  test('loadModel', () async {
    FlutterWhisperkitApple flutterWhisperkitApplePlugin =
        FlutterWhisperkitApple();
    MockFlutterWhisperkitApplePlatform fakePlatform =
        MockFlutterWhisperkitApplePlatform();
    FlutterWhisperkitApplePlatform.instance = fakePlatform;

    expect(
      await flutterWhisperkitApplePlugin.loadModel(
        'tiny-en',
        modelRepo: 'argmaxinc/whisperkit-coreml',
      ),
      'Model loaded successfully',
    );
  });

  test('WhisperKitModelLoader', () async {
    MockFlutterWhisperkitApplePlatform fakePlatform =
        MockFlutterWhisperkitApplePlatform();
    FlutterWhisperkitApplePlatform.instance = fakePlatform;

    final modelLoader = WhisperKitModelLoader();

    expect(
      await modelLoader.loadModel(variant: 'tiny-en'),
      'Model loaded successfully',
    );

    modelLoader.setStorageLocation(ModelStorageLocation.userFolder);
    expect(modelLoader.storageLocation, ModelStorageLocation.userFolder);
  });
}
