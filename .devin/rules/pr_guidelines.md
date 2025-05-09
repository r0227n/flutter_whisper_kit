# Pull Request Guidelines

This document outlines the standards and procedures for creating and managing pull requests. Following these guidelines ensures efficient code review and integration processes.

## 1. PR Naming Convention
**Purpose**: To provide clear, consistent, and informative PR titles that help team members quickly understand the nature of changes.

- Format: `[Type] Brief description`
- Types:
  - `[Feature]` - New functionality (e.g., `[Feature] Add user authentication`)
  - `[Fix]` - Bug fixes (e.g., `[Fix] Resolve login timeout issue`)
  - `[Refactor]` - Code improvements without changing behavior (e.g., `[Refactor] Optimize database queries`)
  - `[Docs]` - Documentation changes (e.g., `[Docs] Update API documentation`)
  - `[Test]` - Adding or modifying tests (e.g., `[Test] Add unit tests for UserService`)
  - `[Chore]` - Maintenance tasks (e.g., `[Chore] Update dependencies`)

**Explanation**: Consistent PR naming helps team members quickly identify the type and purpose of changes, making it easier to prioritize and review work.

## 2. PR Description Template
**Purpose**: To ensure comprehensive and consistent PR descriptions that provide necessary context for reviewers.

```markdown
## Issue

Close #ISSUE_NUMBER

## Description
[Clear description of changes]

## Related Issue
[Link to related issue]

## Changes Made
- [ ] Change 1
- [ ] Change 2
- [ ] Change 3

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] Manual testing performed

## Screenshots (if applicable)
[Add relevant screenshots]

## Checklist
- [ ] Code follows coding conventions
- [ ] Tests pass
- [ ] Documentation updated
- [ ] No breaking changes
```

**Explanation**: This template ensures all necessary information is included in PR descriptions, making reviews more efficient and thorough.

## 3. Commit Message Format
**Purpose**: To maintain a clear and consistent commit history that's easy to understand and navigate.

- Follow Conventional Commits specification:
  - `feat:` for new features
  - `fix:` for bug fixes
  - `docs:` for documentation
  - `style:` for formatting
  - `refactor:` for code refactoring
  - `test:` for tests
  - `chore:` for maintenance

**Explanation**: Consistent commit messages make it easier to understand the history of changes and generate meaningful changelogs.

## 4. Code Review Requirements
**Purpose**: To ensure high-quality code through thorough review processes.

- All PRs must be reviewed by at least one team member
- Address all review comments before merging
- Ensure CI checks pass
- Keep PRs focused and small
- Include appropriate test coverage

**Explanation**: Code reviews help catch issues early, share knowledge, and maintain code quality standards.

## 5. Branch Management
**Purpose**: To maintain an organized and efficient branching strategy.

- Create feature branches from main
- Keep branches up-to-date with main
- Delete branches after merging
- Use meaningful branch names

**Explanation**: Proper branch management prevents conflicts and keeps the repository clean and organized.

## 6. Merge Strategy
**Purpose**: To maintain a clean and meaningful commit history.

- Squash and merge for feature branches
- Rebase and merge for hotfixes
- Maintain clean commit history
- Ensure merge commits are meaningful

**Explanation**: Appropriate merge strategies help maintain a clean and useful git history while ensuring code integrity. 