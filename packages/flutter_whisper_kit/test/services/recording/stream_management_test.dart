import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisper_kit/src/models/transcription/transcription_result.dart';
import 'package:flutter_whisper_kit/src/streams/transcription_stream.dart';

// TDD Green Phase: 最小実装でテストを通す

void main() {
  group('TranscriptionStream', () {
    test('should filter and emit transcription results', () async {
      // Given: TranscriptionStreamが作成される
      final stream = TranscriptionStream();
      final results = <TranscriptionResult>[];

      // When: resultsストリームを購読
      final subscription = stream.results.listen((result) {
        results.add(result);
      });

      // TranscriptionResultEventを送信
      final mockResult = TranscriptionResult(
        text: 'Hello World',
        segments: [],
        language: 'en',
        timings: const TranscriptionTimings(),
      );
      stream.add(TranscriptionResultEvent(mockResult));

      // ProgressEventを送信（フィルタされるべき）
      stream.add(ProgressEvent(0.5));

      // Then: TranscriptionResultEventのみが結果として出力される
      await Future.delayed(const Duration(milliseconds: 10));
      expect(results.length, equals(1));
      expect(results.first.text, equals('Hello World'));

      await subscription.cancel();
      stream.close();
    });

    test('should filter and emit progress updates', () async {
      // Given: TranscriptionStreamが作成される
      final stream = TranscriptionStream();
      final progressValues = <double>[];

      // When: progressストリームを購読
      final subscription = stream.progress.listen((progress) {
        progressValues.add(progress);
      });

      // ProgressEventを送信
      stream.add(ProgressEvent(0.3));
      stream.add(ProgressEvent(0.7));

      // TranscriptionResultEventを送信（フィルタされるべき）
      final mockResult = TranscriptionResult(
        text: 'Test',
        segments: [],
        language: 'en',
        timings: const TranscriptionTimings(),
      );
      stream.add(TranscriptionResultEvent(mockResult));

      // Then: ProgressEventのみが進捗として出力される
      await Future.delayed(const Duration(milliseconds: 10));
      expect(progressValues.length, equals(2));
      expect(progressValues, equals([0.3, 0.7]));

      await subscription.cancel();
      stream.close();
    });
  });

  group('BufferedTranscriptionStream', () {
    test('should create with default buffer size and strategy', () {
      // Given: BufferedTranscriptionStreamを作成
      // When: デフォルトパラメータでインスタンス作成
      final stream = BufferedTranscriptionStream();

      // Then: 正常にインスタンスが作成される
      expect(stream.maxBufferSize, equals(100));
      expect(stream.overflowStrategy, equals(OverflowStrategy.drop));
      expect(stream.currentBufferSize, equals(0));

      stream.dispose();
    });

    test('should create with custom parameters', () {
      // Given: カスタムパラメータでBufferedTranscriptionStreamを作成
      // When: カスタムパラメータでインスタンス作成
      final stream = BufferedTranscriptionStream(
        maxBufferSize: 50,
        overflowStrategy: OverflowStrategy.latest,
      );

      // Then: 指定したパラメータが設定される
      expect(stream.maxBufferSize, equals(50));
      expect(stream.overflowStrategy, equals(OverflowStrategy.latest));

      stream.dispose();
    });

    test('should handle buffer overflow with drop strategy', () async {
      // Given: バッファサイズ2のストリーム（drop戦略）
      final stream = BufferedTranscriptionStream(
        maxBufferSize: 2,
        overflowStrategy: OverflowStrategy.drop,
      );
      final events = <TranscriptionEvent>[];

      final subscription = stream.events.listen((event) {
        events.add(event);
      });

      // When: バッファサイズを超えるイベントを送信
      stream.add(ProgressEvent(0.1));
      stream.add(ProgressEvent(0.2));
      stream.add(ProgressEvent(0.3)); // これは破棄される

      // Then: 最初の2つのイベントのみが出力される
      await Future.delayed(const Duration(milliseconds: 10));
      expect(events.length, equals(2));
      expect((events[0] as ProgressEvent).progress, equals(0.1));
      expect((events[1] as ProgressEvent).progress, equals(0.2));
      expect(stream.currentBufferSize, equals(2));

      await subscription.cancel();
      stream.dispose();
    });

    test('should handle buffer overflow with latest strategy', () async {
      // Given: バッファサイズ2のストリーム（latest戦略）
      final stream = BufferedTranscriptionStream(
        maxBufferSize: 2,
        overflowStrategy: OverflowStrategy.latest,
      );
      final events = <TranscriptionEvent>[];

      final subscription = stream.events.listen((event) {
        events.add(event);
      });

      // When: バッファサイズを超えるイベントを送信
      stream.add(ProgressEvent(0.1));
      stream.add(ProgressEvent(0.2));
      stream.add(ProgressEvent(0.3)); // 古いイベントが削除され、これが追加される

      // Then: 最新の2つのイベントが出力される
      await Future.delayed(const Duration(milliseconds: 10));
      expect(events.length, equals(3)); // すべてのイベントがストリームに出力される
      expect((events[2] as ProgressEvent).progress, equals(0.3));
      expect(stream.currentBufferSize, equals(2)); // バッファサイズは制限内

      await subscription.cancel();
      stream.dispose();
    });

    test('should properly dispose resources', () {
      // Given: BufferedTranscriptionStreamを作成
      final stream = BufferedTranscriptionStream();

      // When: イベントを追加してからdisposeを呼び出す
      stream.add(ProgressEvent(0.5));
      expect(stream.currentBufferSize, equals(1));

      stream.dispose();

      // Then: リソースが適切に解放される
      expect(stream.currentBufferSize, equals(0));

      // disposed後のイベント追加は無視される
      stream.add(ProgressEvent(0.6));
      expect(stream.currentBufferSize, equals(0));
    });
  });
}
