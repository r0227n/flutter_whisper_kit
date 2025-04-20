# WhisperKit モデルローディング調査

## 目次
- [はじめに](#はじめに)
- [WhisperKitのloadModel関数の概要](#whisperkitのloadmodel関数の概要)
- [実装オプション](#実装オプション)
  - [Swift実装](#swift実装)
  - [Dart実装](#dart実装)
  - [比較](#比較)
- [モデルストレージオプション](#モデルストレージオプション)
  - [パッケージディレクトリストレージ](#パッケージディレクトリストレージ)
  - [ユーザーフォルダストレージ](#ユーザーフォルダストレージ)
  - [比較](#比較-1)
- [推奨アプローチ](#推奨アプローチ)
- [サンプルコード](#サンプルコード)
  - [Swift実装例](#swift実装例)
  - [Dart実装例](#dart実装例)
- [参考資料](#参考資料)

## はじめに
このドキュメントでは、Flutter WhisperKit Appleプラグインにおける WhisperKit のモデルローディング機能の実装に関する調査結果を提示します。WhisperKitのサンプルプロジェクトから`loadModel`関数を検証し、SwiftとDartの実装オプションを比較し、異なるモデルストレージ場所の戦略を分析します。

## WhisperKitのloadModel関数の概要
WhisperKitのサンプルプロジェクトにある`loadModel`関数は以下を処理します：
1. 計算オプションでWhisperKitを構成する
2. モデルがローカルで利用可能かどうかを確認する
3. ローカルで利用できない場合はモデルをダウンロードする
4. モデルをロードし、予備計算（prewarm）を行う
5. 処理中にアプリケーションの状態を更新する

この関数の主要コンポーネントは以下の通りです：

```swift
func loadModel(_ model: String, redownload: Bool = false) {
    // 設定を作成
    whisperKit = nil
    Task {
        let config = WhisperKitConfig(computeOptions: getComputeOptions(),
                                      verbose: true,
                                      logLevel: .debug,
                                      prewarm: false,
                                      load: false,
                                      download: false)
        whisperKit = try await WhisperKit(config)
        
        // ローカルモデルを確認またはダウンロード
        var folder: URL?
        if localModels.contains(model) && !redownload {
            folder = URL(fileURLWithPath: localModelPath).appendingPathComponent(model)
        } else {
            // モデルをダウンロード
            folder = try await WhisperKit.download(variant: model, from: repoName, progressCallback: { progress in
                // ダウンロード進捗でUIを更新
            })
        }
        
        // モデルフォルダを設定し、モデルをロード
        if let modelFolder = folder {
            whisperKit.modelFolder = modelFolder
            try await whisperKit.prewarmModels()
            try await whisperKit.loadModels()
        }
    }
}
```

## 実装オプション

### Swift実装
Swiftでモデルローディングを実装すると、WhisperKit APIに直接アクセスできます。

**利点：**
- WhisperKit機能への直接アクセス
- ブリッジングのオーバーヘッドなし
- 完全な型安全性と優れたエラー処理
- WhisperKitのアップデートとシームレスな統合
- 計算集約型操作のパフォーマンス向上

**欠点：**
- プラットフォーム固有のコード（iOS/macOSのみ）
- 機能をDartに公開するためにPigeonが必要
- iOSとmacOSプラットフォーム用に重複するSwiftコードが必要な場合あり
- Flutter側からの制御が少ない

### Dart実装
Dartでモデルローディングを実装する場合、モデル操作を処理するためのプラットフォームチャネルメソッドを作成します。

**利点：**
- プラットフォーム間で統一されたコード
- Flutter側からより多くの制御
- Flutterの状態管理との統合が容易
- 将来的に他のプラットフォームへの拡張が容易
- Flutterの開発者になじみやすい

**欠点：**
- 複雑なプラットフォームチャネル通信が必要
- ブリッジングによるパフォーマンスオーバーヘッド
- WhisperKit機能の重複実装
- プラットフォーム固有の機能へのアクセスが制限される
- プラットフォーム境界を越えたエラー処理が複雑

### 比較
| 側面 | Swift | Dart |
|--------|-------|------|
| パフォーマンス | 高い | ブリッジングにより低い |
| 開発の複雑さ | iOS/macOS開発者には低い | Flutter開発者には低い |
| メンテナンス性 | WhisperKitの更新に適合しやすい | WhisperKitの変更に合わせた更新が必要 |
| クロスプラットフォーム | iOS/macOSのみ | マルチプラットフォームの設計が優れている |
| エラー処理 | エラーへの直接アクセス | エラーはプラットフォーム間でマッピングが必要 |
| UI統合 | UI更新にはブリッジングが必要 | Flutter UIとの直接統合 |

## モデルストレージオプション

### パッケージディレクトリストレージ
アプリのパッケージディレクトリ内にモデルを保存します。

**利点：**
- モデルはアプリケーション内に含まれる
- インストールとアップデートが簡素化される
- 保護されたアプリスペース内にあるためセキュリティが向上
- モデルへのアクセスに権限問題がない
- ライフサイクル管理が明確（アプリのアンインストール時にモデルが削除される）

**欠点：**
- アプリケーションのストレージ容量を使用
- アプリケーション間でモデルが共有されない
- 各アプリケーションで再ダウンロードが必要
- アプリケーションのアンインストール時にモデルが失われる
- ユーザーからの可視性が制限される

### ユーザーフォルダストレージ
ドキュメントやダウンロードフォルダなど、ユーザーがアクセスできる場所にモデルを保存します。

**利点：**
- アプリケーション間でモデルを共有可能
- アプリケーションのライフサイクルを超えて永続的
- ユーザーに見える（透明性）
- ユーザーが手動で管理可能
- アプリケーション間での重複ダウンロードを削減

**欠点：**
- 権限管理が必要
- ユーザーが誤ってモデルを削除または変更するリスク
- より複雑なパス処理
- プラットフォーム固有の実装の違い
- ユーザーがモデルを削除した場合の不足モデルの処理が必要

### 比較
| 側面 | パッケージディレクトリ | ユーザーフォルダ |
|--------|-------------------|-------------|
| セキュリティ | 高い（保護された空間） | 低い（ユーザーアクセス） |
| 可視性 | ユーザーから非表示 | ユーザーに表示 |
| 永続性 | アプリのライフサイクルに依存 | アプリと独立 |
| 共有 | 不可能 | アプリ間で可能 |
| ストレージ使用量 | アプリ間で重複 | 共有可能 |
| ユーザー制御 | 制限あり | フルアクセス |

## 推奨アプローチ
調査に基づき、**Swift実装**と**オプションのユーザーフォルダストレージ**を推奨します：

1. WhisperKitとの直接統合のためにSwiftでコアモデルローディング機能を実装
2. Pigeonを使用してFlutter側に設定可能なAPIを公開
3. モデルストレージの場所（パッケージまたはユーザーフォルダ）を設定可能にし、デフォルトではパッケージディレクトリを使用
4. イベントチャネルを介してFlutter側に進捗更新とステータス情報を提供

このアプローチは、Swiftの実装によるパフォーマンス上の利点と、ユースケースに基づいたストレージ場所の柔軟性を組み合わせています。

## サンプルコード

### Swift実装例

```swift
// WhisperKitModelLoader.swift
import WhisperKit
import Foundation

class WhisperKitModelLoader {
    enum ModelStorageLocation {
        case packageDirectory
        case userFolder
    }
    
    private var whisperKit: WhisperKit?
    private var modelStorageLocation: ModelStorageLocation = .packageDirectory
    
    func setStorageLocation(_ location: ModelStorageLocation) {
        modelStorageLocation = location
    }
    
    func loadModel(
        variant: String,
        modelRepo: String = "argmaxinc/whisperkit-coreml",
        redownload: Bool = false,
        progressCallback: @escaping (Float) -> Void,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        Task {
            do {
                // 1. 設定でWhisperKitを初期化
                let config = WhisperKitConfig(
                    verbose: true,
                    logLevel: .debug,
                    prewarm: false,
                    load: false,
                    download: false
                )
                whisperKit = try await WhisperKit(config)
                
                guard let whisperKit = whisperKit else {
                    throw NSError(domain: "WhisperKitError", code: 1001, userInfo: [
                        NSLocalizedDescriptionKey: "WhisperKitの初期化に失敗しました"
                    ])
                }
                
                // 2. モデルフォルダの場所を決定
                var modelFolder: URL?
                let localModels = await getLocalModels()
                
                if localModels.contains(variant) && !redownload {
                    // 既存のモデルを使用
                    modelFolder = getModelFolderPath().appendingPathComponent(variant)
                } else {
                    // モデルをダウンロード
                    progressCallback(0.1)
                    modelFolder = try await WhisperKit.download(
                        variant: variant,
                        from: modelRepo,
                        progressCallback: { progress in
                            progressCallback(Float(progress.fractionCompleted) * 0.7)
                        }
                    )
                }
                
                // 3. モデルフォルダを設定し、モデルをロード
                if let folder = modelFolder {
                    whisperKit.modelFolder = folder
                    
                    progressCallback(0.8)
                    // モデルの予備計算
                    try await whisperKit.prewarmModels()
                    
                    progressCallback(0.9)
                    // モデルをロード
                    try await whisperKit.loadModels()
                    
                    progressCallback(1.0)
                    completion(.success("モデルが正常にロードされました"))
                } else {
                    throw NSError(domain: "WhisperKitError", code: 1002, userInfo: [
                        NSLocalizedDescriptionKey: "モデルフォルダの取得に失敗しました"
                    ])
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    private func getModelFolderPath() -> URL {
        switch modelStorageLocation {
        case .packageDirectory:
            // アプリケーションサポートディレクトリを使用
            if let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
                let modelDir = appSupport.appendingPathComponent("WhisperKitModels")
                try? FileManager.default.createDirectory(at: modelDir, withIntermediateDirectories: true)
                return modelDir
            }
            // ドキュメントにフォールバック
            return getDocumentsDirectory().appendingPathComponent("WhisperKitModels")
            
        case .userFolder:
            // ダウンロードフォルダを使用
            if let downloads = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first {
                let modelDir = downloads.appendingPathComponent("WhisperKitModels")
                try? FileManager.default.createDirectory(at: modelDir, withIntermediateDirectories: true)
                return modelDir
            }
            // ドキュメントにフォールバック
            return getDocumentsDirectory().appendingPathComponent("WhisperKitModels")
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private func getLocalModels() async -> [String] {
        let modelPath = getModelFolderPath()
        var localModels: [String] = []
        
        do {
            if FileManager.default.fileExists(atPath: modelPath.path) {
                let contents = try FileManager.default.contentsOfDirectory(atPath: modelPath.path)
                localModels = contents
            }
        } catch {
            print("ローカルモデルの確認エラー: \(error.localizedDescription)")
        }
        
        return WhisperKit.formatModelFiles(localModels)
    }
}
```

### Dart実装例

```dart
// whisper_kit_model_loader.dart
import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

enum ModelStorageLocation {
  packageDirectory,
  userFolder
}

class WhisperKitModelLoader {
  static const MethodChannel _channel = MethodChannel('flutter_whisperkit_apple/model_loader');
  static const EventChannel _progressChannel = EventChannel('flutter_whisperkit_apple/model_progress');
  
  ModelStorageLocation storageLocation = ModelStorageLocation.packageDirectory;
  
  Stream<double> get progressStream => _progressChannel.receiveBroadcastStream().map((event) => event as double);
  
  Future<void> setStorageLocation(ModelStorageLocation location) async {
    storageLocation = location;
    await _channel.invokeMethod('setStorageLocation', {
      'location': location.index,
    });
  }
  
  Future<String> loadModel({
    required String variant,
    String modelRepo = 'argmaxinc/whisperkit-coreml',
    bool redownload = false,
    Function(double progress)? onProgress,
  }) async {
    try {
      // コールバックが提供されている場合は進捗更新をサブスクライブ
      StreamSubscription? progressSubscription;
      if (onProgress != null) {
        progressSubscription = progressStream.listen(onProgress);
      }
      
      // プラットフォーム固有の実装を呼び出す
      final result = await _channel.invokeMethod('loadModel', {
        'variant': variant,
        'modelRepo': modelRepo,
        'redownload': redownload,
        'storageLocation': storageLocation.index,
      });
      
      // サブスクリプションをクリーンアップ
      await progressSubscription?.cancel();
      
      return result as String;
    } on PlatformException catch (e) {
      throw Exception('モデルのロードに失敗しました: ${e.message}');
    }
  }
  
  Future<List<String>> getAvailableModels() async {
    try {
      final result = await _channel.invokeMethod('getAvailableModels');
      return List<String>.from(result as List);
    } on PlatformException catch (e) {
      throw Exception('利用可能なモデルの取得に失敗しました: ${e.message}');
    }
  }
  
  Future<String> getModelStoragePath() async {
    switch (storageLocation) {
      case ModelStorageLocation.packageDirectory:
        final directory = await getApplicationSupportDirectory();
        final modelDir = Directory('${directory.path}/WhisperKitModels');
        if (!await modelDir.exists()) {
          await modelDir.create(recursive: true);
        }
        return modelDir.path;
        
      case ModelStorageLocation.userFolder:
        if (Platform.isIOS || Platform.isMacOS) {
          final directory = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
          final modelDir = Directory('${directory.path}/WhisperKitModels');
          if (!await modelDir.exists()) {
            await modelDir.create(recursive: true);
          }
          return modelDir.path;
        } else {
          // サポートされていないプラットフォームのフォールバック
          final directory = await getApplicationDocumentsDirectory();
          final modelDir = Directory('${directory.path}/WhisperKitModels');
          if (!await modelDir.exists()) {
            await modelDir.create(recursive: true);
          }
          return modelDir.path;
        }
    }
  }
}
```

## 参考資料
1. WhisperKit GitHubリポジトリ: https://github.com/argmaxinc/WhisperKit
2. Flutter プラグイン開発: https://docs.flutter.dev/packages-and-plugins/developing-packages
3. 型安全なプラットフォームチャネル用のPigeon: https://pub.dev/packages/pigeon
4. Apple ファイルシステムプログラミングガイド: https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/Introduction/Introduction.html
