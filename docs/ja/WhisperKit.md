# WhisperKit ドキュメント

## 概要

WhisperKit は、[Argmax](https://www.takeargmax.com) が開発した Swift フレームワークで、Apple デバイス上で最先端の音声テキスト変換システム（例：[Whisper](https://github.com/openai/whisper)）を展開するためのものです。リアルタイムストリーミング、単語タイムスタンプ、音声アクティビティ検出などの高度な機能を提供します。

オリジナルのリポジトリは [https://github.com/argmaxinc/WhisperKit.git](https://github.com/argmaxinc/WhisperKit.git) にあります。

## 主な機能

- デバイス上での音声テキスト変換
- リアルタイムストリーミング機能
- 単語タイムスタンプ
- 音声アクティビティ検出
- 複数言語のサポート
- CoreML を使用した Apple デバイス向けの最適化

## インストール

WhisperKit は Swift Package Manager を使用して Swift プロジェクトに統合できます。

### 前提条件

- macOS 14.0 以降
- Xcode 15.0 以降

### Swift Package Manager による統合

1. Swift プロジェクトを Xcode で開く
2. `File` > `Add Package Dependencies...` に移動
3. パッケージリポジトリ URL を入力: `https://github.com/argmaxinc/whisperkit`
4. バージョン範囲または特定のバージョンを選択
5. `Finish` をクリックして WhisperKit をプロジェクトに追加

### Package.swift への追加

Swift パッケージの一部として WhisperKit を使用する場合は、Package.swift の依存関係に以下のように追加できます：

```swift
dependencies: [
    .package(url: "https://github.com/argmaxinc/WhisperKit.git", from: "0.9.0"),
],
```

次に、ターゲットの依存関係として `WhisperKit` を追加します：

```swift
.target(
    name: "YourApp",
    dependencies: ["WhisperKit"]
),
```

### Homebrew によるインストール

[Homebrew](https://brew.sh) を使用して `WhisperKit` コマンドラインアプリをインストールできます：

```bash
brew install whisperkit-cli
```

## 使用方法

### 基本的な使用例

以下は、ローカルの音声ファイルを文字起こしする基本的な例です：

```swift
import WhisperKit

// デフォルト設定で WhisperKit を初期化
Task {
   let pipe = try? await WhisperKit()
   let transcription = try? await pipe!.transcribe(audioPath: "path/to/your/audio.{wav,mp3,m4a,flac}")?.text
    print(transcription)
}
```

### モデルの選択

WhisperKit は、指定されていない場合、デバイスに推奨されるモデルを自動的にダウンロードします。モデル名を指定して特定のモデルを選択することもできます：

```swift
let pipe = try? await WhisperKit(WhisperKitConfig(model: "large-v3"))
```

このメソッドはグロブ検索もサポートしているため、ワイルドカードを使用してモデルを選択できます：

```swift
let pipe = try? await WhisperKit(WhisperKitConfig(model: "distil*large-v3"))
```

利用可能なモデルのリストについては、[HuggingFace リポジトリ](https://huggingface.co/argmaxinc/whisperkit-coreml)を参照してください。

### カスタムモデル

WhisperKit は、[`whisperkittools`](https://github.com/argmaxinc/whisperkittools) リポジトリを使用して、CoreML 形式でカスタムの微調整バージョンの Whisper を作成およびデプロイすることをサポートしています。生成後、リポジトリ名を変更することでロードできます：

```swift
let config = WhisperKitConfig(model: "large-v3", modelRepo: "username/your-model-repo")
let pipe = try? await WhisperKit(config)
```

## Flutter との統合

Flutter WhisperKit Apple プラグインは、Flutter アプリケーションとネイティブの WhisperKit フレームワークの間のブリッジを提供します。これにより、Flutter 開発者はネイティブコードを自分で書くことなく、iOS および macOS アプリケーションに音声テキスト変換機能を実装できます。

### Flutter プラグインの構造

Flutter プラグインは以下で構成されています：

1. **Flutter API レイヤー**: Flutter アプリケーション向けのクリーンなインターフェースを提供する Dart コード
2. **プラットフォームチャネル通信**: Dart コードとネイティブ Apple プラットフォームコードの間のブリッジ
3. **ネイティブ実装**: WhisperKit フレームワークとインターフェースする iOS/macOS Swift コード

### Flutter での WhisperKit の使用

Flutter アプリケーションで WhisperKit を使用するには：

1. pubspec.yaml に Flutter WhisperKit Apple プラグインを追加
2. Dart コードでプラグインをインポート
3. プラグインを初期化し、その API を使用して文字起こしを実行

Flutter プラグインの使用に関する詳細情報については、[Flutter WhisperKit Apple ドキュメント](https://github.com/r0227n/flutter_whisperkit)を参照してください。

## 追加リソース

- [TestFlight デモアプリ](https://testflight.apple.com/join/LPVOyJZW)
- [Python ツール](https://github.com/argmaxinc/whisperkittools)
- [ベンチマークとデバイスサポート](https://huggingface.co/spaces/argmaxinc/whisperkit-benchmarks)
- [WhisperKit Android](https://github.com/argmaxinc/WhisperKitAndroid)

## ライセンス

WhisperKit は MIT ライセンスの下でリリースされています。詳細については[LICENSE](https://github.com/argmaxinc/WhisperKit/blob/main/LICENSE)を参照してください。
