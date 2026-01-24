# Trippified Git Workflow Rules

## MANDATORY - All Commits Must Follow These Rules

### 1. Branch Naming

**Pattern**: `{type}/{description}`

**Types**
- `feature/` - New features
- `fix/` - Bug fixes
- `refactor/` - Code refactoring
- `test/` - Adding tests
- `docs/` - Documentation
- `chore/` - Maintenance tasks

**Examples**
```
feature/trip-setup-screen
feature/day-builder-overview-tab
fix/auth-token-refresh
refactor/trip-repository-cleanup
test/expense-calculation-coverage
docs/api-documentation
chore/update-dependencies
```

### 2. Conventional Commits

**Format**
```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Types**
- `feat` - New feature
- `fix` - Bug fix
- `refactor` - Code refactoring (no behavior change)
- `test` - Adding/updating tests
- `docs` - Documentation changes
- `style` - Formatting (no code change)
- `perf` - Performance improvement
- `chore` - Maintenance tasks

**Scopes** (Trippified-specific)
- `auth` - Authentication
- `trip` - Trip planning
- `day-builder` - Day Builder feature
- `explore` - Explore tab
- `saved` - Saved items
- `budget` - Budget tracking
- `docs` - Travel documents
- `offline` - Offline mode
- `live-trip` - Live trip mode
- `ui` - UI components
- `api` - API integrations

**Examples**
```
feat(trip): add trip setup screen with country selection

fix(auth): handle token refresh on 401 response

refactor(day-builder): extract day card to separate widget

test(budget): add expense calculation unit tests

docs(api): document Google Places integration

perf(explore): implement lazy loading for itinerary cards
```

### 3. Commit Message Body

**When to Include**
- Breaking changes
- Complex changes
- Non-obvious decisions

**Example**
```
feat(day-builder): implement smart itinerary generation

- Use proximity-based ordering for activities
- Warn when activities are far apart (>30min travel)
- Respect opening hours when scheduling

Closes #42
```

### 4. Breaking Changes

**Mark in Footer**
```
feat(api): change trip response format

BREAKING CHANGE: Trip.cities is now Trip.cityBlocks
Migration: Update all Trip model references
```

### 5. Commit Frequency

**Commit Often**
- One logical change per commit
- Don't batch unrelated changes
- Commit working code (tests pass)

**Good**
```
feat(trip): add country autocomplete input
feat(trip): add trip size selection
feat(trip): add see routes CTA with validation
```

**Bad**
```
feat(trip): add entire trip setup screen  # Too large
```

### 6. Pull Request Guidelines

**Title**: Same as conventional commit format
```
feat(day-builder): implement overview tab
```

**Description Template**
```markdown
## Summary
Brief description of what this PR does.

## Changes
- Added X
- Updated Y
- Fixed Z

## Testing
- [ ] Unit tests added/updated
- [ ] Widget tests added/updated
- [ ] Manual testing completed

## Screenshots (if UI change)
[Attach screenshots]

## Related Issues
Closes #123
```

### 7. Branch Protection Rules

**Main Branch**
- No direct commits
- Require PR with approval
- Require tests to pass
- Require lint to pass

### 8. Git Hooks

**Pre-commit** (enforced)
```bash
#!/bin/bash
# Format code
dart format . --set-exit-if-changed || exit 1

# Run analyzer
dart analyze || exit 1

# Run tests
flutter test || exit 1
```

**Commit-msg** (validate commit message)
```bash
#!/bin/bash
commit_regex='^(feat|fix|refactor|test|docs|style|perf|chore)\([a-z-]+\): .+'

if ! grep -qE "$commit_regex" "$1"; then
  echo "Invalid commit message format"
  echo "Expected: type(scope): description"
  exit 1
fi
```

### 9. Git Commands Reference

**Start New Feature**
```bash
git checkout main
git pull origin main
git checkout -b feature/trip-setup-screen
```

**Commit Changes**
```bash
git add .
git commit -m "feat(trip): add country autocomplete input"
```

**Push and Create PR**
```bash
git push -u origin feature/trip-setup-screen
# Then create PR on GitHub
```

**Update Branch with Main**
```bash
git checkout main
git pull origin main
git checkout feature/trip-setup-screen
git rebase main
```

**Fix Last Commit Message**
```bash
git commit --amend -m "feat(trip): corrected message"
```

### 10. Release Tags

**Semantic Versioning**
```
v1.0.0 - Major release
v1.1.0 - Minor release (new features)
v1.1.1 - Patch release (bug fixes)
```

**Creating Release**
```bash
git tag -a v1.0.0 -m "Release 1.0.0: Initial launch"
git push origin v1.0.0
```

### 11. Forbidden Actions

**NEVER**
- Force push to main
- Commit secrets or API keys
- Commit with failing tests
- Commit unformatted code
- Use generic messages ("fix", "update", "changes")
- Commit .env files
- Commit generated files (build/, .dart_tool/)
