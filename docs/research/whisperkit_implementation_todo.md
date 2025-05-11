# WhisperKit 実装 TODO リスト

このドキュメントは、flutter_whisper_kitプロジェクトでWhisperKitを実装するために必要なタスクをまとめたものです。

## 基本構造の実装

- [ ] `WhisperKit`クラスに対応するDartクラスを作成
- [ ] プラットフォームチャネルを設定（Pigeon使用）
- [ ] iOS/macOSプラットフォーム固有の実装を作成

## モデル関連クラスの実装

- [ ] `ModelVariant`列挙型をDartで定義
  - tiny, base, small, medium, largeなどのバリアントを含む
- [ ] `ModelState`列挙型をDartで定義
  - unloaded, loading, loaded, prewarming, prewarmed, unloadingなどの状態を含む
- [ ] `ModelComputeOptions`クラスをDartで定義
  - CPU、GPU、Neural Engineの使用設定を含む
- [ ] `WhisperTokenizer`に対応するDartクラスを作成

## プロトコル実装クラスの作成

- [ ] `AudioProcessing`プロトコルに対応するDartインターフェースを作成
- [ ] `FeatureExtracting`プロトコルに対応するDartインターフェースを作成
- [ ] `AudioEncoding`プロトコルに対応するDartインターフェースを作成
- [ ] `TextDecoding`プロトコルに対応するDartインターフェースを作成
- [ ] `LogitsFiltering`プロトコルに対応するDartインターフェースを作成
- [ ] `SegmentSeeking`プロトコルに対応するDartインターフェースを作成
- [ ] `VoiceActivityDetector`に対応するDartクラスを作成

## 設定関連クラスの実装

- [ ] `WhisperKitConfig`クラスをDartで定義
  - モデル、ダウンロード設定、コンポーネント、ログ設定などを含む
- [ ] `AudioInputConfig`クラスをDartで定義
- [ ] `DecodingOptions`クラスをDartで定義
  - 言語、温度、チャンク戦略などの設定を含む

## 結果関連クラスの実装

- [ ] `TranscriptionResult`クラスをDartで定義
  - テキスト、セグメント、言語、タイミング情報を含む
- [ ] `TranscriptionTimings`クラスをDartで定義
  - 各処理段階の時間計測を含む
- [ ] `Progress`クラスをDartで定義
  - 進捗状況を追跡するためのクラス

## コールバック関連の実装

- [ ] `SegmentDiscoveryCallback`をDartで定義
- [ ] `ModelStateCallback`をDartで定義
- [ ] `TranscriptionStateCallback`をDartで定義
- [ ] `TranscriptionCallback`をDartで定義
- [ ] `Logging.LoggingCallback`をDartで定義

## 主要機能の実装

### モデル管理機能

- [ ] `deviceName()`メソッドの実装
- [ ] `recommendedModels()`メソッドの実装
- [ ] `recommendedRemoteModels()`メソッドの実装
- [ ] `fetchModelSupportConfig()`メソッドの実装
- [ ] `fetchAvailableModels()`メソッドの実装
- [ ] `formatModelFiles()`メソッドの実装
- [ ] `download()`メソッドの実装
- [ ] `setupModels()`メソッドの実装
- [ ] `prewarmModels()`メソッドの実装
- [ ] `loadModels()`メソッドの実装
- [ ] `unloadModels()`メソッドの実装
- [ ] `clearState()`メソッドの実装
- [ ] `loggingCallback()`メソッドの実装

### 言語検出機能

- [ ] `detectLanguage(audioPath:)`メソッドの実装
- [ ] `detectLangauge(audioArray:)`メソッドの実装（注：原文のスペルミスを修正）

### 文字起こし機能

- [ ] `transcribe(audioPaths:decodeOptions:callback:)`メソッドの実装
- [ ] `transcribeWithResults(audioPaths:decodeOptions:callback:)`メソッドの実装
- [ ] `transcribe(audioArrays:decodeOptions:callback:)`メソッドの実装
- [ ] `transcribeWithResults(audioArrays:decodeOptions:callback:)`メソッドの実装
- [ ] `transcribeWithOptions(audioArrays:decodeOptionsArray:callback:)`メソッドの実装
- [ ] `transcribe(audioPath:decodeOptions:callback:)`メソッドの実装
- [ ] `transcribe(audioArray:decodeOptions:callback:)`メソッドの実装
- [ ] `runTranscribeTask(audioArray:decodeOptions:callback:)`メソッドの実装

## プラットフォーム固有の実装

### iOS/macOS実装

- [ ] Swift側で`WhisperKit`のインスタンス化と管理
- [ ] Pigeonで生成されたインターフェースの実装
- [ ] モデルダウンロードと管理の実装
- [ ] 音声処理とMel特徴量抽出の実装
- [ ] 文字起こし処理の実装
- [ ] 進捗状況とコールバックの処理
- [ ] エラーハンドリングとエラーメッセージの変換

## テスト実装

- [ ] モデル管理機能のユニットテスト
- [ ] 言語検出機能のユニットテスト
- [ ] 文字起こし機能のユニットテスト
- [ ] プラットフォームチャネル通信のテスト
- [ ] エラーハンドリングのテスト
- [ ] 統合テスト

## サンプルアプリケーション

- [ ] 基本的な文字起こし機能のデモ
- [ ] モデル管理UIの実装
- [ ] リアルタイム文字起こしのデモ
- [ ] 言語検出機能のデモ
- [ ] 進捗表示の実装

## ドキュメント作成

- [ ] APIドキュメントの作成
- [ ] 使用方法のガイド作成
- [ ] サンプルコードの作成
- [ ] トラブルシューティングガイドの作成
