import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisperkit/flutter_whisperkit.dart';
import 'package:flutter_whisperkit/src/model_loader.dart';
import 'package:flutter_whisperkit/src/models.dart';

import 'test_utils/mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WhisperKitModelLoader', () {
    setUp(() {
      setUpMockPlatform();
    });

    test('loadModel returns success message', () async {
      // Arrange
      final modelLoader = WhisperKitModelLoader();
      
      // Act & Assert
      expect(
        await modelLoader.loadModel(variant: 'tiny-en'),
        'Model loaded',
      );
    });
    
    test('loadModel with custom parameters returns success message', () async {
      // Arrange
      final modelLoader = WhisperKitModelLoader();
      
      // Act & Assert
      expect(
        await modelLoader.loadModel(
          variant: 'base',
          modelRepo: 'argmaxinc/whisperkit-coreml',
          redownload: true,
          storageLocation: ModelStorageLocation.applicationSupport,
        ),
        'Model loaded',
      );
    });
  });
}
