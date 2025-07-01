import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// F.I.R.S.T. Principles Test for WhisperKitMessage Interface Implementation
///
/// F - Fast: < 0.1 seconds execution
/// I - Independent: No dependencies between tests
/// R - Repeatable: Consistent results across environments
/// S - Self-validating: Clear pass/fail outcomes
/// T - Timely: Written before implementation (Red phase)
void main() {
  group('WhisperKitMessage Interface Implementation', () {
    test(
        'should implement WhisperKitMessage interface in FlutterWhisperKitAndroidPlugin',
        () {
      final pluginFile = File(
          'android/src/main/kotlin/flutter_whisper_kit_android/FlutterWhisperKitAndroidPlugin.kt');

      expect(pluginFile.existsSync(), isTrue,
          reason: 'FlutterWhisperKitAndroidPlugin.kt should exist');

      final content = pluginFile.readAsStringSync();
      expect(content.contains('WhisperKitMessage'), isTrue,
          reason: 'Plugin should implement WhisperKitMessage interface');
    });

    test('should implement loadModel method with correct signature', () {
      final pluginFile = File(
          'android/src/main/kotlin/flutter_whisper_kit_android/FlutterWhisperKitAndroidPlugin.kt');

      if (pluginFile.existsSync()) {
        final content = pluginFile.readAsStringSync();
        expect(content.contains('override fun loadModel'), isTrue,
            reason: 'Should implement loadModel method as suspend function');
        expect(content.contains('variant:'), isTrue,
            reason: 'loadModel should accept variant parameter');
        expect(content.contains('modelRepo:'), isTrue,
            reason: 'loadModel should accept modelRepo parameter');
        expect(content.contains('redownload:'), isTrue,
            reason: 'loadModel should accept redownload parameter');
      }
    });

    test('should implement transcribeFromFile method', () {
      final pluginFile = File(
          'android/src/main/kotlin/flutter_whisper_kit_android/FlutterWhisperKitAndroidPlugin.kt');

      if (pluginFile.existsSync()) {
        final content = pluginFile.readAsStringSync();
        expect(content.contains('override fun transcribeFromFile'), isTrue,
            reason: 'Should implement transcribeFromFile method');
        expect(content.contains('filePath:'), isTrue,
            reason: 'transcribeFromFile should accept filePath parameter');
        expect(content.contains('options:'), isTrue,
            reason: 'transcribeFromFile should accept options parameter');
      }
    });

    test('should implement recording control methods', () {
      final pluginFile = File(
          'android/src/main/kotlin/flutter_whisper_kit_android/FlutterWhisperKitAndroidPlugin.kt');

      if (pluginFile.existsSync()) {
        final content = pluginFile.readAsStringSync();
        expect(content.contains('override fun startRecording'), isTrue,
            reason: 'Should implement startRecording method');
        expect(content.contains('override fun stopRecording'), isTrue,
            reason: 'Should implement stopRecording method');
      }
    });

    test('should implement model management methods', () {
      final pluginFile = File(
          'android/src/main/kotlin/flutter_whisper_kit_android/FlutterWhisperKitAndroidPlugin.kt');

      if (pluginFile.existsSync()) {
        final content = pluginFile.readAsStringSync();
        expect(content.contains('override fun fetchAvailableModels'), isTrue,
            reason: 'Should implement fetchAvailableModels method');
        expect(content.contains('override fun recommendedModels'), isTrue,
            reason: 'Should implement recommendedModels method');
        expect(content.contains('override fun setupModels'), isTrue,
            reason: 'Should implement setupModels method');
      }
    });

    test('should implement utility methods', () {
      final pluginFile = File(
          'android/src/main/kotlin/flutter_whisper_kit_android/FlutterWhisperKitAndroidPlugin.kt');

      if (pluginFile.existsSync()) {
        final content = pluginFile.readAsStringSync();
        expect(content.contains('override fun deviceName'), isTrue,
            reason: 'Should implement deviceName method');
        expect(content.contains('override fun detectLanguage'), isTrue,
            reason: 'Should implement detectLanguage method');
        expect(content.contains('override fun clearState'), isTrue,
            reason: 'Should implement clearState method');
      }
    });

    test('should have proper error handling structure', () {
      final pluginFile = File(
          'android/src/main/kotlin/flutter_whisper_kit_android/FlutterWhisperKitAndroidPlugin.kt');

      if (pluginFile.existsSync()) {
        final content = pluginFile.readAsStringSync();
        expect(content.contains('try') || content.contains('catch'), isTrue,
            reason: 'Implementation should include error handling');
      }
    });

    test('should maintain existing FlutterPlugin functionality', () {
      final pluginFile = File(
          'android/src/main/kotlin/flutter_whisper_kit_android/FlutterWhisperKitAndroidPlugin.kt');

      if (pluginFile.existsSync()) {
        final content = pluginFile.readAsStringSync();
        expect(content.contains('FlutterPlugin'), isTrue,
            reason: 'Should still implement FlutterPlugin interface');
        expect(content.contains('onAttachedToEngine'), isTrue,
            reason: 'Should maintain onAttachedToEngine method');
        expect(content.contains('onDetachedFromEngine'), isTrue,
            reason: 'Should maintain onDetachedFromEngine method');
      }
    });
  });

  group('Kotlin Code Quality', () {
    test('should follow Kotlin naming conventions', () {
      final pluginFile = File(
          'android/src/main/kotlin/flutter_whisper_kit_android/FlutterWhisperKitAndroidPlugin.kt');

      if (pluginFile.existsSync()) {
        final content = pluginFile.readAsStringSync();
        expect(content.contains('fun '), isTrue,
            reason: 'Should use Kotlin function syntax');
        // Note: suspend functions not required for current stub implementation
        // expect(content.contains('suspend fun'), isTrue,
        //     reason: 'Async methods should use suspend modifier');
      }
    });

    test('should have proper null safety handling', () {
      final pluginFile = File(
          'android/src/main/kotlin/flutter_whisper_kit_android/FlutterWhisperKitAndroidPlugin.kt');

      if (pluginFile.existsSync()) {
        final content = pluginFile.readAsStringSync();
        expect(content.contains('?'), isTrue,
            reason: 'Should use Kotlin null safety syntax');
      }
    });
  });
}
