import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisper_kit/flutter_whisperkit_platform_interface.dart';
import 'package:flutter_whisper_kit/src/model_loader.dart';
import 'package:flutter_whisper_kit/src/models.dart';

import 'test_utils/mocks.dart';
import 'test_utils/mock_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FlutterWhisperKit Platform Tests', () {
    test('Platform can be set to mock implementation', () {
      final mockPlatform = setUpMockPlatform();
      expect(FlutterWhisperKitPlatform.instance, mockPlatform);
    });

    test('loadModel returns success message', () async {
      // Arrange
      final mockMethodChannel = MockMethodChannelFlutterWhisperkit();
      FlutterWhisperKitPlatform.instance = mockMethodChannel;

      // Act & Assert
      expect(
        await FlutterWhisperKitPlatform.instance.loadModel(
          'tiny-en',
          modelRepo: 'argmaxinc/whisperkit-coreml',
        ),
        'Model loaded successfully',
      );
    });

    test(
      'modelProgressStream emits progress updates',
      () async {
        // Arrange
        final mockMethodChannel = MockMethodChannelFlutterWhisperkit();
        FlutterWhisperKitPlatform.instance = mockMethodChannel;

        // Act
        final progressStream =
            FlutterWhisperKitPlatform.instance.modelProgressStream;

        // Trigger model loading to generate progress updates
        FlutterWhisperKitPlatform.instance.loadModel('tiny-en');

        // Assert
        expect(
          progressStream,
          emitsThrough(
            predicate<Progress>(
              (progress) =>
                  progress.fractionCompleted == 1.0 &&
                  !progress.isIndeterminate,
            ),
          ),
        );
      },
      timeout: const Timeout(Duration(seconds: 5)),
    );

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
