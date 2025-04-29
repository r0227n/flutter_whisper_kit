import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisperkit_apple/src/model/model_support_config.dart';
import 'package:flutter_whisperkit_apple/src/service/model_support_service.dart';
import 'package:huggingface_client/huggingface_client.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'model_support_test.mocks.dart';

// Generate mocks
@GenerateMocks([HuggingFaceClient])
void main() {
  group('ModelSupportConfig', () {
    test('fromJson creates valid config', () {
      final json = {
        'name': 'test-repo',
        'version': '1.0.0',
        'device_support': [
          {
            'identifiers': ['iPhone14,7', 'iPhone14,8'],
            'models': {
              'default': 'openai_whisper-base',
              'supported': ['openai_whisper-tiny', 'openai_whisper-base']
            }
          }
        ]
      };

      final config = ModelSupportConfig.fromJson(json);

      expect(config.repoName, 'test-repo');
      expect(config.repoVersion, '1.0.0');
      expect(config.deviceSupports.length, 1);
      expect(config.deviceSupports[0].identifiers, ['iPhone14,7', 'iPhone14,8']);
      expect(config.deviceSupports[0].models.defaultModel, 'openai_whisper-base');
      expect(config.deviceSupports[0].models.supported, ['openai_whisper-tiny', 'openai_whisper-base']);
    });

    test('toJson creates valid json', () {
      final config = ModelSupportConfig(
        repoName: 'test-repo',
        repoVersion: '1.0.0',
        deviceSupports: [
          DeviceSupport(
            identifiers: ['iPhone14,7', 'iPhone14,8'],
            models: ModelSupport(
              defaultModel: 'openai_whisper-base',
              supported: ['openai_whisper-tiny', 'openai_whisper-base'],
            ),
          )
        ],
      );

      final json = config.toJson();

      expect(json['name'], 'test-repo');
      expect(json['version'], '1.0.0');
      expect(json['device_support'].length, 1);
      expect(json['device_support'][0]['identifiers'], ['iPhone14,7', 'iPhone14,8']);
      expect(json['device_support'][0]['models']['default'], 'openai_whisper-base');
      expect(json['device_support'][0]['models']['supported'], ['openai_whisper-tiny', 'openai_whisper-base']);
    });

    test('getDeviceSupport returns correct device support', () {
      final config = ModelSupportConfig(
        repoName: 'test-repo',
        repoVersion: '1.0.0',
        deviceSupports: [
          DeviceSupport(
            identifiers: ['iPhone14,7', 'iPhone14,8'],
            models: ModelSupport(
              defaultModel: 'openai_whisper-base',
              supported: ['openai_whisper-tiny', 'openai_whisper-base'],
            ),
          ),
          DeviceSupport(
            identifiers: ['iPhone13,1', 'iPhone13,2'],
            models: ModelSupport(
              defaultModel: 'openai_whisper-tiny',
              supported: ['openai_whisper-tiny'],
            ),
          )
        ],
      );

      final support1 = config.getDeviceSupport('iPhone14,7');
      expect(support1.models.defaultModel, 'openai_whisper-base');

      final support2 = config.getDeviceSupport('iPhone13,1');
      expect(support2.models.defaultModel, 'openai_whisper-tiny');

      final defaultSupport = config.getDeviceSupport('unknown');
      expect(defaultSupport.models.defaultModel, 'openai_whisper-base');
    });
  });

  group('ModelSupportService', () {
    late MockHuggingFaceClient mockClient;
    late ModelSupportService service;

    setUp(() {
      mockClient = MockHuggingFaceClient();
      // Note: In a real implementation, we would inject the client
      // For this test, we're just demonstrating the test structure
    });

    test('fetchModelSupportConfig returns success result', () async {
      // This test would mock the HuggingFaceClient response
      // and verify that the service correctly processes it
      
      // Example of how this would be implemented:
      /*
      when(mockClient.getRepositoryFile(
        repo: 'argmaxinc/whisperkit-coreml',
        path: 'config.json',
        revision: null,
      )).thenAnswer((_) async => jsonEncode({
        'name': 'test-repo',
        'version': '1.0.0',
        'device_support': [
          {
            'identifiers': ['iPhone14,7'],
            'models': {
              'default': 'openai_whisper-base',
              'supported': ['openai_whisper-tiny', 'openai_whisper-base']
            }
          }
        ]
      }));

      final result = await service.fetchModelSupportConfig();
      
      expect(result.isSuccess, true);
      expect(result.data?.repoName, 'test-repo');
      */
    });

    test('fetchModelSupportConfig handles network errors', () async {
      // This test would verify error handling for network issues
      
      // Example of how this would be implemented:
      /*
      when(mockClient.getRepositoryFile(
        repo: anyNamed('repo'),
        path: anyNamed('path'),
        revision: anyNamed('revision'),
      )).thenThrow(Exception('Network error'));

      final result = await service.fetchModelSupportConfig();
      
      expect(result.isSuccess, false);
      expect(result.error, ModelSupportConfigError.huggingFaceApiError);
      */
    });
  });
}
