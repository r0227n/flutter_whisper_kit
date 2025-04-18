# WhisperKit API リファレンス

このドキュメントでは、WhisperKit API の詳細なリファレンスを提供します。クラス、メソッド、および設定オプションが含まれています。

## 主要クラス

### WhisperKit

WhisperKit フレームワークのエントリーポイントとなるメインクラスです。

#### 初期化

```swift
init(_ config: WhisperKitConfig = WhisperKitConfig()) async throws
```

指定された設定で新しい WhisperKit インスタンスを作成します。

**パラメータ:**
- `config`: WhisperKit の設定オプション。デフォルトは標準設定です。

**スロー:**
- `WhisperKitError.modelNotFound`: 指定されたモデルが見つからない場合。
- `WhisperKitError.modelLoadFailed`: モデルのロードに失敗した場合。
- `WhisperKitError.invalidConfiguration`: 設定が無効な場合。

#### メソッド

##### transcribe(audioPath:)

```swift
func transcribe(audioPath: String) async throws -> TranscriptionResult?
```

ファイルから音声を文字起こしします。

**パラメータ:**
- `audioPath`: 文字起こしする音声ファイルへのパス。

**戻り値:**
- `TranscriptionResult?`: 文字起こし結果、または文字起こしに失敗した場合は nil。

**スロー:**
- `WhisperKitError.fileNotFound`: 音声ファイルが見つからない場合。
- `WhisperKitError.audioProcessingFailed`: 音声処理に失敗した場合。
- `WhisperKitError.transcriptionFailed`: 文字起こしに失敗した場合。

##### transcribe(audioData:)

```swift
func transcribe(audioData: Data) async throws -> TranscriptionResult?
```

生の音声データから文字起こしします。

**パラメータ:**
- `audioData`: 文字起こしする生の音声データ。

**戻り値:**
- `TranscriptionResult?`: 文字起こし結果、または文字起こしに失敗した場合は nil。

**スロー:**
- `WhisperKitError.audioProcessingFailed`: 音声処理に失敗した場合。
- `WhisperKitError.transcriptionFailed`: 文字起こしに失敗した場合。

##### startStreaming(config:)

```swift
func startStreaming(config: StreamingConfig = StreamingConfig()) async throws
```

マイクからのストリーミング文字起こしを開始します。

**パラメータ:**
- `config`: ストリーミングの設定オプション。デフォルトは標準設定です。

**スロー:**
- `WhisperKitError.microphoneAccessDenied`: マイクへのアクセスが拒否された場合。
- `WhisperKitError.streamingSetupFailed`: ストリーミングのセットアップに失敗した場合。

##### stopStreaming()

```swift
func stopStreaming() async throws -> TranscriptionResult?
```

ストリーミング文字起こしを停止し、最終結果を返します。

**戻り値:**
- `TranscriptionResult?`: 最終的な文字起こし結果、または文字起こしに失敗した場合は nil。

**スロー:**
- `WhisperKitError.streamingNotActive`: ストリーミングがアクティブでない場合。
- `WhisperKitError.transcriptionFailed`: 文字起こしに失敗した場合。

### WhisperKitConfig

WhisperKit の設定オプション。

#### プロパティ

```swift
var model: String = "medium"
```
文字起こしに使用するモデル。オプションには "tiny"、"small"、"medium"、"large"、および "large-v3" が含まれます。

```swift
var modelRepo: String = "argmaxinc/whisperkit-coreml"
```
モデルをダウンロードするリポジトリ。

```swift
var language: String? = nil
```
文字起こしに使用する言語。nil の場合、言語は自動検出されます。

```swift
var task: TranscriptionTask = .transcribe
```
文字起こしタスク。オプションには `.transcribe` と `.translate` があります。

```swift
var enableVAD: Bool = true
```
音声アクティビティ検出を有効にするかどうか。

```swift
var vadFallbackTimeout: TimeInterval = 3.0
```
VAD フォールバックのタイムアウト（秒）。

```swift
var enablePunctuation: Bool = true
```
自動句読点を有効にするかどうか。

```swift
var enableFormatting: Bool = true
```
テキストフォーマットを有効にするかどうか。

```swift
var enableTimestamps: Bool = false
```
文字起こしにタイムスタンプを含めるかどうか。

### StreamingConfig

ストリーミング文字起こしの設定オプション。

#### プロパティ

```swift
var bufferSize: Int = 4096
```
サンプル単位のオーディオバッファのサイズ。

```swift
var sampleRate: Double = 16000
```
Hz 単位のオーディオのサンプルレート。

```swift
var channels: Int = 1
```
オーディオチャンネルの数。

```swift
var updateInterval: TimeInterval = 0.5
```
文字起こし更新間の間隔（秒）。

### TranscriptionResult

文字起こし操作の結果を表します。

#### プロパティ

```swift
var text: String
```
文字起こしされたテキスト。

```swift
var segments: [TranscriptionSegment]
```
詳細情報を持つセグメントのリスト。

```swift
var language: String?
```
検出または指定された言語。

```swift
var processingTime: TimeInterval
```
文字起こしの処理にかかった時間。

### TranscriptionSegment

文字起こしされた音声のセグメントを表します。

#### プロパティ

```swift
var text: String
```
このセグメントの文字起こしされたテキスト。

```swift
var startTime: TimeInterval
```
セグメントの開始時間（秒）。

```swift
var endTime: TimeInterval
```
セグメントの終了時間（秒）。

```swift
var confidence: Double
```
このセグメントの信頼度スコア（0.0 から 1.0）。

```swift
var words: [WordTiming]?
```
利用可能な場合、個々の単語のタイミング情報。

### WordTiming

単語のタイミング情報を表します。

#### プロパティ

```swift
var word: String
```
単語のテキスト。

```swift
var startTime: TimeInterval
```
単語の開始時間（秒）。

```swift
var endTime: TimeInterval
```
単語の終了時間（秒）。

```swift
var confidence: Double
```
この単語の信頼度スコア（0.0 から 1.0）。

## 列挙型

### TranscriptionTask

```swift
enum TranscriptionTask {
    case transcribe
    case translate
}
```

文字起こしのタスクを定義します：
- `transcribe`: 元の言語で音声を文字起こし
- `translate`: 音声を文字起こしし、英語に翻訳

### WhisperKitError

```swift
enum WhisperKitError: Error {
    case modelNotFound
    case modelLoadFailed
    case invalidConfiguration
    case fileNotFound
    case audioProcessingFailed
    case transcriptionFailed
    case microphoneAccessDenied
    case streamingSetupFailed
    case streamingNotActive
}
```

WhisperKit 操作中に発生する可能性のあるエラーを定義します。

## プロトコル

### TranscriptionDelegate

```swift
protocol TranscriptionDelegate: AnyObject {
    func transcriptionDidUpdate(result: TranscriptionResult)
    func transcriptionDidComplete(result: TranscriptionResult?)
    func transcriptionDidFail(error: Error)
}
```

文字起こしの更新を受け取るためのデリゲートプロトコル。

#### メソッド

```swift
func transcriptionDidUpdate(result: TranscriptionResult)
```
部分的な文字起こし結果が利用可能になったときに呼び出されます。

```swift
func transcriptionDidComplete(result: TranscriptionResult?)
```
文字起こしが完了したときに呼び出されます。

```swift
func transcriptionDidFail(error: Error)
```
文字起こしが失敗したときに呼び出されます。

## 拡張機能

### String 拡張機能

```swift
extension String {
    func containsLanguage(_ language: String) -> Bool
}
```

文字列に特定の言語のテキストが含まれているかどうかを確認します。

```swift
extension String {
    func formatTranscription(enablePunctuation: Bool, enableFormatting: Bool) -> String
}
```

句読点とフォーマットで文字起こしテキストをフォーマットします。

## 使用例

### 基本的な文字起こし

```swift
import WhisperKit

Task {
    do {
        let whisperKit = try await WhisperKit()
        let result = try await whisperKit.transcribe(audioPath: "path/to/audio.mp3")
        print("文字起こし: \(result?.text ?? "文字起こしが利用できません")")
    } catch {
        print("エラー: \(error)")
    }
}
```

### デリゲートを使用したストリーミング文字起こし

```swift
import WhisperKit

class TranscriptionManager: TranscriptionDelegate {
    private var whisperKit: WhisperKit?
    
    func startTranscription() async {
        do {
            whisperKit = try await WhisperKit()
            whisperKit?.delegate = self
            try await whisperKit?.startStreaming()
        } catch {
            print("エラー: \(error)")
        }
    }
    
    func stopTranscription() async {
        do {
            let result = try await whisperKit?.stopStreaming()
            print("最終的な文字起こし: \(result?.text ?? "文字起こしが利用できません")")
        } catch {
            print("エラー: \(error)")
        }
    }
    
    // TranscriptionDelegate メソッド
    func transcriptionDidUpdate(result: TranscriptionResult) {
        print("部分的な文字起こし: \(result.text)")
    }
    
    func transcriptionDidComplete(result: TranscriptionResult?) {
        print("文字起こし完了: \(result?.text ?? "文字起こしが利用できません")")
    }
    
    func transcriptionDidFail(error: Error) {
        print("文字起こし失敗: \(error)")
    }
}
```

### カスタム設定

```swift
import WhisperKit

Task {
    do {
        var config = WhisperKitConfig()
        config.model = "large-v3"
        config.language = "ja"
        config.enableVAD = true
        config.enableTimestamps = true
        
        let whisperKit = try await WhisperKit(config)
        let result = try await whisperKit.transcribe(audioPath: "path/to/audio.mp3")
        
        print("文字起こし: \(result?.text ?? "文字起こしが利用できません")")
        
        if let segments = result?.segments {
            for segment in segments {
                print("セグメント: \(segment.text)")
                print("時間: \(segment.startTime) - \(segment.endTime)")
                
                if let words = segment.words {
                    for word in words {
                        print("単語: \(word.word), 時間: \(word.startTime) - \(word.endTime)")
                    }
                }
            }
        }
    } catch {
        print("エラー: \(error)")
    }
}
```
