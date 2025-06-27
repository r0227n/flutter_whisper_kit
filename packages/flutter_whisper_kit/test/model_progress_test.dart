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

    test('modelProgressStream emits progress updates', () async {
      // Arrange
      const expectedProgress = Progress(
        fractionCompleted: 0.5,
        completedUnitCount: 50,
        totalUnitCount: 100,
      );
      
      // Act
      final stream = platform.modelProgressStream;
      
      // Emit test data
      platform.emitProgressUpdates();

      // Assert
      expect(
        stream,
        emitsInOrder([
          predicate<Progress>((progress) => progress.fractionCompleted == 0.25),
          predicate<Progress>((progress) => 
              progress.totalUnitCount == 100 &&
              progress.completedUnitCount == 50 &&
              progress.fractionCompleted == 0.5),
          predicate<Progress>((progress) => progress.fractionCompleted == 1.0),
        ]),
      );
    });
  });
}
