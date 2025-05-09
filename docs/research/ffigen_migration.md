# Flutter WhisperKitにおけるffigenへの移行に関する調査

## 目次

1. [現在の実装概要](#現在の実装概要)
2. [ffigenとは](#ffigenとは)
3. [ffigenへの移行メリット](#ffigenへの移行メリット)
4. [ffigenの導入方法](#ffigenの導入方法)
5. [完全移行のためのステップ](#完全移行のためのステップ)
6. [イベントチャネルの代替実装](#イベントチャネルの代替実装)
7. [課題と対策](#課題と対策)
8. [まとめ](#まとめ)

## 現在の実装概要

現在のFlutter WhisperKitプラグインは、Flutter（Dart）とSwift間の通信に以下の方法を使用しています：

- **MethodChannel**: Flutterとネイティブコードとのメソッド呼び出しに使用
- **EventChannel**: 進捗状況やリアルタイム転写結果などの継続的なデータストリームに使用
- **Pigeon**: 型安全なメッセージングコードを自動生成するためのツール

現在の実装では、`WhisperKitMessage`インターフェースを通じてDartからSwiftへのメソッド呼び出しを行い、`TranscriptionStreamHandler`と`ModelProgressStreamHandler`を使用して継続的なデータをDartに送信しています。

## ffigenとは

ffigen（Foreign Function Interface GENerator）は、C言語のヘッダーファイルからDartのFFI（Foreign Function Interface）バインディングを自動生成するツールです。最近のバージョンでは、Objective-CとSwiftコードに対する実験的なサポートが追加されました。

ffigenの主な特徴：

- C/C++ヘッダーファイルからDartバインディングを生成
- Objective-CとSwiftコードに対する実験的サポート
- LLVMを使用したコード解析
- 高度なカスタマイズオプション
- ネイティブライブラリとの直接的な連携

## ffigenへの移行メリット

MethodChannel/Pigeonからffigenへの移行には以下のメリットがあります：

### 1. パフォーマンスの向上

- **低レイテンシ**: FFIは直接的なネイティブコード呼び出しを行うため、MethodChannelよりも低いレイテンシを実現
- **オーバーヘッドの削減**: メッセージのシリアライズ/デシリアライズのオーバーヘッドを削減
- **メモリ効率**: 大きなデータセットの場合、メモリコピーを減らすことが可能

### 2. 型安全性の向上

- **コンパイル時の型チェック**: FFIバインディングはコンパイル時に型チェックされるため、実行時エラーのリスクが低減
- **自動生成されたバインディング**: ffigenが自動生成するコードにより、型の不一致を防止
- **ネイティブ型との直接マッピング**: DartとSwiftの型の間でより正確なマッピングが可能

### 3. コードの簡素化

- **ボイラープレートコードの削減**: シリアライズ/デシリアライズのためのコードが不要に
- **メンテナンスの容易さ**: 型定義の変更時に自動的にバインディングが更新される
- **一貫性のある実装**: 統一されたアプローチでネイティブコードとの連携が可能

### 4. 将来性

- **Dartの方向性**: DartチームはFFIの改善に注力しており、将来的にさらなる機能強化が期待できる
- **クロスプラットフォーム**: 同じアプローチでiOS/macOSだけでなく、将来的にAndroidなど他のプラットフォームもサポート可能
- **最新技術への対応**: 新しいDartやFlutterのバージョンとの互換性が向上

## ffigenの導入方法

Flutter WhisperKitプラグインにffigenを導入するための手順は以下の通りです：

### 1. 依存関係の追加

`pubspec.yaml`に以下の依存関係を追加します：

```yaml
dependencies:
  ffi: ^2.1.0

dev_dependencies:
  ffigen: ^10.0.0
```

### 2. ffigen設定の追加

`pubspec.yaml`にffigenの設定を追加します：

```yaml
ffigen:
  name: 'WhisperKitBindings'
  description: 'Bindings for WhisperKit'
  language: 'objc++'  # Swift用の実験的サポートを使用
  output: 'lib/src/bindings/whisper_kit_bindings.dart'
  headers:
    entry-points:
      - 'darwin/flutter_whisper_kit_apple/Sources/flutter_whisper_kit_apple/WhisperKitBindings.h'
  objc-interfaces:
    include:
      - 'WhisperKit.*'
```

### 3. ブリッジヘッダーファイルの作成

SwiftコードをObjective-C++から呼び出すためのブリッジヘッダーファイルを作成します：

```objc
// WhisperKitBindings.h
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WhisperKitBridge : NSObject

+ (nullable NSString *)loadModel:(nullable NSString *)variant
                       modelRepo:(nullable NSString *)modelRepo
                      redownload:(BOOL)redownload
                           error:(NSError **)error;

+ (nullable NSString *)transcribeFromFile:(NSString *)filePath
                                  options:(NSDictionary *)options
                                    error:(NSError **)error;

+ (nullable NSString *)startRecording:(NSDictionary *)options
                                 loop:(BOOL)loop
                                error:(NSError **)error;

+ (nullable NSString *)stopRecording:(BOOL)loop
                               error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
```

### 4. ブリッジ実装の作成

SwiftからObjective-Cブリッジを実装します：

```swift
// WhisperKitBridge.swift
import Foundation
import WhisperKit

@objc public class WhisperKitBridge: NSObject {
    private static let whisperKitImpl = WhisperKitApiImpl()
    
    @objc public static func loadModel(_ variant: String?,
                                      modelRepo: String?,
                                      redownload: Bool,
                                      error: NSErrorPointer) -> String? {
        do {
            return try await whisperKitImpl.loadModel(variant, modelRepo, redownload)
        } catch {
            if let error = error {
                error.pointee = error as NSError
            }
            return nil
        }
    }
    
    // 他のメソッドも同様に実装
}
```

### 5. Dartからの呼び出し

生成されたバインディングを使用してDartからSwiftコードを呼び出します：

```dart
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'bindings/whisper_kit_bindings.dart';

class FFIFlutterWhisperKit extends FlutterWhisperKitPlatform {
  final WhisperKitBindings _bindings;
  
  FFIFlutterWhisperKit() : _bindings = WhisperKitBindings(DynamicLibrary.process());
  
  @override
  Future<String?> loadModel(String? variant, {String? modelRepo, bool redownload = false}) async {
    final variantPtr = variant?.toNativeUtf8() ?? nullptr;
    final modelRepoPtr = modelRepo?.toNativeUtf8() ?? nullptr;
    
    try {
      final errorPtr = calloc<Pointer<ObjCObject>>();
      final result = _bindings.WhisperKitBridge.loadModel(
        variantPtr,
        modelRepoPtr,
        redownload,
        errorPtr,
      );
      
      if (errorPtr.value != nullptr) {
        // エラー処理
        throw Exception('Failed to load model');
      }
      
      return result?.toDartString();
    } finally {
      if (variantPtr != nullptr) calloc.free(variantPtr);
      if (modelRepoPtr != nullptr) calloc.free(modelRepoPtr);
    }
  }
  
  // 他のメソッドも同様に実装
}
```

## 完全移行のためのステップ

MethodChannel/Pigeonからffigenへの完全移行には、以下のステップが必要です：

### 1. プロジェクト構造の準備

1. ffigen依存関係の追加
2. ブリッジヘッダーとSwiftファイルの作成
3. 既存のPigeonコードとの共存戦略の検討

### 2. モデルクラスの移行

1. 現在のモデルクラス（TranscriptionResult, DecodingOptions等）をFFI互換に更新
2. ネイティブ型とDart型の間のマッピング関数の実装

### 3. コア機能の移行

1. loadModel機能の移行
2. transcribeFromFile機能の移行
3. startRecording/stopRecording機能の移行

### 4. イベントストリームの実装

1. コールバック機能を使用したイベントストリームの実装
2. 進捗状況通知とリアルタイム転写結果のストリーミング

### 5. テストと検証

1. 単体テストの更新
2. 統合テストの実行
3. パフォーマンス比較

### 6. 段階的なロールアウト

1. 一部の機能からffigenへの移行を開始
2. 既存のMethodChannel/Pigeonコードと並行して動作させる
3. 問題がなければ完全に移行

## イベントチャネルの代替実装

現在のEventChannelベースの進捗状況通知機能をffigenで置き換えるには、以下のアプローチが考えられます：

### 1. コールバックベースのアプローチ

```dart
// Dart側
typedef TranscriptionCallback = Void Function(Pointer<Utf8> result);

// FFIバインディング
void registerTranscriptionCallback(
  Pointer<NativeFunction<TranscriptionCallback>> callback
);

// 実装
final _callbackPointer = Pointer.fromFunction<TranscriptionCallback>(_onTranscription);

void _onTranscription(Pointer<Utf8> resultPtr) {
  final result = resultPtr.toDartString();
  _transcriptionStreamController.add(TranscriptionResult.fromJsonString(result));
}

// 登録
_bindings.registerTranscriptionCallback(_callbackPointer);
```

### 2. ポーリングベースのアプローチ

定期的にネイティブ側から最新の結果を取得する方法も考えられます。

### 3. ネイティブプラグインのアプローチ

Flutter Engineのプラグインシステムを直接使用して、イベントチャネルの機能を再実装する方法もあります。

## 課題と対策

ffigenへの移行には以下の課題が考えられます：

### 1. Swift対応の実験的な状態

- **課題**: ffigenのSwiftサポートはまだ実験的段階
- **対策**: Objective-Cブリッジを使用して安定性を確保

### 2. 複雑なデータ構造の受け渡し

- **課題**: 複雑なオブジェクトの受け渡しが難しい
- **対策**: JSON文字列を使用した受け渡しや、構造体の分解と再構築

### 3. 非同期処理

- **課題**: FFIは基本的に同期的な呼び出し
- **対策**: コールバックパターンや、Isolateを使用した非同期処理の実装

### 4. メモリ管理

- **課題**: ネイティブメモリの管理が必要
- **対策**: Finalizer APIを使用した適切なメモリ解放

### 5. プラットフォーム固有の機能

- **課題**: iOS/macOS固有の機能へのアクセス
- **対策**: プラットフォーム検出と条件付きコンパイル

## まとめ

Flutter WhisperKitプラグインをMethodChannel/Pigeonからffigenへ移行することで、パフォーマンスの向上、型安全性の強化、コードの簡素化、将来性の確保といった多くのメリットが期待できます。

移行には一定の労力が必要ですが、段階的なアプローチを取ることで、リスクを最小限に抑えながら移行を進めることができます。特に、パフォーマンスが重要なオーディオ処理や機械学習モデルの実行においては、FFIによる直接的なネイティブコード呼び出しが大きなメリットとなるでしょう。

イベントチャネルの機能についても、コールバックベースのアプローチなどで代替実装が可能であり、完全な移行を実現できます。

ffigenの実験的なSwiftサポートを活用することで、WhisperKitの機能を最大限に引き出しつつ、Flutterアプリケーションとのシームレスな統合を実現することができます。
