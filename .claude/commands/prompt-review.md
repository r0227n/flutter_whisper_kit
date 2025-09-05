# Prompt Review Command - Claude 4 Best Practices

**IMPORTANT**: This command implements AI Review-First design following Claude 4 best practices for automated prompt and code quality evaluation with Japanese reporting.

## Overview

Evaluate files according to Claude 4 best practices and provide comprehensive Japanese evaluation. This command reads local files passed as arguments, analyzes content based on structured review templates, and creates detailed review files without external references.

## Core Principles (Claude 4 Best Practices)

**Scope**: Local file evaluation only - no external references

### AI Review-First Methodology

- **Pattern**: File input → Critical review → Structured evaluation → Japanese report
- **Approach**: Use AI as "Senior Reviewer" for comprehensive quality assessment
- **Cycles**: Multi-perspective evaluation (Security → SOLID → Performance)
- **Priority**: Security (High) → SOLID Principles (Medium) → Performance (Low)

### Clear Instructions

- Eliminate ambiguity in evaluation criteria
- Define specific quality metrics and deliverables
- Provide structured review templates for consistent assessment

### Structured Quality Assessment

Apply consistent evaluation framework:

```
1. セキュリティ脆弱性 (高優先度) - Security vulnerabilities assessment
2. SOLID原則違反 (中優先度) - SOLID principle violations analysis
3. パフォーマンス最適化 (低優先度) - Performance optimization opportunities
制約: 各カテゴリ400文字以内で要約
```

## Execution Modes

### Interactive Mode (No Arguments)

```bash
/prompt-review
```

**Behavior**:

1. **Argument Validation**: Check if file path is provided
2. **Early Termination**: If no arguments, display "⏺ ファイルパスを引数として提供してください" in red and terminate immediately
3. **No further processing** when no arguments provided

### Direct Mode (With File Path)

```bash
/prompt-review path/to/file.md
```

**Behavior**:

- **No confirmation prompts** - immediate execution
- Validate file path and accessibility
- Begin content evaluation automatically
- Generate structured Japanese review report

## AI Review-First Processing Flow

### Phase 1: File Processing and Initial Analysis

**Objective**: Secure file access and content parsing

**Actions**:

1. **File Access Validation**: Verify file exists and is readable with security checks
2. **Content Analysis**: Parse and analyze content structure
3. **Context Detection**: Identify file type and content category
4. **Initial Quality Check**: Validate content against Claude 4 best practices

**Quality Gate**: Successfully parsed content ready for evaluation

### Phase 2: Multi-Perspective Evaluation

**Review Template** (Use this exact format):

```
以下の内容をClaude 4ベストプラクティスに基づいてレビューしてください。

評価カテゴリ:
1. セキュリティ脆弱性 (高優先度) - セキュリティリスク、入力検証、認証認可
2. SOLID原則違反 (中優先度) - 設計原則、アーキテクチャパターン、保守性
3. パフォーマンス最適化 (低優先度) - 効率性、スケーラビリティ、リソース使用

制約: 各カテゴリ400文字以内で具体的かつ実行可能なフィードバックを提供。
最も優先度の高い問題に焦点を当ててください。
```

**Evaluation Process**:

1. **高優先度評価**: セキュリティ脆弱性の包括的分析
2. **中優先度評価**: SOLID原則とアーキテクチャ設計の検証
3. **低優先度評価**: パフォーマンス最適化機会の特定
4. **総合評価**: 全体的な品質スコアと改善提案

**Quality Gates**:

- Security: 重大なセキュリティリスクの特定と評価
- Architecture: 設計原則違反の検出と改善提案
- Performance: 最適化機会の特定と実装提案

### Phase 3: Japanese Review Report Generation

**Actions**:

1. **Review File Creation**: Generate `.review.<extension>` file with structured Japanese evaluation
2. **Quality Score Calculation**: Comprehensive quality assessment with numeric scoring
3. **Improvement Recommendations**: Specific, actionable improvement suggestions
4. **Best Practice References**: Links to relevant Claude 4 best practices documentation

**Quality Gate**: High-quality Japanese review report with actionable insights

## Enhanced Core Implementation

### 1. Secure File Reading and Validation

```typescript
// Enhanced security-first file access with comprehensive validation
import { resolve, relative, join, extname, isAbsolute } from "path";
import { stat, readFile } from "fs/promises";

const ALLOWED_EXTENSIONS = [
  ".md",
  ".txt",
  ".js",
  ".ts",
  ".dart",
  ".py",
  ".java",
  ".json",
  ".yaml",
  ".yml",
];
const MAX_FILE_SIZE = 50 * 1024 * 1024; // 50MB
const WORK_DIRECTORY = process.env.WORK_DIRECTORY || ".";

async function validateAndReadFile(
  filePath: string,
): Promise<{ content: string; extension: string }> {
  // Input sanitization - prevent malicious file access
  if (!filePath || /[\x00-\x1f\x7f-\x9f]/.test(filePath)) {
    throw new SecurityError(
      "アクセス拒否: 無効なファイルパス文字が含まれています",
    );
  }

  // Resolve absolute path and validate
  const resolvedPath = resolve(filePath);
  const workDir = resolve(WORK_DIRECTORY);
  const relativePath = relative(workDir, resolvedPath);

  // Enhanced path validation - prevent directory traversal
  if (
    relativePath.startsWith("..") ||
    isAbsolute(relativePath) ||
    relativePath.includes("..")
  ) {
    throw new SecurityError(
      "アクセス拒否: ディレクトリトラバーサル攻撃の試行が検出されました",
    );
  }

  // Validate file extension
  const ext = extname(filePath).toLowerCase();
  if (!ALLOWED_EXTENSIONS.includes(ext)) {
    throw new ValidationError(`サポートされていないファイル拡張子: ${ext}`);
  }

  // Check file size and permissions
  const stats = await stat(resolvedPath);
  if (stats.size > MAX_FILE_SIZE) {
    throw new ValidationError(
      `ファイルサイズが大きすぎます: ${stats.size} bytes`,
    );
  }

  // Read with encoding validation
  const content = await readFile(resolvedPath, { encoding: "utf8" });
  return { content, extension: ext };
}
```

### 2. Claude 4 Best Practices Evaluator

```typescript
// Comprehensive evaluation engine based on Claude 4 best practices
interface EvaluationResult {
  category: "security" | "solid" | "performance";
  priority: "high" | "medium" | "low";
  score: number; // 0-100
  issues: Issue[];
  recommendations: string[];
  bestPracticeReferences: string[];
}

interface Issue {
  severity: "critical" | "major" | "minor";
  description: string;
  location?: string;
  suggestion: string;
}

class Claude4BestPracticesEvaluator {
  private readonly securityPatterns = [
    /password\s*=\s*['""].+['"]/gi,
    /api_key\s*=\s*['""].+['"]/gi,
    /token\s*=\s*['""].+['"]/gi,
    /eval\s*\(/gi,
    /exec\s*\(/gi,
    /innerHTML\s*=/gi,
  ];

  private readonly solidViolationPatterns = [
    /class\s+\w+[^{]*{[^}]*}[^}]*{/gs, // God classes (rough heuristic)
    /function\s+\w+\([^)]*\)[^{]*{(?:[^{}]*{[^{}]*})*[^{}]*}/gs, // Long functions
  ];

  async evaluateContent(
    content: string,
    extension: string,
  ): Promise<EvaluationResult[]> {
    const results: EvaluationResult[] = [];

    // High Priority: Security Evaluation
    results.push(await this.evaluateSecurity(content, extension));

    // Medium Priority: SOLID Principles Evaluation
    results.push(await this.evaluateSOLIDPrinciples(content, extension));

    // Low Priority: Performance Evaluation
    results.push(await this.evaluatePerformance(content, extension));

    return results;
  }

  private async evaluateSecurity(
    content: string,
    extension: string,
  ): Promise<EvaluationResult> {
    const issues: Issue[] = [];
    const recommendations: string[] = [];

    // Check for hardcoded secrets
    this.securityPatterns.forEach((pattern, index) => {
      const matches = content.match(pattern);
      if (matches) {
        issues.push({
          severity: "critical",
          description: "ハードコードされた機密情報が検出されました",
          suggestion: "環境変数やセキュアな設定ファイルを使用してください",
        });
      }
    });

    // Check for SQL injection patterns
    if (content.includes("query") && content.includes("+")) {
      issues.push({
        severity: "major",
        description: "SQLインジェクションの可能性があります",
        suggestion: "パラメータ化クエリを使用してください",
      });
    }

    // Calculate security score
    const criticalCount = issues.filter(
      (i) => i.severity === "critical",
    ).length;
    const majorCount = issues.filter((i) => i.severity === "major").length;
    const score = Math.max(0, 100 - criticalCount * 40 - majorCount * 20);

    if (score < 70) {
      recommendations.push("セキュリティ監査の実施を強く推奨します");
    }
    if (criticalCount > 0) {
      recommendations.push(
        "クリティカルなセキュリティ問題を即座に修正してください",
      );
    }

    return {
      category: "security",
      priority: "high",
      score,
      issues,
      recommendations,
      bestPracticeReferences: [
        "セキュリティベストプラクティス",
        "セキュアコーディング原則",
      ],
    };
  }

  private async evaluateSOLIDPrinciples(
    content: string,
    extension: string,
  ): Promise<EvaluationResult> {
    const issues: Issue[] = [];
    const recommendations: string[] = [];

    // Single Responsibility Principle check
    const classMatches = content.match(/class\s+(\w+)/g);
    if (classMatches) {
      classMatches.forEach((match) => {
        const className = match.split(" ")[1];
        // Simple heuristic: check if class has multiple concerns
        if (
          content.includes(`${className}`) &&
          content.split(className).length > 5
        ) {
          issues.push({
            severity: "minor",
            description: `クラス ${className} が複数の責任を持っている可能性があります`,
            suggestion:
              "単一責任原則に従ってクラスを分割することを検討してください",
          });
        }
      });
    }

    // Open/Closed Principle check
    if (
      content.includes("instanceof") ||
      content.includes("switch") ||
      content.includes("case")
    ) {
      issues.push({
        severity: "minor",
        description: "拡張に対して閉じている可能性があります",
        suggestion:
          "ポリモーフィズムやStrategy パターンの使用を検討してください",
      });
    }

    const score = Math.max(0, 100 - issues.length * 15);

    if (score < 80) {
      recommendations.push("SOLID原則の適用を検討してください");
    }

    return {
      category: "solid",
      priority: "medium",
      score,
      issues,
      recommendations,
      bestPracticeReferences: ["SOLID設計原則", "オブジェクト指向設計パターン"],
    };
  }

  private async evaluatePerformance(
    content: string,
    extension: string,
  ): Promise<EvaluationResult> {
    const issues: Issue[] = [];
    const recommendations: string[] = [];

    // Check for performance anti-patterns
    if (content.includes("n+1") || content.includes("nested loop")) {
      issues.push({
        severity: "major",
        description: "パフォーマンスの問題が検出されました",
        suggestion: "アルゴリズムの最適化やキャッシュの使用を検討してください",
      });
    }

    // Check for large file indicators
    if (content.length > 10000) {
      issues.push({
        severity: "minor",
        description: "ファイルサイズが大きすぎます",
        suggestion: "ファイルの分割やモジュール化を検討してください",
      });
    }

    const score = Math.max(0, 100 - issues.length * 10);

    if (score < 85) {
      recommendations.push("パフォーマンス最適化の機会があります");
    }

    return {
      category: "performance",
      priority: "low",
      score,
      issues,
      recommendations,
      bestPracticeReferences: ["パフォーマンス最適化手法"],
    };
  }
}
```

### 3. Japanese Review Report Generator

```typescript
// Comprehensive Japanese review report generator
class JapaneseReviewReportGenerator {
  async generateReport(
    filePath: string,
    evaluationResults: EvaluationResult[],
    originalContent: string,
  ): Promise<string> {
    const timestamp = new Date().toLocaleString("ja-JP", {
      year: "numeric",
      month: "2-digit",
      day: "2-digit",
      hour: "2-digit",
      minute: "2-digit",
      second: "2-digit",
    });

    const overallScore = this.calculateOverallScore(evaluationResults);
    const qualityRating = this.getQualityRating(overallScore);

    return `# Claude 4 ベストプラクティス レビューレポート

## 基本情報

- **ファイル**: ${filePath}
- **レビュー日時**: ${timestamp}
- **総合スコア**: ${overallScore}/100 (${qualityRating})
- **レビュー基準**: Claude 4 ベストプラクティス（ローカル評価）

## 評価サマリー

${this.generateScoreSummary(evaluationResults)}

## 詳細評価

${evaluationResults.map((result) => this.generateDetailedEvaluation(result)).join("\n\n")}

## 総合的な改善提案

### 即座に対応すべき項目 (高優先度)

${this.getHighPriorityRecommendations(evaluationResults)}

### 改善を検討すべき項目 (中優先度)

${this.getMediumPriorityRecommendations(evaluationResults)}

### 最適化の機会 (低優先度)

${this.getLowPriorityRecommendations(evaluationResults)}

## Claude 4 ベストプラクティス適用度

### AIレビューファースト設計への適合性

${this.evaluateAIReviewFirstCompliance(originalContent)}

### プロンプトエンジニアリング原則への準拠

${this.evaluatePromptEngineeringCompliance(originalContent)}

## 参考資料

- Claude 4 ベストプラクティス（ローカル評価基準）
- AIレビューファースト設計手法
- セキュリティ・SOLID原則・パフォーマンス評価フレームワーク

## レビューアー情報

- **レビュアー**: Claude Code AI Review System
- **バージョン**: Claude 4 Best Practices v1.0
- **レビュー方法**: 自動化されたAIレビューファースト手法

---

*このレポートはClaude 4ベストプラクティスに基づいて自動生成されました。*
*詳細な改善案については、人間による最終検証を推奨します。*`;
  }

  private calculateOverallScore(results: EvaluationResult[]): number {
    const weights = { high: 0.5, medium: 0.3, low: 0.2 };
    let totalScore = 0;
    let totalWeight = 0;

    results.forEach((result) => {
      const weight = weights[result.priority];
      totalScore += result.score * weight;
      totalWeight += weight;
    });

    return Math.round(totalScore / totalWeight);
  }

  private getQualityRating(score: number): string {
    if (score >= 90) return "優秀";
    if (score >= 80) return "良好";
    if (score >= 70) return "普通";
    if (score >= 60) return "要改善";
    return "要大幅改善";
  }

  private generateScoreSummary(results: EvaluationResult[]): string {
    return results
      .map((result) => {
        const categoryName = {
          security: "セキュリティ",
          solid: "SOLID原則",
          performance: "パフォーマンス",
        }[result.category];

        const priorityName = {
          high: "高優先度",
          medium: "中優先度",
          low: "低優先度",
        }[result.priority];

        return `- **${categoryName}** (${priorityName}): ${result.score}/100`;
      })
      .join("\n");
  }

  private generateDetailedEvaluation(result: EvaluationResult): string {
    const categoryName = {
      security: "セキュリティ脆弱性評価",
      solid: "SOLID原則評価",
      performance: "パフォーマンス評価",
    }[result.category];

    let report = `### ${categoryName}\n\n`;
    report += `**スコア**: ${result.score}/100\n\n`;

    if (result.issues.length > 0) {
      report += `**検出された問題**:\n\n`;
      result.issues.forEach((issue, index) => {
        const severityEmoji = {
          critical: "🔴",
          major: "🟡",
          minor: "🔵",
        }[issue.severity];

        report += `${index + 1}. ${severityEmoji} **${issue.description}**\n`;
        report += `   - 改善提案: ${issue.suggestion}\n`;
        if (issue.location) {
          report += `   - 場所: ${issue.location}\n`;
        }
        report += "\n";
      });
    } else {
      report += `✅ この分野では問題は検出されませんでした。\n\n`;
    }

    if (result.recommendations.length > 0) {
      report += `**推奨事項**:\n\n`;
      result.recommendations.forEach((rec, index) => {
        report += `${index + 1}. ${rec}\n`;
      });
      report += "\n";
    }

    return report;
  }

  private getHighPriorityRecommendations(results: EvaluationResult[]): string {
    const highPriorityItems = results
      .filter((r) => r.priority === "high")
      .flatMap((r) => r.issues.filter((i) => i.severity === "critical"))
      .map((i) => `- ${i.description}: ${i.suggestion}`);

    return highPriorityItems.length > 0
      ? highPriorityItems.join("\n")
      : "- 高優先度の問題は検出されませんでした。";
  }

  private getMediumPriorityRecommendations(
    results: EvaluationResult[],
  ): string {
    const mediumPriorityItems = results
      .filter((r) => r.priority === "medium")
      .flatMap((r) => r.recommendations)
      .map((rec) => `- ${rec}`);

    return mediumPriorityItems.length > 0
      ? mediumPriorityItems.join("\n")
      : "- 中優先度の改善項目はありません。";
  }

  private getLowPriorityRecommendations(results: EvaluationResult[]): string {
    const lowPriorityItems = results
      .filter((r) => r.priority === "low")
      .flatMap((r) => r.recommendations)
      .map((rec) => `- ${rec}`);

    return lowPriorityItems.length > 0
      ? lowPriorityItems.join("\n")
      : "- 低優先度の最適化機会はありません。";
  }

  private evaluateAIReviewFirstCompliance(content: string): string {
    const patterns = [
      { pattern: /小さなドラフト|draft/gi, point: "最小実装の概念" },
      { pattern: /レビュー|review/gi, point: "レビューサイクルの実装" },
      { pattern: /反復|iteration/gi, point: "反復的改善プロセス" },
      {
        pattern: /セキュリティ|security/gi,
        point: "セキュリティ優先のアプローチ",
      },
    ];

    const foundPatterns = patterns.filter((p) => content.match(p.pattern));
    const score = (foundPatterns.length / patterns.length) * 100;

    let compliance = `**適合度**: ${Math.round(score)}%\n\n`;

    if (foundPatterns.length > 0) {
      compliance += `**確認されたベストプラクティス**:\n`;
      foundPatterns.forEach((p) => {
        compliance += `- ✅ ${p.point}\n`;
      });
    }

    const missingPatterns = patterns.filter((p) => !content.match(p.pattern));
    if (missingPatterns.length > 0) {
      compliance += `\n**改善の余地**:\n`;
      missingPatterns.forEach((p) => {
        compliance += `- ❌ ${p.point}\n`;
      });
    }

    return compliance;
  }

  private evaluatePromptEngineeringCompliance(content: string): string {
    const principles = [
      {
        pattern: /明確.*指示|clear.*instruction/gi,
        point: "明確で具体的な指示",
      },
      { pattern: /構造化|structured/gi, point: "構造化されたフォーマット" },
      { pattern: /コンテキスト|context/gi, point: "コンテキストの提供" },
      { pattern: /例|example/gi, point: "実例の活用" },
    ];

    const foundPrinciples = principles.filter((p) => content.match(p.pattern));
    const score = (foundPrinciples.length / principles.length) * 100;

    let compliance = `**準拠度**: ${Math.round(score)}%\n\n`;

    if (foundPrinciples.length > 0) {
      compliance += `**確認された原則**:\n`;
      foundPrinciples.forEach((p) => {
        compliance += `- ✅ ${p.point}\n`;
      });
    }

    const missingPrinciples = principles.filter(
      (p) => !content.match(p.pattern),
    );
    if (missingPrinciples.length > 0) {
      compliance += `\n**強化すべき原則**:\n`;
      missingPrinciples.forEach((p) => {
        compliance += `- ❌ ${p.point}\n`;
      });
    }

    return compliance;
  }
}
```

### 4. Main Command Orchestrator

```typescript
// Main command orchestrator with enhanced error handling
class PromptReviewCommand {
  constructor(
    private fileValidator: FileValidator,
    private evaluator: Claude4BestPracticesEvaluator,
    private reportGenerator: JapaneseReviewReportGenerator,
  ) {}

  async execute(filePath?: string): Promise<string> {
    // Enhanced argument validation - exit early if no file path provided
    if (!filePath || filePath.trim() === "") {
      console.log("\x1b[31m⏺ ファイルパスを引数として提供してください\x1b[0m");
      console.log("使用例: /prompt-review ./path/to/file.md");
      process.exit(0);
    }

    try {
      // Phase 1: Secure file processing
      console.log(`📖 ファイルを読み込み中: ${filePath}`);
      const { content, extension } =
        await this.fileValidator.validateAndRead(filePath);

      // Phase 2: Claude 4 best practices evaluation
      console.log("🔍 Claude 4ベストプラクティスに基づく評価を実行中...");
      const evaluationResults = await this.evaluator.evaluateContent(
        content,
        extension,
      );

      // Phase 3: Generate Japanese review report
      console.log("📝 日本語レビューレポートを生成中...");
      const reviewReport = await this.reportGenerator.generateReport(
        filePath,
        evaluationResults,
        content,
      );

      // Phase 4: Create review file
      const reviewFilePath = await this.createReviewFile(
        filePath,
        reviewReport,
        extension,
      );

      // Phase 5: Display summary
      const overallScore = this.calculateOverallScore(evaluationResults);
      console.log(`✅ レビュー完了: ${reviewFilePath}`);
      console.log(`📊 総合スコア: ${overallScore}/100`);

      return reviewFilePath;
    } catch (error) {
      this.handleError(error);
      throw error;
    }
  }

  private async createReviewFile(
    originalPath: string,
    reviewContent: string,
    extension: string,
  ): Promise<string> {
    // Generate review file path
    const parsedPath = path.parse(originalPath);
    const reviewFilePath = path.join(
      parsedPath.dir,
      `${parsedPath.name}.review${extension}`,
    );

    // Write review file
    await writeFile(reviewFilePath, reviewContent, { encoding: "utf8" });
    console.log(`📁 レビューファイルを作成: ${reviewFilePath}`);

    return reviewFilePath;
  }

  private calculateOverallScore(results: EvaluationResult[]): number {
    const weights = { high: 0.5, medium: 0.3, low: 0.2 };
    let totalScore = 0;
    let totalWeight = 0;

    results.forEach((result) => {
      const weight = weights[result.priority];
      totalScore += result.score * weight;
      totalWeight += weight;
    });

    return Math.round(totalScore / totalWeight);
  }

  private handleError(error: Error): void {
    console.error("❌ エラー:", error.message);

    if (error.name === "SecurityError") {
      console.error("🔒 セキュリティ検証に失敗しました");
    } else if (error.name === "ValidationError") {
      console.error("⚠️ 入力検証に失敗しました");
    } else {
      console.error("💥 予期しないエラーが発生しました");
    }
  }
}
```

## Enhanced Security Requirements

### File Access Controls

- **Path Validation**: Only allow files within accessible directory structure
- **Extension Whitelist**: Support multiple programming languages and documentation formats
- **Size Limits**: Maximum 50MB file size with performance considerations
- **Permission Check**: Verify read permissions and prevent unauthorized access
- **Input Sanitization**: Comprehensive protection against malicious input patterns

### Content Analysis Security

- **Pattern Matching**: Safe regex patterns for security vulnerability detection
- **Memory Management**: Efficient processing for large files
- **Error Handling**: Secure error messages without sensitive information exposure
- **Rate Limiting**: Protection against excessive resource usage

## Usage Examples

### Basic File Review

```bash
/prompt-review ./docs/CLAUDE_4_BEST_PRACTICES.md

📖 ファイルを読み込み中: ./docs/CLAUDE_4_BEST_PRACTICES.md
🔍 Claude 4ベストプラクティスに基づく評価を実行中...
📝 日本語レビューレポートを生成中...
📁 レビューファイルを作成: ./docs/CLAUDE_4_BEST_PRACTICES.review.md
✅ レビュー完了: ./docs/CLAUDE_4_BEST_PRACTICES.review.md
📊 総合スコア: 85/100
```

### Code File Review

```bash
/prompt-review ./app/lib/main.dart

📖 ファイルを読み込み中: ./app/lib/main.dart
🔍 Claude 4ベストプラクティスに基づく評価を実行中...
📝 日本語レビューレポートを生成中...
📁 レビューファイルを作成: ./app/lib/main.review.dart
✅ レビュー完了: ./app/lib/main.review.dart
📊 総合スコア: 78/100
```

### No Arguments Example

```bash
/prompt-review

⏺ ファイルパスを引数として提供してください
使用例: /prompt-review ./path/to/file.md
```

## Error Handling and Recovery

### File Access Errors

```bash
/prompt-review nonexistent.md
❌ エラー: ファイル 'nonexistent.md' が見つかりません
💡 正しいファイルパスを使用してください
```

### Invalid File Extension

```bash
/prompt-review file.exe
❌ エラー: サポートされていないファイル拡張子: .exe
💡 サポートされている拡張子: .md, .txt, .js, .ts, .dart, .py, .java, .json, .yaml, .yml
```

### Security Violations

```bash
/prompt-review ../../etc/passwd
❌ エラー: アクセス拒否: ディレクトリトラバーサル攻撃の試行が検出されました
🔒 セキュリティ検証に失敗しました
```

## Best Practices and Limitations

### Optimal Use Cases

- **Documentation files** requiring Claude 4 best practices compliance check
- **Code files** needing security and architecture review
- **Configuration files** requiring validation
- **Prompt templates** needing quality assessment
- **Project guidelines** requiring best practices alignment

### Limitations

- **Binary files** are not supported (only text-based files)
- **Very large files** (>50MB) require manual splitting
- **Language-specific** analysis may need domain expertise
- **Context-dependent** evaluation may require human validation

### Success Factors

1. **Clear file structure** with consistent formatting
2. **Meaningful content** with sufficient detail for evaluation
3. **Proper file permissions** for read access
4. **Standard file extensions** for accurate analysis
5. **Claude 4 best practices knowledge** for interpretation

## Configuration Requirements

### Environment Variables

```bash
export WORK_DIRECTORY="."
export MAX_FILE_SIZE_MB=50
export SUPPORTED_EXTENSIONS=".md,.txt,.js,.ts,.dart,.py,.java,.json,.yaml,.yml"
export REVIEW_LANGUAGE="japanese"
export ENABLE_SECURITY_CHECKS=true
```

### File Structure Requirements

```
project-root/
├── .claude/
│   └── commands/
│       └── prompt-review.md
├── docs/
│   └── CLAUDE_4_BEST_PRACTICES.md
└── reviews/ (created automatically)
```

---

**Note**: This enhanced command provides comprehensive evaluation based on Claude 4 best practices with secure file handling, multi-perspective analysis, and detailed Japanese reporting.
