import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisperkit_apple/flutter_whisperkit_apple.dart';
import 'package:flutter_whisperkit_apple/flutter_whisperkit_apple_method_channel.dart';
import 'package:flutter_whisperkit/flutter_whisperkit_platform_interface.dart';
import 'package:flutter_whisperkit/src/model_loader.dart';
import 'package:flutter_whisperkit/src/models.dart';

import 'test_utils/mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FlutterWhisperkitApple', () {
    final FlutterWhisperkitPlatform initialPlatform = FlutterWhisperkitPlatform.instance;

    test('FlutterWhisperkitApple extends FlutterWhisperkitPlatform', () {
      expect(FlutterWhisperkitApple(), isA<FlutterWhisperkitPlatform>());
    });

    test('loadModel returns success message', () async {
      // Arrange
      FlutterWhisperkitApple flutterWhisperkitApplePlugin = FlutterWhisperkitApple();
      setUpMockPlatform();
      
      // Act & Assert
      expect(
        await flutterWhisperkitApplePlugin.loadModel(
          'tiny-en',
          modelRepo: 'argmaxinc/whisperkit-coreml',
        ),
        'Model loaded',
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

      test('can change storage location', () async {
        // Arrange
        setUpMockPlatform();
        final modelLoader = WhisperKitModelLoader();
        
        // Act
        modelLoader.setStorageLocation(ModelStorageLocation.userFolder);
        
        // Assert
        expect(modelLoader.storageLocation, ModelStorageLocation.userFolder);
      });
    });
  });
}
