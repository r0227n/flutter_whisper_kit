import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisperkit/flutter_whisperkit.dart';
import 'package:flutter_whisperkit/flutter_whisperkit_platform_interface.dart';
import 'package:flutter_whisperkit/flutter_whisperkit_method_channel.dart';
import 'package:flutter_whisperkit_apple/src/models/decoding_options.dart';
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
    int? storageLocation,
  }) {
    // TODO: implement loadModel
    throw UnimplementedError();
  }

  @override
  Future<String?> startRecording(DecodingOptions options, bool loop) {
    // TODO: implement startRecording
    throw UnimplementedError();
  }

  @override
  Future<String?> stopRecording(bool loop) {
    // TODO: implement stopRecording
    throw UnimplementedError();
  }

  @override
  Future<String?> transcribeFromFile(String filePath, DecodingOptions options) {
    // TODO: implement transcribeFromFile
    throw UnimplementedError();
  }

  @override
  // TODO: implement transcriptionStream
  Stream<String> get transcriptionStream => throw UnimplementedError();
}

void main() {
  final FlutterWhisperkitPlatform initialPlatform =
      FlutterWhisperkitPlatform.instance;

  test('$MethodChannelFlutterWhisperkit is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterWhisperkit>());
  });
}
