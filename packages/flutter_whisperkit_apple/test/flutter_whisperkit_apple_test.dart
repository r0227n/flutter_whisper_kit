import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisperkit/flutter_whisperkit_platform_interface.dart';
import 'package:flutter_whisperkit_apple/flutter_whisperkit_apple.dart';
import 'package:flutter_whisperkit_apple/flutter_whisperkit_apple_method_channel.dart';
import 'package:flutter_whisperkit_apple/model_loader.dart';

import 'test_utils/mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FlutterWhisperkitApple', () {
    // Register the Apple implementation before running tests
    setUpAll(() {
      FlutterWhisperkitApple.registerWith();
    });

    test('platform interface uses method channel by default', () {
      final platform = FlutterWhisperkitPlatform.instance;
      expect(platform, isInstanceOf<MethodChannelFlutterWhisperkitApple>());
    });

    test('loadModel returns success message', () async {
      // Arrange
      FlutterWhisperkitApple flutterWhisperkitApplePlugin = FlutterWhisperkitApple();
      MockFlutterWhisperkitPlatform fakePlatform = setUpMockPlatform();
      
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
