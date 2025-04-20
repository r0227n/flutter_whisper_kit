---
name: Devin Task
about: Devin Task Template
title: '[Devin] '
labels: devin task
assignees: ''

---

### 概要（What）

<!-- このIssueでは何をしてほしいかを簡潔に記述してください。  
例: 特定のバグ修正、新機能追加、既存コードの改善 など -->

---

### 作業対象（Where）

<!-- 対象となるファイル、ディレクトリ、モジュール名など  
例: `lib/screens/home_screen.dart` -->

Make changes **only** within the following directories:

- `/packages/flutter_whisperkit_apple/ios`
- `/packages/flutter_whisperkit_apple/macos`
- `/packages/flutter_whisperkit_apple/lib`
- `/packages/flutter_whisperkit_apple/test`
- `/packages/flutter_whisperkit_apple/example`

Do not modify any files outside of these directories.

---

### 背景・目的（Why）

<!-- なぜこの作業が必要なのか、ビジネスや技術的な理由を記述してください。  
例: ユーザーが画像投稿時にクラッシュする問題のため -->

---

### 実装方針・制約（How）

<!-- 使用してほしい技術、避けるべき方法、既知の問題などを記述してください。  
例: 外部ライブラリを追加せずに対応／既存のRiverpod構成を維持する -->

---

### 作業ブランチ

<!-- 作業を行うブランチ名をここに指定してください。
例: feature/add-login-functionality -->

<!-- 初期設定: developから新規ブランチを作成 -->
Please create a new branch from `develop`.

---

### PR作成方針

<!-- 以下から選択してください: -->
<!-- 新規でPRを作成する (Open) -->
<!-- 新規でドラフトPRを作成する (Draft) -->
<!-- 既存のPR #〇〇 に作業内容を追加する -->

<!-- 新規PRを作成する場合は、このIssueを紐付け、マージされたらIssueがクローズされるようにしてください。
例: Closes #123 -->

---

### 完了条件（Definition of Done）

- [ ] 該当機能が期待通り動作すること（再現手順 or テストケースで確認）
- [ ] 単体テストまたはUIテストが追加・修正されていること（必要に応じて）
- [ ] Lint／静的解析エラーがないこと
- [ ] PRに変更内容の要約が記載されていること
- [ ] 既存機能に影響がないことを確認済み

---

### 補足情報（任意）

<!-- - 関連Issue: `#123`
- スクリーンショット、再現手順、ログなどがあれば記載 -->