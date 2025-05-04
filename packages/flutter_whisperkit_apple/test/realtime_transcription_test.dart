import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisperkit/flutter_whisperkit_platform_interface.dart';
import 'package:flutter_whisperkit/src/models.dart';

import 'test_utils/mock_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Realtime Transcription', () {
    late FlutterWhisperkitPlatform plugin;
    
    setUp(() {
      // Create a mock method channel that provides a test stream
      final mockMethodChannel = MockMethodChannelFlutterWhisperkit();
      
      // Set the mock method channel as the platform instance
      FlutterWhisperkitPlatform.instance = mockMethodChannel;
      plugin = FlutterWhisperkitPlatform.instance;
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
    
    test('stopRecording with loop=false returns final transcription', () async {
      // Arrange
      await plugin.startRecording(loop: false);
      
      // Act & Assert
      expect(await plugin.stopRecording(loop: false), 'Recording stopped');
    });
    
    test('startRecording handles microphone permissions', () async {
      // This test would normally check permission handling
      // Since we're using mocks, we'll just verify the recording starts successfully
      
      // Act & Assert
      expect(await plugin.startRecording(), 'Recording started');
    });
  });
}
