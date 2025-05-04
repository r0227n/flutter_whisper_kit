import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisper_kit/flutter_whisper_kit.dart';
import 'package:flutter_whisper_kit/src/platform_specifics/flutter_whisper_kit_method_channel.dart';
import 'package:flutter_whisper_kit/src/platform_specifics/flutter_whisper_kit_platform_interface.dart';

import 'test_utils/mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FlutterWhisperKit', () {
    final FlutterWhisperKitPlatform initialPlatform =
        FlutterWhisperKitPlatform.instance;

    test('$MethodChannelFlutterWhisperKit is the default instance', () {
      expect(initialPlatform, isInstanceOf<MethodChannelFlutterWhisperKit>());
    });

    test('FlutterWhisperKit is accessible', () {
      expect(FlutterWhisperKit(), isNotNull);
    });

    group('WhisperKitModelLoader', () {
      test('loads model and returns success message', () async {
        // Arrange
        setUpMockPlatform();
        final modelLoader = WhisperKitModelLoader();

        // Act & Assert
        expect(await modelLoader.loadModel(variant: 'tiny-en'), 'Model loaded');
      });
    });
  });
}
