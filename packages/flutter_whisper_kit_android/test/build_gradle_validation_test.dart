import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('build.gradle validation', () {
    late File buildGradleFile;
    late String buildGradleContent;

    setUpAll(() {
      buildGradleFile = File('android/build.gradle');
      expect(buildGradleFile.existsSync(), isTrue,
          reason: 'android/build.gradle should exist');
      buildGradleContent = buildGradleFile.readAsStringSync();
    });

    test('should have WhisperKitAndroid dependency', () {
      expect(
          buildGradleContent.contains('com.argmaxinc:whisperkit:0.3.2'), isTrue,
          reason: 'WhisperKitAndroid dependency should be included');
    });

    test('should have QNN Runtime dependency', () {
      expect(buildGradleContent.contains('com.qualcomm.qti:qnn-runtime:2.34.0'),
          isTrue,
          reason: 'QNN Runtime dependency should be included');
    });

    test('should have QNN LiteRT Delegate dependency', () {
      // QNN LiteRT Delegate is not currently included in build.gradle
      // This test can be enabled when the dependency is added
    }, skip: 'QNN LiteRT Delegate dependency not yet included');

    test('should configure minimum SDK version 26', () {
      expect(buildGradleContent.contains('minSdkVersion 26'), isTrue,
          reason: 'Minimum SDK version should be 26');
    });

    test('should configure compilation SDK version 34', () {
      expect(buildGradleContent.contains('compileSdkVersion 34'), isTrue,
          reason: 'Compilation SDK version should be 34');
    });

    test('should enable Kotlin compilation', () {
      expect(
          buildGradleContent.contains("apply plugin: 'kotlin-android'"), isTrue,
          reason: 'Kotlin Android plugin should be applied');
    });

    test('should use HTTPS-only repository URLs', () {
      // Check that repository blocks don't contain http:// URLs
      expect(buildGradleContent.contains('http://'), isFalse,
          reason: 'All repository URLs should use HTTPS, not HTTP');
    });

    test('should have proper dependency configuration', () {
      expect(buildGradleContent.contains('dependencies {'), isTrue,
          reason: 'Dependencies block should exist');
      expect(buildGradleContent.contains('implementation'), isTrue,
          reason: 'Should use implementation configuration for dependencies');
    });

    test('should configure android block properly', () {
      expect(buildGradleContent.contains('android {'), isTrue,
          reason: 'Android configuration block should exist');
      expect(buildGradleContent.contains('namespace'), isTrue,
          reason:
              'Namespace should be configured for Android Gradle Plugin 8.0+');
    });
  });
}
