import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_whisper_kit/src/models.dart';

import 'test_utils/mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Model Progress Streaming', () {
    late MockFlutterWhisperkitPlatform platform;

    setUp(() {
      platform = setUpMockPlatform();
    });

    tearDown(() {
      platform.progressController.close();
    });

    test('modelProgressStream emits progress updates', () async {
      // Arrange
      final stream = platform.modelProgressStream;
      final firstProgressFuture = stream.first;

      // Act
      platform.emitProgressUpdates();

      // Assert
      final firstProgress = await firstProgressFuture;
      expect(firstProgress.fractionCompleted, 0.25);

      expectLater(
        stream,
        emitsInOrder([
          predicate<Progress>((progress) => progress.fractionCompleted == 0.5),
          predicate<Progress>((progress) => progress.fractionCompleted == 1.0),
        ]),
      );
    });
  });
}
