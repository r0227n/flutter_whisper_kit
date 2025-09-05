import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisper_kit/src/result.dart';

class TestException implements Exception {
  const TestException(this.message, [this.code]);
  final String message;
  final int? code;

  @override
  String toString() => code != null
      ? 'TestException($code): $message'
      : 'TestException: $message';

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
  group('Result', () {
    group('Success', () {
      test('should create a success result', () {
        final result = Success('test value');

        expect(result, isA<Success<String, Exception>>());
        expect(result.isSuccess, isTrue);
        expect(result.isFailure, isFalse);
      });

      test('should return value with when pattern matching', () {
        final result = Success<String, TestException>('success');

        final value = result.when(
          success: (value) => value,
          failure: (exception) => 'failed',
        );

        expect(value, equals('success'));
      });

      test('should return value with fold transformation', () {
        final result = Success<int, TestException>(42);

        final transformed = result.fold(
          onSuccess: (value) => value * 2,
          onFailure: (exception) => 0,
        );

        expect(transformed, equals(84));
      });

      test('should map success value', () {
        final result = Success<int, TestException>(10);
        final mapped = result.map((value) => value.toString());

        expect(mapped.isSuccess, isTrue);
        expect(
          mapped.when(success: (value) => value, failure: (_) => ''),
          equals('10'),
        );
      });

      test('should not map error on success', () {
        final result = Success<String, TestException>('test');
        final mapped = result.mapError(
          (exception) => TestException(exception.toString()),
        );

        expect(mapped.isSuccess, isTrue);
        expect(
          mapped.when(success: (value) => value, failure: (_) => ''),
          equals('test'),
        );
      });
    });

    group('Failure', () {
      test('should create a failure result', () {
        final result = Failure(TestException('error message'));

        expect(result, isA<Failure<dynamic, TestException>>());
        expect(result.isSuccess, isFalse);
        expect(result.isFailure, isTrue);
      });

      test('should return error with when pattern matching', () {
        final result = Failure<String, TestException>(
          TestException('Not found', 404),
        );

        final value = result.when(
          success: (value) => value,
          failure: (exception) => 'Error: $exception',
        );

        expect(value, equals('Error: TestException(404): Not found'));
      });

      test('should return error with fold transformation', () {
        final result = Failure<int, TestException>(TestException('not found'));

        final transformed = result.fold(
          onSuccess: (value) => value,
          onFailure: (exception) => exception.message.length,
        );

        expect(transformed, equals(9)); // "not found" has 9 characters
      });

      test('should not map value on failure', () {
        final result = Failure<int, TestException>(TestException('error'));
        final mapped = result.map((value) => value * 2);

        expect(mapped.isFailure, isTrue);
        expect(
          mapped.when(
            success: (_) => 0,
            failure: (exception) => exception.message,
          ),
          equals('error'),
        );
      });

      test('should map error on failure', () {
        final result = Failure<String, TestException>(
          TestException('Not found', 404),
        );
        final mapped = result.mapError(
          (exception) => TestException('Error code: ${exception.code}'),
        );

        expect(mapped.isFailure, isTrue);
        expect(
          mapped.when(
            success: (_) => '',
            failure: (exception) => exception.message,
          ),
          equals('Error code: 404'),
        );
      });
    });

    group('Complex type scenarios', () {
      test('should work with nullable types', () {
        final successResult = Success<String?, TestException>(null);
        final failureResult = Failure<String?, TestException>(
          TestException('error', 0),
        );

        expect(successResult.isSuccess, isTrue);
        expect(
          successResult.when(
            success: (value) => value,
            failure: (_) => 'error',
          ),
          isNull,
        );

        expect(failureResult.isFailure, isTrue);
        expect(
          failureResult.when(
            success: (_) => 'success',
            failure: (exception) => exception.code,
          ),
          equals(0),
        );
      });

      test('should work with custom error types', () {
        final error = Exception('Custom error');
        final result = Failure<int, Exception>(error);

        expect(result.isFailure, isTrue);
        expect(
          result.when(success: (_) => null, failure: (e) => e),
          equals(error),
        );
      });

      test('should chain multiple transformations', () {
        final result = Success<int, TestException>(10);

        final transformed = result
            .map((value) => value * 2)
            .map((value) => value.toString())
            .map((value) => 'Result: $value');

        expect(transformed.isSuccess, isTrue);
        expect(
          transformed.when(success: (value) => value, failure: (_) => ''),
          equals('Result: 20'),
        );
      });

      test('should chain error transformations', () {
        final result = Failure<int, TestException>(
          TestException('Not found', 404),
        );

        final transformed = result
            .mapError((exception) => TestException('Error ${exception.code}'))
            .mapError(
              (exception) => TestException('${exception.message} not found'),
            )
            .mapError(
              (exception) => TestException(exception.message.toUpperCase()),
            );

        expect(transformed.isFailure, isTrue);
        expect(
          transformed.when(
            success: (_) => '',
            failure: (exception) => exception.message,
          ),
          equals('ERROR 404 NOT FOUND'),
        );
      });

      test('should preserve error type through value transformations', () {
        final result = Failure<int, TestException>(
          TestException('original error'),
        );

        final transformed = result
            .map((value) => value * 2)
            .map((value) => value.toString());

        expect(transformed.isFailure, isTrue);
        expect(
          transformed.when(
            success: (_) => '',
            failure: (exception) => exception.message,
          ),
          equals('original error'),
        );
      });
    });

    group('Type inference', () {
      test('should infer types correctly for success', () {
        final result = Success(42);

        // This should compile and infer Result<int, Exception>
        expect(result, isA<Result<int, Exception>>());
      });

      test('should infer types correctly for failure', () {
        final result = Failure(TestException('error'));

        // This should compile and infer Result<dynamic, TestException>
        expect(result, isA<Result<dynamic, TestException>>());
      });

      test('should work with explicit type parameters', () {
        final result = Success<String, TestException>('test');

        expect(result, isA<Result<String, TestException>>());
        expect(result.isSuccess, isTrue);
      });
    });
  });
}
