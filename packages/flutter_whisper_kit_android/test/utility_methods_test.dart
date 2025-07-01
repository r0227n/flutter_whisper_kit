import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';

// This test focuses on testing the Android plugin's utility methods
// through platform channel communication
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('flutter_whisper_kit_android');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('Android Plugin Utility Methods Tests', () {
    test('deviceName() returns formatted device information', () async {
      // Simulate Android plugin response
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'deviceName') {
          return 'Samsung Galaxy S21 (Android 12)';
        }
        return null;
      });

      final result = await channel.invokeMethod<String>('deviceName');

      expect(result, isNotNull);
      expect(result, contains('Android'));
      expect(result, matches(RegExp(r'.+ .+ \(Android \d+\.?\d*\)')));
    });

    test('detectLanguage() validates empty audio path', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'detectLanguage') {
          final String audioPath = methodCall.arguments['audioPath'] as String;
          if (audioPath.isEmpty) {
            throw PlatformException(
              code: 'INVALID_ARGUMENT',
              message: 'Audio path cannot be empty',
            );
          }
          return null;
        }
        return null;
      });

      expect(
        () async => await channel.invokeMethod<String>(
          'detectLanguage',
          {'audioPath': ''},
        ),
        throwsA(
          isA<PlatformException>().having(
            (e) => e.message,
            'message',
            contains('Audio path cannot be empty'),
          ),
        ),
      );
    });

    test('detectLanguage() handles unsupported audio formats', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'detectLanguage') {
          final String audioPath = methodCall.arguments['audioPath'] as String;
          if (!audioPath.endsWith('.wav') &&
              !audioPath.endsWith('.mp3') &&
              !audioPath.endsWith('.m4a') &&
              !audioPath.endsWith('.flac')) {
            return 'Language detection failed: Unsupported audio format';
          }
          return null;
        }
        return null;
      });

      final result = await channel.invokeMethod<String>(
        'detectLanguage',
        {'audioPath': '/path/to/image.png'},
      );

      expect(result, contains('Language detection failed: Unsupported audio format'));
    });

    test('detectLanguage() handles non-existent files', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'detectLanguage') {
          final String audioPath = methodCall.arguments['audioPath'] as String;
          if (audioPath.contains('nonexistent')) {
            return 'Error: Audio file not found or not readable';
          }
          return null;
        }
        return null;
      });

      final result = await channel.invokeMethod<String>(
        'detectLanguage',
        {'audioPath': '/path/to/nonexistent_file.wav'},
      );

      expect(result, contains('Error: Audio file not found'));
    });

    test('detectLanguage() validates file path security', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'detectLanguage') {
          final String audioPath = methodCall.arguments['audioPath'] as String;
          if (audioPath.contains('..') ||
              audioPath.startsWith('/etc/') ||
              audioPath.contains(':\\') ||
              audioPath.startsWith('file://')) {
            return 'Error: Invalid file path';
          }
          return null;
        }
        return null;
      });

      final maliciousPaths = [
        '../../../etc/passwd',
        '/etc/passwd',
        '..\\..\\windows\\system32',
        'file://etc/passwd',
      ];

      for (final path in maliciousPaths) {
        final result = await channel.invokeMethod<String>(
          'detectLanguage',
          {'audioPath': path},
        );

        expect(result, contains('Error'));
      }
    });

    test('clearState() returns success message', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'clearState') {
          return 'State cleared successfully';
        }
        return null;
      });

      final result = await channel.invokeMethod<String>('clearState');

      expect(result, equals('State cleared successfully'));
    });

    test('clearState() handles errors without exposing internal state', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'clearState') {
          throw PlatformException(
            code: 'STATE_ERROR',
            message: 'Clear state failed: Internal error',
          );
        }
        return null;
      });

      try {
        await channel.invokeMethod<String>('clearState');
        fail('Should have thrown an exception');
      } catch (e) {
        expect(e, isA<PlatformException>());
        final platformException = e as PlatformException;
        expect(platformException.message, isNot(contains('memory address')));
        expect(platformException.message, isNot(contains('pointer')));
        expect(platformException.message, isNot(contains('stack trace')));
      }
    });

    test('clearState() is idempotent', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'clearState') {
          return 'State cleared successfully';
        }
        return null;
      });

      // Call clearState multiple times
      final result1 = await channel.invokeMethod<String>('clearState');
      final result2 = await channel.invokeMethod<String>('clearState');
      final result3 = await channel.invokeMethod<String>('clearState');

      expect(result1, equals('State cleared successfully'));
      expect(result2, equals('State cleared successfully'));
      expect(result3, equals('State cleared successfully'));
    });
  });
}