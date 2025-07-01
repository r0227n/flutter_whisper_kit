import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// F.I.R.S.T. Principles Test for flutter_whisper_kit_android Package Structure
///
/// F - Fast: < 0.1 seconds execution
/// I - Independent: No dependencies between tests
/// R - Repeatable: Consistent results across environments
/// S - Self-validating: Clear pass/fail outcomes
/// T - Timely: Written before implementation (Red phase)
void main() {
  group('FlutterWhisperKitAndroidPlugin', () {
    test('should have plugin class file in correct location', () {
      final pluginFile = File(
          'android/src/main/kotlin/flutter_whisper_kit_android/FlutterWhisperKitAndroidPlugin.kt');
      expect(pluginFile.existsSync(), isTrue,
          reason:
              'FlutterWhisperKitAndroidPlugin.kt should exist in correct directory');
    });

    test('should have proper package declaration', () {
      final pluginFile = File(
          'android/src/main/kotlin/flutter_whisper_kit_android/FlutterWhisperKitAndroidPlugin.kt');
      if (pluginFile.existsSync()) {
        final content = pluginFile.readAsStringSync();
        expect(
            content.contains('package flutter_whisper_kit_android'),
            isTrue,
            reason: 'Plugin should have correct package declaration');
      }
    });

    test('should implement FlutterPlugin interface', () {
      final pluginFile = File(
          'android/src/main/kotlin/flutter_whisper_kit_android/FlutterWhisperKitAndroidPlugin.kt');
      if (pluginFile.existsSync()) {
        final content = pluginFile.readAsStringSync();
        expect(content.contains('FlutterPlugin'), isTrue,
            reason: 'Plugin should implement FlutterPlugin interface');
        expect(content.contains('MethodCallHandler'), isTrue,
            reason: 'Plugin should implement MethodCallHandler interface');
      }
    });

    test('should have required lifecycle methods', () {
      final pluginFile = File(
          'android/src/main/kotlin/flutter_whisper_kit_android/FlutterWhisperKitAndroidPlugin.kt');
      if (pluginFile.existsSync()) {
        final content = pluginFile.readAsStringSync();
        expect(content.contains('onAttachedToEngine'), isTrue,
            reason: 'Plugin should have onAttachedToEngine method');
        expect(content.contains('onDetachedFromEngine'), isTrue,
            reason: 'Plugin should have onDetachedFromEngine method');
        expect(content.contains('onMethodCall'), isTrue,
            reason: 'Plugin should have onMethodCall method');
      }
    });

    test('should use correct channel name', () {
      final pluginFile = File(
          'android/src/main/kotlin/flutter_whisper_kit_android/FlutterWhisperKitAndroidPlugin.kt');
      if (pluginFile.existsSync()) {
        final content = pluginFile.readAsStringSync();
        expect(content.contains('flutter_whisper_kit_android'), isTrue,
            reason: 'Plugin should use correct method channel name');
      }
    });

    test('should have proper class name', () {
      final pluginFile = File(
          'android/src/main/kotlin/flutter_whisper_kit_android/FlutterWhisperKitAndroidPlugin.kt');
      if (pluginFile.existsSync()) {
        final content = pluginFile.readAsStringSync();
        expect(content.contains('class FlutterWhisperKitAndroidPlugin'), isTrue,
            reason: 'Plugin should have correct class name');
      }
    });
  });
}
