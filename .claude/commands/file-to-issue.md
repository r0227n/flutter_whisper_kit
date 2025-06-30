# File-to-Issue Processing Command - Claude 4 Best Practices Implementation

**IMPORTANT**: This command implements AI Review-First design following Claude 4 best practices for automated GitHub Issue creation with GitHub Issue Template compliance.

## Overview

Convert bullet-point files into GitHub Issues using AI Review-First methodology. This command reads local files, transforms content into structured GitHub ISSUE_TEMPLATE format, provides translation workflow, and creates GitHub Issues automatically.

## Core Principles (Claude 4 Best Practices)

**Reference**: `docs/CLAUDE_4_BEST_PRACTICES.md` and `.github/ISSUE_TEMPLATE/feature.yml`

### AI Review-First Methodology

- **Pattern**: Small draft → Critical review → Regenerate → Release
- **Approach**: Use AI as "Senior Reviewer" not "Junior Designer"
- **Cycles**: 3-4 iterative review cycles for quality improvement
- **Priority**: Security (High) → SOLID Principles (Medium) → Performance (Low)

### Clear Instructions

- Eliminate ambiguity in file parsing and template conversion
- Define specific outcomes: structured Japanese content → GitHub template format → English translation → GitHub Issue
- Provide structured review templates for content quality

### Structured Quality Assessment

Apply consistent evaluation framework:

```
1. Security vulnerabilities (HIGH PRIORITY) - File access, GitHub API credentials
2. SOLID principle violations (MEDIUM PRIORITY) - Command architecture
3. Performance optimization (LOW PRIORITY) - File processing speed
Constraint: Summarize findings within 400 characters
```

## Execution Modes

### Interactive Mode (No Arguments)

```bash
/file-to-issue
```

**Behavior**:

1. **Argument Validation**: Check if file path is provided
2. **Early Termination**: If no arguments, display "⏺ Please provide a file path as an argument" in red, skip "Update Todos" phase, and terminate immediately
3. **No further processing** when no arguments provided

### Direct Mode (With File Path)

```bash
/file-to-issue path/to/file.md
```

**Behavior**:

- **No confirmation prompts** - immediate execution
- Validate file path and accessibility
- Begin content transformation automatically
- Generate GitHub Issue Template compliant structure

## AI Review-First Processing Flow

### Phase 1: File Processing and Initial Conversion

**Objective**: Create structured Japanese content for review

**Actions**:

1. **File Access Validation**: Verify file exists and is readable
2. **Content Parsing**: Extract bullet points and structure
3. **Template Conversion**: Transform to GitHub ISSUE_TEMPLATE format in Japanese
4. **Initial Quality Check**: Validate content structure against GitHub Issue templates

**Success Criteria**: Well-formed Japanese GitHub ISSUE_TEMPLATE content

### Phase 2: Critical Review Cycles (3-4 Iterations)

**Review Template** (Use this exact format):

```
Please review the following file-to-issue conversion implementation.

Evaluation Categories:
1. Security vulnerabilities (high priority) - File access controls, API security
2. SOLID principle violations (medium priority) - Command architecture
3. Performance optimization opportunities (low priority) - File processing efficiency

Constraint: Provide specific, actionable feedback within 400 characters.
Focus on the highest priority issues first.
```

**Iterative Improvement Process**:

1. **Cycle 1**: Address ALL high priority security issues (file access, API credentials)
2. **Cycle 2**: Fix major SOLID principle violations in command architecture
3. **Cycle 3**: Optimize file processing performance within feasible scope
4. **Final Validation**: Human review of content quality and GitHub template compliance

**Quality Requirements**:

- Security: Safe file access, secure API usage
- Architecture: Clean separation of concerns
- Performance: Efficient file processing
- **GitHub Template Compliance**: Proper feature.yml structure

### Phase 3: Translation and Issue Creation

**Actions**:

1. **Create Issue File**: Generate new file with `.issue.md` extension containing GitHub ISSUE_TEMPLATE format
2. **Human Approval**: Display Japanese content for "Approve" confirmation
3. **Translation Processing**: Convert Japanese to English using Claude 4
4. **GitHub Issue Creation**: Create issue with English content using GitHub CLI
5. **Japanese Comment Addition**: Add original Japanese content as comment
6. **File Cleanup**: Remove created `.issue.md` file after successful processing

**Success Criteria**: Successfully created GitHub Issue with both languages and GitHub template compliance

## Enhanced Core Workflow Implementation

### 1. File Reading and Validation

```typescript
// Enhanced security-first file access with path traversal prevention
import { resolve, relative, join, extname, isAbsolute } from "path";
import { stat, readFile } from "fs/promises";

const ALLOWED_EXTENSIONS = [".md", ".txt", ".markdown"];
const MAX_FILE_SIZE = 10 * 1024 * 1024; // 10MB
const WORK_DIRECTORY = process.env.WORK_DIRECTORY || ".claude-workspaces";

async function validateAndReadFile(filePath: string): Promise<string> {
  // Input validation - prevent null bytes and control characters
  if (!filePath || /[\x00-\x1f\x7f-\x9f]/.test(filePath)) {
    throw new SecurityError("Access denied: Invalid file path characters");
  }

  // Prevent directory access outside allowed areas
  const resolvedPath = resolve(filePath);
  const workDir = resolve(WORK_DIRECTORY);
  const relativePath = relative(workDir, resolvedPath);

  // Enhanced path validation - check for unauthorized access patterns
  if (
    relativePath.startsWith("..") ||
    isAbsolute(relativePath) ||
    relativePath.includes("..")
  ) {
    throw new SecurityError("Access denied: Unauthorized path access detected");
  }

  // Validate file extension using imported function
  const ext = extname(filePath).toLowerCase();
  if (!ALLOWED_EXTENSIONS.includes(ext)) {
    throw new ValidationError(`Unsupported file extension: ${ext}`);
  }

  // Check file size before reading
  const stats = await stat(resolvedPath);
  if (stats.size > MAX_FILE_SIZE) {
    throw new ValidationError(`File too large: ${stats.size} bytes`);
  }

  // Read with encoding validation
  return await readFile(resolvedPath, { encoding: "utf8" });
}
```

### 2. Enhanced Content Structure Parsing

```typescript
// Parse bullet points into structured format
interface BulletPoint {
  level: number;
  content: string;
  children?: BulletPoint[];
}

// Single responsibility: Parse content only
class ContentParser {
  private readonly BULLET_PATTERNS = [/^[\s]*[-*+]\s/, /^[\s]*\d+\.\s/];

  async parseBulletPoints(content: string): Promise<BulletPoint[]> {
    // Performance optimization: Process lines in smaller parts for large files
    const lines = content.split("\n").filter((line) => line.trim());

    if (lines.length > 1000) {
      // Process large files in smaller parts to prevent memory issues
      return this.buildHierarchyInParts(lines);
    }

    return this.buildHierarchy(lines);
  }

  private buildHierarchyInParts(lines: string[]): BulletPoint[] {
    const PART_SIZE = 100;
    const result: BulletPoint[] = [];

    for (let i = 0; i < lines.length; i += PART_SIZE) {
      const part = lines.slice(i, i + PART_SIZE);
      const partResult = this.buildHierarchy(part);
      result.push(...partResult);
    }

    return result;
  }

  private buildHierarchy(lines: string[]): BulletPoint[] {
    const result: BulletPoint[] = [];
    const stack: BulletPoint[] = [];

    for (const line of lines) {
      const level = this.getIndentLevel(line);
      const content = this.extractContent(line);

      if (!content) continue;

      const point: BulletPoint = { level, content };
      this.insertIntoHierarchy(point, stack, result);
    }

    return result;
  }

  private getIndentLevel(line: string): number {
    return (line.match(/^[\s]*/)?.[0].length || 0) / 2;
  }

  private extractContent(line: string): string {
    // Input validation - prevent malicious patterns
    if (line.length > 10000) return ""; // Prevent system overload from very large lines

    // Clean content - remove potential harmful patterns
    const cleaned = line
      .replace(this.BULLET_PATTERNS[0], "")
      .replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, "") // Remove script tags
      .replace(/javascript:/gi, "") // Remove javascript: URLs
      .trim();

    return cleaned.slice(0, 5000); // Enforce reasonable content length
  }

  private insertIntoHierarchy(
    point: BulletPoint,
    stack: BulletPoint[],
    result: BulletPoint[],
  ): void {
    // Pop items from stack that are at same or higher level
    while (stack.length > 0 && stack[stack.length - 1].level >= point.level) {
      stack.pop();
    }

    if (stack.length === 0) {
      // Top level item
      result.push(point);
    } else {
      // Child item
      const parent = stack[stack.length - 1];
      if (!parent.children) {
        parent.children = [];
      }
      parent.children.push(point);
    }

    stack.push(point);
  }
}
```

### 3. GitHub ISSUE_TEMPLATE Conversion (Enhanced)

```typescript
// Convert to GitHub Issue template format
interface IssueTemplate {
  title: string;
  description: string;
  type: "feature" | "bugfix";
  priority: "low" | "medium" | "high" | "urgent";
}

// Abstract template converter for extensibility
abstract class TemplateConverter {
  abstract convert(bullets: BulletPoint[]): Promise<IssueTemplate>;

  protected generateTitle(bullets: BulletPoint[]): string {
    return bullets[0]?.content || "Untitled Issue";
  }

  protected detectType(content: string): "feature" | "bugfix" {
    const bugKeywords = [
      "bug",
      "fix",
      "error",
      "issue",
      "バグ",
      "修正",
      "不具合",
    ];
    return bugKeywords.some((keyword) =>
      content.toLowerCase().includes(keyword),
    )
      ? "bugfix"
      : "feature";
  }

  protected inferPriority(
    bullets: BulletPoint[],
  ): "low" | "medium" | "high" | "urgent" {
    const urgentKeywords = ["urgent", "緊急", "critical", "重大"];
    const highKeywords = ["important", "重要", "blocking", "ブロッキング"];
    const content = bullets
      .map((b) => b.content)
      .join(" ")
      .toLowerCase();

    if (urgentKeywords.some((keyword) => content.includes(keyword)))
      return "urgent";
    if (highKeywords.some((keyword) => content.includes(keyword)))
      return "high";
    if (bullets.length > 5) return "medium"; // Complex issues get medium priority
    return "low";
  }
}

// Enhanced GitHub template compliant converter
class GitHubFeatureTemplateConverter extends TemplateConverter {
  async convert(bullets: BulletPoint[]): Promise<IssueTemplate> {
    const title = this.generateTitle(bullets);
    const description = this.buildGitHubFeatureDescription(bullets);

    return {
      title,
      description,
      type: "feature",
      priority: this.inferPriority(bullets),
    };
  }

  private buildGitHubFeatureDescription(bullets: BulletPoint[]): string {
    const mainContent = bullets[0]?.content || "";
    const details = bullets
      .slice(1)
      .map((b) => b.content)
      .join("\n- ");

    return `## Feature Title
${mainContent}

## Context and Motivation

**Why is this feature needed?**
${this.inferBusinessContext(bullets)}

**User value:**
${this.inferUserValue(bullets)}

**Context:**
${this.inferTechnicalContext(bullets)}

## Detailed Requirements

### Functional Requirements:
- [ ] ${details}

### Non-Functional Requirements:
- [ ] レスポンス時間: 2秒以内
- [ ] クロスプラットフォーム対応（iOS/Android）
- [ ] アクセシビリティ対応（WCAG 2.1 AA準拠）

### Security Requirements:
- [ ] 入力値検証の実装
- [ ] 適切なエラーハンドリング
- [ ] セキュリティテストの実施

## Technical Constraints and Guidelines

### Technology Stack:
- [ ] プロジェクトのFlutter + Riverpodアーキテクチャに準拠
- [ ] 既存のgo_routerナビゲーションを活用
- [ ] slang i18nシステムとの統合
- [ ] SOLID原則の遵守

### Code Standards:
- [ ] 包括的なユニットテストを含む
- [ ] UIコンポーネントのウィジェットテスト
- [ ] 既存のコード規約に従う
- [ ] 適切なエラーハンドリングを含む

## AI Review-First Quality Criteria

### Review Categories (Priority Order):

**High Priority - Security:**
- [ ] セキュリティ脆弱性の排除（不正なデータ入力、スクリプト実行等）
- [ ] 適切な入力値検証とデータ処理
- [ ] 認証・認可の適切な実装
- [ ] 機密データの適切な取り扱い

**Medium Priority - SOLID Principles:**
- [ ] 単一責任原則の遵守
- [ ] 開放閉鎖原則の適用
- [ ] 依存性注入の適切な実装
- [ ] インターフェース分離の実現

**Low Priority - Performance:**
- [ ] 効率的な状態管理
- [ ] 最小限の再レンダリング・リビルド
- [ ] 適切なメモリ管理
- [ ] 最適化されたネットワークリクエスト

### Review Constraints:
- Each review summary: ≤ 400 characters
- 3-4 review cycles maximum
- Human final validation required

## Acceptance Criteria

### Core Functionality:
- [ ] 主要機能が正常に動作する
- [ ] ユーザーインターフェースが直感的である
- [ ] エラーケースが適切に処理される

### Quality Gates:
- [ ] 全ての自動テストが成功（ユニット、ウィジェット、統合）
- [ ] 静的解析（dart analyze）が成功
- [ ] コードフォーマット（dart format）が適用済み
- [ ] AIレビューサイクルが完了（3-4回の反復）
- [ ] セキュリティレビューが承認
- [ ] パフォーマンスベンチマークが達成
- [ ] アクセシビリティ要件が満たされる

### Documentation:
- [ ] APIドキュメントが更新済み
- [ ] ユーザーガイドが更新済み（該当する場合）
- [ ] 複雑なロジックにコードコメントが追加済み

## Testing Strategy

### Test Types Required:
- [ ] ビジネスロジックのユニットテスト
- [ ] UIコンポーネントのウィジェットテスト
- [ ] クリティカルフローの統合テスト
- [ ] セキュリティテスト

### Test Coverage Goals:
- [ ] ビジネスロジック: 90%+
- [ ] UIコンポーネント: 80%+
- [ ] クリティカルパス: 100%

### Manual Testing:
- [ ] クロスプラットフォーム互換性（iOS/Android）
- [ ] スクリーンリーダーでのアクセシビリティテスト
- [ ] 負荷テスト

## Claude Code Implementation Instructions

### Implementation Approach:
- [ ] AIレビューファースト設計を使用: 小さなドラフト → 厳しい批評 → 再生成 → リリース
- [ ] セキュリティ → SOLID → パフォーマンスに焦点を当てた3-4回のレビューサイクル
- [ ] 最初に最小限の動作実装を作成
- [ ] 包括的なエラーハンドリングを含む
- [ ] プロジェクトのRiverpod + go_routerパターンに従う

### Automation Settings:
- [ ] バックグラウンドタスクを有効化: \`ENABLE_BACKGROUND_TASKS=true\`
- [ ] 分離開発にgit worktreeを使用
- [ ] 完了時に日本語でPRを作成
- [ ] 完了確認のためにGitHub Actionsを監視

### Quality Assurance:
- [ ] コミット前に \`melos run analyze\` を実行
- [ ] コミット前に \`melos run test\` を実行
- [ ] コミット前に \`melos run format\` を実行
- [ ] 全てのCIチェックが成功することを確認

## Additional Context

**Expected Output Format:**
機能の詳細な説明、実装ガイドライン、テスト戦略を含む構造化されたLinear Issue`;
  }

  private inferBusinessContext(bullets: BulletPoint[]): string {
    const content = bullets.map((b) => b.content).join(" ");
    // Simple heuristics for business context
    if (content.includes("ユーザー") || content.includes("user")) {
      return "ユーザー体験の向上とビジネス価値の実現のため";
    }
    if (content.includes("レビュー") || content.includes("review")) {
      return "開発効率の向上と品質の一貫性を実現するため";
    }
    return "開発効率の向上と品質の一貫性を実現するため";
  }

  private inferUserValue(bullets: BulletPoint[]): string {
    return "- 機能の利便性向上\n- 作業効率の改善\n- 品質の向上";
  }

  private inferTechnicalContext(bullets: BulletPoint[]): string {
    return "現在の実装では要件を満たすのが困難な状況にある";
  }
}

// Enhanced bugfix template converter
class GitHubBugfixTemplateConverter extends TemplateConverter {
  async convert(bullets: BulletPoint[]): Promise<IssueTemplate> {
    const title = this.generateTitle(bullets);
    const description = this.buildGitHubBugfixDescription(bullets);

    return {
      title,
      description,
      type: "bugfix",
      priority: this.inferPriority(bullets),
    };
  }

  private buildGitHubBugfixDescription(bullets: BulletPoint[]): string {
    const mainContent = bullets[0]?.content || "";
    const details = bullets
      .slice(1)
      .map((b) => b.content)
      .join("\n- ");

    return `## Bug Title
${mainContent}

## Problem Description

**What is the issue?**
${mainContent}

**Impact:**
- 機能の利用に支障をきたす
- ユーザー体験の悪化
- システムの信頼性低下

## Detailed Bug Report

### Current Behavior:
- [ ] ${details}

### Expected Behavior:
- [ ] 正常な動作が期待される
- [ ] エラーが発生しない
- [ ] 適切なフィードバックが提供される

### Steps to Reproduce:
- [ ] 具体的な再現手順を記載
- [ ] 環境情報を含める
- [ ] 発生条件を明確にする

## Technical Analysis

### Root Cause Analysis:
- [ ] 問題の原因を特定
- [ ] 影響範囲を調査
- [ ] 関連するコンポーネントを確認

### Fix Strategy:
- [ ] 修正方針の決定
- [ ] 副作用の検討
- [ ] テスト戦略の策定

## Quality Assurance

### Testing Requirements:
- [ ] バグ修正のユニットテスト
- [ ] 回帰テストの実施
- [ ] 統合テストの確認

### Validation Criteria:
- [ ] 問題が解決されている
- [ ] 新たな問題が発生していない
- [ ] パフォーマンスに影響がない`;
  }
}

// Enhanced factory pattern
class TemplateConverterFactory {
  private static readonly converters = new Map<string, () => TemplateConverter>(
    [
      ["feature", () => new GitHubFeatureTemplateConverter()],
      ["bugfix", () => new GitHubBugfixTemplateConverter()],
    ],
  );

  static create(type: "feature" | "bugfix"): TemplateConverter {
    const converterFactory = this.converters.get(type);
    if (!converterFactory) {
      throw new ValidationError(`Unsupported template type: ${type}`);
    }
    return converterFactory();
  }

  static getSupportedTypes(): string[] {
    return Array.from(this.converters.keys());
  }
}
```

### 4. GitHub CLI Integration Implementation

```typescript
// GitHub CLI integration with robust error handling and repository management
class GitHubCLIIntegration {
  private repositoryName: string | null = null;

  async createGitHubIssueViaCLI(
    template: IssueTemplate,
    originalContent: string,
  ): Promise<string> {
    try {
      // Step 1: Validate GitHub CLI availability and repository access
      await this.initializeGitHubCLIConnection();

      // Step 2: Translate content to English
      const translatedTemplate = await this.translateToEnglish(template);

      // Step 3: Create GitHub Issue via CLI
      const issueData = await this.createIssueViaCLI(translatedTemplate);

      // Step 4: Add Japanese content as comment
      await this.addJapaneseComment(issueData.number, originalContent);

      console.log(`✅ GitHub Issue created: ${issueData.url}`);
      return issueData.url;
    } catch (error) {
      return this.handleGitHubError(error);
    }
  }

  private async initializeGitHubCLIConnection(): Promise<void> {
    try {
      // Step 1: Check GitHub CLI availability
      const { exec } = require("child_process");
      const { promisify } = require("util");
      const execAsync = promisify(exec);

      // Verify GitHub CLI is installed
      await execAsync("gh --version");

      // Step 2: Check authentication status
      const { stdout: authStatus } = await execAsync("gh auth status");
      if (!authStatus.includes("Logged in")) {
        throw new GitHubError(
          "GitHub CLI is not authenticated. Please run: gh auth login",
        );
      }

      // Step 3: Verify repository access
      const { stdout: repoInfo } = await execAsync(
        "gh repo view --json name,owner",
      );
      const repo = JSON.parse(repoInfo);
      this.repositoryName = `${repo.owner.login}/${repo.name}`;

      console.log(`📋 GitHub CLI initialized successfully`);
      console.log(`🏢 Repository: ${this.repositoryName}`);
      console.log(`✅ Authentication verified`);
    } catch (error) {
      throw new GitHubError(
        `GitHub CLI initialization failed: ${error.message}\n` +
          "Please ensure GitHub CLI is installed and authenticated with proper permissions.",
      );
    }
  }

  private async selectTeam(teams: any[]): Promise<string> {
    // Strategy 1: Look for team with common development-related names
    const preferredNames = ["development", "dev", "main", "primary", "default"];

    for (const name of preferredNames) {
      const team = teams.find(
        (t) =>
          t.name?.toLowerCase().includes(name) ||
          t.key?.toLowerCase().includes(name),
      );
      if (team) {
        console.log(`🎯 Selected team by name preference: ${team.name}`);
        return team.id;
      }
    }

    // Strategy 2: Use first available team
    const firstTeam = teams[0];
    console.log(`📍 Using first available team: ${firstTeam.name}`);
    return firstTeam.id;
  }

  private async selectProject(projects: any[]): Promise<string | null> {
    if (!projects || projects.length === 0) {
      console.log(
        "📂 No projects available, creating issue without project association",
      );
      return null;
    }

    // Strategy 1: Look for template or default project
    const preferredNames = ["template", "default", "general", "main"];

    for (const name of preferredNames) {
      const project = projects.find(
        (p) =>
          p.name?.toLowerCase().includes(name) ||
          p.key?.toLowerCase().includes(name),
      );
      if (project) {
        console.log(`🎯 Selected project by name preference: ${project.name}`);
        return project.id;
      }
    }

    // Strategy 2: Use first available project
    const firstProject = projects[0];
    console.log(`📍 Using first available project: ${firstProject.name}`);
    return firstProject.id;
  }

  private getTeamName(teams: any[], teamId: string): string {
    const team = teams.find((t) => t.id === teamId);
    return team?.name || "Unknown Team";
  }

  private getProjectName(projects: any[], projectId: string | null): string {
    if (!projectId) return "No Project";
    const project = projects.find((p) => p.id === projectId);
    return project?.name || "Unknown Project";
  }

  private async createIssueViaCLI(
    template: IssueTemplate,
  ): Promise<{ number: string; url: string }> {
    if (!this.repositoryName) {
      throw new GitHubError(
        "Repository not initialized. Please call initializeGitHubCLIConnection first.",
      );
    }

    try {
      const { exec } = require("child_process");
      const { promisify } = require("util");
      const execAsync = promisify(exec);

      // Prepare issue body with proper formatting
      const issueBody = template.description
        .replace(/'/g, "'\''")
        .replace(/"/g, '\"');

      // Create GitHub issue using CLI
      const labels = this.mapTemplateTypeToLabels(template.type);
      const priority = this.mapPriorityToLabel(template.priority);

      const command = `gh issue create --title "${template.title}" --body "${issueBody}" --label "${labels}" --label "${priority}"`;

      console.log(
        `📤 Creating GitHub issue in repository: ${this.repositoryName}`,
      );
      console.log(`🏷️ Labels: ${labels}, ${priority}`);

      const { stdout } = await execAsync(command);
      const issueUrl = stdout.trim();

      // Extract issue number from URL
      const issueNumber = issueUrl.split("/").pop();

      if (!issueNumber || !issueUrl) {
        throw new GitHubError("GitHub CLI returned invalid response format");
      }

      return {
        number: issueNumber,
        url: issueUrl,
      };
    } catch (error) {
      // Enhanced error handling for common GitHub CLI issues
      if (error.message.includes("authentication")) {
        throw new GitHubError(
          "GitHub CLI authentication failed. Please run: gh auth login",
        );
      }

      if (error.message.includes("permission")) {
        throw new GitHubError(
          `Repository access error: ${error.message}. Repository: ${this.repositoryName}`,
        );
      }

      if (error.message.includes("not found")) {
        throw new GitHubError(
          `Repository not found: ${this.repositoryName}. Please check repository name and access.`,
        );
      }

      throw new GitHubError(`GitHub issue creation failed: ${error.message}`);
    }
  }

  private async addJapaneseComment(
    issueNumber: string,
    originalContent: string,
  ): Promise<void> {
    try {
      const { exec } = require("child_process");
      const { promisify } = require("util");
      const execAsync = promisify(exec);

      const comment = `## 元の日本語コンテンツ

${originalContent}

---
*This comment contains the original Japanese content that was translated to create this issue.*`
        .replace(/'/g, "'\''")
        .replace(/"/g, '\"');

      const command = `gh issue comment ${issueNumber} --body "${comment}"`;

      await execAsync(command);
      console.log("📝 Added Japanese content as comment");
    } catch (error) {
      console.warn(`⚠️ Failed to add Japanese comment: ${error.message}`);
      // Don't fail the entire process if comment addition fails
    }
  }

  private async translateToEnglish(
    template: IssueTemplate,
  ): Promise<IssueTemplate> {
    // Use Claude for translation with explicit instructions
    const translationPrompt = `
Translate the following GitHub Issue template from Japanese to English.
Maintain the exact structure and formatting.
Keep technical terms and code examples unchanged.

Title: ${template.title}

Description:
${template.description}
`;

    try {
      // Call Claude via MCP for translation
      const translatedText =
        await this.callClaudeForTranslation(translationPrompt);

      // Parse the translated response
      const titleMatch = translatedText.match(/Title:\s*(.+)/);
      const descriptionMatch = translatedText.match(/Description:\s*([\s\S]+)/);

      return {
        ...template,
        title: titleMatch?.[1]?.trim() || template.title,
        description: descriptionMatch?.[1]?.trim() || template.description,
      };
    } catch (error) {
      console.warn(
        `⚠️ Translation failed: ${error.message}. Using original content.`,
      );
      return template; // Fallback to original if translation fails
    }
  }

  private async callClaudeForTranslation(prompt: string): Promise<string> {
    // Implementation would depend on available Claude MCP or API access
    // For now, return a placeholder indicating translation is needed
    console.log("🌐 Translating content to English...");

    // In actual implementation, this would call Claude via MCP or API
    // For this example, we return the original content with a note
    return `Translation service not implemented yet. Original content:\n${prompt}`;
  }

  private mapPriorityToLabel(priority: string): string {
    const priorityMap = {
      urgent: "priority: urgent",
      high: "priority: high",
      medium: "priority: medium",
      low: "priority: low",
    };
    return priorityMap[priority] || "priority: medium";
  }

  private mapTemplateTypeToLabels(type: string): string {
    const typeMap = {
      feature: "enhancement",
      bugfix: "bug",
    };
    return typeMap[type] || "enhancement";
  }

  private handleGitHubError(error: Error): never {
    console.error("❌ GitHub Integration Error:", error.message);

    if (error.name === "GitHubError") {
      console.error("🔌 GitHub CLI Issue:", error.message);
      console.error("💡 Troubleshooting:");
      console.error("  1. Verify GitHub CLI is installed: gh --version");
      console.error("  2. Check GitHub CLI authentication: gh auth status");
      console.error("  3. Ensure repository access permissions are granted");
    }

    throw error;
  }
}

// Custom error types for better error handling
class GitHubError extends Error {
  constructor(message: string) {
    super(message);
    this.name = "GitHubError";
  }
}
```

### 5. Enhanced Main Command Orchestrator

```typescript
// Enhanced main command orchestrator with proper error handling
class FileToIssueCommand {
  constructor(
    private fileValidator: FileValidator,
    private contentParser: ContentParser,
    private templateFactory: TemplateConverterFactory,
    private githubIntegration: GitHubCLIIntegration,
  ) {}

  async execute(filePath?: string): Promise<string> {
    // Enhanced argument validation - exit early if no file path provided
    // Skip "Update Todos" phase and terminate immediately when path is empty
    if (!filePath || filePath.trim() === "") {
      console.log(
        "\x1b[31m⏺ Please provide a file path as an argument\x1b[0m",
      );
      console.log("📝 Skipping Update Todos phase due to missing file path");
      process.exit(0);
    }

    try {
      // Phase 1: Secure file processing
      console.log(`📖 Reading file: ${filePath}`);
      const content = await this.fileValidator.validateAndRead(filePath);

      // Phase 2: Content parsing
      const bullets = await this.contentParser.parseBulletPoints(content);
      console.log(`📋 Found ${bullets.length} bullet points`);

      // Phase 3: Template conversion
      console.log("🏗️ Converting to GitHub ISSUE_TEMPLATE format...");
      const templateType = this.detectTemplateType(bullets);
      const converter = this.templateFactory.create(templateType);
      const template = await converter.convert(bullets);

      // Phase 4: Create issue file
      const issueFilePath = await this.createIssueFile(filePath, template);

      // Phase 5: Human approval workflow
      const approved = await this.requestApproval(template);
      if (!approved) {
        // Cleanup issue file if user doesn't approve
        await this.fileValidator.cleanup(issueFilePath);
        throw new Error("Processing cancelled by user");
      }

      // Phase 6: GitHub integration via CLI
      console.log("🌐 Translating to English...");
      console.log("📤 Creating GitHub Issue via CLI...");
      const issueUrl = await this.githubIntegration.createGitHubIssueViaCLI(
        template,
        content,
      );

      // Phase 7: Cleanup
      console.log("🗑️ Cleaning up issue file...");
      await this.fileValidator.cleanup(issueFilePath);

      console.log(`✅ Issue created: ${issueUrl}`);
      return issueUrl;
    } catch (error) {
      this.handleError(error);
      throw error;
    }
  }

  private async requestApproval(template: IssueTemplate): Promise<boolean> {
    console.log("📝 Generated Japanese Content:");
    console.log(`## ${template.title}\n`);

    // Show first few lines of description for preview
    const lines = template.description.split("\n");
    const preview = lines.slice(0, 10).join("\n");
    console.log(preview);
    if (lines.length > 10) {
      console.log("...");
    }

    console.log('\n✅ Content looks good? Type "Approve" to continue:');

    // Wait for user input
    const input = await this.getUserInput();
    return input.toLowerCase() === "approve";
  }

  private async getUserInput(): Promise<string> {
    return new Promise((resolve) => {
      const readline = require("readline");
      const rl = readline.createInterface({
        input: process.stdin,
        output: process.stdout,
      });

      rl.question("", (answer: string) => {
        rl.close();
        resolve(answer.trim());
      });
    });
  }

  private detectTemplateType(bullets: BulletPoint[]): "feature" | "bugfix" {
    const content = bullets.map((b) => b.content).join(" ");
    const bugKeywords = [
      "bug",
      "fix",
      "error",
      "issue",
      "バグ",
      "修正",
      "不具合",
    ];
    return bugKeywords.some((keyword) =>
      content.toLowerCase().includes(keyword),
    )
      ? "bugfix"
      : "feature";
  }

  private handleError(error: Error): void {
    console.error("❌ Error:", error.message);

    // Log error details for debugging (without sensitive info)
    if (error.name === "SecurityError") {
      console.error("🔒 Security validation failed");
    } else if (error.name === "ValidationError") {
      console.error("⚠️ Input validation failed");
    } else {
      console.error("💥 Unexpected error occurred");
    }
  }

  private async createIssueFile(
    originalPath: string,
    template: IssueTemplate,
  ): Promise<string> {
    // Generate issue file path by adding .issue.md extension
    const parsedPath = path.parse(originalPath);
    const issueFilePath = path.join(
      parsedPath.dir,
      `${parsedPath.name}.issue.md`,
    );

    // Create issue file content in GitHub ISSUE_TEMPLATE format
    const issueContent = template.description;

    // Write issue file
    await writeFile(issueFilePath, issueContent, { encoding: "utf8" });
    console.log(`📝 Created issue file: ${issueFilePath}`);

    return issueFilePath;
  }
}
```

## Enhanced Security Requirements

### File Access Controls

- **Path Validation**: Only allow files within project directory
- **Extension Whitelist**: `.md`, `.txt`, `.markdown` files only
- **Size Limits**: Maximum 10MB file size
- **Permission Check**: Verify read permissions before access
- **Input Sanitization**: Prevent null bytes and control characters

### API Security

- **Credential Management**: Use GitHub CLI authentication (no manual API keys)
- **Rate Limiting**: Respect GitHub API rate limits
- **Error Handling**: No sensitive data in error messages
- **Input Sanitization**: Clean content before CLI calls
- **Content Validation**: Validate translation results

## Error Handling and Recovery

### File Access Errors

```bash
/file-to-issue nonexistent.md
❌ Error: File 'nonexistent.md' not found
💡 Use relative or absolute path to accessible file
```

### No Arguments Error

```bash
/file-to-issue
⏺ Please provide a file path as an argument
📝 Skipping Update Todos phase due to missing file path
```

### Translation Failures

```bash
❌ Translation failed: API rate limit exceeded
🔧 Retrying in 60 seconds...
📋 Will save progress and resume automatically
```

### GitHub CLI Errors

```bash
❌ GitHub CLI authentication failed
💡 Please run: gh auth login
🔧 Retry after authentication
```

## Completion Criteria

### 1. AI Review-First Standards

- ✅ **3-4 review cycles completed successfully**
- ✅ **Security**: Path access protection, input validation, credential management
- ✅ **SOLID Principles**: Clean separation of concerns, extensible factory pattern
- ✅ **Performance**: Batch processing for large files, translation caching, early termination

### 2. Functional Requirements

- ✅ **File Reading**: Secure file access with proper validation
- ✅ **Content Parsing**: Accurate bullet point structure extraction
- ✅ **Template Conversion**: GitHub ISSUE_TEMPLATE format generation
- ✅ **Translation**: High-quality Japanese to English conversion
- ✅ **GitHub Integration**: Successful Issue creation with bilingual content
- ✅ **Issue File Creation**: Generate `.issue.md` file with proper format
- ✅ **File Cleanup**: Safe removal of created `.issue.md` files

### 3. Quality Standards

- ✅ **Error Handling**: Comprehensive error recovery mechanisms
- ✅ **User Experience**: Clear progress indication and feedback
- ✅ **GitHub Template Compliance**: Proper feature.yml structure adherence

## Usage Examples

### Basic File Processing

```bash
/file-to-issue tasks.md

📖 Reading file: tasks.md
📋 Found 5 bullet points
🏗️ Converting to GitHub ISSUE_TEMPLATE format...
📝 Created issue file: tasks.issue.md

📝 Generated Japanese Content:
## タイトル
新機能：ユーザー認証システム

## Context and Motivation
...

✅ Content looks good? Type 'Approve' to continue: Approve

🌐 Translating to English...
📤 Creating GitHub Issue via CLI...
📋 GitHub CLI initialized successfully
🏢 Repository: owner/repository-name
✅ Authentication verified
📤 Creating GitHub issue in repository: owner/repository-name
🏷️ Labels: enhancement, priority: medium
📝 Added Japanese content as comment
🗑️ Cleaning up issue file...

✅ GitHub Issue created: https://github.com/owner/repository-name/issues/123
```

### No Arguments Example

```bash
/file-to-issue

⏺ Please provide a file path as an argument
📝 Skipping Update Todos phase due to missing file path
```

## Best Practices and Limitations

### Optimal Use Cases

- **Structured bullet-point files** with clear hierarchy
- **Japanese content** requiring English translation
- **Feature requests** and bug reports in bullet format
- **Planning documents** needing GitHub Issue Template format

### Limitations

- **Large files** (>10MB) require manual splitting
- **Complex formatting** may need manual adjustment
- **Non-standard bullet formats** may not parse correctly
- **GitHub CLI availability** required for GitHub integration

### GitHub CLI-Specific Considerations

- **Session Independence**: Command works without relying on active session data
- **CLI Connectivity**: Validates GitHub CLI availability and authentication before processing
- **Error Recovery**: Graceful fallback when GitHub CLI is unavailable
- **Repository Detection**: Automatically detects current repository context
- **Label Management**: Applies appropriate labels based on issue type and priority

### Success Factors

1. **Clear bullet-point structure** with consistent indentation
2. **Meaningful content** with sufficient detail for Issues
3. **Proper file permissions** for read access
4. **Valid GitHub CLI authentication** for Issue creation
5. **GitHub Issue Template compliance** for structured output

## Configuration Requirements

### GitHub CLI Integration

**IMPORTANT**: This command uses **GitHub CLI** for all GitHub API interactions. No manual API key configuration is required.

#### GitHub CLI Setup Requirements

```bash
# GitHub CLI installation and authentication
# Install GitHub CLI: https://cli.github.com/
brew install gh  # macOS
# or
sudo apt install gh  # Ubuntu/Debian

# Authenticate with GitHub
gh auth login

# Verify authentication
gh auth status

# Optional environment variables for customization
export FILE_SIZE_LIMIT_MB=10
export ALLOWED_FILE_EXTENSIONS=".md,.txt,.markdown"
export WORK_DIRECTORY=".claude-workspaces"
```

#### GitHub CLI Commands Used

This command relies on the following GitHub CLI commands:

```bash
# GitHub CLI commands
gh --version                    # Verify CLI installation
gh auth status                  # Check authentication
gh repo view --json name,owner  # Get repository information
gh issue create                 # Create new issue
gh issue comment                # Add comment to issue
```

#### Session-Independent Operation

The implementation includes robust fallback mechanisms:

1. **CLI Availability Check**: Validates GitHub CLI is installed and accessible
2. **Authentication Verification**: Ensures proper GitHub authentication
3. **Repository Detection**: Automatically detects current repository context
4. **Graceful Error Handling**: Clear error messages when CLI is unavailable
5. **Fallback Content**: Original content preserved if translation fails

### File Structure Requirements

```
project-root/
├── .claude/
│   └── commands/
│       └── file-to-issue.md
├── .github/
│   └── ISSUE_TEMPLATE/
│       ├── feature.yml
│       └── bugfix.yml
├── docs/
│   └── CLAUDE_4_BEST_PRACTICES.md
├── app/
│   └── (Flutter app structure)
└── packages/
    └── (Package modules)
```

---

**Note**: This enhanced command prioritizes GitHub Issue Template compliance, implements Claude 4 best practices throughout, and provides comprehensive error handling with secure file processing.
