# flutter_whisper_kit

[![pub package](https://img.shields.io/pub/v/flutter_whisper_kit.svg)](https://pub.dev/packages/flutter_whisper_kit)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

高品質なオンデバイス音声認識機能を提供するFlutterプラグインです。[WhisperKit](https://github.com/argmaxinc/WhisperKit)を使用して、プライバシーを保護しながら高精度な音声文字起こしを実現します。

[English README](README.md)

## 特徴

- 🔒 **完全なオンデバイス処理** - データが外部サーバーに送信されることはありません
- 🎯 **高精度な音声認識** - Whisperモデルによる高品質な文字起こし
- 📱 **複数のモデルサイズ** - tiny から large まで用途に応じて選択可能
- 🎙️ **リアルタイム文字起こし** - マイクからの音声をリアルタイムで変換
- 📁 **ファイルベース文字起こし** - 音声ファイルからの文字起こしに対応
- 📊 **進捗トラッキング** - モデルダウンロードの進捗を取得可能
- 🌍 **多言語対応** - 100以上の言語に対応
- ⚡ **型安全なエラーハンドリング** - Result型による安全なエラー処理

## プラットフォームサポート

| Platform | 最小バージョン | 状態                        |
| -------- | -------------- | --------------------------- |
| iOS      | 16.0+          | ✅ 完全サポート             |
| macOS    | 13.0+          | ✅ 完全サポート             |
| Android  | -              | 🚧 今後のリリースで対応予定 |

## インストール

`pubspec.yaml`に以下を追加：

```yaml
dependencies:
  flutter_whisper_kit: ^0.2.0
```

### iOS設定

iOSアプリの`ios/Runner/Info.plist`に以下の権限を追加してください：

```xml
<key>NSMicrophoneUsageDescription</key>
<string>このアプリは音声認識のためにマイクへのアクセスが必要です</string>
<key>NSDownloadsFolderUsageDescription</key>
<string>このアプリはWhisperKitモデルを保存するためにダウンロードフォルダへのアクセスが必要です</string>
<key>NSDocumentsFolderUsageDescription</key>
<string>このアプリはWhisperKitモデルを保存するためにドキュメントフォルダへのアクセスが必要です</string>
```

### macOS設定

macOSアプリの`macos/Runner/Info.plist`に以下の権限を追加してください：

```xml
<key>NSMicrophoneUsageDescription</key>
<string>このアプリは音声認識のためにマイクへのアクセスが必要です</string>
<key>NSLocalNetworkUsageDescription</key>
<string>このアプリはWhisperKitモデルをダウンロードするためにローカルネットワークへのアクセスが必要です</string>
<key>NSDownloadsFolderUsageDescription</key>
<string>このアプリはWhisperKitモデルを保存するためにダウンロードフォルダへのアクセスが必要です</string>
<key>NSDocumentsFolderUsageDescription</key>
<string>このアプリはWhisperKitモデルを保存するためにドキュメントフォルダへのアクセスが必要です</string>
```

また、`macos/Runner.xcodeproj/project.pbxproj`でmacOSデプロイメントターゲットが13.0以上に設定されていることを確認してください：

```
MACOSX_DEPLOYMENT_TARGET = 13.0;
```

## 使い方

### 基本的な使い方

```dart
import 'package:flutter_whisper_kit/flutter_whisper_kit.dart';

// プラグインのインスタンスを作成
final whisperKit = FlutterWhisperKit();

// モデルをロード
final result = await whisperKit.loadModel(
  'tiny',  // モデルサイズ: tiny, base, small, medium, large-v2, large-v3
  modelRepo: 'argmaxinc/whisperkit-coreml',
);
print('モデルロード完了: $result');

// 音声ファイルから文字起こし
final transcription = await whisperKit.transcribeFromFile(
  '/path/to/audio/file.mp3',
  options: DecodingOptions(
    task: DecodingTask.transcribe,
    language: 'ja',  // 日本語を指定（null で自動検出）
  ),
);
print('文字起こし結果: ${transcription?.text}');
```

### リアルタイム文字起こし

```dart
// 文字起こしストリームを監視
whisperKit.transcriptionStream.listen((transcription) {
  print('リアルタイム文字起こし: ${transcription.text}');
});

// 録音を開始
await whisperKit.startRecording(
  options: DecodingOptions(
    task: DecodingTask.transcribe,
    language: 'ja',
  ),
);

// 録音を停止
final finalTranscription = await whisperKit.stopRecording();
print('最終文字起こし: ${finalTranscription?.text}');
```

### エラーハンドリング（Result型）

v0.2.0から、より安全なエラーハンドリングのためのResult型APIが追加されました：

```dart
// Result型を使用したモデルロード
final loadResult = await whisperKit.loadModelWithResult(
  'tiny',
  modelRepo: 'argmaxinc/whisperkit-coreml',
);

loadResult.when(
  success: (modelPath) {
    print('モデルロード成功: $modelPath');
  },
  failure: (error) {
    print('モデルロード失敗: ${error.message}');
    // エラーコードによる処理分岐も可能
    switch (error.code) {
      case WhisperKitErrorCode.modelNotFound:
        // モデルが見つからない場合の処理
        break;
      case WhisperKitErrorCode.networkError:
        // ネットワークエラーの場合の処理
        break;
      default:
        // その他のエラー
    }
  },
);

// Result型を使用した文字起こし
final transcribeResult = await whisperKit.transcribeFileWithResult(
  audioPath,
  options: DecodingOptions(language: 'ja'),
);

// fold メソッドで成功/失敗を処理
final text = transcribeResult.fold(
  onSuccess: (result) => result?.text ?? '結果なし',
  onFailure: (error) => 'エラー: ${error.message}',
);
```

### モデル管理

```dart
// 利用可能なモデルを取得
final models = await whisperKit.fetchAvailableModels(
  modelRepo: 'argmaxinc/whisperkit-coreml',
);

// 推奨モデルを取得
final recommended = await whisperKit.recommendedModels();
print('推奨モデル: ${recommended?.defaultModel}');

// モデルをダウンロード（進捗付き）
await whisperKit.download(
  variant: 'base',
  repo: 'argmaxinc/whisperkit-coreml',
  onProgress: (progress) {
    print('ダウンロード進捗: ${(progress.fractionCompleted * 100).toStringAsFixed(1)}%');
  },
);

// モデルの進捗ストリームを監視
whisperKit.modelProgressStream.listen((progress) {
  print('モデル進捗: ${progress.fractionCompleted * 100}%');
});
```

### 言語検出

```dart
// 音声ファイルの言語を検出
final detection = await whisperKit.detectLanguage(audioPath);
print('検出された言語: ${detection?.language}');
print('信頼度: ${detection?.probabilities[detection.language]}');
```

### 高度な設定

```dart
// カスタムデコードオプション
final options = DecodingOptions(
  verbose: true,                        // 詳細ログを出力
  task: DecodingTask.transcribe,       // transcribe または translate
  language: 'ja',                       // 言語コード（null で自動検出）
  temperature: 0.0,                     // サンプリング温度（0.0-1.0）
  temperatureFallbackCount: 5,          // 温度フォールバック回数
  wordTimestamps: true,                 // 単語ごとのタイムスタンプ
  chunkingStrategy: ChunkingStrategy.vad, // チャンク分割戦略
);

// 文字起こし結果の詳細情報
final result = await whisperKit.transcribeFromFile(audioPath, options: options);
if (result != null) {
  print('テキスト: ${result.text}');
  print('言語: ${result.language}');

  // セグメント情報
  for (final segment in result.segments) {
    print('セグメント ${segment.id}: ${segment.text}');
    print('  開始: ${segment.startTime}秒, 終了: ${segment.endTime}秒');

    // 単語のタイミング情報（wordTimestamps: true の場合）
    for (final word in segment.words) {
      print('  単語: ${word.word} (${word.start}秒 - ${word.end}秒)');
    }
  }
}
```

## モデルサイズの選択

用途に応じて適切なモデルサイズを選択してください：

| モデル   | サイズ | 速度       | 精度           | 用途                             |
| -------- | ------ | ---------- | -------------- | -------------------------------- |
| tiny     | ~39MB  | 非常に高速 | 低             | リアルタイム処理、バッテリー重視 |
| tiny-en  | ~39MB  | 非常に高速 | 低（英語特化） | 英語のみのリアルタイム処理       |
| base     | ~145MB | 高速       | 中             | バランス重視                     |
| small    | ~466MB | 中速       | 高             | 高精度が必要な場合               |
| medium   | ~1.5GB | 低速       | より高         | より高い精度が必要な場合         |
| large-v2 | ~2.9GB | 非常に低速 | 非常に高       | 最高精度が必要な場合             |
| large-v3 | ~2.9GB | 非常に低速 | 最高           | 最新・最高精度                   |

## サンプルアプリ

`example`フォルダに、すべての機能を試せるサンプルアプリが含まれています：

```bash
cd packages/flutter_whisper_kit/example
flutter run
```

## トラブルシューティング

### iOS/macOSでビルドエラーが発生する

1. 最小デプロイメントターゲットを確認（iOS 16.0+, macOS 13.0+）
2. Xcodeを最新版にアップデート
3. `pod install`を実行

### モデルのダウンロードが失敗する

1. ネットワーク接続を確認
2. 十分なストレージ容量があることを確認
3. `redownload: true`オプションを試す

### 文字起こし精度が低い

1. より大きなモデルサイズを試す
2. `language`パラメータで言語を明示的に指定
3. `temperature`パラメータを調整（0.0でより決定的、1.0でより創造的）

## ライセンス

このプロジェクトはMITライセンスの下で公開されています。詳細は[LICENSE](LICENSE)ファイルを参照してください。

## 貢献

プルリクエストを歓迎します！大きな変更を行う場合は、まずissueを開いて変更内容について議論してください。

## 謝辞

このプラグインは[WhisperKit](https://github.com/argmaxinc/WhisperKit)をベースにしています。素晴らしいライブラリを提供してくださったArgmax Inc.チームに感謝します。
