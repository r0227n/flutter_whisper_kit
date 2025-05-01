import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisperkit_apple/flutter_whisperkit_apple.dart';
import 'package:flutter_whisperkit_apple/flutter_whisperkit_apple_method_channel.dart';
import 'package:flutter_whisperkit/flutter_whisperkit_platform_interface.dart';
import 'package:flutter_whisperkit/src/model_loader.dart';
import 'package:flutter_whisperkit/src/models.dart';

import 'test_utils/mocks.dart';
import 'test_utils/mock_whisper_kit_message.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FlutterWhisperkitApple', () {
    final FlutterWhisperkitPlatform initialPlatform = FlutterWhisperkitPlatform.instance;

    test('FlutterWhisperkitApple extends FlutterWhisperkitPlatform', () {
      expect(FlutterWhisperkitApple(), isA<FlutterWhisperkitPlatform>());
    });

    test('loadModel returns success message', () async {
      // Arrange
      final mockWhisperKitMessage = MockWhisperKitMessage();
      final methodChannel = MethodChannelFlutterWhisperkitApple(
        whisperKitMessage: mockWhisperKitMessage
      );
      final flutterWhisperkitApplePlugin = FlutterWhisperkitApple(
        methodChannel: methodChannel
      );
      setUpMockPlatform();
      
      // Act & Assert
      expect(
        await flutterWhisperkitApplePlugin.loadModel(
          'tiny-en',
          modelRepo: 'argmaxinc/whisperkit-coreml',
        ),
        'Model loaded successfully',
      );
    });

    group('WhisperKitModelLoader', () {
      test('loads model and returns success message', () async {
        // Arrange
        setUpMockPlatform();
        final modelLoader = WhisperKitModelLoader();

        // Act & Assert
        expect(
          await modelLoader.loadModel(variant: 'tiny-en'),
          'Model loaded',
        );
      });

      // Test removed as ModelStorageLocation has been removed from the codebase
    });
  });
}
