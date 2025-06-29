import 'dart:async';

import 'package:flutter_whisper_kit/src/models/transcription/transcription_result.dart';

/// Base event for transcription stream
sealed class TranscriptionEvent {}

/// Event carrying transcription result
class TranscriptionResultEvent extends TranscriptionEvent {
  TranscriptionResultEvent(this.result);
  final TranscriptionResult result;
}

/// Event carrying progress information
class ProgressEvent extends TranscriptionEvent {
  ProgressEvent(this.progress);
  final double progress;
}

/// Strategy for handling buffer overflow
enum OverflowStrategy {
  drop, // Drop new events when buffer is full
  backpressure, // Apply backpressure to source
  latest, // Keep only latest events
}

/// Reactive programming support for transcription events
class TranscriptionStream implements IDisposable {
  /// Creates a new TranscriptionStream
  TranscriptionStream()
      : _controller = StreamController<TranscriptionEvent>.broadcast();
  final StreamController<TranscriptionEvent> _controller;
  bool _disposed = false;

  /// Stream of transcription results filtered from events
  Stream<TranscriptionResult> get results => _controller.stream
      .where((event) => event is TranscriptionResultEvent)
      .map((event) => (event as TranscriptionResultEvent).result);

  /// Stream of progress updates filtered from events
  Stream<double> get progress => _controller.stream
      .where((event) => event is ProgressEvent)
      .map((event) => (event as ProgressEvent).progress);

  /// Add an event to the stream
  void add(TranscriptionEvent event) {
    if (!_disposed) {
      _controller.add(event);
    }
  }

  /// Close the stream
  void close() {
    dispose();
  }

  @override
  void dispose() {
    if (!_disposed) {
      _disposed = true;
      _controller.close();
    }
  }
}

/// Interface for disposable stream resources
abstract class IDisposable {
  void dispose();
}

/// Buffered transcription stream with backpressure support
class BufferedTranscriptionStream implements IDisposable {
  /// Creates a buffered transcription stream
  BufferedTranscriptionStream({
    this.maxBufferSize = 100,
    this.overflowStrategy = OverflowStrategy.drop,
  }) : _controller = StreamController<TranscriptionEvent>.broadcast();
  final int maxBufferSize;
  final OverflowStrategy overflowStrategy;
  final List<TranscriptionEvent> _buffer = [];
  final StreamController<TranscriptionEvent> _controller;
  bool _disposed = false;

  /// Stream of buffered events
  Stream<TranscriptionEvent> get events => _controller.stream;

  /// Add event with overflow handling
  void add(TranscriptionEvent event) {
    if (_disposed) return;

    // バックプレッシャー対応
    if (_buffer.length >= maxBufferSize) {
      _handleOverflow(event);
    } else {
      _buffer.add(event);
      _controller.add(event);
    }
  }

  void _handleOverflow(TranscriptionEvent event) {
    switch (overflowStrategy) {
      case OverflowStrategy.drop:
        // Discard new event
        break;
      case OverflowStrategy.latest:
        // Remove oldest event and add new event
        if (_buffer.isNotEmpty) {
          _buffer.removeAt(0);
        }
        _buffer.add(event);
        _controller.add(event);
        break;
      case OverflowStrategy.backpressure:
        // Apply backpressure (no-op in implementation)
        // Production code should provide logging library or callback functionality
        // Example: onOverflow?.call('Buffer overflow, applying backpressure');
        break;
    }
  }

  /// Get current buffer size for monitoring
  int get currentBufferSize => _buffer.length;

  /// Clear the buffer
  void clearBuffer() {
    _buffer.clear();
  }

  @override
  void dispose() {
    if (!_disposed) {
      _disposed = true;
      _buffer.clear();
      _controller.close();
    }
  }
}
