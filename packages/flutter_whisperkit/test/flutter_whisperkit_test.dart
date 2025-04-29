import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisperkit/flutter_whisperkit.dart';
import 'package:flutter_whisperkit/flutter_whisperkit_platform_interface.dart';
import 'package:flutter_whisperkit/flutter_whisperkit_method_channel.dart';
import 'package:flutter_whisperkit/src/models.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterWhisperkitPlatform
    with MockPlatformInterfaceMixin
    implements FlutterWhisperkitPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<String?> loadModel(
    String? variant, {
    String? modelRepo,
    bool? redownload,
    ModelStorageLocation? storageLocation,
  }) {
    // TODO: implement loadModel
    throw UnimplementedError();
  }

  @override
  Future<String?> startRecording({
    DecodingOptions options = const DecodingOptions(),
    bool loop = true,
  }) {
    // TODO: implement startRecording
    throw UnimplementedError();
  }

  @override
  Future<String?> stopRecording({bool loop = true}) {
    // TODO: implement stopRecording
    throw UnimplementedError();
  }

  @override
  Future<String?> transcribeFromFile(
    String filePath, {
    DecodingOptions options = const DecodingOptions(),
  }) {
    // TODO: implement transcribeFromFile
    throw UnimplementedError();
  }

  @override
  // TODO: implement transcriptionStream
  Stream<TranscriptionResult> get transcriptionStream => throw UnimplementedError();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  final FlutterWhisperkitPlatform initialPlatform =
      FlutterWhisperkitPlatform.instance;

  test('$MethodChannelFlutterWhisperkit is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterWhisperkit>());
  });
}
