# WhisperKit クラスのドキュメント

このドキュメントは、[WhisperKit](https://github.com/argmaxinc/WhisperKit)の`WhisperKit`クラスのプロパティと関数について解説します。WhisperKitは、Apple製デバイス上でオンデバイス音声認識を実行するためのSwiftフレームワークです。

## 対応プラットフォーム

```swift
@available(macOS 13, iOS 16, watchOS 10, visionOS 1, *)
```

WhisperKitは以下のプラットフォームで利用可能です：
- macOS 13以上
- iOS 16以上
- watchOS 10以上
- visionOS 1以上

## プロパティ

### モデル関連

```swift
public private(set) var modelVariant: ModelVariant = .tiny
```
- **説明**: 現在使用中のWhisperモデルのバリアント（サイズ）
- **デフォルト値**: `.tiny`
- **アクセス**: 読み取り専用（外部からは変更不可）

```swift
public private(set) var modelState: ModelState = .unloaded
```
- **説明**: モデルの現在の状態（読み込み済み、読み込み中など）
- **デフォルト値**: `.unloaded`（未読み込み）
- **アクセス**: 読み取り専用
- **特記事項**: 値が変更されると`modelStateCallback`が呼び出される

```swift
public var modelCompute: ModelComputeOptions
```
- **説明**: モデルの計算オプション（CPU、GPU、Neural Engineの使用設定など）
- **アクセス**: 読み書き可能

```swift
public var tokenizer: WhisperTokenizer?
```
- **説明**: テキストのトークン化と逆トークン化を処理するトークナイザー
- **アクセス**: 読み書き可能
- **型**: オプショナル

### プロトコル実装

```swift
public var audioProcessor: any AudioProcessing
```
- **説明**: 音声処理を担当するコンポーネント
- **プロトコル**: `AudioProcessing`

```swift
public var featureExtractor: any FeatureExtracting
```
- **説明**: 音声からMel特徴量を抽出するコンポーネント
- **プロトコル**: `FeatureExtracting`

```swift
public var audioEncoder: any AudioEncoding
```
- **説明**: Mel特徴量をエンコードするコンポーネント
- **プロトコル**: `AudioEncoding`

```swift
public var textDecoder: any TextDecoding
```
- **説明**: エンコードされた特徴量からテキストを生成するコンポーネント
- **プロトコル**: `TextDecoding`

```swift
public var logitsFilters: [any LogitsFiltering]
```
- **説明**: デコード中にロジットをフィルタリングするコンポーネントの配列
- **プロトコル**: `LogitsFiltering`の配列

```swift
public var segmentSeeker: any SegmentSeeking
```
- **説明**: 音声セグメントを検索するコンポーネント
- **プロトコル**: `SegmentSeeking`

```swift
public var voiceActivityDetector: VoiceActivityDetector?
```
- **説明**: 音声アクティビティ検出（VAD）を担当するコンポーネント
- **型**: オプショナル

### 形状定数

```swift
public static let sampleRate: Int = 16000
```
- **説明**: 音声のサンプルレート（Hz）
- **値**: 16000

```swift
public static let hopLength: Int = 160
```
- **説明**: 特徴抽出時のホップ長
- **値**: 160

```swift
public static let secondsPerTimeToken = Float(0.02)
```
- **説明**: 各時間トークンが表す秒数
- **値**: 0.02秒

### 進捗と計測

```swift
public private(set) var currentTimings: TranscriptionTimings
```
- **説明**: 文字起こし処理の各段階の時間計測
- **アクセス**: 読み取り専用

```swift
public private(set) var progress = Progress()
```
- **説明**: 文字起こし処理の進捗状況
- **アクセス**: 読み取り専用

### 設定

```swift
public var modelFolder: URL?
```
- **説明**: モデルファイルが格納されているフォルダのURL
- **型**: オプショナル

```swift
public var tokenizerFolder: URL?
```
- **説明**: トークナイザーファイルが格納されているフォルダのURL
- **型**: オプショナル

```swift
public private(set) var useBackgroundDownloadSession: Bool
```
- **説明**: バックグラウンドダウンロードセッションを使用するかどうか
- **アクセス**: 読み取り専用

### コールバック

```swift
public var segmentDiscoveryCallback: SegmentDiscoveryCallback?
```
- **説明**: 新しいセグメントが発見されたときに呼び出されるコールバック
- **型**: オプショナル

```swift
public var modelStateCallback: ModelStateCallback?
```
- **説明**: モデルの状態が変更されたときに呼び出されるコールバック
- **型**: オプショナル

```swift
public var transcriptionStateCallback: TranscriptionStateCallback?
```
- **説明**: 文字起こし処理の状態が変更されたときに呼び出されるコールバック
- **型**: オプショナル

## 初期化メソッド

### 主要な初期化メソッド

```swift
public init(_ config: WhisperKitConfig = WhisperKitConfig()) async throws
```
- **説明**: WhisperKitの主要な初期化メソッド
- **パラメータ**:
  - `config`: WhisperKitの設定オブジェクト（デフォルト値あり）
- **戻り値**: なし
- **例外**: モデルのセットアップや読み込み中にエラーが発生した場合にスロー
- **非同期**: `async`で実行され、完了を待機する必要がある
- **処理内容**:
  1. 設定オブジェクトから各種コンポーネントを初期化
  2. モデルのセットアップを実行
  3. 必要に応じてモデルのプリウォームと読み込みを実行

### 便利な初期化メソッド

```swift
public convenience init(
    model: String? = nil,
    downloadBase: URL? = nil,
    modelRepo: String? = nil,
    modelFolder: String? = nil,
    tokenizerFolder: URL? = nil,
    computeOptions: ModelComputeOptions? = nil,
    audioProcessor: (any AudioProcessing)? = nil,
    featureExtractor: (any FeatureExtracting)? = nil,
    audioEncoder: (any AudioEncoding)? = nil,
    textDecoder: (any TextDecoding)? = nil,
    logitsFilters: [any LogitsFiltering]? = nil,
    segmentSeeker: (any SegmentSeeking)? = nil,
    verbose: Bool = true,
    logLevel: Logging.LogLevel = .info,
    prewarm: Bool? = nil,
    load: Bool? = nil,
    download: Bool = true,
    useBackgroundDownloadSession: Bool = false
) async throws
```
- **説明**: 個別のパラメータを指定して初期化できる便利なイニシャライザ
- **パラメータ**:
  - `model`: モデルバリアント名（オプショナル）
  - `downloadBase`: ダウンロードのベースURL（オプショナル）
  - `modelRepo`: モデルリポジトリ名（オプショナル）
  - `modelFolder`: モデルフォルダのパス（オプショナル）
  - `tokenizerFolder`: トークナイザーフォルダのURL（オプショナル）
  - `computeOptions`: 計算オプション（オプショナル）
  - `audioProcessor`: 音声処理コンポーネント（オプショナル）
  - `featureExtractor`: 特徴抽出コンポーネント（オプショナル）
  - `audioEncoder`: 音声エンコーダーコンポーネント（オプショナル）
  - `textDecoder`: テキストデコーダーコンポーネント（オプショナル）
  - `logitsFilters`: ロジットフィルターの配列（オプショナル）
  - `segmentSeeker`: セグメントシーカーコンポーネント（オプショナル）
  - `verbose`: 詳細なログ出力を有効にするかどうか（デフォルト: true）
  - `logLevel`: ログレベル（デフォルト: .info）
  - `prewarm`: モデルをプリウォームするかどうか（オプショナル）
  - `load`: モデルを読み込むかどうか（オプショナル）
  - `download`: モデルをダウンロードするかどうか（デフォルト: true）
  - `useBackgroundDownloadSession`: バックグラウンドダウンロードセッションを使用するかどうか（デフォルト: false）
- **処理内容**: パラメータから`WhisperKitConfig`オブジェクトを作成し、主要な初期化メソッドを呼び出す

## モデル読み込み関連メソッド

### デバイス名取得

```swift
public static func deviceName() -> String
```
- **説明**: 現在のデバイス名を取得する
- **戻り値**: デバイス名の文字列
- **処理内容**: プラットフォームに応じてデバイス名を取得する方法が異なる

### 推奨モデル取得

```swift
public static func recommendedModels() -> ModelSupport
```
- **説明**: 現在のデバイスに推奨されるモデルを取得する
- **戻り値**: `ModelSupport`オブジェクト（サポートされているモデルとデフォルトモデルの情報を含む）
- **処理内容**: デバイス名を取得し、そのデバイスに適したモデルサポート情報を返す

```swift
public static func recommendedRemoteModels(
    from repo: String = "argmaxinc/whisperkit-coreml",
    downloadBase: URL? = nil,
    token: String? = nil
) async -> ModelSupport
```
- **説明**: リモートリポジトリから現在のデバイスに推奨されるモデルを取得する
- **パラメータ**:
  - `repo`: モデルリポジトリ名（デフォルト: "argmaxinc/whisperkit-coreml"）
  - `downloadBase`: ダウンロードのベースURL（オプショナル）
  - `token`: アクセストークン（オプショナル）
- **戻り値**: `ModelSupport`オブジェクト
- **非同期**: `async`で実行される
- **処理内容**: リモートリポジトリからモデルサポート設定を取得し、デバイスに適したモデルサポート情報を返す

### モデルサポート設定取得

```swift
public static func fetchModelSupportConfig(
    from repo: String = "argmaxinc/whisperkit-coreml",
    downloadBase: URL? = nil,
    token: String? = nil
) async -> ModelSupportConfig
```
- **説明**: リモートリポジトリからモデルサポート設定を取得する
- **パラメータ**:
  - `repo`: モデルリポジトリ名（デフォルト: "argmaxinc/whisperkit-coreml"）
  - `downloadBase`: ダウンロードのベースURL（オプショナル）
  - `token`: アクセストークン（オプショナル）
- **戻り値**: `ModelSupportConfig`オブジェクト
- **非同期**: `async`で実行される
- **処理内容**: 
  1. HubApiを使用してリポジトリからconfig.jsonファイルを取得
  2. JSONデータを`ModelSupportConfig`オブジェクトにデコード
  3. エラーが発生した場合はフォールバック設定を使用

### 利用可能なモデル取得

```swift
public static func fetchAvailableModels(
    from repo: String = "argmaxinc/whisperkit-coreml",
    matching: [String] = ["*"],
    downloadBase: URL? = nil,
    token: String? = nil
) async throws -> [String]
```
- **説明**: リモートリポジトリから利用可能なモデルのリストを取得する
- **パラメータ**:
  - `repo`: モデルリポジトリ名（デフォルト: "argmaxinc/whisperkit-coreml"）
  - `matching`: マッチングパターンの配列（デフォルト: ["*"]）
  - `downloadBase`: ダウンロードのベースURL（オプショナル）
  - `token`: アクセストークン（オプショナル）
- **戻り値**: 利用可能なモデル名の配列
- **非同期**: `async`で実行される
- **例外**: モデル取得中にエラーが発生した場合にスロー
- **処理内容**:
  1. モデルサポート設定を取得
  2. サポートされているモデルをフィルタリング
  3. モデルファイル名をフォーマット

### モデルファイル名フォーマット

```swift
public static func formatModelFiles(_ modelFiles: [String]) -> [String]
```
- **説明**: モデルファイル名を整形する
- **パラメータ**:
  - `modelFiles`: モデルファイル名の配列
- **戻り値**: 整形されたモデルファイル名の配列
- **処理内容**:
  1. モデルバリアントに基づいてファイル名をフィルタリング
  2. バリアント名を抽出
  3. モデルサイズに基づいてソート

### モデルダウンロード

```swift
public static func download(
    variant: String,
    downloadBase: URL? = nil,
    useBackgroundSession: Bool = false,
    from repo: String = "argmaxinc/whisperkit-coreml",
    token: String? = nil,
    progressCallback: ((Progress) -> Void)? = nil
) async throws -> URL
```
- **説明**: 指定されたバリアントのモデルをダウンロードする
- **パラメータ**:
  - `variant`: モデルバリアント名
  - `downloadBase`: ダウンロードのベースURL（オプショナル）
  - `useBackgroundSession`: バックグラウンドセッションを使用するかどうか（デフォルト: false）
  - `repo`: モデルリポジトリ名（デフォルト: "argmaxinc/whisperkit-coreml"）
  - `token`: アクセストークン（オプショナル）
  - `progressCallback`: 進捗コールバック（オプショナル）
- **戻り値**: ダウンロードされたモデルフォルダのURL
- **非同期**: `async`で実行される
- **例外**: ダウンロード中にエラーが発生した場合にスロー
- **処理内容**:
  1. HubApiを使用してリポジトリからモデルファイルを検索
  2. 一意のモデルパスを特定
  3. モデルをダウンロード
  4. ダウンロードされたモデルフォルダのURLを返す

### モデルセットアップ

```swift
open func setupModels(
    model: String?,
    downloadBase: URL? = nil,
    modelRepo: String?,
    modelToken: String? = nil,
    modelFolder: String?,
    download: Bool
) async throws
```
- **説明**: モデルフォルダをローカルパスから設定するか、リポジトリからダウンロードする
- **パラメータ**:
  - `model`: モデルバリアント名（オプショナル）
  - `downloadBase`: ダウンロードのベースURL（オプショナル）
  - `modelRepo`: モデルリポジトリ名（オプショナル）
  - `modelToken`: アクセストークン（オプショナル）
  - `modelFolder`: モデルフォルダのパス（オプショナル）
  - `download`: モデルをダウンロードするかどうか
- **非同期**: `async`で実行される
- **例外**: セットアップ中にエラーが発生した場合にスロー
- **処理内容**:
  1. ローカルモデルフォルダが指定されている場合はそれを使用
  2. そうでなく、ダウンロードが有効な場合はモデルをダウンロード
  3. モデルフォルダのURLを設定

### モデルプリウォーム

```swift
open func prewarmModels() async throws
```
- **説明**: モデルをプリウォームする（事前に準備して高速化する）
- **非同期**: `async`で実行される
- **例外**: プリウォーム中にエラーが発生した場合にスロー
- **処理内容**: プリウォームモードでモデルを読み込む

### モデル読み込み

```swift
open func loadModels(
    prewarmMode: Bool = false
) async throws
```
- **説明**: モデルを読み込む
- **パラメータ**:
  - `prewarmMode`: プリウォームモードで読み込むかどうか（デフォルト: false）
- **非同期**: `async`で実行される
- **例外**: 読み込み中にエラーが発生した場合にスロー
- **処理内容**:
  1. モデル状態を更新
  2. モデルフォルダからモデルファイルを検出
  3. 特徴抽出器、テキストデコーダー、音声エンコーダーを読み込み
  4. プリウォームモードでない場合はトークナイザーも読み込み
  5. モデルバリアントを検出
  6. 読み込み時間を計測

### モデルアンロード

```swift
open func unloadModels() async
```
- **説明**: モデルをアンロードする
- **非同期**: `async`で実行される
- **処理内容**:
  1. モデル状態を更新
  2. 各モデルコンポーネントをアンロード
  3. モデル状態を未読み込み状態に設定

### 状態クリア

```swift
open func clearState()
```
- **説明**: 内部状態をクリアする
- **処理内容**:
  1. 音声処理を停止
  2. 文字起こし時間計測をリセット

### ロギングコールバック設定

```swift
open func loggingCallback(_ callback: Logging.LoggingCallback?)
```
- **説明**: ロギングコールバックを設定する
- **パラメータ**:
  - `callback`: ロギングコールバック（オプショナル）
- **処理内容**: 共有ロギングインスタンスにコールバックを設定

## 言語検出関連メソッド

### 音声ファイルからの言語検出

```swift
open func detectLanguage(
    audioPath: String
) async throws -> (language: String, langProbs: [String: Float])
```
- **説明**: 指定された音声ファイルの言語を検出する
- **パラメータ**:
  - `audioPath`: 音声ファイルのパス
- **戻り値**: 検出された言語と言語確率のタプル
- **非同期**: `async`で実行される
- **例外**: 言語検出中にエラーが発生した場合にスロー
- **処理内容**:
  1. 音声ファイルから最初の30秒を読み込み
  2. 音声配列に変換
  3. 言語検出メソッドを呼び出す

### 音声配列からの言語検出

```swift
open func detectLangauge(
    audioArray: [Float]
) async throws -> (language: String, langProbs: [String: Float])
```
- **説明**: 指定された音声配列の言語を検出する
- **パラメータ**:
  - `audioArray`: 音声サンプルの配列
- **戻り値**: 検出された言語と言語確率のタプル
- **非同期**: `async`で実行される
- **例外**: 言語検出中にエラーが発生した場合にスロー
- **処理内容**:
  1. モデルが読み込まれていない場合は読み込み
  2. モデルが多言語対応かチェック
  3. トークナイザーが利用可能かチェック
  4. デコーダー入力を準備
  5. 音声サンプルをパディングまたはトリミング
  6. Mel特徴量を抽出
  7. 特徴量をエンコード
  8. 言語を検出
  9. 検出された言語と確率を返す

## 文字起こし関連メソッド

### 複数音声ファイルの文字起こし（便利メソッド）

```swift
open func transcribe(
    audioPaths: [String],
    decodeOptions: DecodingOptions? = nil,
    callback: TranscriptionCallback = nil
) async -> [[TranscriptionResult]?]
```
- **説明**: 複数の音声ファイルを文字起こしする便利なメソッド
- **パラメータ**:
  - `audioPaths`: 音声ファイルパスの配列
  - `decodeOptions`: デコードオプション（オプショナル）
  - `callback`: 文字起こし進捗コールバック（オプショナル）
- **戻り値**: 文字起こし結果の配列の配列（オプショナル）
- **非同期**: `async`で実行される
- **処理内容**: 結果付きの文字起こしメソッドを呼び出し、結果をオプショナル配列に変換

### 複数音声ファイルの文字起こし（結果付き）

```swift
open func transcribeWithResults(
    audioPaths: [String],
    decodeOptions: DecodingOptions? = nil,
    callback: TranscriptionCallback = nil
) async -> [Result<[TranscriptionResult], Swift.Error>]
```
- **説明**: 複数の音声ファイルを文字起こしし、結果を返す
- **パラメータ**:
  - `audioPaths`: 音声ファイルパスの配列
  - `decodeOptions`: デコードオプション（オプショナル）
  - `callback`: 文字起こし進捗コールバック（オプショナル）
- **戻り値**: 文字起こし結果または失敗の`Result`オブジェクトの配列
- **非同期**: `async`で実行される
- **処理内容**:
  1. 文字起こし状態を更新
  2. 音声ファイルを読み込み
  3. 音声配列を文字起こし
  4. 結果を元の順序で返す

### 複数音声配列の文字起こし（便利メソッド）

```swift
open func transcribe(
    audioArrays: [[Float]],
    decodeOptions: DecodingOptions? = nil,
    callback: TranscriptionCallback = nil
) async -> [[TranscriptionResult]?]
```
- **説明**: 複数の音声配列を文字起こしする便利なメソッド
- **パラメータ**:
  - `audioArrays`: 音声サンプル配列の配列
  - `decodeOptions`: デコードオプション（オプショナル）
  - `callback`: 文字起こし進捗コールバック（オプショナル）
- **戻り値**: 文字起こし結果の配列の配列（オプショナル）
- **非同期**: `async`で実行される
- **処理内容**: 結果付きの文字起こしメソッドを呼び出し、結果をオプショナル配列に変換

### 複数音声配列の文字起こし（結果付き）

```swift
open func transcribeWithResults(
    audioArrays: [[Float]],
    decodeOptions: DecodingOptions? = nil,
    callback: TranscriptionCallback = nil
) async -> [Result<[TranscriptionResult], Swift.Error>]
```
- **説明**: 複数の音声配列を文字起こしし、結果を返す
- **パラメータ**:
  - `audioArrays`: 音声サンプル配列の配列
  - `decodeOptions`: デコードオプション（オプショナル）
  - `callback`: 文字起こし進捗コールバック（オプショナル）
- **戻り値**: 文字起こし結果または失敗の`Result`オブジェクトの配列
- **非同期**: `async`で実行される
- **処理内容**: 同じデコードオプションを持つ配列を作成し、オプション付きの文字起こしメソッドを呼び出す

### 複数音声配列の文字起こし（オプション付き）

```swift
open func transcribeWithOptions(
    audioArrays: [[Float]],
    decodeOptionsArray: [DecodingOptions?] = [nil],
    callback: TranscriptionCallback = nil
) async -> [Result<[TranscriptionResult], Swift.Error>]
```
- **説明**: 複数の音声配列を関連するデコードオプションで文字起こしする
- **パラメータ**:
  - `audioArrays`: 音声サンプル配列の配列
  - `decodeOptionsArray`: 各音声配列に対応するデコードオプションの配列（デフォルト: [nil]）
  - `callback`: 文字起こし進捗コールバック（オプショナル）
- **戻り値**: 文字起こし結果または失敗の`Result`オブジェクトの配列
- **非同期**: `async`で実行される
- **処理内容**:
  1. 音声配列とデコードオプションの数が一致するか確認
  2. 並行ワーカー数を決定
  3. 音声配列をバッチに分割
  4. 各バッチを並行して処理
  5. 結果を元の順序で返す

### 単一音声ファイルの文字起こし（非推奨）

```swift
@available(*, deprecated, message: "Subject to removal in a future version. Use `transcribe(audioPath:decodeOptions:callback:) async throws -> [TranscriptionResult]` instead.")
@_disfavoredOverload
open func transcribe(
    audioPath: String,
    decodeOptions: DecodingOptions? = nil,
    callback: TranscriptionCallback = nil
) async throws -> TranscriptionResult?
```
- **説明**: 単一の音声ファイルを文字起こしする（非推奨）
- **パラメータ**:
  - `audioPath`: 音声ファイルのパス
  - `decodeOptions`: デコードオプション（オプショナル）
  - `callback`: 文字起こし進捗コールバック（オプショナル）
- **戻り値**: 文字起こし結果（オプショナル）
- **非同期**: `async`で実行される
- **例外**: 文字起こし中にエラーが発生した場合にスロー
- **処理内容**: 新しいメソッドを呼び出し、最初の結果を返す

### 単一音声ファイルの文字起こし

```swift
open func transcribe(
    audioPath: String,
    decodeOptions: DecodingOptions? = nil,
    callback: TranscriptionCallback = nil
) async throws -> [TranscriptionResult]
```
- **説明**: 単一の音声ファイルを文字起こしする
- **パラメータ**:
  - `audioPath`: 音声ファイルのパス
  - `decodeOptions`: デコードオプション（オプショナル）
  - `callback`: 文字起こし進捗コールバック（オプショナル）
- **戻り値**: 文字起こし結果の配列
- **非同期**: `async`で実行される
- **例外**: 文字起こし中にエラーが発生した場合にスロー
- **処理内容**:
  1. 文字起こし状態を更新
  2. 音声ファイルを音声サンプル配列に変換
  3. 音声配列を文字起こし
  4. 結果を返す

### 単一音声配列の文字起こし（非推奨）

```swift
@available(*, deprecated, message: "Subject to removal in a future version. Use `transcribe(audioArray:decodeOptions:callback:) async throws -> [TranscriptionResult]` instead.")
@_disfavoredOverload
open func transcribe(
    audioArray: [Float],
    decodeOptions: DecodingOptions? = nil,
    callback: TranscriptionCallback = nil
) async throws -> TranscriptionResult?
```
- **説明**: 単一の音声配列を文字起こしする（非推奨）
- **パラメータ**:
  - `audioArray`: 音声サンプルの配列
  - `decodeOptions`: デコードオプション（オプショナル）
  - `callback`: 文字起こし進捗コールバック（オプショナル）
- **戻り値**: 文字起こし結果（オプショナル）
- **非同期**: `async`で実行される
- **例外**: 文字起こし中にエラーが発生した場合にスロー
- **処理内容**: 新しいメソッドを呼び出し、最初の結果を返す

### 単一音声配列の文字起こし

```swift
open func transcribe(
    audioArray: [Float],
    decodeOptions: DecodingOptions? = nil,
    callback: TranscriptionCallback = nil
) async throws -> [TranscriptionResult]
```
- **説明**: 単一の音声配列を文字起こしする
- **パラメータ**:
  - `audioArray`: 音声サンプルの配列
  - `decodeOptions`: デコードオプション（オプショナル）
  - `callback`: 文字起こし進捗コールバック（オプショナル）
- **戻り値**: 文字起こし結果の配列
- **非同期**: `async`で実行される
- **例外**: 文字起こし中にエラーが発生した場合にスロー
- **処理内容**:
  1. 音声配列がチャンク分割が必要かどうかを判断
  2. 必要に応じてVADを使用してチャンク分割
  3. 各チャンクを文字起こし
  4. 結果を返す

### 文字起こしタスク実行

```swift
open func runTranscribeTask(
    audioArray: [Float],
    decodeOptions: DecodingOptions? = nil,
    callback: TranscriptionCallback = nil
) async throws -> [TranscriptionResult]
```
- **説明**: 単一の音声サンプル配列に対して文字起こしタスクを実行する
- **パラメータ**:
  - `audioArray`: 音声サンプルの配列
  - `decodeOptions`: デコードオプション（オプショナル）
  - `callback`: 文字起こし進捗コールバック（オプショナル）
- **戻り値**: 文字起こし結果の配列
- **非同期**: `async`で実行される
- **例外**: 文字起こし中にエラーが発生した場合にスロー
- **処理内容**:
  1. モデルが読み込まれていない場合は読み込み
  2. トークナイザーが利用可能かチェック
  3. キャンセルチェック
  4. 進捗オブジェクトを設定
  5. 文字起こしタスクを作成
  6. タスクを実行
  7. 結果を返す
