import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisperkit/flutter_whisperkit_platform_interface.dart';
import 'package:flutter_whisperkit/src/models.dart';

import 'test_utils/mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Model Progress Streaming', () {
    late FlutterWhisperkitPlatform platform;
    
    setUp(() {
      platform = setUpMockPlatform();
    });

    test('modelProgressStream emits progress updates', () async {
      // Act
      final stream = platform.modelProgressStream;
      
      // Assert
      expect(stream, emitsThrough(predicate<Progress>(
        (progress) => 
            progress.totalUnitCount == 100 && 
            progress.completedUnitCount == 50 &&
            progress.fractionCompleted == 0.5,
      )));
    });
  });
}
