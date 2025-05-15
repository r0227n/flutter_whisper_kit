# Contributing to Flutter WhisperKit

Thank you for your interest in contributing to Flutter WhisperKit! This document provides guidelines and instructions for contributing to this project.

## Commit Message Guidelines

We follow the [Conventional Commits specification](https://www.conventionalcommits.org/) for our commit messages. This format makes it easier to generate changelogs automatically and understand the purpose of each commit.

### Commit Message Format

Each commit message consists of a **header**, an optional **body**, and an optional **footer**:

```
<type>(<optional scope>): <description>

<optional body>

<optional footer>
```

The **header** is mandatory and has a special format that includes a **type**, an optional **scope**, and a **description**:

- **type**: This represents the kind of change you're making. It must be one of the following:
  - `feat`: A new feature
  - `fix`: A bug fix
  - `docs`: Documentation changes
  - `style`: Changes that do not affect the meaning of the code (formatting, etc.)
  - `refactor`: Code changes that neither fix a bug nor add a feature
  - `test`: Adding or updating tests
  - `chore`: Changes to the build process or auxiliary tools

- **scope** (optional): This specifies the section of the codebase your change affects, e.g., `auth`, `ui`, `api`.

- **description**: A short description of the change. Use the imperative, present tense: "change" not "changed" nor "changes".

### Examples of Valid Commit Messages

```
feat(auth): add user authentication flow
fix(ui): resolve overflow in dashboard layout
docs: update README with setup instructions
test(api): add unit tests for REST client
```

### Setup Requirements

This project uses commitlint to enforce commit message standards and husky to run git hooks. After cloning the repository, run:

```
npm install
```

This will set up the necessary hooks to validate your commit messages automatically.
