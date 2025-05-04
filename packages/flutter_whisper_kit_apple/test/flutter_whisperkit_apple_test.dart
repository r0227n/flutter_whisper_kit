import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisper_kit/flutter_whisper_kit.dart';
import 'package:flutter_whisper_kit/src/platform_specifics/flutter_whisper_kit_platform_interface.dart';

import 'test_utils/mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FlutterWhisperKit Platform Tests', () {
    test('Platform can be set to mock implementation', () {
      final mockPlatform = setUpMockPlatform();
      expect(FlutterWhisperKitPlatform.instance, mockPlatform);
    });

    test('loadModel returns success message', () async {
      // Arrange
      final mockPlatform = MockFlutterWhisperkitPlatform();
      FlutterWhisperKitPlatform.instance =
          mockPlatform as FlutterWhisperKitPlatform;

      // Act & Assert
      expect(
        await FlutterWhisperKitPlatform.instance.loadModel(
          'tiny-en',
          modelRepo: 'argmaxinc/whisperkit-coreml',
        ),
        'Model loaded',
      );
    });

    test(
      'modelProgressStream emits progress updates',
      () async {
        // Arrange
        final mockPlatform = MockFlutterWhisperkitPlatform();
        FlutterWhisperKitPlatform.instance =
            mockPlatform as FlutterWhisperKitPlatform;

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
