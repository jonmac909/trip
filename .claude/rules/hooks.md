# Trippified Git Hooks

## Overview

Git hooks automate quality checks before code is committed or pushed. All hooks are mandatory and must pass before code can be committed.

---

## Pre-Commit Hook

**Location**: `.githooks/pre-commit`

**Purpose**: Ensure code quality before every commit

```bash
#!/bin/bash

set -e

echo "Running pre-commit checks..."

# 1. Format check
echo "Checking code formatting..."
dart format --set-exit-if-changed lib/ test/ || {
  echo "ERROR: Code is not formatted. Run 'dart format .'"
  exit 1
}

# 2. Static analysis
echo "Running static analysis..."
dart analyze --fatal-infos || {
  echo "ERROR: Static analysis failed. Fix the issues above."
  exit 1
}

# 3. Run tests
echo "Running tests..."
flutter test || {
  echo "ERROR: Tests failed. Fix failing tests before committing."
  exit 1
}

# 4. Check for secrets
echo "Checking for secrets..."
if grep -rE "(api_key|apikey|secret|password|token)(\s*=\s*['\"][^'\"]+['\"])" lib/ --include="*.dart"; then
  echo "ERROR: Potential secrets found in code. Use environment variables."
  exit 1
fi

# 5. Check for print statements (debug code)
echo "Checking for debug statements..."
if grep -rE "^\s*print\(" lib/ --include="*.dart"; then
  echo "WARNING: print() statements found. Use logger instead."
  # Warning only, doesn't block commit
fi

# 6. Check for TODO without ticket
echo "Checking TODOs..."
if grep -rE "TODO(?!.*#[0-9]+)" lib/ --include="*.dart"; then
  echo "WARNING: TODOs found without ticket reference."
  # Warning only, doesn't block commit
fi

echo "All pre-commit checks passed!"
```

---

## Commit Message Hook

**Location**: `.githooks/commit-msg`

**Purpose**: Enforce conventional commit format

```bash
#!/bin/bash

commit_msg_file=$1
commit_msg=$(cat "$commit_msg_file")

# Conventional commit pattern
pattern="^(feat|fix|refactor|test|docs|style|perf|chore)(\([a-z-]+\))?: .{1,72}$"

if ! echo "$commit_msg" | head -1 | grep -qE "$pattern"; then
  echo "ERROR: Invalid commit message format."
  echo ""
  echo "Expected format: type(scope): description"
  echo ""
  echo "Types: feat, fix, refactor, test, docs, style, perf, chore"
  echo ""
  echo "Scopes: auth, trip, day-builder, explore, saved, budget, docs, offline, live-trip, ui, api"
  echo ""
  echo "Examples:"
  echo "  feat(trip): add country selection screen"
  echo "  fix(auth): handle token refresh on 401"
  echo "  refactor(day-builder): extract day card widget"
  echo ""
  exit 1
fi

# Check description length
desc_length=$(echo "$commit_msg" | head -1 | wc -c)
if [ "$desc_length" -gt 72 ]; then
  echo "ERROR: Commit message first line should be 72 characters or less."
  exit 1
fi

echo "Commit message format OK."
```

---

## Pre-Push Hook

**Location**: `.githooks/pre-push`

**Purpose**: Run comprehensive checks before pushing

```bash
#!/bin/bash

set -e

echo "Running pre-push checks..."

# 1. Run full test suite with coverage
echo "Running tests with coverage..."
flutter test --coverage || {
  echo "ERROR: Tests failed."
  exit 1
}

# 2. Check coverage threshold
echo "Checking coverage threshold..."
if command -v lcov &> /dev/null; then
  coverage=$(lcov --summary coverage/lcov.info 2>&1 | grep "lines" | awk '{print $2}' | sed 's/%//')
  if (( $(echo "$coverage < 80" | bc -l) )); then
    echo "ERROR: Code coverage is $coverage%, minimum is 80%."
    exit 1
  fi
  echo "Coverage: $coverage% (OK)"
fi

# 3. Build check (ensure it compiles)
echo "Verifying build..."
flutter build apk --debug --no-pub || {
  echo "ERROR: Build failed."
  exit 1
}

echo "All pre-push checks passed!"
```

---

## Setup Script

**Location**: `scripts/setup-hooks.sh`

**Purpose**: Install git hooks for new developers

```bash
#!/bin/bash

echo "Setting up git hooks..."

# Create hooks directory
mkdir -p .githooks

# Copy hooks (if they exist in repo)
cp scripts/hooks/* .githooks/ 2>/dev/null || true

# Make hooks executable
chmod +x .githooks/*

# Configure git to use custom hooks directory
git config core.hooksPath .githooks

echo "Git hooks installed successfully!"
echo ""
echo "Hooks enabled:"
echo "  - pre-commit: Format, analyze, test, security check"
echo "  - commit-msg: Conventional commit format"
echo "  - pre-push: Full test suite, coverage check, build verification"
```

---

## Claude Code Hooks

### Pre-Tool Hook

Runs before any Claude Code tool execution.

```json
// .claude/hooks/pre-tool.json
{
  "tools": ["Write", "Edit"],
  "command": "dart analyze ${file} 2>/dev/null || true"
}
```

### Post-Tool Hook

Runs after Claude Code tool execution.

```json
// .claude/hooks/post-tool.json
{
  "tools": ["Write", "Edit"],
  "patterns": ["*.dart"],
  "command": "dart format ${file}"
}
```

---

## CI/CD Integration

### GitHub Actions Workflow

**Location**: `.github/workflows/ci.yml`

```yaml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'

      - name: Install dependencies
        run: flutter pub get

      - name: Format check
        run: dart format --set-exit-if-changed lib/ test/

      - name: Analyze
        run: dart analyze --fatal-infos

      - name: Run tests
        run: flutter test --coverage

      - name: Check coverage
        uses: VeryGoodOpenSource/very_good_coverage@v2
        with:
          min_coverage: 80

      - name: Build APK
        run: flutter build apk --debug

      - name: Build iOS
        run: flutter build ios --no-codesign
```

---

## Hook Bypass (Emergency Only)

**When absolutely necessary** (e.g., hotfix), hooks can be bypassed:

```bash
# Skip pre-commit hook (AVOID)
git commit --no-verify -m "hotfix: critical fix"

# Skip pre-push hook (AVOID)
git push --no-verify
```

**Rules for bypass**:
1. Only for production hotfixes
2. Must run checks manually after
3. Must document in PR
4. Must not become habit

---

## Troubleshooting

### Hooks not running
```bash
# Check hooks path
git config core.hooksPath

# Reset to default
git config --unset core.hooksPath

# Reinstall
./scripts/setup-hooks.sh
```

### Permission denied
```bash
chmod +x .githooks/*
```

### Slow hooks
```bash
# Run specific tests only
flutter test test/unit/
```
