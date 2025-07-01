import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

void main() {
  group('pubspec.yaml validation', () {
    late File pubspecFile;
    late Map pubspec;

    setUpAll(() {
      pubspecFile = File('pubspec.yaml');
      expect(pubspecFile.existsSync(), isTrue,
          reason: 'pubspec.yaml should exist');
      final content = pubspecFile.readAsStringSync();
      pubspec = loadYaml(content) as Map;
    });

    test('should have correct package name', () {
      expect(pubspec['name'], equals('flutter_whisper_kit_android'));
    });

    test('should have correct version', () {
      expect(pubspec['version'], equals('0.1.0'));
    });

    test('should have proper description', () {
      expect(pubspec['description'], isNotNull);
      expect(pubspec['description'].toString().length, greaterThan(10),
          reason: 'Description should be meaningful');
    });

    test('should have repository and issue_tracker URLs', () {
      expect(pubspec['repository'], isNotNull,
          reason: 'Repository URL should be specified');
      expect(pubspec['repository'],
          equals('https://github.com/r0227n/flutter_whisper_kit'));
      expect(pubspec['issue_tracker'], isNotNull,
          reason: 'Issue tracker URL should be specified');
      expect(pubspec['issue_tracker'],
          equals('https://github.com/r0227n/flutter_whisper_kit/issues'));
    });

    test('should have flutter_lints in dev_dependencies', () {
      expect(pubspec['dev_dependencies'], isNotNull);
      expect(pubspec['dev_dependencies']['flutter_lints'], isNotNull,
          reason: 'flutter_lints should be in dev_dependencies');
      // Check version is ^4.0.0 or higher
      final version = pubspec['dev_dependencies']['flutter_lints'].toString();
      expect(version, matches(r'^\^[4-9]\.\d+\.\d+'),
          reason: 'flutter_lints should be version ^4.0.0 or higher');
    });

    test('should have correct plugin configuration', () {
      expect(pubspec['flutter'], isNotNull);
      expect(pubspec['flutter']['plugin'], isNotNull);
      expect(pubspec['flutter']['plugin']['platforms'], isNotNull);
      expect(pubspec['flutter']['plugin']['platforms']['android'], isNotNull);

      final androidConfig =
          pubspec['flutter']['plugin']['platforms']['android'];
      expect(androidConfig['package'], equals('flutter_whisper_kit_android'));
      expect(androidConfig['pluginClass'],
          equals('FlutterWhisperKitAndroidPlugin'));
    });

    test('should have flutter_whisper_kit dependency', () {
      expect(pubspec['dependencies'], isNotNull);
      expect(pubspec['dependencies']['flutter_whisper_kit'], isNotNull);
      expect(pubspec['dependencies']['flutter_whisper_kit']['path'],
          equals('../flutter_whisper_kit'));
    });
  });
}
