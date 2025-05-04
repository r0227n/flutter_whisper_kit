import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisperkit/flutter_whisperkit_platform_interface.dart';
import 'package:flutter_whisperkit/src/model_loader.dart';
import 'package:flutter_whisperkit/src/models.dart';

import 'test_utils/mocks.dart';
import 'test_utils/mock_whisper_kit_message.dart';
import 'test_utils/mock_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FlutterWhisperkit Platform Tests', () {
    final FlutterWhisperkitPlatform initialPlatform =
        FlutterWhisperkitPlatform.instance;

    test('Platform can be set to mock implementation', () {
      final mockPlatform = setUpMockPlatform();
      expect(FlutterWhisperkitPlatform.instance, mockPlatform);
    });

    test('loadModel returns success message', () async {
      // Arrange
      final mockMethodChannel = MockMethodChannelFlutterWhisperkit();
      FlutterWhisperkitPlatform.instance = mockMethodChannel;

      // Act & Assert
      expect(
        await FlutterWhisperkitPlatform.instance.loadModel(
          'tiny-en',
          modelRepo: 'argmaxinc/whisperkit-coreml',
        ),
        'Model loaded successfully',
      );
    });
    
    test('modelProgressStream emits progress updates', () async {
      // Arrange
      final mockMethodChannel = MockMethodChannelFlutterWhisperkit();
      FlutterWhisperkitPlatform.instance = mockMethodChannel;
      
      // Act
      final progressStream = FlutterWhisperkitPlatform.instance.modelProgressStream;
      
      // Assert
      expect(
        progressStream,
        emitsThrough(
          predicate<Progress>(
            (progress) => progress.fractionCompleted == 1.0 && !progress.isIndeterminate,
          ),
        ),
      );
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
