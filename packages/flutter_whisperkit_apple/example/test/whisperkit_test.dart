import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisperkit_apple/flutter_whisperkit_apple.dart';
import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FlutterWhisperkitApple whisperKit;

  setUp(() {
    whisperKit = FlutterWhisperkitApple();
  });

  test('initializeWhisperKit should complete successfully', () async {
    try {
      final config = WhisperKitConfig(
        enableVAD: true,
        vadFallbackSilenceThreshold: 600,
        vadTemperature: 0.15,
        enableLanguageIdentification: true,
      );

      final result = await whisperKit.initializeWhisperKit(config: config);
      expect(result, isTrue);
      print('WhisperKit initialized successfully: $result');
    } catch (e) {
      fail('WhisperKit initialization failed with error: $e');
    }
  });
}
