import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisperkit_apple/flutter_whisperkit_apple.dart';
import 'package:flutter_whisperkit_apple/flutter_whisperkit_apple_method_channel.dart';
import 'package:flutter_whisperkit/flutter_whisperkit_platform_interface.dart';
import 'package:flutter_whisperkit/src/models.dart';

import 'test_utils/mocks.dart';
import 'test_utils/mock_whisper_kit_message.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Realtime Transcription', () {
    late FlutterWhisperkitApple plugin;
    
    group('Platform Interface', () {
      test('FlutterWhisperkitApple extends FlutterWhisperkitPlatform', () {
        // Assert
        expect(FlutterWhisperkitApple(), isA<FlutterWhisperkitPlatform>());
      });
    });

    setUp(() {
      // Create a method channel with mock WhisperKitMessage
      final mockWhisperKitMessage = MockWhisperKitMessage();
      final methodChannel = MethodChannelFlutterWhisperkitApple(
        whisperKitMessage: mockWhisperKitMessage
      );
      
      // Create plugin instance with mock method channel
      plugin = FlutterWhisperkitApple(methodChannel: methodChannel);
      
      // Set up mock platform interface
      setUpMockPlatform();
    });

    test('startRecording initiates audio recording with default options', () async {
      // Act & Assert
      expect(await plugin.startRecording(), 'Recording started');
    });

    test('startRecording initiates audio recording with custom options', () async {
      // Arrange
      final options = DecodingOptions(
        language: 'en',
        temperature: 0.5,
        wordTimestamps: true,
      );
      
      // Act & Assert
      expect(await plugin.startRecording(options: options), 'Recording started');
    });

    test('stopRecording ends audio recording', () async {
      // Act & Assert
      expect(await plugin.stopRecording(), 'Recording stopped');
    });

    test('transcriptionStream emits transcription results', () async {
      // Act
      final stream = plugin.transcriptionStream;
      
      // Assert
      expect(stream, emitsThrough(predicate<TranscriptionResult>(
        (result) => result.text == 'Test transcription' && result.language == 'en',
      )));
    });
  });
}
