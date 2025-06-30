# Commitlint and Husky Setup Guide

This guide provides step-by-step instructions for setting up commitlint and husky in your local development environment to enforce conventional commit message standards.

## Prerequisites

- Node.js and npm installed on your machine
- Git installed on your machine
- Clone of the Flutter WhisperKit repository

## Setup Instructions

### 1. Clone the Repository (if you haven't already)

```bash
git clone https://github.com/r0227n/flutter_whisper_kit.git
cd flutter_whisper_kit
```

### 2. Install Dependencies

After cloning the repository, install the Node.js dependencies which include commitlint and husky:

```bash
npm install
```

This command will:

- Install all required dependencies from package.json
- Set up husky Git hooks automatically via the prepare script

### 3. Verify Installation

To verify that commitlint is installed correctly, you can test it with a sample commit message:

```bash
echo "testing" | npx commitlint
```

This should fail with an error message because "testing" doesn't follow the conventional commit format.

Try a valid commit message:

```bash
echo "chore: test commitlint" | npx commitlint
```

This should pass without errors.

### 4. Understanding the Commit Message Format

All commit messages must follow the Conventional Commits specification:

```
<type>(<optional scope>): <description>

<optional body>

<optional footer>
```

Valid types are:

- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation changes
- `style`: Changes that do not affect the meaning of the code
- `refactor`: Code changes that neither fix a bug nor add a feature
- `test`: Adding or correcting tests
- `chore`: Changes to the build process or auxiliary tools

Examples of valid commit messages:

```
feat(auth): add user authentication flow
fix(ui): resolve overflow in dashboard layout
docs: update README with setup instructions
test(api): add unit tests for REST client
```

### 5. Making Commits

When you make a commit, husky will automatically run commitlint to validate your commit message:

```bash
git add <files>
git commit -m "feat(component): add new feature"
```

If your commit message doesn't follow the conventional format, the commit will be rejected with an error message.

### 6. Troubleshooting

If you encounter issues with husky hooks not running:

1. Make sure you have run `npm install` after cloning the repository
2. Check that the .husky directory exists and contains the commit-msg file
3. Ensure the commit-msg file has execute permissions:
   ```bash
   chmod +x .husky/commit-msg
   ```

If commitlint is not working:

1. Make sure you have Node.js and npm installed
2. Try reinstalling the dependencies:
   ```bash
   npm ci
   ```

## For Team Leads and CI/CD Integration

If you want to enforce commit message standards in your CI/CD pipeline:

1. Add a step in your CI workflow to validate commit messages:

   ```yaml
   - name: Check commit message
     run: echo "${{ github.event.head_commit.message }}" | npx commitlint
   ```

2. For multi-commit PRs, you can validate all commits in the PR:
   ```yaml
   - name: Check PR commits
     run: npx commitlint --from ${{ github.event.pull_request.base.sha }} --to ${{ github.event.pull_request.head.sha }} --verbose
   ```

## Additional Resources

- [Conventional Commits Specification](https://www.conventionalcommits.org/)
- [Commitlint Documentation](https://commitlint.js.org/)
- [Husky Documentation](https://typicode.github.io/husky/)
