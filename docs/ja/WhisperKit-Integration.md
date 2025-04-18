# WhisperKit と Flutter の統合

このドキュメントでは、Flutter WhisperKit Apple プラグインを使用して WhisperKit を Flutter アプリケーションと統合する方法について詳細な情報を提供します。

## 概要

Flutter WhisperKit Apple プラグインは、Flutter アプリケーションと Apple の WhisperKit フレームワークの間のブリッジとして機能します。この統合により、Flutter 開発者はネイティブコードを自分で書くことなく、iOS および macOS アプリケーションに音声テキスト変換機能を実装できます。

## アーキテクチャ

統合アーキテクチャは、主に3つのレイヤーで構成されています：

1. **Flutter API レイヤー**: Flutter アプリケーション向けのクリーンで使いやすいインターフェースを提供する Dart コード
2. **プラットフォームチャネル通信**: Dart コードとネイティブ Apple プラットフォームコードの間のブリッジ
3. **ネイティブ実装**: WhisperKit フレームワークとインターフェースする iOS/macOS Swift コード

![アーキテクチャ図](https://github.com/r0227n/flutter_whisperkit/raw/doc/docs/images/architecture.png)

## 統合手順

### 1. プラグインを Flutter プロジェクトに追加する

Flutter WhisperKit Apple プラグインを `pubspec.yaml` ファイルに追加します：

```yaml
dependencies:
  flutter_whisperkit_apple: ^0.0.1
```

`flutter pub get` を実行してプラグインをインストールします。

### 2. iOS/macOS プロジェクトの設定

#### iOS の設定

マイク権限を含めるために `Info.plist` ファイルを更新します：

```xml
<key>NSMicrophoneUsageDescription</key>
<string>このアプリは音声認識のためにマイクへのアクセスが必要です</string>
```

Podfile に正しい iOS バージョンがあることを確認します：

```ruby
platform :ios, '14.0'
```

#### macOS の設定

macOS アプリケーションの場合、`Info.plist` に以下を追加します：

```xml
<key>NSMicrophoneUsageDescription</key>
<string>このアプリは音声認識のためにマイクへのアクセスが必要です</string>
```

マイクアクセスのための適切な権限を追加します：

```xml
<key>com.apple.security.device.audio-input</key>
<true/>
```

### 3. Flutter アプリで WhisperKit を初期化する

プラグインをインポートして WhisperKit を初期化します：

```dart
import 'package:flutter_whisperkit_apple/flutter_whisperkit_apple.dart';

// プラグインのインスタンスを作成
final flutterWhisperkitApple = FlutterWhisperkitApple();

// WhisperKit を初期化
Future<void> initializeWhisperKit() async {
  try {
    await flutterWhisperkitApple.initializeWhisperKit();
    print('WhisperKit が正常に初期化されました');
  } catch (e) {
    print('WhisperKit の初期化に失敗しました: $e');
  }
}
```

### 4. 文字起こし機能の実装

#### ファイルベースの文字起こし

```dart
Future<String?> transcribeAudioFile(String filePath) async {
  try {
    final result = await flutterWhisperkitApple.transcribeAudio(
      filePath: filePath,
      config: TranscriptionConfig(
        language: 'ja',
        modelSize: 'medium',
      ),
    );
    
    return result.text;
  } catch (e) {
    print('文字起こしに失敗しました: $e');
    return null;
  }
}
```

#### リアルタイム文字起こし

```dart
// 録音と文字起こしを開始
Future<void> startRecording() async {
  try {
    await flutterWhisperkitApple.startRecording(
      config: TranscriptionConfig(
        language: 'ja',
        modelSize: 'medium',
        enableVAD: true,
      ),
    );
    
    // 文字起こしの更新をリッスン
    flutterWhisperkitApple.onTranscriptionProgress.listen((result) {
      print('部分的な文字起こし: ${result.text}');
    });
  } catch (e) {
    print('録音の開始に失敗しました: $e');
  }
}

// 録音を停止
Future<String?> stopRecording() async {
  try {
    final finalResult = await flutterWhisperkitApple.stopRecording();
    return finalResult.text;
  } catch (e) {
    print('録音の停止に失敗しました: $e');
    return null;
  }
}
```

## 高度な設定

Flutter WhisperKit Apple プラグインは、`TranscriptionConfig` クラスを通じてさまざまな設定オプションをサポートしています：

```dart
final config = TranscriptionConfig(
  language: 'ja',       // 言語コード（例：'en'、'fr'、'ja'）
  modelSize: 'medium',  // モデルサイズ：'tiny'、'small'、'medium'、'large'
  enableVAD: true,      // 音声アクティビティ検出
  vadFallbackTimeout: 3000, // ミリ秒単位のタイムアウト
  enablePunctuation: true,  // 自動句読点を有効にする
  enableFormatting: true,   // テキストフォーマットを有効にする
  enableTimestamps: false,  // 文字起こしにタイムスタンプを含める
);
```

## エラー処理

文字起こし中に発生する可能性のある問題を管理するために、適切なエラー処理を実装します：

```dart
try {
  // 文字起こしコード
} on WhisperKitConfigError catch (e) {
  print('設定エラー: $e');
} on PlatformException catch (e) {
  print('プラットフォームエラー: ${e.message}');
} catch (e) {
  print('不明なエラー: $e');
}
```

## パフォーマンスに関する考慮事項

- **モデルサイズ**: より大きなモデルはより良い精度を提供しますが、より多くの処理能力とメモリを必要とします
- **リアルタイムストリーミング**: レイテンシーを減らすために、リアルタイムアプリケーションではより小さなモデルの使用を検討してください
- **バッテリー使用量**: 継続的な文字起こしはバッテリー寿命に影響を与える可能性があります。適切な UI インジケーターを実装してください
- **メモリ管理**: 文字起こしが不要になったらリソースを解放してください

## トラブルシューティング

### 一般的な問題

1. **権限の欠如**: マイク権限が適切に設定されていることを確認してください
2. **モデルダウンロードの失敗**: ネットワーク接続と利用可能なストレージを確認してください
3. **文字起こしの精度**: 異なるモデルサイズや言語設定を試してください
4. **メモリ警告**: より小さなモデルを使用するか、アプリのメモリ使用量を最適化することを検討してください

### デバッグのヒント

1. プラグインでデバッグログを有効にする：
   ```dart
   flutterWhisperkitApple.setDebugLogging(true);
   ```

2. 文字起こし中のメモリ使用量を監視する
3. 異なるオーディオソースと品質レベルでテストする
4. 正しいモデルが使用されていることを確認する

## リソース

- [WhisperKit GitHub リポジトリ](https://github.com/argmaxinc/WhisperKit)
- [Flutter WhisperKit Apple プラグイン](https://github.com/r0227n/flutter_whisperkit)
- [HuggingFace の WhisperKit モデル](https://huggingface.co/argmaxinc/whisperkit-coreml)
