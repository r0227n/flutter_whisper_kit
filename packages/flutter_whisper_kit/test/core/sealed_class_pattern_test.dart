import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisper_kit/src/result.dart';
import 'package:flutter_whisper_kit/src/whisper_kit_error.dart';

class TestException implements Exception {
  const TestException(this.message, [this.code]);
  final String message;
  final int? code;

  @override
  String toString() => message;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TestException &&
        other.message == message &&
        other.code == code;
  }

  @override
  int get hashCode => message.hashCode ^ (code?.hashCode ?? 0);
}

void main() {
  group('Sealed class Result pattern matching', () {
    test('exhaustive pattern matching with switch expression', () {
      final successResult = Success<String, WhisperKitError>('Hello');
      final failureResult = Failure<String, WhisperKitError>(
        ModelLoadingFailedError(code: 1001, message: 'Error'),
      );

      // Switch expression with exhaustive pattern matching
      String handleResult(Result<String, WhisperKitError> result) {
        return switch (result) {
          Success(:final value) => 'Success: $value',
          Failure(:final exception) => 'Error: ${exception.message}',
          // No default case needed - compiler knows all cases are covered
        };
      }

      expect(handleResult(successResult), equals('Success: Hello'));
      expect(handleResult(failureResult), equals('Error: Error'));
    });

    test('pattern matching with if-case', () {
      final result = Success<int, TestException>(42);

      String message = '';
      if (result case Success(value: final v)) {
        message = 'Got value: $v';
      }

      expect(message, equals('Got value: 42'));
    });

    test('destructuring in for loops', () {
      final results = [
        Success<int, TestException>(1),
        Failure<int, TestException>(TestException('Error 1')),
        Success<int, TestException>(2),
        Failure<int, TestException>(TestException('Error 2')),
      ];

      final successes = <int>[];
      final failures = <TestException>[];

      for (final result in results) {
        switch (result) {
          case Success(value: final v):
            successes.add(v);
          case Failure(exception: final e):
            failures.add(e);
        }
      }

      expect(successes, equals([1, 2]));
      expect(failures.map((e) => e.message), equals(['Error 1', 'Error 2']));
    });

    test('pattern matching with guards', () {
      Result<int, TestException> checkNumber(int n) {
        return switch (n) {
          < 0 => Failure(TestException('Negative number')),
          0 => Failure(TestException('Zero is not allowed')),
          > 100 => Failure(TestException('Number too large')),
          _ => Success(n),
        };
      }

      expect(checkNumber(-5), isA<Failure<int, TestException>>());
      expect(checkNumber(0), isA<Failure<int, TestException>>());
      expect(checkNumber(50), isA<Success<int, TestException>>());
      expect(checkNumber(101), isA<Failure<int, TestException>>());
    });

    test('nested pattern matching', () {
      final result = Success<Result<int, TestException>, TestException>(
        Success(42),
      );

      final value = switch (result) {
        Success(value: Success(value: final v)) => v,
        Success(value: Failure(exception: final _)) => -1,
      };

      expect(value, equals(42));
    });

    test('pattern matching ensures type safety', () {
      // This function handles all possible cases
      T processResult<T>(
        Result<T, WhisperKitError> result, {
        required T Function() onEmpty,
      }) {
        return switch (result) {
          Success(value: final v) => v,
          Failure(exception: final e) when e.code == 404 => onEmpty(),
          Failure(exception: final e) => throw e,
        };
      }

      final result = Success<String, WhisperKitError>('data');
      expect(
        processResult(result, onEmpty: () => 'default'),
        equals('data'),
      );

      final emptyResult = Failure<String, WhisperKitError>(
        UnknownError(code: 404, message: 'Not found'),
      );
      expect(
        processResult(emptyResult, onEmpty: () => 'default'),
        equals('default'),
      );
    });
  });
}
