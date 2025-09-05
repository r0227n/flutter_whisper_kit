# ADR-003: Testing Approach

## Status

Accepted

## Date

2024-12-29

## Context

The Flutter WhisperKit plugin required a comprehensive testing strategy to ensure reliability across multiple platforms and complex audio processing workflows. Key challenges included:

1. **Platform-specific testing**: Different behavior on iOS/macOS
2. **Audio processing complexity**: Real-time recording and transcription
3. **Asynchronous operations**: Model loading, downloads, streaming
4. **Hardware dependencies**: Microphone access, audio sessions
5. **Network dependencies**: Model downloads from remote repositories
6. **Integration complexity**: Multiple components working together

The existing testing approach had several limitations:

- Scattered test utilities and mocks
- Inconsistent testing patterns across packages
- Limited coverage of error scenarios
- Difficulty testing platform-specific features

## Decision

We implemented a **Multi-Layer Testing Strategy** with standardized utilities and comprehensive coverage:

### 1. Testing Pyramid Structure

```
                    ┌─────────────────┐
                    │ E2E Tests (10%) │  ← Integration tests with real hardware
                    └─────────────────┘
                  ┌───────────────────────┐
                  │ Integration Tests (20%) │  ← Component interaction tests
                  └───────────────────────┘
              ┌─────────────────────────────────┐
              │    Unit Tests (70%)             │  ← Individual component tests
              └─────────────────────────────────┘
```

### 2. Standardized Test Utilities

#### Shared Mock Platform

```dart
// packages/flutter_whisper_kit/test/test_utils/mocks.dart
class MockFlutterWhisperkitPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements FlutterWhisperKitPlatform {

  final StreamController<TranscriptionResult> transcriptionController;
  final StreamController<Progress> progressController;

  MockFlutterWhisperkitPlatform() :
    transcriptionController = StreamController.broadcast(),
    progressController = StreamController.broadcast();
}

MockFlutterWhisperkitPlatform setUpMockPlatform() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final mockPlatform = MockFlutterWhisperkitPlatform();
  FlutterWhisperKitPlatform.instance = mockPlatform;
  return mockPlatform;
}
```

#### Test Data Factories

```dart
class TestDataFactory {
  static TranscriptionResult createTranscriptionResult({
    String text = 'Hello world',
    String language = 'en',
    List<TranscriptionSegment>? segments,
  }) {
    return TranscriptionResult(
      text: text,
      language: language,
      segments: segments ?? [createTranscriptionSegment()],
    );
  }

  static Progress createProgress({
    double fractionCompleted = 0.5,
    int completedUnitCount = 50,
    int totalUnitCount = 100,
  }) {
    return Progress(
      fractionCompleted: fractionCompleted,
      completedUnitCount: completedUnitCount,
      totalUnitCount: totalUnitCount,
    );
  }
}
```

### 3. Test Categories and Organization

#### Unit Tests (70% of test suite)

```
test/
├── models/
│   ├── transcription_result_test.dart
│   ├── decoding_options_test.dart
│   └── progress_test.dart
├── error_handling/
│   ├── whisper_kit_error_test.dart
│   ├── error_recovery_test.dart
│   └── error_constants_test.dart
├── streams/
│   ├── transcription_stream_test.dart
│   └── buffered_stream_test.dart
└── api/
    ├── result_api_test.dart
    └── traditional_api_test.dart
```

#### Integration Tests (20% of test suite)

```
test/
├── integration/
│   ├── result_api_integration_test.dart
│   ├── platform_channel_test.dart
│   └── stream_management_test.dart
└── workflows/
    ├── model_loading_workflow_test.dart
    ├── transcription_workflow_test.dart
    └── recording_workflow_test.dart
```

#### End-to-End Tests (10% of test suite)

```
integration_test/
├── whisper_kit_e2e_test.dart
├── platform_specific/
│   ├── ios_specific_test.dart
│   └── macos_specific_test.dart
└── performance/
    └── performance_benchmark_test.dart
```

### 4. Result Pattern Testing Strategy

#### Testing Success Cases

```dart
group('Result API Success Cases', () {
  testWidgets('loadModelWithResult returns success', (tester) async {
    // Arrange
    mockPlatform.mockLoadModel(result: '/path/to/model');

    // Act
    final result = await whisperKit.loadModelWithResult('tiny');

    // Assert
    expect(result, isA<Success<String, WhisperKitError>>());
    result.when(
      success: (path) => expect(path, '/path/to/model'),
      failure: (error) => fail('Expected success but got: $error'),
    );
  });
});
```

#### Testing Error Cases

```dart
group('Result API Error Cases', () {
  testWidgets('loadModelWithResult handles platform errors', (tester) async {
    // Arrange
    final platformError = WhisperKitError(code: 1001, message: 'Model not found');
    mockPlatform.mockLoadModelError(error: platformError);

    // Act
    final result = await whisperKit.loadModelWithResult('invalid');

    // Assert
    expect(result, isA<Failure<String, WhisperKitError>>());
    result.when(
      success: (path) => fail('Expected failure but got success: $path'),
      failure: (error) {
        expect(error.code, 1001);
        expect(error.message, 'Model not found');
      },
    );
  });
});
```

### 5. Stream Testing Patterns

#### Real-time Transcription Testing

```dart
group('Transcription Stream', () {
  testWidgets('emits transcription results', (tester) async {
    // Arrange
    final expectedResults = [
      TestDataFactory.createTranscriptionResult(text: 'Hello'),
      TestDataFactory.createTranscriptionResult(text: 'World'),
    ];

    // Act
    final streamResults = <TranscriptionResult>[];
    final subscription = whisperKit.transcriptionStream.listen(
      streamResults.add,
    );

    // Simulate platform events
    for (final result in expectedResults) {
      mockPlatform.emitTranscriptionResult(result);
      await tester.pump();
    }

    // Assert
    expect(streamResults, expectedResults);
    await subscription.cancel();
  });
});
```

### 6. Platform-Specific Testing

#### iOS/macOS Specific Tests

```dart
@TestOn('mac-os || ios')
group('Apple Platform Specific', () {
  testWidgets('supports background downloads', (tester) async {
    expect(FlutterWhisperKitPlatform.instance.supportsBackgroundDownloads, isTrue);
  });

  testWidgets('handles audio session interruptions', (tester) async {
    // Test iOS-specific audio session behavior
  });
});
```

#### Mock Platform Behavior Validation

```dart
group('Platform Mock Validation', () {
  test('mock platform maintains state correctly', () {
    // Verify mock behavior matches real platform expectations
    final mock = setUpMockPlatform();

    // Test state transitions
    expect(mock.isRecording, isFalse);
    mock.mockStartRecording(result: 'Recording started');
    expect(mock.isRecording, isTrue);
  });
});
```

## Implementation Details

### Test-Driven Development (TDD) Workflow

Following the **Red-Green-Refactor** cycle documented in `docs/TEST_DRIVEN_DEVELOPMENT.md`:

1. **Red**: Write failing test first
2. **Green**: Implement minimal code to pass
3. **Refactor**: Improve design while keeping tests green

#### Example TDD Implementation

```dart
// 1. Red: Write failing test
test('downloadWithResult should return success with model path', () async {
  final result = await whisperKit.downloadWithResult(variant: 'tiny');
  expect(result, isA<Success<String, WhisperKitError>>());
});

// 2. Green: Minimal implementation
Future<Result<String, WhisperKitError>> downloadWithResult({required String variant}) async {
  return Success('/mock/path'); // Hardcoded to pass test
}

// 3. Refactor: Real implementation
Future<Result<String, WhisperKitError>> downloadWithResult({required String variant}) async {
  try {
    final path = await download(variant: variant);
    return path != null ? Success(path) : Failure(WhisperKitError(code: 1000, message: 'Download failed'));
  } catch (e) {
    return Failure(WhisperKitError(code: 1000, message: 'Download failed: $e'));
  }
}
```

### Error Scenario Testing

#### Comprehensive Error Coverage

```dart
class ErrorScenarioTests {
  static void testAllErrorCodes() {
    group('Error Code Coverage', () {
      for (final errorCode in ErrorCodes.allCodes) {
        test('handles error code $errorCode correctly', () async {
          final error = WhisperKitError(code: errorCode, message: 'Test error');
          final result = await simulateErrorScenario(error);

          expect(result.isFailure, isTrue);
          expect(result.error.code, errorCode);
        });
      }
    });
  }
}
```

### Performance Testing

#### Benchmark Integration

```dart
group('Performance Benchmarks', () {
  testWidgets('model loading performance', (tester) async {
    final stopwatch = Stopwatch()..start();

    final result = await whisperKit.loadModelWithResult('tiny');

    stopwatch.stop();

    expect(result.isSuccess, isTrue);
    expect(stopwatch.elapsedMilliseconds, lessThan(5000)); // 5 second limit
  });
});
```

## Rationale

### Why Multi-Layer Testing

1. **Comprehensive coverage**: Each layer tests different aspects
2. **Fast feedback**: Unit tests provide immediate feedback
3. **Confidence**: Integration tests verify component interactions
4. **Reality check**: E2E tests validate real-world scenarios

### Why Standardized Utilities

1. **Consistency**: Same patterns across all tests
2. **Maintainability**: Centralized mock management
3. **Reusability**: Common test scenarios shared
4. **Quality**: Better test quality through proven patterns

### Why TDD Approach

1. **Design quality**: Tests drive better API design
2. **Coverage**: Natural 100% test coverage
3. **Confidence**: Changes are safer with comprehensive tests
4. **Documentation**: Tests serve as living documentation

## Consequences

### Positive

1. **High confidence**: Comprehensive test coverage ensures reliability
2. **Fast development**: TDD approach speeds up development cycles
3. **Easy debugging**: Good test isolation makes issues easier to find
4. **Documentation**: Tests serve as usage examples
5. **Refactoring safety**: Tests enable safe code improvements

### Negative

1. **Initial investment**: Setting up comprehensive tests takes time
2. **Maintenance overhead**: Tests need to be maintained alongside code
3. **Complexity**: Multi-layer testing increases project complexity
4. **Mock maintenance**: Keeping mocks in sync with real implementations

### Mitigation Strategies

1. **Automated testing**: CI/CD integration for automatic test execution
2. **Test utilities**: Shared utilities reduce individual test complexity
3. **Documentation**: Clear testing guidelines for contributors
4. **Regular review**: Periodic review of test effectiveness and coverage

## Testing Guidelines

### For Contributors

1. **Follow TDD**: Write tests before implementation
2. **Use shared utilities**: Leverage existing test helpers
3. **Test error cases**: Don't just test happy paths
4. **Keep tests focused**: One concept per test
5. **Maintain mocks**: Update mocks when changing real implementations

### Test Quality Standards

```yaml
test_quality_standards:
  coverage:
    minimum: 90%
    target: 95%

  performance:
    unit_test_max_time: 100ms
    integration_test_max_time: 5s
    e2e_test_max_time: 30s

  reliability:
    flaky_test_tolerance: 0%
    test_isolation: required
```

## Monitoring and Success Criteria

### Metrics to Track

1. **Test coverage**: Line and branch coverage percentages
2. **Test execution time**: Speed of test suite execution
3. **Test reliability**: Flaky test frequency
4. **Bug detection**: Tests catching bugs before production

### Success Indicators

- [ ] 95% test coverage across all packages
- [ ] Test suite completes in under 5 minutes
- [ ] Zero flaky tests in CI/CD
- [ ] 90% of bugs caught by tests before release

## Related ADRs

- ADR-001: Error Handling Strategy (testing error scenarios)
- ADR-002: Platform Abstraction (platform-specific testing)
- ADR-004: Stream Management (testing real-time streams)

## References

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Test-Driven Development Guide](docs/TEST_DRIVEN_DEVELOPMENT.md)
- [Mockito for Dart](https://pub.dev/packages/mockito)
- [Integration Testing Best Practices](https://docs.flutter.dev/testing/integration-tests)
