# Flutter Analysis Command

Process Flutter code analysis and quality checks for WhisperKit integration.

## Overview

Perform comprehensive Flutter code analysis including static analysis, formatting checks, and test execution.

## Usage

```bash
/analyze [--fix]
```

## Options

- `--fix`: Automatically apply fixes where possible

## Execution Flow

### Phase 1: Static Analysis

```bash
# Run Flutter analyzer
flutter analyze

# Check for common issues
dart analyze --fatal-infos --fatal-warnings
```

### Phase 2: Code Formatting

```bash
# Check formatting
dart format --output=none --set-exit-if-changed .

# Apply formatting (if --fix flag provided)
dart format .
```

### Phase 3: Test Execution

```bash
# Run all tests
flutter test

# Run specific test suites
flutter test --coverage
```

### Phase 4: WhisperKit-Specific Checks

```bash
# Check iOS integration
cd ios && pod install --repo-update

# Verify WhisperKit dependencies
flutter pub deps
```

## Quality Gates

- ✅ Zero analyzer warnings/errors
- ✅ 100% code formatting compliance
- ✅ All tests pass
- ✅ WhisperKit dependencies resolved
- ✅ iOS integration verified

## Error Handling

- **Analysis Errors**: Report specific issues with file:line references
- **Test Failures**: Provide detailed test failure information
- **Dependency Issues**: Suggest resolution steps
- **iOS Integration Problems**: Check Xcode configuration

## Success Criteria

All checks must pass:
- Static analysis clean
- Formatting compliant
- Tests passing
- Dependencies resolved
- iOS integration working

---

**Note**: This command ensures WhisperKit Flutter integration meets quality standards.