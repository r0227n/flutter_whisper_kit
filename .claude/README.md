# Claude Code ローカル設定

**ワークスペース固有のClaude Code設定と引数検証ワークフロー**

このディレクトリは、プロジェクト内のClaude Code固有の設定とカスタムコマンドを管理します。

## ドキュメント構造

この`.claude/`ディレクトリは、以下のドキュメント体系に従います：

### CLAUDE.md - README.md 1:1対応

- **[CLAUDE.md](CLAUDE.md)**: Claude Code用のローカルワークスペース設定
- **[README.md](README.md)**: 人間向けのClaude Code設定説明（本文書）
- **1:1関係**: CLAUDE.mdの各セクションは、このREADME.mdで対応する人間向け説明を持ちます

## コマンド引数検証ワークフロー

`.claude/commands/`で定義されたコマンドを実行する際、以下のワークフローが適用されます：

### 引数検証ルール

**引数が必要なコマンドの場合：**

1. **引数チェック**: 必須引数が提供されているかを確認
2. **引数不足時の動作**:
   - エラーメッセージ表示: `⏺ Please provide required arguments`
   - 終了理由をログ記録
   - **「Todos更新」フェーズをスキップ**
   - **処理を即座に終了**
   - **コマンド実行を継続しない**

3. **引数提供時**: 通常のコマンド処理を継続

### 実装パターン

```bash
# コマンド実行パターン
if [[ -z "${REQUIRED_ARG}" ]]; then
    echo "⏺ Please provide required arguments"
    echo "📝 Terminating: Missing required arguments"
    exit 0
fi

# コマンド処理を継続...
```

## ルートCLAUDE.mdのオーバーライド

**重要**: このローカル`.claude/CLAUDE.md`設定は、プロジェクトルートレベルのCLAUDE.mdファイルを**オーバーライド**し、**無視**します。

- ルートCLAUDE.mdパス: `/Users/r0227n/dev/flutter_template_project/CLAUDE.md` （無視される）
- ローカルCLAUDE.mdパス: `/Users/r0227n/dev/flutter_template_project/.claude-workspaces/TASK-84/.claude/CLAUDE.md` （アクティブ）

## コマンド固有ルール

### /task コマンド

**必須引数**: GitHub Issue番号またはID

**検証ワークフロー**:

```bash
if [[ -z "${ISSUE_ID}" ]]; then
    echo "⏺ Please provide an Issue ID as an argument"
    echo "📝 Skipping Update Todos phase due to missing Issue ID"
    exit 0
fi
```

### 将来のコマンド

`.claude/commands/`ディレクトリで定義される全コマンドは、同じ引数検証パターンを実装する必要があります：

1. 必須引数をチェック
2. 不足時に早期終了
3. todos/クリーンアップフェーズをスキップ
4. 終了理由をログ記録

## ワークスペース分離

このワークスペースは、ルートプロジェクト設定から分離されて動作します：

- **独立したコマンド実行**
- **分離されたメモリ/コンテキスト**
- **ローカル専用設定ルール**
- **ルートレベル指示のオーバーライド**

## 優先順位

設定の優先順位（高い順）：

1. `.claude/CLAUDE.md`（このファイル） - **最高優先度**
2. `.claude/commands/*.md` - コマンド固有設定
3. ローカル環境変数
4. ルートCLAUDE.md - **このワークスペースでは無視**

## カスタムコマンド

### コマンドディレクトリ構造

```
.claude/
├── CLAUDE.md          # Claude Code設定（AI向け）
├── README.md          # 人間向け説明（本文書）
└── commands/          # カスタムコマンド定義
    ├── task.md        # GitHub Issue処理コマンド
    └── [future].md    # 将来のコマンド
```

### 使用可能なコマンド

- **`/task`**: GitHub Issue処理コマンド（詳細は`commands/task.md`を参照）

## 開発者向けガイド

### 新しいコマンドの追加

新しいカスタムコマンドを追加する際：

1. `commands/`ディレクトリに新しい`.md`ファイルを作成
2. 引数検証ワークフローを実装
3. コマンド固有のロジックを定義
4. ドキュメントを更新

### 引数検証の実装

全てのコマンドで一貫した引数検証を実装：

```bash
# 必須引数チェックの例
if [[ $# -eq 0 ]] || [[ -z "$1" ]]; then
    echo "⏺ Please provide required arguments"
    echo "📝 Command terminated due to missing arguments"
    exit 0
fi

# コマンド処理を継続
echo "✅ Arguments provided, proceeding with command execution"
```

## トラブルシューティング

### よくある問題

1. **コマンドが実行されない**
   - 必須引数が提供されているか確認
   - ローカルCLAUDE.md設定を確認

2. **設定が反映されない**
   - ローカル設定がルート設定をオーバーライドしているか確認
   - ワークスペース分離が適切に動作しているか確認

3. **引数検証が動作しない**
   - コマンド定義ファイルの引数検証ロジックを確認
   - 適切な終了コードが設定されているか確認

## 設定の検証

ローカル設定が正しく動作していることを確認するには：

```bash
# コマンドの引数なし実行をテスト
/task
# 期待される出力: "⏺ Please provide required arguments"

# コマンドの引数付き実行をテスト
/task ISSUE-123
# 期待される動作: 通常のコマンド処理
```

---

**注記**: この設定により、全カスタムコマンドで一貫した引数検証を確保し、ルートプロジェクト設定からワークスペース分離を維持します。
