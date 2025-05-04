import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisperkit/flutter_whisperkit.dart';
import 'package:flutter_whisperkit/flutter_whisperkit_platform_interface.dart';
import 'package:flutter_whisperkit/flutter_whisperkit_method_channel.dart';
import 'package:flutter_whisperkit/src/models.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'test_utils/mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('FlutterWhisperkit', () {
    final FlutterWhisperkitPlatform initialPlatform =
        FlutterWhisperkitPlatform.instance;

    test('$MethodChannelFlutterWhisperkit is the default instance', () {
      expect(initialPlatform, isInstanceOf<MethodChannelFlutterWhisperkit>());
    });
    
    test('FlutterWhisperkit is accessible', () {
      expect(FlutterWhisperkit(), isNotNull);
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
