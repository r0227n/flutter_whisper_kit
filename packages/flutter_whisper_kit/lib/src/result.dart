/// Base Result class
/// [S] represents the type of the success value
/// [E] should be [Exception] or a subclass of it
sealed class Result<S, E extends Exception> {
  const Result();

  /// Returns true if this is a Success result
  bool get isSuccess => this is Success<S, E>;

  /// Returns true if this is a Failure result
  bool get isFailure => this is Failure<S, E>;

  /// Pattern matches on the result
  T when<T>({
    required T Function(S value) success,
    required T Function(E exception) failure,
  }) {
    return switch (this) {
      Success(:final value) => success(value),
      Failure(:final exception) => failure(exception),
    };
  }

  /// Transforms the result value based on success or failure
  T fold<T>({
    required T Function(S value) onSuccess,
    required T Function(E exception) onFailure,
  }) {
    return when(
      success: onSuccess,
      failure: onFailure,
    );
  }

  /// Maps the success value to a new value
  Result<T, E> map<T>(T Function(S value) transform) {
    return switch (this) {
      Success(:final value) => Success(transform(value)),
      Failure(:final exception) => Failure(exception),
    };
  }

  /// Maps the failure exception to a new exception
  Result<S, F> mapError<F extends Exception>(F Function(E exception) transform) {
    return switch (this) {
      Success(:final value) => Success(value),
      Failure(:final exception) => Failure(transform(exception)),
    };
  }

  /// Returns the success value or null
  S? getOrNull() {
    return switch (this) {
      Success(:final value) => value,
      Failure() => null,
    };
  }

  /// Returns the success value or throws the exception
  S getOrThrow() {
    return switch (this) {
      Success(:final value) => value,
      Failure(:final exception) => throw exception,
    };
  }

  /// Returns the success value or a default value
  S getOrElse(S defaultValue) {
    return switch (this) {
      Success(:final value) => value,
      Failure() => defaultValue,
    };
  }

  /// Returns the exception or null
  E? exceptionOrNull() {
    return switch (this) {
      Success() => null,
      Failure(:final exception) => exception,
    };
  }
}

final class Success<S, E extends Exception> extends Result<S, E> {
  const Success(this.value);
  final S value;
}

final class Failure<S, E extends Exception> extends Result<S, E> {
  const Failure(this.exception);
  final E exception;
}